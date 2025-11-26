import Vision
import Foundation

class OCRProcessor {
    private var recognizeTextRequest: VNRecognizeTextRequest!

    var onTextRecognized: (([TextResult]) -> Void)?

    init() {
        setupOCR()
    }

    private func setupOCR() {
        recognizeTextRequest = VNRecognizeTextRequest { [weak self] request, error in
            self?.handleOCRResults(request: request, error: error)
        }

        // Configuration for real-time performance
        recognizeTextRequest.recognitionLevel = .fast
        recognizeTextRequest.usesLanguageCorrection = true
        recognizeTextRequest.recognitionLanguages = ["en-US"]
    }

    func recognizeText(in pixelBuffer: CVPixelBuffer) {
        // Use .up since CameraManager sets videoOrientation to .portrait
        // The pixel buffer is already delivered in portrait orientation
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .up,
                                            options: [:])
        do {
            try handler.perform([recognizeTextRequest])
        } catch {
            print("OCR error: \(error)")
        }
    }

    func recognizeText(in cgImage: CGImage) {
        let handler = VNImageRequestHandler(cgImage: cgImage,
                                            orientation: .up,
                                            options: [:])
        do {
            try handler.perform([recognizeTextRequest])
        } catch {
            print("OCR error: \(error)")
        }
    }

    private func handleOCRResults(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            return
        }

        var results: [TextResult] = []

        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else {
                continue
            }

            let result = TextResult(
                text: topCandidate.string,
                boundingBox: observation.boundingBox,
                confidence: topCandidate.confidence
            )
            results.append(result)
        }

        onTextRecognized?(results)
    }
}
