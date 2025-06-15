//
//  TheameThreeVC.swift
//  Fake Call
//
//  Created by mac on 03/05/24.
//

import UIKit
import MarqueeLabel
import Kingfisher
import AVFAudio

class TheameThreeVC: UIViewController,MTSlideToOpenDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var ResponseCall_VIew: UIView!
    @IBOutlet weak var duringCall_View: UIView!
    @IBOutlet weak var suggestion_View: UIView!
    @IBOutlet weak var btn_CallAccept: MTSlideToOpenView!
    
    @IBOutlet weak var stake_View: UIStackView!
    
    @IBOutlet weak var msgBg_View: UIImageView!
    @IBOutlet weak var clockBg_View: UIImageView!
    @IBOutlet weak var img_WallPaper: UIImageView!
        
    @IBOutlet weak var img_AppIcons: UIImageView!
        
    @IBOutlet weak var img_Dp: UIImageView!
    @IBOutlet weak var btn_DuringDecline: UIButton!
    @IBOutlet weak var lbl_Name: MarqueeLabel!
    @IBOutlet weak var lbl_NameDuringCall: MarqueeLabel!
    @IBOutlet weak var lbl_CallTimer: UILabel!
    
    @IBOutlet weak var btn_Speaker: UIButton!
    
    var audioPlayer: AVAudioPlayer?
    var arrCllerIds = [CallerId]()
    var index  = Int()
    
    var name = String()
    var voiceUrl = URL(string: "")
    var font = String()
    var fontColor = String()
    var isUsingLoudspeaker = true
    var dpImageUrl = String()
    var isRunning = true
    var timer: Timer?
    var secondsElapsed: Int = 0
    let vibrationManager = VibrationManager()
    var vibrationTimer: Timer?

    let cache = ImageCache.default
    var options: KingfisherOptionsInfo = []

    var playbackDuration: TimeInterval = 0
    var timers: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        SetUI()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
            AdMob.sharedInstance()?.loadInste()
        }
    }

    
    @IBAction func tap_CallAccept(_ sender: Any) {

    }
        
    @IBAction func tap_DuringDecline(_ sender: Any) {
        stake_View.alpha = 0.5
        lbl_Name.alpha = 0.5
        lbl_CallTimer.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            UIView.animate(withDuration: 1) { [self] in
                
                ResponseCall_VIew.isHidden = true
                duringCall_View.isHidden = true
                img_AppIcons.isHidden = false
                
                let gotoDirectHome = Constants.USERDEFAULTS.bool(forKey: "DirectHomePage")
                //
                if !gotoDirectHome {
                    
                    // Get After Call WallPaper
                    if let imageDataAfterCall = Constants.USERDEFAULTS.string(forKey: "AfterCall") {
                        if let imageURL = URL(string: imageDataAfterCall), imageURL.scheme == "https" {
                            self.img_WallPaper.downloadImage(url: imageDataAfterCall, placeHolder: nil) { [weak self] error in
                                guard self != nil else { return }
                                
                                if let error = error {
                                    print("Failed to download image: \(error)")
                                }
                            }
                        } else {
                            let vidPath = CreateURL().documentsUrl().appendingPathComponent(imageDataAfterCall)
                            let imageURL = URL(string: vidPath.absoluteString)
                            let provider = LocalFileImageDataProvider(fileURL: imageURL!)
                            self.img_WallPaper.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"))
                            
                        }
                        
                    }
                } else {
                    exit(0)
                }
            }
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1 // Single tap
        view.addGestureRecognizer(tapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2 // Double tap
        view.addGestureRecognizer(doubleTapGesture)
        
        // Ensure single tap is recognized before double tap
        tapGesture.require(toFail: doubleTapGesture)

        isRunning = false
        Torch.setTorch(to:0.0)

        UIDevice.current.isProximityMonitoringEnabled = false

        audioPlayer?.stop()
        stopTimer()
    
    }
    
    @IBAction func tap_Speaker(_ sender: Any) {
        if isUsingLoudspeaker == true {
            isUsingLoudspeaker = false
            btn_Speaker.setImage(UIImage(named: "fill Speaker"), for: .normal)
            UIDevice.current.isProximityMonitoringEnabled = false

        } else {
            
            isUsingLoudspeaker = true
            btn_Speaker.setImage(UIImage(named: "Speaker"), for: .normal)
            UIDevice.current.isProximityMonitoringEnabled = true

        }
        toggleAudioOutput()
    }
    
}

extension TheameThreeVC {
    
    // Set UP UI
    func SetUI() {
//        img_WallPaper.addBlurToViews()
        index =  Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
        lbl_Name.scrollDuration = 8.0
        lbl_NameDuringCall.scrollDuration = 8.0

        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
            arrCllerIds = Ids
            
            for i in arrCllerIds {
                if i == arrCllerIds[index] {
                    let vidPath = CreateURL().documentsUrl().appendingPathComponent(i.dpimage!)
                    let imageURL = URL(string: vidPath.absoluteString)
                    let provider = LocalFileImageDataProvider(fileURL: imageURL!)
                    img_Dp.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"))
                }
            }
        }

        DispatchQueue.main.async { [self] in
            img_Dp.layer.cornerRadius = img_Dp.bounds.height / 2
            clockBg_View.layer.cornerRadius = clockBg_View.bounds.height / 2
            msgBg_View.layer.cornerRadius = msgBg_View.bounds.height / 2
            duringCall_View.isHidden = true
            suggestion_View.layer.cornerRadius = 12
            suggestion_View.layer.masksToBounds  = true
            suggestion_View.isHidden = true
        }
        
        setUpSliderButton()
        
    
        cache.memoryStorage.config.totalCostLimit = 500 * 1024 * 1024
        cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
        
        let size = CGSize(width: 1000, height: 1000)
        let processor = DownsamplingImageProcessor(size: size)
        options = [.processor(processor), .targetCache(cache)]

        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playback)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(false)
            
        } catch {
            
        }
        
        
        // Schedule to show the views after 5 seconds
        let Time = Constants.USERDEFAULTS.integer(forKey: "SaveTimer")
        let futureTime = DispatchTime.now() + .seconds(Time)
        DispatchQueue.main.asyncAfter(deadline: futureTime) { [weak self] in
            guard let self = self else { return }
            self.getAllValues()

            UIView.animate(withDuration: 0.5) {
                self.ResponseCall_VIew.isHidden = false
                self.img_AppIcons.isHidden = true
                
                // Get RingTone
                if let ringtoneURLString = Constants.USERDEFAULTS.url(forKey: "selectedRingToneUrl") {
                    self.setupAudioSession()

                    self.playAudio(from: ringtoneURLString)
                    
                } else {
                    print("No valid URL found in UserDefaults")
                }
                
            }
            
            let isFlashlight = Constants.USERDEFAULTS.bool(forKey: "Flashlight")
             let isVibration = Constants.USERDEFAULTS.bool(forKey: "Vibration")

             if isFlashlight {
                 self.startTorch()
             }
             
             if isVibration {
                 self.startVibrationTimer()
             }
             
                // Get During Call WallPaper
            if let imageDataBeforeCall = Constants.USERDEFAULTS.string(forKey: "DuringCall") {
              
                if let imageURL = URL(string: imageDataBeforeCall), imageURL.scheme == "https" {
                    let imageUrl = URL(string: imageDataBeforeCall)
                    
                    self.img_WallPaper.downloadImage(url: "\(imageUrl!)", placeHolder: nil) { [weak self] error in
                        guard self != nil else { return }
                        if let error = error {
                            print("Failed to download image: \(error)")
                        }
                    }
                    
                } else {
                    let vidPath = CreateURL().documentsUrl().appendingPathComponent(imageDataBeforeCall)
                    let imageURL = URL(string: vidPath.absoluteString)
                    let provider = LocalFileImageDataProvider(fileURL: imageURL!)
                    self.img_WallPaper.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"), options: self.options)
                }

            }
            if let imageDataBeforeCall = Constants.USERDEFAULTS.data(forKey: "DuringCall") {
                self.img_WallPaper.image = UIImage(data: imageDataBeforeCall)
            }
            }
            
        
        if Time != 0 {
            
            // Get Before Call WallPaper
            if let imageDataBeforeCall = Constants.USERDEFAULTS.string(forKey: "BeforeCall") {
                
                if imageDataBeforeCall == "https://apptrendz.com/API/fake_call/images/ios_wallpaper/ios_Wallpaper-1.png" {
                    self.img_AppIcons.isHidden = true
                } else {
                    self.img_AppIcons.isHidden = false
                    
                }
                ResponseCall_VIew.isHidden = true
                duringCall_View.isHidden = true
                
                
                if let imageURL = URL(string: imageDataBeforeCall), imageURL.scheme == "https" {
                    let imageUrl = URL(string: imageDataBeforeCall)
                    self.img_WallPaper.downloadImage(url: imageDataBeforeCall, placeHolder: nil) { [weak self] error in
                        guard self != nil else { return }
                        
                        if let error = error {
                            print("Failed to download image: \(error)")
                        }
                    }
                } else {
                    let vidPath = CreateURL().documentsUrl().appendingPathComponent(imageDataBeforeCall)
                    let imageURL = URL(string: vidPath.absoluteString)
                    let provider = LocalFileImageDataProvider(fileURL: imageURL!)
                    img_WallPaper.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"))
                    
                }
            }
        }
    }
    
    // Set Up Slider Button
    func setUpSliderButton() {
        btn_CallAccept.sliderViewTopDistance = 0
        btn_CallAccept.thumbnailViewTopDistance = Utils().IpadorIphone(value: 4);
        btn_CallAccept.thumbnailViewStartingDistance = Utils().IpadorIphone(value: 4);
        btn_CallAccept.sliderCornerRadius = Utils().IpadorIphone(value: 40)
        btn_CallAccept.thumnailImageView.backgroundColor = .white
        btn_CallAccept.draggedView.backgroundColor = .clear
        btn_CallAccept.delegate = self
        btn_CallAccept.thumnailImageView.image = UIImage(named: "Accept")
        btn_CallAccept.sliderBackgroundColor = .clear
        btn_CallAccept.labelText = "slide to answer"
        btn_CallAccept.textLabel.colors = [Utils().RGBColor(red: 255, green: 255, blue: 255,alpha: 0.5), UIColor.white]
        btn_CallAccept.textLabel.direction = .left
        btn_CallAccept.textLabel.animate = true
        btn_CallAccept.textLabel.infinity = true

    }
        
    // Play Audio
    func playAudio(from url: URL) {
               do {

                   self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                   self.audioPlayer?.delegate = self  // Set delegate to self to handle playback completion
                   self.audioPlayer?.prepareToPlay()
                   self.audioPlayer?.volume = 1.0
                   self.audioPlayer?.play()
                   audioPlayer?.numberOfLoops = -1
                   
                   let audioSession = AVAudioSession.sharedInstance()
                   try audioSession.setCategory(.playback, mode: .default, options: [])
                   try audioSession.setActive(true)

               } catch {
                   print("Error loading audio file: \(error.localizedDescription)")
               }
       }
    
    // Play Audio For Ear Speaker
    func playAudioEar(from url: URL) {
        let session = AVAudioSession.sharedInstance()
        
        do{
            try session.setCategory(.playAndRecord)
            try session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
            try session.setActive(true)
        } catch {
            print ("\(#file) - \(#function) error: \(error.localizedDescription)")
        }
        
        DispatchQueue.main.async { [self] in
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = 1.0
                audioPlayer?.play()
                
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
            }
        }
    }
    
    // Setup Audio Session
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Observe interruptions
            NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: AVAudioSession.sharedInstance())
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Interruption began, take appropriate actions (e.g., pause the audio)
            audioPlayer?.pause()
        case .ended:
            // Interruption ended, resume playback if needed
            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            if options.contains(.shouldResume) {
                audioPlayer?.play()
            }
        default:
            break
        }
    }

  
    // Get All Set Values In Database
    func getAllValues() {
        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
            arrCllerIds = Ids

            for i in arrCllerIds {
                if i == arrCllerIds[index] {
                    lbl_Name.text = i.name!
                    lbl_NameDuringCall.text = i.name!
                    voiceUrl = i.voiceUrl
                    if i.fonts != "" {
                        lbl_Name.font = UIFont.init(name:i.fonts! , size: 55)
                        lbl_NameDuringCall.font = UIFont.init(name:i.fonts! , size: 55)
                    }
//
                    if i.fontColor != "#FFFFFF" {
                        lbl_Name.textColor = Utils().hexStringToUIColor(hex:  i.fontColor!)
                        lbl_NameDuringCall.textColor = Utils().hexStringToUIColor(hex:  i.fontColor!)
//
                    }
                }
            }
        }
    }
    
    // Start Call Timer
    func startTimer() {
            // Invalidate any existing timer
            timer?.invalidate()
            
            // Reset elapsed seconds
            secondsElapsed = 0
            
            // Schedule a timer to update label every second
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
        
    // Update Call Timer
    @objc func updateTimer() {
        secondsElapsed += 1
        
        // Update label with formatted time
        let minutes = (secondsElapsed / 60) % 60
        let seconds = secondsElapsed % 60
        
        let timerText = String(format: "%02d:%02d", minutes, seconds)
        lbl_CallTimer.text = timerText
    }
    
    // Stop Call Timer
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func toggleAudioOutput() {
        let session = AVAudioSession.sharedInstance()

        do {
            if isUsingLoudspeaker {
                do{
                    try session.setCategory(.playAndRecord)
                    try session.overrideOutputAudioPort(AVAudioSession.PortOverride.none)
                    try session.setActive(true)
                } catch {
                    print ("\(#file) - \(#function) error: \(error.localizedDescription)")
                }
            } else {
                try session.setCategory(.playback)
                try session.overrideOutputAudioPort(.speaker)
            }
            try session.setActive(true)

        } catch {
            print("Error toggling audio output: \(error.localizedDescription)")
        }
    }

    // Call Accsept Button
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        timers?.invalidate()
        UIView.transition(with: ResponseCall_VIew, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.ResponseCall_VIew.isHidden = true
        }, completion: nil)

        // Show duringCall_View with fade animation
        UIView.transition(with: duringCall_View, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.duringCall_View.isHidden = false
        }, completion: nil)
        
        audioPlayer?.stop()
        startTimer()
        if let voiceUrl = voiceUrl {
//            self.playAudio(from: voiceUrl)
            self.playAudioEar(from: voiceUrl)
        } else {
            print("Error: voiceUrl is nil")
        }
        UIDevice.current.isProximityMonitoringEnabled = true
        isRunning = false
        Torch.setTorch(to:0.0)
        stopVibrationTimer()

    }
    
    // Start Torch
    func startTorch() {
        var torchValue: Float = 0.0
        guard isRunning else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            torchValue = 1.0
            Torch.setTorch(to:torchValue)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                torchValue = 0.0
                Torch.setTorch(to:torchValue)

                self.startTorch() // Repeat the process
            }
        }
    }
    
    // Start Vibration
    func startVibrationTimer() {
        // Create a timer that repeats every 0.5 seconds
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            // Trigger vibration
            self?.vibrate()
        }
    }
    
    // Stop Vibration
    func stopVibrationTimer() {
        // Stop the vibration timer if needed
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
    
    func vibrate() {
        DispatchQueue.main.async {
            
            AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) {
                // do what you'd like now that the sound has completed playing
            }
            // You can perform additional actions here after each vibration
        }
    }
    
    // Singale Tap To show Pop Up
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            // Show suggestion_View with fade-in animation
            self.suggestion_View.isHidden = false
            self.suggestion_View.alpha = 0.0
            
            // Fade in animation
            UIView.animate(withDuration: 0.3) {
                self.suggestion_View.alpha = 1.0 // Fade in to full visibility
            }
            
            // Hide suggestion_View after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 0.3, animations: {
                    self.suggestion_View.alpha = 0.0 // Fade out to invisible
                }) { _ in
                    self.suggestion_View.isHidden = true // Hide the view after fading out
                }
            }
        }
    }

    // Double Tap To Go to Home Page
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            navigationController?.popViewController(animated: false)
        }
    }

}
