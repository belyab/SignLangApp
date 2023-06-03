import UIKit

class LiveCameraVoiceRecognaiserViewController: UIViewController {
    
    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    private var isRunning = false
    var recognitionViewModel = RecognitionViewModel()
    
    @IBAction func startRecordingButtonTapped(_ sender: UIButton) {
        
        if self.isRunning == true {
            recognitionViewModel.stopRecognition()
            isRunning = false
        } else {
            recognitionViewModel.startRecognition(textView: textView)
            isRunning = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
    }
}
