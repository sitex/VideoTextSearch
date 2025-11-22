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

        // Update bounding boxes when matches change
        viewModel.boundingBoxOverlay.drawBoundingBoxes(
            for: viewModel.matchedTexts,
            in: uiView.bounds.size
        )
    }
}
