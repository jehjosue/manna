import Foundation
import StoreKit
import Observation

/// Gerencia compras e assinatura Manna Plus via StoreKit 2.
@Observable
final class SubscriptionStore {
    static let shared = SubscriptionStore()

    // Produtos
    var monthlyProduct: Product?
    var yearlyProduct: Product?

    var isLoading = false
    var isPlus = false

    private let productIDs = ["app.manna.plus.monthly", "app.manna.plus.yearly"]
    private var updateTask: Task<Void, Never>?

    init() {
        updateTask = Task {
            await loadProducts()
            for await _ in Transaction.updates {
                await refresh()
            }
        }
    }

    deinit {
        updateTask?.cancel()
    }

    // MARK: - Carregamento de produtos

    @MainActor
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: productIDs)
            for product in products {
                if product.id == "app.manna.plus.monthly" {
                    monthlyProduct = product
                } else if product.id == "app.manna.plus.yearly" {
                    yearlyProduct = product
                }
            }
        } catch {
            print("Erro ao carregar produtos: \(error.localizedDescription)")
        }

        await refresh()
    }

    // MARK: - Compra

    @MainActor
    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verification.payloadValue
                await transaction.finish()
                await refresh()
                return true

            case .pending:
                return false

            case .userCancelled:
                return false

            @unknown default:
                return false
            }
        } catch {
            print("Erro na compra: \(error.localizedDescription)")
            return false
        }
    }

    // MARK: - Restauração de compras

    @MainActor
    func restore() async {
        do {
            try await AppStore.sync()
            await refresh()
        } catch {
            print("Erro ao restaurar: \(error.localizedDescription)")
        }
    }

    // MARK: - Atualizar status Plus

    @MainActor
    private func refresh() async {
        var hasActiveSubscription = false

        for await result in Transaction.currentEntitlements {
            if let transaction = try? result.payloadValue {
                if transaction.productID == "app.manna.plus.monthly" || transaction.productID == "app.manna.plus.yearly" {
                    hasActiveSubscription = true
                    break
                }
            }
        }

        isPlus = hasActiveSubscription
    }

    /// Sincroniza o status de assinatura com o GameState.
    @MainActor
    func sync(game: GameState) {
        game.isPlus = isPlus
    }
}
