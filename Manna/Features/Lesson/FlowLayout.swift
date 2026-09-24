import SwiftUI

/// Layout que quebra itens em múltiplas linhas quando não cabem em uma.
/// Usado para os blocos de palavras no exercício de montar versículo.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxLineWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width + spacing > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }

            if currentX > 0 {
                currentX += spacing
            }

            currentX += size.width
            lineHeight = max(lineHeight, size.height)
            maxLineWidth = max(maxLineWidth, currentX)
        }

        let height = currentY + lineHeight
        return CGSize(width: maxLineWidth, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let maxWidth = bounds.width
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX - bounds.minX + size.width + spacing > maxWidth, currentX - bounds.minX > 0 {
                currentX = bounds.minX
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }

            if currentX - bounds.minX > 0 {
                currentX += spacing
            }

            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            currentX += size.width
            lineHeight = max(lineHeight, size.height)
        }
    }
}
