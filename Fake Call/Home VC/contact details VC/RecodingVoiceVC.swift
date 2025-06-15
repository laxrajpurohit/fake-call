//
//  RecodingVoiceVC.swift
//  Fake Call
//
//  Created by mac on 09/04/24.
//

import UIKit
import AVFAudio
//import SoundWave

class RecodingVoiceVC: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var btn_PlayRecoding: UIButton!
    @IBOutlet weak var btn_StartRecoding: UIButton!
    @IBOutlet weak var btn_SaveVoice: UIButton!
    @IBOutlet weak var waveformView: AudioVisualizerView!
    @IBOutlet weak var lbl_RecodingTimer: UILabel!

    var isRecording = true
    var isChange = false
    
    var audioEngine: AVAudioEngine!
    var inputNode: AVAudioInputNode!

    private var fileURL: URL?

    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?

    var timer: Timer?
    var timer1: Timer?

    var elapsedTime: TimeInterval = 0

    var recordingDurationLabel: UILabel?
    
    var saveAction: UIAlertAction!

    weak var audioMeteringDelegate: AudioMeteringDelegate?
    var meteringTimer: Timer?
    
    // record value every 0.08 seconds.
    var meteringFrequency = 0.1

    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    // Tap PlayRecoding
    @IBAction func tap_PlayRecoding(_ sender: Any) {
        guard let player = audioPlayer else {
               print("Audio player is nil")
               return
           }
        player.play()
        player.volume = 1.0
        
       }
        
    // Tap StartRecoding
    @IBAction func tap_StartRecoding(_ sender: Any) {
        isChange = true
     
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            if isRecording {
                // Stop recording
                //            stopRecording()
                btn_StartRecoding.setImage(UIImage(named: "pause"), for: .normal)
                btn_PlayRecoding.isEnabled = false
                btn_SaveVoice.isEnabled = false
                
                startRecording()
            } else {
                // Start recording
                btn_StartRecoding.setImage(UIImage(named: "recoding"), for: .normal)
                btn_PlayRecoding.isEnabled = true
                btn_SaveVoice.isEnabled = true
                
                stopRecording()
            }
            
            // Toggle recording state
            isRecording.toggle()
            
        case .denied :
            let alert = UIAlertController(title: "Microphone Permission Required", message: "Please grant microphone permission in Settings to enable this feature.", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            
            
        case .undetermined:break;
            
        default:break;
            
        }

        
    
 
    }
    
    // Tap SaveRecoding
    @IBAction func tap_SaveRecoding(_ sender: Any) {
    
        print(fileURL as Any)
        
        showAlertWithTextField()
        
    }
    
}

extension RecodingVoiceVC {
                                                                        
    // Set Up UI
    func setUI() {
        setNavigationBaar()
        DispatchQueue.main.async { [self] in
            
            btn_PlayRecoding.layer.cornerRadius = btn_PlayRecoding.bounds.height / 2
            btn_StartRecoding.layer.cornerRadius = btn_StartRecoding.bounds.height / 2
            btn_SaveVoice.layer.cornerRadius = btn_SaveVoice.bounds.height / 2
            checkMicrophonePermission()
            
            btn_PlayRecoding.isEnabled = false
            btn_SaveVoice.isEnabled = false
            
            self.audioMeteringDelegate = self.waveformView
        }
        
        audioEngine = AVAudioEngine()
        inputNode = audioEngine.inputNode

        
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error.localizedDescription)")
        }
    }
    
    // Set Navigation Bar
    func setNavigationBaar() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Record Voice"
        navigationItem.hidesBackButton = true

        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(Utils().RGBColor(red: 104, green: 206, blue: 103), for: .normal)
        backButton.addTarget(self, action: #selector(customButtonTapped), for: .touchUpInside)
        backButton.sizeToFit() // Adjust button size based on title content
        let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 44 // Default height if navigation controller or navigation bar not available
        let buttonHeight = min(backButton.frame.height, navigationBarHeight)
        backButton.frame = CGRect(x: 0, y: 0, width: backButton.frame.width + 20, height: buttonHeight)
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        backButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)

        let customBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = customBarButtonItem
    }
                        
    // start Recording
    func startRecording() {
        self.waveformView.removeVisualizerCircles()
        self.waveformView.drawVisualizerCircles()

        audioPlayer?.stop()
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
            
            // Get a unique file URL for the recording
            guard let audioFileURL = getUniqueAudioFileURL() else {
                print("Failed to obtain audio file URL")
                return
            }
            
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // Initialize AVAudioRecorder with the unique file URL and settings
            audioRecorder = try AVAudioRecorder(url: audioFileURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            audioRecorder?.isMeteringEnabled = true // Enable metering for input level monitoring

            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            print("Started recording at: \(audioFileURL)")
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
        self.runMeteringTimer()
    }
                      
    // stop Recording
    func stopRecording() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        timer1 = nil
        timer1?.invalidate()

        elapsedTime = 0

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            print("Audio session deactivation failed")
        }
        
        // Check if a valid file URL is available for playback
        if let audioFileURL = audioRecorder?.url {
            print("Recording stopped. Playback URL: \(audioFileURL)")
            fileURL = audioFileURL
            // Initialize AVAudioPlayer with the recorded audio file URL
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error initializing audio player: \(error.localizedDescription)")
            }
        } else {
            print("No audio file URL available for playback")
        }
        self.stopMeteringTimer()

    }
                              
    // update Timer
    @objc func updateTimer() {
          elapsedTime += 1
          updateRecordingDurationLabel()
        
      }
                                                                                                                                                
    func updateRecordingDurationLabel() {
//        guard let label = recordingDurationLabel else { return }
        lbl_RecodingTimer.text = formattedTime(seconds: Int(elapsedTime))
    }
                                                                    
    private func formattedTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
            return String(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds)
      
    }
                    
    // Get Unique Audio FileURL
    func getUniqueAudioFileURL() -> URL? {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let directory = documentsDirectory else { return nil }
        
        // Create a unique filename based on timestamp
        let uniqueFilename = "recording_\(Date().timeIntervalSince1970).m4a"
        
        // Append the unique filename to the documents directory URL
        let fileURL = directory.appendingPathComponent(uniqueFilename)
        
        return fileURL
    }
                         
    // Request Microphone Access
    func requestMicrophoneAccess() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("Microphone access granted")
                // Microphone access is granted, you can start using the microphone
            } else {
                print("Microphone access denied")
                // Microphone access is denied, handle accordingly (e.g., show alert, disable microphone features)
            }
        }
    }
                    
    // Check Microphone Permission
    func checkMicrophonePermission() {
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            print("Microphone access already granted")
            // Microphone access is already granted, you can start using the microphone
        case .denied:
            print("Microphone access denied")
            // Microphone access is denied, inform the user and provide instructions to enable it in Settings
        case .undetermined:
            print("Microphone access not determined yet")
            // Microphone access has not been requested yet, request it
            requestMicrophoneAccess()
        @unknown default:
            break
        }
    }
                       
    // Show Alert With TextField
    func showAlertWithTextField() {
          // Create an alert controller
          let alertController = UIAlertController(title: "Save AS", message: "Please enter voice title", preferredStyle: .alert)
          
          // Add a text field to the alert
          alertController.addTextField { (textField) in
              textField.placeholder = "Enter text here"
              textField.addTarget(self, action: #selector(self.textDidChange(_:)), for: .editingChanged)

          }
          
          // Create a "Delete" action
          let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
              // Handle delete action
              if (alertController.textFields?.first?.text) != nil {
                  // Perform delete operation with the input text
                  self.navigationController?.popViewController(animated: true)
              }
          }
          
          // Create a "Save" action
           saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
               self.isChange = false
              // Handle save action
              if let text = alertController.textFields?.first?.text {
                  // Perform save operation with the input text
                  print("Save: \(text)")
                  
                  let userInfo: [AnyHashable: Any] = ["SaveRecoding": text, "URL": self.fileURL as Any]
                  NotificationCenter.default.post(name: Notification.Name("SaveRecoding"), object: nil, userInfo: userInfo)
                  self.navigationController?.popViewController(animated: true)
                  
              }
          }
        saveAction.isEnabled = false

          
          // Add actions to the alert controller
          alertController.addAction(deleteAction)
          alertController.addAction(saveAction)
          
          // Present the alert controller
          self.present(alertController, animated: true, completion: nil)
        
        
      }
    
    // Function to handle text field editing changes
    @objc func textDidChange(_ sender: UITextField) {
        // Enable saveAction if the text field is not empty, otherwise disable it
        if let text = sender.text, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            saveAction.isEnabled = true
        } else {
            saveAction.isEnabled = false
        }
        
    }
    
    // Tap Back Button
    @objc func customButtonTapped() {
        if isChange {
            
            Utils().presentAlert(title: "Discard Changes?", message: "Are you sure want to discard this changes?", cancelTitle: "Cancel", discardTitle:  "Discard") {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
}

extension RecodingVoiceVC {
    
    fileprivate func runMeteringTimer() {
        
        self.meteringTimer = Timer.scheduledTimer(withTimeInterval: self.meteringFrequency, repeats: true, block: { [weak self] (_) in
            
            guard let self = self else { return }
            
            self.audioRecorder?.updateMeters()
            guard let averagePower = self.audioRecorder?.averagePower(forChannel: 0) else { return }
            
            // 1.1 to increase the feedback for low voice - due to noise cancellation.
            let amplitude = 1.1 * pow(10.0, averagePower / 20.0)
            let clampedAmplitude = min(max(amplitude, 0), 1)
            
            self.audioMeteringDelegate?.audioMeter(didUpdateAmplitude: clampedAmplitude)
        })
        
        self.meteringTimer?.fire()
    }
    
    fileprivate func stopMeteringTimer() {
        
        self.meteringTimer?.invalidate()
        self.meteringTimer = nil
    }
}


class AudioVisualizerView: UIView {
    
    enum ComponentValue {
        static let numOfColumns = 20
    }
    
    var columnWidth: CGFloat?
    var columns: [CAShapeLayer] = []
    var amplitudesHistory: [CGFloat] = []
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func drawVisualizerCircles() {
        
        self.amplitudesHistory = Array(repeating: 0, count: ComponentValue.numOfColumns)
        
        let diameter = self.bounds.width / CGFloat(2 * ComponentValue.numOfColumns + 1)
        self.columnWidth = diameter
        
        let startingPointY = self.bounds.midY - diameter / 2
        // minX + initial padding
        var startingPointX = self.bounds.minX + diameter
        
        for _ in 0..<ComponentValue.numOfColumns {
            
            let circleOrigin = CGPoint(x: startingPointX, y: startingPointY)
            let circleSize = CGSize(width: diameter, height: diameter)
            
            let circle = UIBezierPath(roundedRect: CGRect(origin: circleOrigin, size: circleSize), cornerRadius: diameter / 2)
            
            let circleLayer = CAShapeLayer()
            circleLayer.path = circle.cgPath
            circleLayer.fillColor = #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1)
            
            self.layer.addSublayer(circleLayer)
            
            self.columns.append(circleLayer)
            
            // Circle Diameter + Padding
            startingPointX += 2 * diameter
        }
    }
    
    func removeVisualizerCircles() {
        
        for column in self.columns {
            column.removeFromSuperlayer()
        }
        
        self.columns.removeAll()
    }
    
    private func computeNewPath(for layer: CAShapeLayer, with amplitude: CGFloat) -> CGPath {
        
        let width = self.columnWidth ?? 8.0
        
        // maxHeightGain = fullHeight - (circleInitialDiameter + 2 padding)
        let maxHeightGain = self.bounds.height - 3 * width
        
        let heightGain =  maxHeightGain * amplitude
        let newHeight = width + heightGain
        
        let newOrigin = CGPoint(x: layer.path?.boundingBox.origin.x ?? 0,
                                y: (layer.superlayer?.bounds.midY ?? 0) - (newHeight / 2))
        let newSize = CGSize(width: width, height: newHeight)
        
        return UIBezierPath(roundedRect: CGRect(origin: newOrigin, size: newSize), cornerRadius: width / 2).cgPath
    }
    
    fileprivate func updateVisualizerView(with amplitude: CGFloat) {
        
        guard self.columns.count == ComponentValue.numOfColumns else { return }
        
        // Adding a new value, removing the oldest
        self.amplitudesHistory.append(amplitude)
        self.amplitudesHistory.removeFirst()
        
        for i in 0..<self.columns.count {
            self.columns[i].path = computeNewPath(for: self.columns[i], with: self.amplitudesHistory[i])
        }
    }
    
}


// MARK: AudioMeteringDelegate
extension AudioVisualizerView: AudioMeteringDelegate {
    
    func audioMeter(didUpdateAmplitude amplitude: Float) {
        self.updateVisualizerView(with: CGFloat(amplitude))
    }
}

protocol AudioMeteringDelegate: NSObjectProtocol {
    
    func audioMeter(didUpdateAmplitude amplitude: Float)
}
