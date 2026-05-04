import AVFoundation
import Vision
import Combine

// MARK: - Pose Detector Observable

class PoseDetector: NSObject, ObservableObject {
    @Published var currentPose: PoseData?
    @Published var isDetecting = false
    @Published var detectionError: String?
    @Published var cameraPermissionGranted = false

    /// Expose capture session for the camera preview layer.
    let captureSession = AVCaptureSession()

    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.foundry.pose.session")
    private let detectionQueue = DispatchQueue(label: "com.foundry.pose.detection", qos: .userInitiated)

    override init() {
        super.init()
        checkCameraPermission()
    }

    // MARK: - Camera Permission

    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            DispatchQueue.main.async {
                self.cameraPermissionGranted = true
            }
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.cameraPermissionGranted = granted
                }
                if granted {
                    self?.setupCamera()
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.cameraPermissionGranted = false
                self.detectionError = "Camera permission denied. Please enable in Settings."
            }
        @unknown default:
            break
        }
    }

    // MARK: - Camera Setup

    private func setupCamera() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high

            // Prefer back camera for full-body capture, fall back to front
            let camera: AVCaptureDevice? =
                AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
                ?? AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)

            guard let device = camera else {
                DispatchQueue.main.async {
                    self.detectionError = "No camera available on this device."
                }
                self.captureSession.commitConfiguration()
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: device)
                if self.captureSession.canAddInput(input) {
                    self.captureSession.addInput(input)
                }

                // Configure video output
                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.videoOutput.setSampleBufferDelegate(self, queue: self.detectionQueue)
                if self.captureSession.canAddOutput(self.videoOutput) {
                    self.captureSession.addOutput(self.videoOutput)
                }

                if let connection = self.videoOutput.connection(with: .video) {
                    if device.position == .front {
                        connection.isVideoMirrored = true
                    }
                }

                self.captureSession.commitConfiguration()
                self.captureSession.startRunning()

                DispatchQueue.main.async {
                    self.isDetecting = true
                }
            } catch {
                self.captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    self.detectionError = "Failed to setup camera: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Pose Detection

    private func detectPose(in sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.detectionError = "Pose detection error: \(error.localizedDescription)"
                }
                return
            }

            guard let observations = request.results as? [VNHumanBodyPoseObservation],
                  let observation = observations.first else {
                DispatchQueue.main.async {
                    self.currentPose = nil
                }
                return
            }

            do {
                let pose = try self.extractPoseData(from: observation)
                DispatchQueue.main.async {
                    self.currentPose = pose
                    self.detectionError = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.detectionError = "Failed to extract pose: \(error.localizedDescription)"
                }
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([request])
        } catch {
            DispatchQueue.main.async {
                self.detectionError = "Vision request failed: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Extract Pose Data

    private func extractPoseData(from observation: VNHumanBodyPoseObservation) throws -> PoseData {
        let recognizedPoints = try observation.recognizedPoints(.all)

        func getPoint(_ joint: VNHumanBodyPoseObservation.JointName) -> CGPoint {
            guard let point = recognizedPoints[joint],
                  point.confidence > 0.3 else {
                return .zero
            }
            // Vision provides coordinates with origin at bottom-left; flip Y for SwiftUI.
            return CGPoint(x: point.location.x, y: 1.0 - point.location.y)
        }

        return PoseData(
            nose: getPoint(.nose),
            leftEye: getPoint(.leftEye),
            rightEye: getPoint(.rightEye),
            leftEar: getPoint(.leftEar),
            rightEar: getPoint(.rightEar),
            leftShoulder: getPoint(.leftShoulder),
            rightShoulder: getPoint(.rightShoulder),
            leftElbow: getPoint(.leftElbow),
            rightElbow: getPoint(.rightElbow),
            leftWrist: getPoint(.leftWrist),
            rightWrist: getPoint(.rightWrist),
            leftHip: getPoint(.leftHip),
            rightHip: getPoint(.rightHip),
            leftKnee: getPoint(.leftKnee),
            rightKnee: getPoint(.rightKnee),
            leftAnkle: getPoint(.leftAnkle),
            rightAnkle: getPoint(.rightAnkle),
            timestamp: Date(),
            isValid: true
        )
    }

    // MARK: - Session Lifecycle

    func startSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if !self.captureSession.isRunning {
                self.captureSession.startRunning()
                DispatchQueue.main.async { self.isDetecting = true }
            }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
                DispatchQueue.main.async { self.isDetecting = false }
            }
        }
    }

    deinit {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension PoseDetector: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        detectPose(in: sampleBuffer)
    }
}
