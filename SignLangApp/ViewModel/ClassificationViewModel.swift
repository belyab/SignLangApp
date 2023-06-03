import Foundation
import Vision

class ClassificationViewModel {
    
    public var model: SignLangModel?
    public var result: SignLangModelOutput?
    public let handPoseRequest = VNDetectHumanHandPoseRequest()
    
    func classify() {
        handPoseRequest.maximumHandCount = 1
        
        guard let model = HandPosePredictor.HandPoseClassifier() else {
            print("error")
            return
        }

        self.model = model
        
    }
    
    func predictResult(handler: VNImageRequestHandler) {
     
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                print("Нет данных")
                return
            }
            
            result = try model?.prediction(poses: observation.keypointsMultiArray())
            print("[Prediction] \(result?.label ?? "ошибка")")
        } catch {
            print("Ошибка \(error)")
        }
    }

}
