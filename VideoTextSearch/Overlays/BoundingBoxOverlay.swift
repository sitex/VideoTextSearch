import UIKit

class BoundingBoxOverlay: CALayer {
    private var boxLayers: [CAShapeLayer] = []

    func drawBoundingBoxes(for matches: [TextResult], in viewSize: CGSize) {
        // Remove previous boxes
        clearBoxes()

        for match in matches {
            let boxLayer = createGreenBox(for: match.boundingBox, in: viewSize)
            addSublayer(boxLayer)
            boxLayers.append(boxLayer)
        }
    }

    func clearBoxes() {
        boxLayers.forEach { $0.removeFromSuperlayer() }
        boxLayers.removeAll()
    }

    private func createGreenBox(for normalizedRect: CGRect,
                                in viewSize: CGSize) -> CAShapeLayer {
        // Convert Vision coordinates to UIKit coordinates
        let convertedRect = convertToViewCoordinates(normalizedRect, viewSize: viewSize)

        let boxLayer = CAShapeLayer()
        boxLayer.frame = convertedRect
        boxLayer.borderWidth = 3.0
        boxLayer.borderColor = UIColor.green.cgColor
        boxLayer.backgroundColor = UIColor.green.withAlphaComponent(0.1).cgColor
        boxLayer.cornerRadius = 4.0

        return boxLayer
    }

    private func convertToViewCoordinates(_ visionRect: CGRect,
                                          viewSize: CGSize) -> CGRect {
        // Vision framework: origin at bottom-left, normalized (0-1)
        // UIKit: origin at top-left, pixels

        let x = visionRect.origin.x * viewSize.width
        let y = (1 - visionRect.origin.y - visionRect.height) * viewSize.height
        let width = visionRect.width * viewSize.width
        let height = visionRect.height * viewSize.height

        return CGRect(x: x, y: y, width: width, height: height)
    }
}
