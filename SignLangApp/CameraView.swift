import UIKit
import AVFoundation
import Vision

class CameraView: UIView {
    private var overlayLayer: CAShapeLayer = CAShapeLayer()
    private var pointsPath: UIBezierPath = UIBezierPath()
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame:  frame)
        setupOverlay()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupOverlay()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        if layer == previewLayer {
            overlayLayer.frame = layer.bounds
        }
    }
    
    private func setupOverlay() {
        previewLayer.addSublayer(overlayLayer)
    }
}

extension VNRecognizedPoint {
    var previewPoint: CGPoint {
        return CGPoint(x: self.location.x, y: 1 - self.location.y)
    }
}


