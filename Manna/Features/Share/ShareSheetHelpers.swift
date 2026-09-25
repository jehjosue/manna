import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension Image {
    /// Converte uma Image SwiftUI em UIImage para compartilhamento.
    @MainActor
    func asUIImage() -> UIImage? {
        // Usar ImageRenderer (iOS 16+)
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage
    }
}
