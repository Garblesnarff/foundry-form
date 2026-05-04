import SwiftUI
import AVFoundation

// MARK: - Camera View with Skeleton Overlay

struct CameraView: View {
    let captureSession: AVCaptureSession
    let poseData: PoseData?
    let formScore: Float

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreviewRepresentable(session: captureSession)
                    .ignoresSafeArea()

                if let pose = poseData, pose.isValid {
                    SkeletonOverlay(poseData: pose, formScore: formScore)
                        .ignoresSafeArea()
                }
            }
            .background(Color.black)
        }
    }
}

// MARK: - Camera Preview (NSViewRepresentable wrapping AVCaptureVideoPreviewLayer)

struct CameraPreviewRepresentable: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> CameraPreviewNSView {
        let view = CameraPreviewNSView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateNSView(_ nsView: CameraPreviewNSView, context: Context) {
        nsView.previewLayer.session = session
    }
}

class CameraPreviewNSView: NSView {
    let previewLayer = AVCaptureVideoPreviewLayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer = previewLayer
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layer = previewLayer
    }

    override func layout() {
        super.layout()
        previewLayer.frame = bounds
    }
}

// MARK: - Skeleton Overlay

struct SkeletonOverlay: View {
    let poseData: PoseData
    let formScore: Float

    private var skeletonColor: Color {
        Color.formScoreColor(for: formScore)
    }

    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let scale = size

                for (i, j) in PoseData.connections {
                    let landmarks = poseData.allLandmarks
                    guard i < landmarks.count, j < landmarks.count else { continue }
                    let p1 = landmarks[i]
                    let p2 = landmarks[j]

                    guard p1 != .zero, p2 != .zero else { continue }

                    let start = CGPoint(x: p1.x * scale.width, y: p1.y * scale.height)
                    let end = CGPoint(x: p2.x * scale.width, y: p2.y * scale.height)

                    var path = Path()
                    path.move(to: start)
                    path.addLine(to: end)

                    context.stroke(
                        path,
                        with: .color(skeletonColor),
                        lineWidth: 3
                    )
                }

                let radius: CGFloat = 6
                for landmark in poseData.allLandmarks where landmark != .zero {
                    let position = CGPoint(
                        x: landmark.x * scale.width,
                        y: landmark.y * scale.height
                    )

                    let rect = CGRect(
                        x: position.x - radius,
                        y: position.y - radius,
                        width: radius * 2,
                        height: radius * 2
                    )

                    context.fill(Path(ellipseIn: rect), with: .color(skeletonColor))
                }
            }
        }
    }
}

// MARK: - No-Camera Placeholder

struct CameraPermissionView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.fill")
                .font(.system(size: 48))
                .foregroundColor(.forgeMediumGray)

            Text("Camera Access Required")
                .font(.headline)
                .foregroundColor(.white)

            Text("Foundry Form needs camera access to analyze your exercise form. Please enable it in System Settings > Privacy & Security > Camera.")
                .font(.subheadline)
                .foregroundColor(.forgeMediumGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Open System Settings") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera") {
                    NSWorkspace.shared.open(url)
                }
            }
            .buttonStyle(ForgeButtonStyle())
            .padding(.horizontal, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.forgeBlack)
    }
}

#Preview {
    CameraView(
        captureSession: AVCaptureSession(),
        poseData: PoseData(
            nose: CGPoint(x: 0.5, y: 0.2),
            leftEye: CGPoint(x: 0.45, y: 0.18),
            rightEye: CGPoint(x: 0.55, y: 0.18),
            leftEar: CGPoint(x: 0.4, y: 0.2),
            rightEar: CGPoint(x: 0.6, y: 0.2),
            leftShoulder: CGPoint(x: 0.3, y: 0.35),
            rightShoulder: CGPoint(x: 0.7, y: 0.35),
            leftElbow: CGPoint(x: 0.25, y: 0.5),
            rightElbow: CGPoint(x: 0.75, y: 0.5),
            leftWrist: CGPoint(x: 0.2, y: 0.6),
            rightWrist: CGPoint(x: 0.8, y: 0.6),
            leftHip: CGPoint(x: 0.35, y: 0.6),
            rightHip: CGPoint(x: 0.65, y: 0.6),
            leftKnee: CGPoint(x: 0.35, y: 0.75),
            rightKnee: CGPoint(x: 0.65, y: 0.75),
            leftAnkle: CGPoint(x: 0.35, y: 0.9),
            rightAnkle: CGPoint(x: 0.65, y: 0.9)
        ),
        formScore: 85
    )
}
