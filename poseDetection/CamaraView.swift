import SwiftUI
import AVFoundation
import Firebase
import MLKit
import MLKitPoseDetectionAccurate
import MLKitPoseDetectionCommon



struct CameraView: UIViewControllerRepresentable {
    class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
        var session: AVCaptureSession!
        var poseDetector: PoseDetector!
        var overlayView: PoseOverlayView!

        override func viewDidLoad() {
            super.viewDidLoad()

            session = AVCaptureSession()
            session.sessionPreset = .medium

            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)
                session.addInput(input)
            } catch {
                print("Error configurando la cámara: \(error.localizedDescription)")
                return
            }

            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            session.addOutput(output)

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            // Crear el detector de poses
            let options = AccuratePoseDetectorOptions()
            options.detectorMode = .stream
            let poseDetector = PoseDetector.poseDetector(options: options)
                        
                        // Crear la vista overlay para dibujar los puntos
                        overlayView = PoseOverlayView(frame: view.bounds)
                        overlayView.backgroundColor = .clear
                        view.addSubview(overlayView)

                        session.startRunning()
        }
        
              
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            
            
            
            
            func imageOrientation(
              deviceOrientation: UIDeviceOrientation,
              cameraPosition: AVCaptureDevice.Position
            ) -> UIImage.Orientation {
              switch deviceOrientation {
              case .portrait:
                return cameraPosition == .front ? .leftMirrored : .right
              case .landscapeLeft:
                return cameraPosition == .front ? .downMirrored : .up
              case .portraitUpsideDown:
                return cameraPosition == .front ? .rightMirrored : .left
              case .landscapeRight:
                return cameraPosition == .front ? .upMirrored : .down
              case .faceDown, .faceUp, .unknown:
                return .up
              }
            }
            
            let image = VisionImage(buffer: sampleBuffer)
            image.orientation = imageOrientation(
              deviceOrientation: UIDevice.current.orientation,
              cameraPosition: .front )

            let options = AccuratePoseDetectorOptions()
            options.detectorMode = .stream
            let poseDetector = PoseDetector.poseDetector(options: options)
            var results: [Pose]
            do {
              results = try poseDetector.results(in: image)
            } catch let error {
              print("Failed to detect pose with error: \(error.localizedDescription).")
              return
            }

            // Verifica si el array de poses está vacío
            if results.isEmpty {
              print("Pose detector returned no results.")
              return
            }
            DispatchQueue.main.async {
                self.overlayView.pose = results.first
                self.overlayView.setNeedsDisplay()
                                }
            // Success. Get pose landmarks here.
            for pose in results {
              // Procesa las poses detectadas
              for landmark in pose.landmarks {
                let position = landmark.position
                print("Landmark: \(landmark.type), Posición: \(position.x), \(position.y), \(position.z)")
              }
            }
            // Success. Get pose landmarks here.

        }

        func handleDetectedPose(_ pose: Pose) {
            for landmark in pose.landmarks {
                let position = landmark.position
                print("Landmark: \(landmark.type), Posición: \(position.x), \(position.y), \(position.z)")
            }
        }
    }

    func makeUIViewController(context: Context) -> CameraViewController {
        return CameraViewController()
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
