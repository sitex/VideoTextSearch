import Foundation
import AVFoundation
import Combine
import UIKit

enum CameraPermissionStatus {
    case notDetermined
    case authorized
    case denied
    case restricted
}

class TextSearchViewModel: ObservableObject {
    private let cameraManager = CameraManager()
    private let ocrProcessor = OCRProcessor()
    private let searchMatcher = TextSearchMatcher()

    @Published var matchedTexts: [TextResult] = []
    @Published var allRecognizedTexts: [TextResult] = []
    @Published var searchQuery: String = "" {
        didSet {
            searchMatcher.searchQuery = searchQuery
            // Re-filter existing results when search changes (both demo and camera mode)
            matchedTexts = searchMatcher.findMatches(in: allRecognizedTexts)
        }
    }
    @Published var cameraPermissionStatus: CameraPermissionStatus = .notDetermined
    @Published var isDemoMode: Bool = false
    @Published var demoImage: UIImage?

    var previewLayer: AVCaptureVideoPreviewLayer? {
        cameraManager.previewLayer
    }

    let boundingBoxOverlay = BoundingBoxOverlay()

    // Frame skipping for performance
    private var frameCounter = 0
    private let processEveryNthFrame = 3

    init() {
        setupCallbacks()
        checkCameraPermission()
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            cameraPermissionStatus = .notDetermined
        case .authorized:
            cameraPermissionStatus = .authorized
        case .denied:
            cameraPermissionStatus = .denied
        case .restricted:
            cameraPermissionStatus = .restricted
        @unknown default:
            cameraPermissionStatus = .notDetermined
        }
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
                self.allRecognizedTexts = results
                self.matchedTexts = matches
            }
        }
    }

    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.cameraPermissionStatus = granted ? .authorized : .denied
                if granted {
                    self?.startCameraSession()
                }
            }
        }
    }

    func startCamera() {
        switch cameraPermissionStatus {
        case .notDetermined:
            requestCameraPermission()
        case .authorized:
            startCameraSession()
        case .denied, .restricted:
            // Permission denied - UI will show appropriate message
            break
        }
    }

    private func startCameraSession() {
        cameraManager.setupCamera()
        cameraManager.startSession()
    }

    func stopCamera() {
        cameraManager.stopSession()
    }

    // MARK: - Demo Mode

    func enableDemoMode() {
        isDemoMode = true
        stopCamera()
        loadDemoImage()
    }

    func disableDemoMode() {
        isDemoMode = false
        demoImage = nil
        allRecognizedTexts = []
        matchedTexts = []
        boundingBoxOverlay.clearBoxes()
        startCamera()
    }

    private func loadDemoImage() {
        // Try to load from assets first, fall back to generated image
        if let image = UIImage(named: "DemoText") {
            demoImage = image
            processImageForOCR(image)
        } else {
            // Generate a demo image with sample text
            demoImage = generateDemoImage()
            if let image = demoImage {
                processImageForOCR(image)
            }
        }
    }

    private func processImageForOCR(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }

        // Process on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.ocrProcessor.recognizeText(in: cgImage)
        }
    }

    private func generateDemoImage() -> UIImage {
        let size = CGSize(width: 400, height: 600)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            // White background
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))

            // Sample text content
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            paragraphStyle.lineSpacing = 8

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraphStyle
            ]

            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .foregroundColor: UIColor.darkGray,
                .paragraphStyle: paragraphStyle
            ]

            let highlightAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.systemBlue,
                .paragraphStyle: paragraphStyle
            ]

            // Draw text
            "Video Text Search".draw(at: CGPoint(x: 20, y: 30), withAttributes: titleAttributes)
            "Demo Mode".draw(at: CGPoint(x: 20, y: 70), withAttributes: highlightAttributes)

            let body1 = "This is a sample image with text that you can search. Try typing 'hello' or 'world' in the search box."
            (body1 as NSString).draw(in: CGRect(x: 20, y: 120, width: 360, height: 100), withAttributes: bodyAttributes)

            "Hello World!".draw(at: CGPoint(x: 20, y: 230), withAttributes: titleAttributes)

            let body2 = "The OCR engine will recognize all the text in this image and highlight matches with green boxes."
            (body2 as NSString).draw(in: CGRect(x: 20, y: 280, width: 360, height: 100), withAttributes: bodyAttributes)

            "Search Features:".draw(at: CGPoint(x: 20, y: 380), withAttributes: highlightAttributes)

            let features = """
            • Case insensitive matching
            • Partial word matching
            • Real-time results
            • Green box highlights
            """
            (features as NSString).draw(in: CGRect(x: 20, y: 420, width: 360, height: 150), withAttributes: bodyAttributes)
        }
    }
}
