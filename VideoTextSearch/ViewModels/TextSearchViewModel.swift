import Foundation
import Combine
import AVFoundation

// Placeholder for Phase 6
class TextSearchViewModel: ObservableObject {
    @Published var matchedTexts: [TextResult] = []
    @Published var searchQuery: String = ""

    var previewLayer: AVCaptureVideoPreviewLayer? {
        return nil
    }

    let boundingBoxOverlay = BoundingBoxOverlay()

    func startCamera() {
        // Implementation in Phase 6
    }

    func stopCamera() {
        // Implementation in Phase 6
    }
}
