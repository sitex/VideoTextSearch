import Foundation
import AVFoundation
import Combine

class TextSearchViewModel: ObservableObject {
    private let cameraManager = CameraManager()
    private let ocrProcessor = OCRProcessor()
    private let searchMatcher = TextSearchMatcher()

    @Published var matchedTexts: [TextResult] = []
    @Published var searchQuery: String = "" {
        didSet {
            searchMatcher.searchQuery = searchQuery
        }
    }

    var previewLayer: AVCaptureVideoPreviewLayer? {
        cameraManager.previewLayer
    }

    let boundingBoxOverlay = BoundingBoxOverlay()

    // Frame skipping for performance
    private var frameCounter = 0
    private let processEveryNthFrame = 3

    init() {
        setupCallbacks()
    }

    private func setupCallbacks() {
        // Frame processing callback with frame skipping
        cameraManager.onFrameCapture = { [weak self] pixelBuffer in
            guard let self = self else { return }

            self.frameCounter += 1
            guard self.frameCounter % self.processEveryNthFrame == 0 else { return }

            self.ocrProcessor.recognizeText(in: pixelBuffer)
        }

        // OCR results callback
        ocrProcessor.onTextRecognized = { [weak self] results in
            guard let self = self else { return }

            let matches = self.searchMatcher.findMatches(in: results)

            DispatchQueue.main.async {
                self.matchedTexts = matches
            }
        }
    }

    func startCamera() {
        cameraManager.setupCamera()
        cameraManager.startSession()
    }

    func stopCamera() {
        cameraManager.stopSession()
    }
}
