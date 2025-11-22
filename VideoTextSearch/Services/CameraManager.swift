import AVFoundation
import Foundation

class CameraManager: NSObject {
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")

    var previewLayer: AVCaptureVideoPreviewLayer?
    var onFrameCapture: ((CVPixelBuffer) -> Void)?

    func setupCamera() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high

        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                         for: .video,
                                                         position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            captureSession.commitConfiguration()
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        // Add video output
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]

        let processingQueue = DispatchQueue(label: "video.processing.queue",
                                            qos: .userInitiated)
        videoOutput.setSampleBufferDelegate(self, queue: processingQueue)

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        // Set video orientation
        if let connection = videoOutput.connection(with: .video) {
            connection.videoOrientation = .portrait
        }

        captureSession.commitConfiguration()

        // Setup preview layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
    }

    func startSession() {
        sessionQueue.async {
            self.captureSession.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async {
            self.captureSession.stopRunning()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        onFrameCapture?(pixelBuffer)
    }
}
