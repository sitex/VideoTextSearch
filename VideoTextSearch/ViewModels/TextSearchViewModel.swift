import Foundation
import AVFoundation
import Combine

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
    @Published var searchQuery: String = "" {
        didSet {
            searchMatcher.searchQuery = searchQuery
        }
    }
    @Published var cameraPermissionStatus: CameraPermissionStatus = .notDetermined

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
}
