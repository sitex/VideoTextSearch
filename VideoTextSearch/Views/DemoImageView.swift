import SwiftUI
import UIKit

struct DemoImageView: UIViewRepresentable {
    @ObservedObject var viewModel: TextSearchViewModel

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView(frame: UIScreen.main.bounds)
        containerView.backgroundColor = .black

        // Image view for the demo image
        let imageView = UIImageView(frame: containerView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.tag = 100 // Tag to find it later
        containerView.addSubview(imageView)

        // Add bounding box overlay
        viewModel.boundingBoxOverlay.frame = containerView.bounds
        containerView.layer.addSublayer(viewModel.boundingBoxOverlay)

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Find the image view
        guard let imageView = uiView.viewWithTag(100) as? UIImageView else { return }

        // Update image
        imageView.frame = uiView.bounds
        imageView.image = viewModel.demoImage

        // Update overlay frame
        viewModel.boundingBoxOverlay.frame = uiView.bounds

        // Calculate the actual image rect within the view (accounting for aspect fit)
        let imageRect = calculateImageRect(for: viewModel.demoImage, in: uiView.bounds)

        // Update bounding boxes with the correct image rect
        viewModel.boundingBoxOverlay.drawBoundingBoxes(
            for: viewModel.matchedTexts,
            in: imageRect.size,
            offset: imageRect.origin
        )
    }

    private func calculateImageRect(for image: UIImage?, in bounds: CGRect) -> CGRect {
        guard let image = image else { return bounds }

        let imageSize = image.size
        let boundsSize = bounds.size

        let widthRatio = boundsSize.width / imageSize.width
        let heightRatio = boundsSize.height / imageSize.height
        let scale = min(widthRatio, heightRatio)

        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale

        let x = (boundsSize.width - scaledWidth) / 2
        let y = (boundsSize.height - scaledHeight) / 2

        return CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
    }
}
