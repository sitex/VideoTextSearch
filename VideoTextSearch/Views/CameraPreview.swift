import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var viewModel: TextSearchViewModel

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)

        if let previewLayer = viewModel.previewLayer {
            previewLayer.frame = view.bounds
            view.layer.addSublayer(previewLayer)
        }

        // Add bounding box overlay
        viewModel.boundingBoxOverlay.frame = view.bounds
        view.layer.addSublayer(viewModel.boundingBoxOverlay)

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update layer frames on size change
        viewModel.previewLayer?.frame = uiView.bounds
        viewModel.boundingBoxOverlay.frame = uiView.bounds

        // Calculate the video rect within the preview layer
        // The preview layer uses .resizeAspectFill, so we need to account for cropping
        let videoRect = calculateVideoRect(in: uiView.bounds)

        // Update bounding boxes when matches change
        viewModel.boundingBoxOverlay.drawBoundingBoxes(
            for: viewModel.matchedTexts,
            in: videoRect.size,
            offset: videoRect.origin
        )
    }

    private func calculateVideoRect(in bounds: CGRect) -> CGRect {
        // For .resizeAspectFill, the video fills the entire bounds
        // but may extend beyond the edges (cropped)
        // For OCR purposes, we need to match the visible area

        guard let previewLayer = viewModel.previewLayer else {
            return bounds
        }

        // Get the actual video dimensions from the preview layer
        // This accounts for aspect fill behavior
        return previewLayer.layerRectConverted(fromMetadataOutputRect: CGRect(x: 0, y: 0, width: 1, height: 1))
    }
}
