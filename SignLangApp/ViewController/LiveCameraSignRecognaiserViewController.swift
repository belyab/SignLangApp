import UIKit
import Vision
import AVFoundation

class LiveCameraSignRecognaiserViewController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!
    private var cameraView: CameraView { view as! CameraView }
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    private let videoDataOutputQueue = DispatchQueue(label: "CameraFeedDataOutput", qos: .userInteractive)
    private var cameraFeedSession: AVCaptureSession?
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    var classificationViewModel = ClassificationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classificationViewModel.classify()
        
            do {
                if cameraFeedSession == nil {
                    cameraView.previewLayer.videoGravity = .resizeAspectFill
                    try setupAVSession()
                    cameraView.previewLayer.session = cameraFeedSession
                }
                sessionQueue.async {
                    self.cameraFeedSession?.startRunning()
                }
            } catch {
                print(error)
            
        }
    }
    
    // MARK: - setupAVSession
    func setupAVSession() throws {
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }
        
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard session.canAddInput(deviceInput) else {
            return
        }
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
        }
        session.commitConfiguration()
        cameraFeedSession = session
    }

    private func prepareCaptureSession() {
        let captureSession = AVCaptureSession()

        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: .main)
        captureSession.addOutput(output)

        self.captureSession = captureSession
        self.captureSession?.startRunning()
    }

    private func prepareCaptureUI() {
        guard let session = captureSession else { return }
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        self.videoPreviewLayer = videoPreviewLayer
    }
}

extension LiveCameraSignRecognaiserViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .right, options: [:])
        
        defer {
            DispatchQueue.main.sync {
                resultLabel.text = " " + (classificationViewModel.result?.label ?? "Нет данных") + " "
            }
        }
        do {
            classificationViewModel.predictResult(handler: handler)
        }
    }
}

