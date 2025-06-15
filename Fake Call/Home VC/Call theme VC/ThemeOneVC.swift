//
//  ThemeOneVC.swift
//  Fake Call
//
//  Created by mac on 23/04/24.
//

import UIKit
import AVFAudio
import Kingfisher
import MarqueeLabel
import AVFoundation
import AudioToolbox.AudioServices

class ThemeOneVC: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var ResponseCall_VIew: UIView!
    @IBOutlet weak var duringCall_View: UIView!
    
    @IBOutlet weak var suggestion_View: UIView!
    @IBOutlet weak var btn_CallAccept: UIButton!
    @IBOutlet weak var btn_CallDecline: UIButton!
    
    @IBOutlet weak var msgBg_View: UIImageView!
    @IBOutlet weak var clockBg_View: UIImageView!
    @IBOutlet weak var img_WallPaper: UIImageView!
    
    @IBOutlet weak var img_AppIcons: UIImageView!
    @IBOutlet weak var blur_View: UIVisualEffectView!
    
    @IBOutlet weak var btn_DuringDecline: UIButton!

    @IBOutlet weak var stake_View: UIStackView!
    @IBOutlet weak var lbl_Name: MarqueeLabel!
    @IBOutlet weak var lbl_NameDuringCall: MarqueeLabel!
    
    @IBOutlet weak var btn_Speaker: UIButton!
    @IBOutlet weak var lbl_CallTimer: UILabel!
    
    var audioPlayer: AVAudioPlayer?
    var arrCllerIds = [CallerId]()
    var index  = Int()
    
    var name = String()
    var voiceUrl = URL(string: "")
    var font = String()
    var fontColor = String()
    var isUsingLoudspeaker = true
    
    var isRunning = true
    var vibrationTimer: Timer?

    var timer: Timer?
    var secondsElapsed: Int = 0
    
    var playbackDuration: TimeInterval = 0
    var timers: Timer?

    let vibrationManager = VibrationManager()
    let cache = ImageCache.default
    var options: KingfisherOptionsInfo = []

    override func viewDidLoad() {
        super.viewDidLoad()
        SetUI()
//        img_WallPaper.addBlurToViews()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
            AdMob.sharedInstance()?.loadInste()
        }
    }

    @IBAction func tap_CallAccept(_ sender: Any) {
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
        stopVibrationTimer()
        Torch.setTorch(to: 0.0)
        isRunning = false
        
        if let voiceUrl = voiceUrl {
//            self.playAudio(from: voiceUrl)
            self.playAudioEar(from: voiceUrl)
        } else {
            print("Error: voiceUrl is nil")
        }
        
        UIDevice.current.isProximityMonitoringEnabled = true

    }
    
    @IBAction func tap_Decline(_ sender: Any) {
        timers?.invalidate()

        UIView.animate(withDuration: 1) { [self] in
            ResponseCall_VIew.isHidden = true
            duringCall_View.isHidden = true
            img_AppIcons.isHidden = false
            Torch.setTorch(to: 0.0)
            isRunning = false
            stopVibrationTimer()
            let gotoDirectHome = Constants.USERDEFAULTS.bool(forKey: "DirectHomePage")

            if !gotoDirectHome {
                if let imageDataAfterCall = Constants.USERDEFAULTS.string(forKey: "AfterCall") {
                    
                    if let imageURL = URL(string: imageDataAfterCall), imageURL.scheme == "https" {
                        _ = URL(string: imageDataAfterCall)
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
                    
//                    let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
//                    doubleTapGesture.numberOfTapsRequired = 2
//                    view.addGestureRecognizer(doubleTapGesture)
                    // Add tap gesture recognizer
                }
             
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                tapGesture.numberOfTapsRequired = 1 // Single tap
                view.addGestureRecognizer(tapGesture)
                
                let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
                doubleTapGesture.numberOfTapsRequired = 2 // Double tap
                view.addGestureRecognizer(doubleTapGesture)
                
                // Ensure single tap is recognized before double tap
                tapGesture.require(toFail: doubleTapGesture)

                
                
            } else {
//                let array = [Int]()
//                let _ = array[1]
                exit(0)
//                navigationController?.popViewController(animated: false)
            }
        }
        
        audioPlayer?.stop()
          
    }
    
    @IBAction func tap_DuringDecline(_ sender: Any) {
        timers?.invalidate()
        stake_View.alpha = 0.5
        lbl_Name.alpha = 0.5
        lbl_CallTimer.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 1) { [self] in
                
                ResponseCall_VIew.isHidden = true
                duringCall_View.isHidden = true
                img_AppIcons.isHidden = false
                
                let cache = ImageCache.default
                var options: KingfisherOptionsInfo = []
                cache.memoryStorage.config.totalCostLimit = 500 * 1024 * 1024
                cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
                
                let size = CGSize(width: 500, height: 500)
                let processor = DownsamplingImageProcessor(size: size)
                options = [.processor(processor), .targetCache(cache)]
                
                
                let gotoDirectHome = Constants.USERDEFAULTS.bool(forKey: "DirectHomePage")
                
                if !gotoDirectHome {
                    
                    if let imageDataAfterCall = Constants.USERDEFAULTS.string(forKey: "AfterCall") {
                        
                        if let imageURL = URL(string: imageDataAfterCall), imageURL.scheme == "https" {
                            let imageUrl = URL(string: imageDataAfterCall)
                            img_WallPaper.kf.setImage(with: imageUrl!, placeholder: UIImage(named: "img_place"), options: options)
                            
                        } else {
                            let vidPath = CreateURL().documentsUrl().appendingPathComponent(imageDataAfterCall)
                            let imageURL = URL(string: vidPath.absoluteString)
                            let provider = LocalFileImageDataProvider(fileURL: imageURL!)
                            img_WallPaper.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"), options: options)
                            
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


                } else {
                    exit(0)
                }
            }
        }
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

extension ThemeOneVC {
    
    // Set UP UI
    func SetUI() {
        index =  Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
        clockBg_View.layer.cornerRadius = clockBg_View.bounds.height / 2
        msgBg_View.layer.cornerRadius = msgBg_View.bounds.height / 2
        suggestion_View.layer.cornerRadius = 12
        suggestion_View.layer.masksToBounds  = true
        suggestion_View.isHidden = true
        duringCall_View.isHidden = true
        
        lbl_Name.scrollDuration = 8.0
        lbl_NameDuringCall.scrollDuration = 8.0
        
        
        
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(.playback)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
        } catch {
            
        }
        
        cache.memoryStorage.config.totalCostLimit = 500 * 1024 * 1024
        cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
        
        let size = CGSize(width: 800, height: 800)
        let processor = DownsamplingImageProcessor(size: size)
        options = [.processor(processor), .targetCache(cache)]

        
        // Schedule to show the views after 5 seconds
        let Time = Constants.USERDEFAULTS.integer(forKey: "SaveTimer")
        let futureTime = DispatchTime.now() + .seconds(Time)
        
        DispatchQueue.main.asyncAfter(deadline: futureTime) { [weak self] in
            guard let self = self else { return }
            self.getAllValues()

            UIView.animate(withDuration: 0.5) { [self] in
                self.ResponseCall_VIew.isHidden = false
                self.img_AppIcons.isHidden = true
                if let imageDataBeforeCall = Constants.USERDEFAULTS.string(forKey: "DuringCall") {
                  
                    if let imageURL = URL(string: imageDataBeforeCall), imageURL.scheme == "https" {
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
                        self.img_WallPaper.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"), options: self.options)
                    }

                }
                
                if let imageDataBeforeCall = Constants.USERDEFAULTS.data(forKey: "DuringCall") {
                    self.img_WallPaper.image = UIImage(data: imageDataBeforeCall)
                }

                
                let isFlashlight = Constants.USERDEFAULTS.bool(forKey: "Flashlight")
                 let isVibration = Constants.USERDEFAULTS.bool(forKey: "Vibration")

                 if isFlashlight {
                     self.startTorch()
                 }
                 
                 if isVibration {
                     self.startVibrationTimer()//
                     self.vibrationManager.startPeriodicVibration()
                 }
            }
            
            if let ringtoneURLString = Constants.USERDEFAULTS.url(forKey: "selectedRingToneUrl") {
//                let savedUrl = URL(fileURLWithPath: ringtoneURLString)
                self.playAudio(from: ringtoneURLString)
                
            } else {
                print("No valid URL found in UserDefaults")
            }
            
        }
        
        // Show BeforeCall Wallpaper
        if Time != 0 {
            if let imageDataBeforeCall = Constants.USERDEFAULTS.string(forKey: "BeforeCall") {
                
                if imageDataBeforeCall == "https://apptrendz.com/API/fake_call/images/ios_wallpaper/ios_Wallpaper-1.png" {
                    self.img_AppIcons.isHidden = true
                } else {
                    self.img_AppIcons.isHidden = false
                    
                }
                ResponseCall_VIew.isHidden = true
                duringCall_View.isHidden = true
                
                if let imageURL = URL(string: imageDataBeforeCall), imageURL.scheme == "https" {
                    _ = URL(string: imageDataBeforeCall)
                    img_WallPaper.downloadImage(url: imageDataBeforeCall, placeHolder: nil) { [weak self] error in
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
    
    // Play Audio
    func playAudio(from url: URL) {
               do {
                   self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                   self.audioPlayer?.delegate = self  // Set delegate to self to handle playback completion
                   self.audioPlayer?.prepareToPlay()
                   self.audioPlayer?.volume = 1.0
                   self.audioPlayer?.play()
                   audioPlayer?.numberOfLoops = -1
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
        
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.volume = 1.0
                audioPlayer?.play()
            } catch {
                print("Error loading audio file: \(error.localizedDescription)")
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
    
    // Start Vibration
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
