import UIKit

class BoundingBoxOverlay: CALayer {
    private var boxLayers: [CAShapeLayer] = []

    func drawBoundingBoxes(for matches: [TextResult], in viewSize: CGSize) {
        drawBoundingBoxes(for: matches, in: viewSize, offset: .zero)
    }

    func drawBoundingBoxes(for matches: [TextResult], in viewSize: CGSize, offset: CGPoint) {
        // Remove previous boxes
        clearBoxes()

        for match in matches {
            let boxLayer = createGreenBox(for: match.boundingBox, in: viewSize, offset: offset)
            addSublayer(boxLayer)
            boxLayers.append(boxLayer)
        }
    }

    func clearBoxes() {
        boxLayers.forEach { $0.removeFromSuperlayer() }
        boxLayers.removeAll()
    }

    private func createGreenBox(for normalizedRect: CGRect,
                                in viewSize: CGSize,
                                offset: CGPoint = .zero) -> CAShapeLayer {
        // Convert Vision coordinates to UIKit coordinates
        let convertedRect = convertToViewCoordinates(normalizedRect, viewSize: viewSize, offset: offset)

        let boxLayer = CAShapeLayer()
        boxLayer.frame = convertedRect
        boxLayer.borderWidth = 3.0
        boxLayer.borderColor = UIColor.green.cgColor
        boxLayer.backgroundColor = UIColor.green.withAlphaComponent(0.1).cgColor
        boxLayer.cornerRadius = 4.0

        return boxLayer
    }

    private func convertToViewCoordinates(_ visionRect: CGRect,
                                          viewSize: CGSize,
                                          offset: CGPoint = .zero) -> CGRect {
        // Vision framework: origin at bottom-left, normalized (0-1)
        // UIKit: origin at top-left, pixels

        let x = visionRect.origin.x * viewSize.width + offset.x
        let y = (1 - visionRect.origin.y - visionRect.height) * viewSize.height + offset.y
        let width = visionRect.width * viewSize.width
        let height = visionRect.height * viewSize.height

        return CGRect(x: x, y: y, width: width, height: height)
    }
}
