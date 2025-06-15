//
//  ViewController.swift
//  Fake Call
//
//  Created by mac on 03/04/24.
//

import UIKit
import MarqueeLabel
import Kingfisher
import AVFAudio
import AVFoundation
import ProgressHUD
import GoogleMobileAds

class HomeVC: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var bg_View: UIView!
    @IBOutlet weak var btn_ReceiveCall: UIButton!
    @IBOutlet weak var tbl_Caller: UITableView!
    
    @IBOutlet weak var adsVIew_height: NSLayoutConstraint!
    @IBOutlet weak var bannerAds_View: GADBannerView!
    
    @IBOutlet weak var callLimit_PopUp_VIew: UIView!
    
    @IBOutlet weak var blur_View: UIVisualEffectView!
    @IBOutlet weak var btn_Upgrade: UIButton!
    
    
    
    var arrSetting:[[String]] = [[""],["Voice","Ringtone","Call theme","Wallpaper"],["Timer"]]
    var arrImage:[[String]] = [[""],["Voice 1","Ringtone","Call theme","Wallpaper 1"],["Timer"]]
    var arrHeader = ["Caller id settings","More settings","Set timer"]

    var labelTexts = ["Neel Patel", "Anjli Labde", "Viram Thakur","Meet Kheni","Nelesh Kanodiya"] // Add your desired texts here
    var imgTexts = ["1", "3", "2","4","3"] // Add your desired texts here
    var voiceTexts = ["Elon musk", "Narendra modi ", "Shah rukh khan","VIkratnt","Rani"] // Add your desired texts here
    var currentTextIndex = 0
    
    var arrImg = [UIImage(named: "Elon musk"),UIImage(named: "My Girl"),UIImage(named: "My Girl"), UIImage(named: "Unknown"),UIImage(named: "Kylie Jenner"), UIImage(named: "Work"),UIImage(named: "The Rock"),UIImage(named: "Shah Rukh Khan"),UIImage(named: "Zendaya"),UIImage(named: "Angelina Jolie"),UIImage(named: "Donald Trump"),UIImage(named: "Barack Obama"),UIImage(named: "Cristiano Ronaldo")]
    
    var arrDefaultDpImg = [UIImage(named: "Elon musk 1"),UIImage(named: "My Girl 1"),UIImage(named: "My Girl 1"), UIImage(named: "Unknown 1"),UIImage(named: "Kylie Jenner 1"), UIImage(named: "Work 1"),UIImage(named: "The Rock 1"),UIImage(named: "Shah Rukh Khan 1"),UIImage(named: "Zendaya 1"),UIImage(named: "Angelina Jolie 1"),UIImage(named: "Donald Trump 1"),UIImage(named: "Barack Obama 1"),UIImage(named: "Cristiano Ronaldo 1")]

    var arrName = ["Elon musk","Girlfriend","Boyfriend", "Unknown","Kylie Jenner", "Work","The Rock","Shah Rukh Khan","Zendaya","Angelina Jolie","Donald Trump","Barack Obama","Cristiano Ronaldo"]
    
    var arrPhone = ["+18885183752","+7 5874563258", "+1 5874563258","+(612) 645-75-568", "+1 2374563258","+91 5874563258","+1 5874563258","+91 5874563258","+1 6974563258","+(612) 645-75-568","+1 6457556825","+1 5874563258","01618688000"]
    
    var arrVoice = ["Elon musk","Girlfriend","Boyfriend", "Unknown","Kylie Jenner", "Work","The Rock","Shah Rukh Khan","Zendaya","Angelina Jolie","Donald Trump","Barack Obama","Cristiano Ronaldo"]
    
    
    var arrtextColor = ["#FFFFFF","#FFFFFF", "#FFFFFF", "#FFFFFF","#FFFFFF","#FFFFFF","#FFFFFF","#FFFFFF","#FFFFFF","#FFFFFF","#FFFFFF","#FFFFFF","FFFFFF"]
    
    var arrVoiceName = ["Elon Musk","Love","Love male","Unknown","Kylie Jen","Work","The Rock","Sarukh khan","Zenda","Angelina jolie","Donald Trump","Barack Obama","Cristiano Ronaldo"]
    
//    var arrVoiceName = [URL]()
    var arrVoiceUrl = [URL]()
    var arrRingtoneUrl = [URL]()

    var name = "Elon musk"
    var voice = "Elon musk"
    var number = ""
    var dpImageUrl = ""
    var font = String()
    var fontColor = String()
    var isDefaultImage = Bool()
    var callTimer = String()


    var dpImage = UIImage()
    var defaultDpImage = UIImage()

    var imgCallDuration = UIImage()
    var demoImg = UIImageView()

    var contacts = CallerIds()
    let uniqueKey = UUID()
    var arrCllerIds = [CallerId]()
    var audioPlayer: AVAudioPlayer?

    var callerIdIndex = 0
    
    let defaultDuringCallImage = UIImage(named: "Wallpaper")

    override func viewDidLoad() {
        super.viewDidLoad()
//        addNumbersDaily()
        //  primium Flow
//        Constants.USERDEFAULTS.set(1, forKey: "Premium")
        
        // Freemium Flow
        Constants.USERDEFAULTS.removeObject(forKey:"Premium")

        setUI()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDataNotification(_:)), name: Notification.Name("ContactDetails"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDataNotificationIndex(_:)), name: Notification.Name("selectedCallerIdIndex"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioDownloadInProgress), name: .audioDownloadInProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioDownloadCompleted), name: .audioDownloadCompleted, object: nil)

        navigationController?.isNavigationBarHidden = true
        imgCallDuration = dpImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = true
        }
        callerIdIndex = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
        fetchCallerData()
        
    }
    
    @IBAction func tap_ReceiveCall(_ sender: Any) {
        if Constants.USERDEFAULTS.integer(forKey: "Premium") == 1 {
            // First time running the app or no last enabled date found, enable the button
            let index = Constants.USERDEFAULTS.integer(forKey: "callThemeSelectedIndex")
            let navigate: UIViewController
            
            switch index {
            case 0:
                navigate = storyboard?.instantiateViewController(withIdentifier: "ThemeOneVC") as! ThemeOneVC
            case 1:
                navigate = storyboard?.instantiateViewController(withIdentifier: "ThemeTwoVC") as! ThemeTwoVC
            case 2:
                navigate = storyboard?.instantiateViewController(withIdentifier: "TheameThreeVC") as! TheameThreeVC
            default:
                navigate = storyboard?.instantiateViewController(withIdentifier: "ThemeTwoVC") as! ThemeTwoVC
            }

            // Set the transition style to cross dissolve (fade)
            navigate.modalTransitionStyle = .crossDissolve

            // Push the view controller onto the navigation stack with animation
            if let navigationController = navigationController {
                UIView.transition(with: navigationController.view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    navigationController.pushViewController(navigate, animated: false)
                }, completion: nil)
            } else {
                // If navigationController is nil (e.g., not embedded in a navigation controller), present the view controller modally
                navigate.modalPresentationStyle = .fullScreen
                present(navigate, animated: true, completion: nil)
            }
        } else {
            callTwoTimesPerDay()
        }
    }
    
    @IBAction func tap_Setting(_ sender: Any) {
        let navigate = storyboard?.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        navigationController?.pushViewController(navigate, animated: true)
    }
    
    @IBAction func tap_Upgrade(_ sender: Any) {
        let naviget = storyboard?.instantiateViewController(withIdentifier: "primiumVC") as! primiumVC
        naviget.modalPresentationStyle = .fullScreen
        present(naviget, animated: true, completion: {
            self.blur_View.isHidden = true
        })
    }
    
    @IBAction func tap_Close_Popup(_ sender: Any) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
            self.blur_View.alpha = 0
        }) { _ in
            self.blur_View.isHidden = true
        }
        
    }
    
    
    // MARK: - GADBannerViewDelegate Methods
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        // Stop skeleton shimmer once the ad is loaded
        print("Banner ad received")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("Banner ad failed to receive with error: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("Banner ad recorded impression")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("Banner ad will present screen")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("Banner ad will dismiss screen")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("Banner ad did dismiss screen")
    }
}

extension HomeVC {
                                                                                       
    //  Set Up UI
    func setUI() {

        if Utils().isConnectedToNetwork() {
            bannerAds_View.adUnitID = Constants.BANNER
            bannerAds_View.adSize = GADAdSizeBanner
            bannerAds_View.rootViewController = self
            bannerAds_View.delegate = self
            bannerAds_View.load(GADRequest())
        }
        
        // Premium User To Hide Ads View
        if Constants.USERDEFAULTS.value(forKey: "Premium") != nil {
            adsVIew_height.constant = 0
        } else {
            adsVIew_height.constant = 60
        }
        
        blur_View.isHidden = true
        callLimit_PopUp_VIew.layer.cornerRadius = 16
        callLimit_PopUp_VIew.layer.masksToBounds = true
        btn_Upgrade.layer.cornerRadius = 16
        btn_Upgrade.layer.masksToBounds = true

        
        Constants.USERDEFAULTS.set(true, forKey: "startUp")
        dpImage = UIImage(named: "Elon musk 1")!
        //        playAudio(from:  Bundle.main.url(forResource:"Elon-Musk", withExtension: "mp3")!)
        
        
        
        if isFirstLaunch() {
            ProgressHUD.animate(interaction: false)
            
            for i in arrVoiceName {
                arrVoiceUrl.append(Bundle.main.url(forResource:i, withExtension: "wav")!)
            }

            
            let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
            if let jpegData = dpImage.jpegData(compressionQuality: 0.7) {
                let imageFilter = CreateURL().saveFile(data: jpegData as Data, fileName: filterUrl)
                dpImageUrl = imageFilter!
            }
            
            let filterUrls = "IMG_\(Date().currentTimeMillis()).png"
            
            if let pngData = defaultDuringCallImage!.jpegData(compressionQuality: 0.5) {
                let imageFilter = CreateURL().saveFile(data: pngData as Data, fileName: filterUrls)
                Constants.USERDEFAULTS.set(imageFilter,forKey: "BeforeCall")
                Constants.USERDEFAULTS.set(imageFilter,forKey: "AfterCall")
            }
            
            Constants.USERDEFAULTS.set(name, forKey: "Name")
            Constants.USERDEFAULTS.set(number, forKey: "number")
            Constants.USERDEFAULTS.set(voice, forKey: "voice")
            Constants.USERDEFAULTS.set(dpImageUrl, forKey: "dpImageUrl")
            Constants.USERDEFAULTS.set(Bundle.main.url(forResource: "Reflection", withExtension: "wav"), forKey: "selectedRingToneUrl")
            //            Constants.USERDEFAULTS.set(name, forKey: "Name")
            
            // Mark that the setup has been completed
            setFirstLaunchFlag()
            
            print(arrVoiceUrl)
            self.setupDefaultContact()
            self.fetchCallerData()
            ProgressHUD.dismiss()

        }
        
        
//        if Constants.ISDownloadingUrl {
//            arrVoiceUrl = Constants.arrVoiceUrl
//            if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: arrVoiceUrl, requiringSecureCoding: false) {
//                // Step 2: Save Data to UserDefaults
//                UserDefaults.standard.set(encodedData, forKey: "savedVoiceUrls")
//            } else {
//                print("Error encoding array of URLs")
//            }
//            
//            arrRingtoneUrl = Constants.arrRingToneUrl
//            
//            let urlStringArray = arrRingtoneUrl.map { $0.absoluteString }
//            UserDefaults.standard.set(urlStringArray, forKey: "RingToneUrl")
//            
//            if let firstRingtoneUrl = arrRingtoneUrl.first {
//                Constants.USERDEFAULTS.set(firstRingtoneUrl, forKey: "selectedRingToneUrl")
//            } else {
//                // Handle the case where the array is empty
//                print("Error: arrRingtoneUrl is empty")
//            }
//            self.setupDefaultContact()
//            self.fetchCallerData()
//            ProgressHUD.dismiss()
//        }
        

      
        DispatchQueue.main.async { [self] in
            bg_View.roundCorners(corners: [.topLeft, .topRight], radius: 20)
            btn_ReceiveCall.layer.cornerRadius = 20
            btn_ReceiveCall.layer.masksToBounds = true
//            btn_ReceiveCall.layer.backgroundColor = Utils().RGBColor(red: 42, green: 131, blue: 239).cgColor
        }

        NotificationCenter.default.addObserver(self, selector: #selector(handleImgDuringCallNotification(_:)), name: NSNotification.Name("ImgDuringCall"), object: nil)
//        Constants.USERDEFAULTS.set(true, forKey: "Empty Image")
//        fetchCallerData()
    }
                                                                                                                   
    // Fetch Caller Data From Database
    func fetchCallerData() {

        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
            arrCllerIds = Ids

            for i in arrCllerIds {
                if i == arrCllerIds[callerIdIndex] {
                    name = i.name!
                    voice = i.voice!
                    number = i.number!
                    dpImageUrl = i.dpimage!
                    font = i.fonts!
                    fontColor = i.fontColor!
                    isDefaultImage = i.isDefault
                }

                if let imageUrl = URL(string: i.dpimage!) {
                    // Download the image asynchronously using Kingfisher
                    KingfisherManager.shared.retrieveImage(with: imageUrl) { [self] result in
                        switch result {
                        case .success(let imageResult):
                            // Image download and caching successful
                            // Assign the downloaded image to your Contact object's dpImage property
                            dpImage = imageResult.image
                            defaultDpImage = imageResult.image
                        case .failure(let error):
                            // Handle image download failure (e.g., show placeholder, log error)
                            print("Image download failed with error: \(error)")
                            // You can assign a placeholder image to dpImage if needed
                            //                            contacts.dpImage = UIImage(named: "img_place")
                        }
                    }
                } else {
                    // Invalid URL, handle this case if necessary
                    print("Invalid image URL")
                    // Assign a placeholder image to dpImage if needed
                    //                    contacts.dpImage = UIImage(named: "img_place")
                }
            }
            
//
//            let index = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
//            if arrDefaultDpImg.count >= index {
//                let valueAtIndex = arrDefaultDpImg.remove(at: index)
//                arrDefaultDpImg.insert(valueAtIndex, at: 0)
//            }
            
       
        
        if let savedImageDataArray = UserDefaults.standard.array(forKey: "savedImagesDuration") as? [Data] {
            // Convert array of Data back to array of UIImage
            let savedImages = savedImageDataArray.compactMap { UIImage(data: $0) }
               arrImg = savedImages
        }
            
        
                
            print(arrCllerIds)
        }
        
        DispatchQueue.main.async {
            self.tbl_Caller.reloadData()
        }
    }
                
    // Setup Default Contact
    func setupDefaultContact() {
        
        let filterUrl = "IMG_\(Date().currentTimeMillis()).png"

        Constants.USERDEFAULTS.set(true, forKey: "Empty Image")
        Constants.USERDEFAULTS.set("Refalection", forKey: "selectedRingToneName")
        Constants.USERDEFAULTS.set(0,forKey: "callThemeSelectedIndex")
        Constants.USERDEFAULTS.set(3, forKey: "SaveTimer")
        Constants.USERDEFAULTS.set(true,forKey: "FirstFile")
        Constants.USERDEFAULTS.set(0, forKey: "SaveTimer")


        let imageDataArray = arrImg.compactMap { Utils().imageData(from: $0!) }

        // Save the array of Data to UserDefaults
        UserDefaults.standard.set(imageDataArray, forKey: "savedImagesDuration")

        
        for i in 0..<arrName.count {
            contacts.name = arrName[i]
            contacts.voice = arrVoice[i]
            contacts.number = arrPhone[i]
            contacts.timestamp = "\(Date().currentTimeMillis())"
            contacts.fontColor = "#FFFFFF"
            contacts.isDefault = true
            contacts.VoiceUrl =  arrVoiceUrl[i]
            contacts.isEmptyDp =  false
            
            let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
            if let lupinImage = arrDefaultDpImg[i], let jpegData = lupinImage.jpegData(compressionQuality: 0.7) {
                if let imageFilter = CreateURL().saveFile(data: jpegData, fileName: filterUrl) {
                    contacts.dpImage = imageFilter
                } else {
                    print("Failed to save image filter")
                }
            } else {
                print("Failed to load or convert image")
            }
            
            
            let addImage = IMAGEDATA().SaveData(context: self.context, CallerIds: contacts)
            if addImage {
                print("yess")
            } else {
                print("Noooo")
            }
        }
        
//
//        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
//            arrCllerIds = Ids
//            print(arrCllerIds)
//            for i in arrCllerIds {
//                print(i.voiceUrl)
//                print(i.name)
//
//            }
//        }
                
        if let pngData = arrImg[0]!.jpegData(compressionQuality: 0.5) {
            let imageFilter = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)
            Constants.USERDEFAULTS.set(imageFilter,forKey: "DuringCall")
        }
        
        
        // Now you can use the 'contacts' object with default values and image
    }
                 
    // play Audio
    func playAudio(from url: URL) {
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
                 
    // First Time Launch Set UserDefault
    func isFirstLaunch() -> Bool {
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        return !isFirstLaunch // Return true if it's the first launch (flag not set)
    }
                                                                                                               
    func setFirstLaunchFlag() {
        UserDefaults.standard.set(true, forKey: "isFirstLaunch")
    }
  
    // Show Alert
    func showAlert() {
            // Create an alert controller
            let alertController = UIAlertController(title: "", message: "You cannot change the Voice of the default caller ID.", preferredStyle: .alert)
            
            // Add an action to the alert (a button)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // Handle OK button tap (if needed)
                print("OK tapped")
            }
            
            // Add the OK action to the alert controller
            alertController.addAction(okAction)
            
            // Present the alert controller
            present(alertController, animated: true, completion: nil)
        }
    
    @objc func handleTextDataNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            // Extract name and phoneNumber from userInfo
            if let name = userInfo["name"] as? String {
                // Use the received text data (name and phoneNumber) as needed
                print("Received Name: \(name)")
                print("Received Phone Number: \(voice)")
                
                self.name = name
                tbl_Caller.reloadData()
            }
            
            if let voice = userInfo["Voice"] as? String {
                self.voice = voice
                tbl_Caller.reloadData()

            }
            
            if let number = userInfo["number"] as? String {
                self.number = number
                tbl_Caller.reloadData()

            }
            
            if let Dp = userInfo["Dp"] as? UIImage {
                self.dpImage = Dp
                _ = UIImage(named: "Empty Image")
 
                tbl_Caller.reloadData()

            }
        }
        
    }
                                                                                                                   
    @objc func handleTextDataNotificationIndex(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if userInfo["index"] is Int {
            }
        }
    }
                                                                                                               
    @objc func handleImgDuringCallNotification(_ notification: Notification) {
        // Extract userInfo dictionary from the notification
        guard let userInfo = notification.userInfo else {
            print("Invalid userInfo in notification")
            return
        }

        // Extract the image from userInfo using the "image" key
        if let image = userInfo["image"] as? UIImage {
            // Use the retrieved image as needed
           imgCallDuration = image
        } else {
            print("Failed to extract image from notification userInfo")
        }
    }
    
    // Audio load In Progress
    @objc func audioDownloadInProgress() {
        // Show loader or update UI to indicate that download is in progress
        // You can display a loading indicator here
        print("Audio download in progress...")
    }

    // Audio Download Completed
    @objc func audioDownloadCompleted(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            // Extract name and phoneNumber from userInfo
            if let VoiceUrl = userInfo["VoiceUrl"] as? [URL] {
                arrVoiceUrl = VoiceUrl
                
                if let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: VoiceUrl, requiringSecureCoding: false) {
                    // Step 2: Save Data to UserDefaults
                    UserDefaults.standard.set(encodedData, forKey: "savedVoiceUrls")
                } else {
                    print("Error encoding array of URLs")
                }
            }
            
            if let RingToneUrl = userInfo["RingToneUrl"] as? [URL] {
                print(RingToneUrl)
                let urlStringArray = RingToneUrl.map { $0.absoluteString }
                UserDefaults.standard.set(urlStringArray, forKey: "RingToneUrl")
                Constants.USERDEFAULTS.set(RingToneUrl[0].absoluteString, forKey: "selectedRingToneUrl")
                print(RingToneUrl[0].absoluteString)

            }
        }
        
        
        self.setupDefaultContact()
        self.fetchCallerData()
        ProgressHUD.dismiss()
        print("Audio download completed.")
    }

                                                                                       
}

// TableView Delegate Methods
extension HomeVC:UITableViewDelegate,UITableViewDataSource {
                
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrSetting.count
    }
                
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSetting[section].count
    }
                
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //
        //            tblHeight.constant = tblSetting.contentSize.height
        //            }
        //
        if indexPath.row == 0  && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tbl_Caller_ID_Cell", for: indexPath) as! tbl_Caller_ID_Cell
            cell.selectionStyle = .none
            
            DispatchQueue.main.async {
                
                cell.img_Dp.layer.cornerRadius = cell.img_Dp.bounds.height / 2
                cell.img_Dp.clipsToBounds = true
                cell.img_Dp.layer.borderWidth = Utils().IpadorIphone(value: 2)
                cell.img_Dp.layer.borderColor = #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1) //UIColor.systemBlue.cgColor
            }
            
                cell.lblName.text = name

                let vidPath = CreateURL().documentsUrl().appendingPathComponent(dpImageUrl)
                let imageURL = URL(string: vidPath.absoluteString)
                let provider = LocalFileImageDataProvider(fileURL: imageURL!)
                cell.img_Dp.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"))
            
            if isDefaultImage {
                cell.img_EditIcon.image = nil
            } else {
                cell.img_EditIcon.image = UIImage(systemName: "square.and.pencil")
            }
            
            cell.lblVoice.text = voice
            animateLabelChange(cell.lblName)
            animateLabelChanges(cell.img_Dp)
            animateLabelChange(cell.lblVoice)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "tbl_Caller_Cell", for: indexPath) as! tbl_Caller_Cell
            cell.selectionStyle = .none
            //            cell.accessoryType = .disclosureIndicator
            if indexPath.section == 1 && (indexPath.row == 2 || indexPath.row == 3) {
                cell.lblSelectedName.isHidden = true
            } else {
                cell.lblSelectedName.isHidden = false
            }
            
            
            if indexPath.section == 1 {
                if indexPath.row == 0 {
                    cell.lblSelectedName.text = voice
                }
                if indexPath.row == 1 {
                    let ringTone =  Constants.USERDEFAULTS.string(forKey: "selectedRingToneName")
                    cell.lblSelectedName.text = ringTone
                }
            }

            
            if indexPath.section == 2 {
                if let callTimer =  Constants.USERDEFAULTS.string(forKey:  "SaveTimer") {
                    if callTimer == "0" {
                        cell.lblSelectedName.text = "Call Now"
                    } else {
                            if callTimer == "60" {
                                cell.lblSelectedName.text = "\(1) Minute"

                            } else if callTimer == "120" {
                                cell.lblSelectedName.text = "\(2) Minute"

                            } else if callTimer == "180" {
                                cell.lblSelectedName.text = "\(3) Minute"
                            } else {
                            cell.lblSelectedName.text = "\(callTimer) second"
                        }
                    }
                } else {
                    cell.lblSelectedName.text = "Call Now"

                }
            }
                
            
            cell.lblName.text = self.arrSetting[indexPath.section][indexPath.row]
            cell.imgIcon.image = UIImage(named: arrImage[indexPath.section][indexPath.row])
            return cell
        }
    }
                
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        
        // Create a horizontal stack view
        let stackView = UIStackView(frame: CGRect(x: 10, y: 10, width: headerView.bounds.width - 20, height: 30))
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        
        // Create label
        let label = UILabel()
        label.text = self.arrHeader[section]
        label.textColor = .init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        label.font = UIFont.systemFont(ofSize: Utils().IpadorIphone(value: 15), weight: .regular)
        stackView.addArrangedSubview(label)
        
        // Create button
        if section == 0 {
            let button = UIButton(type: .custom)
            button.setTitle("View All Caller ID ❯", for: .normal)
            button.setTitleColor(#colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize:  Utils().IpadorIphone(value: 15), weight: .medium)
            button.addTarget(self, action: #selector(viewAllCallerID), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        headerView.addSubview(stackView)
        
        // Set constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -10),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 5)
        ])
        
        
        return headerView
    }
                
    @objc func viewAllCallerID() {
        // Handle button tap action here
        print("View All Caller ID tapped")
        let navigate = storyboard?.instantiateViewController(withIdentifier: "CallerIdVC") as! CallerIdVC
        navigate.isSelectedCallerId = true
        navigate.arrDuringImage = arrImg
        navigate.modalTransitionStyle = .crossDissolve
        navigationController?.pushViewController(navigate, animated: true)
                                         
    }
                
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Utils().IpadorIphone(value: 50)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Utils().IpadorIphone(value: 100)
        } else  if indexPath.section == 1 {
            return Utils().IpadorIphone(value: 50)
        } else {
            return Utils().IpadorIphone(value: 50)

        }
    }
                
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tbl_Caller.cellForRow(at: IndexPath(row: 0, section: 0)) as? tbl_Caller_ID_Cell

        if indexPath.section == 0 {

            let navigate = storyboard?.instantiateViewController(withIdentifier: "ContactDetailsVC") as! ContactDetailsVC
            navigate.contact.name = name
            navigate.contact.number = number
            navigate.contact.voice = voice
            navigate.contact.dpImage = (cell?.img_Dp.image!)!
            
                if Constants.USERDEFAULTS.bool(forKey: "Empty Image") {
                    let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
                    if let pngData = arrImg[0]!.jpegData(compressionQuality: 0.5) {
                        let imageFilter = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)
                        Constants.USERDEFAULTS.set(imageFilter,forKey: "DuringCall")
                    }
                }
            navigationController?.pushViewController(navigate, animated: true)
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                if !isDefaultImage {
                    let navigate = storyboard?.instantiateViewController(withIdentifier: "VoiceVC") as! VoiceVC
                    navigate.isFirstOpationChangeVoice = true
                    navigate.isFromHome = true
                    navigationController?.pushViewController(navigate, animated: true)
                } else {
                    showAlert()
                }
            }
            
            if indexPath.row == 1 {
                let navigate = storyboard?.instantiateViewController(withIdentifier: "RingtoneVC") as! RingtoneVC
                navigationController?.pushViewController(navigate, animated: true)
            }
            
            if indexPath.row == 2 {
                let navigate = storyboard?.instantiateViewController(withIdentifier: "CallThemeVC") as! CallThemeVC
                navigationController?.pushViewController(navigate, animated: true)
            }
            if indexPath.row == 3 {
                let navigate = storyboard?.instantiateViewController(withIdentifier: "WallpaperVC") as! WallpaperVC
                
                if  dpImage.size.width == 56.333333333333336 &&  dpImage.size.height == 56  {
                    
                    navigate.Dpimage = defaultDuringCallImage!
                    
                } else {
                    navigate.Dpimage = imgCallDuration
                    
                }
                navigationController?.pushViewController(navigate, animated: true)
                
                if Constants.USERDEFAULTS.bool(forKey: "Empty Image") {
                    _ = dpImage
                    let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
                    
                    if let pngData = arrImg[0]!.jpegData(compressionQuality: 0.5) {
                        let imageFilter = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)
                        Constants.USERDEFAULTS.set(imageFilter,forKey: "DuringCall")
                    }
                }
            }
        }
        
        if indexPath.section == 2 {
            let navigate = storyboard?.instantiateViewController(withIdentifier: "TimerVC") as! TimerVC
            navigationController?.pushViewController(navigate, animated: true)

        }
    }
                
    func animateLabelChange(_ label: UILabel) {
        UIView.transition(with: label,
                          duration: 0.5, // Animation duration
                          options: .transitionCrossDissolve,
                          animations: {
            // Nothing to change here, we're just updating the label text
        },
                          completion: nil)
    }
                
    func animateLabelChanges(_ image: UIImageView) {
        UIView.transition(with: image,
                          duration: 0.5, // Animation duration
                          options: .transitionCrossDissolve,
                          animations: {
            // Nothing to change here, we're just updating the label text
        },
                          completion: nil)
    }
    
    func callTwoTimesPerDay() {
        let lastUpdateDate = Constants.USERDEFAULTS.value(forKey: "LastUpdateDate") as! Date
        print(lastUpdateDate)
        let timeIntervalSinceLastUpdate = Date().timeIntervalSince(lastUpdateDate)

        // Define the time interval for 24 hours (24 hours * 60 minutes * 60 seconds)
        let twentyFourHours: TimeInterval = 24 * 60 * 60

        if timeIntervalSinceLastUpdate > twentyFourHours {
       
            Constants.USERDEFAULTS.set(Date(), forKey: "LastUpdateDate")
            Constants.USERDEFAULTS.set(0, forKey: "limit")
            Constants.USERDEFAULTS.set(0, forKey: "RunCount")
            Constants.USERDEFAULTS.synchronize()
            
        }
        
        let runCount = UserDefaults.standard.integer(forKey: "RunCount")
        if runCount >= 2 {
            blur_View.alpha = 0
            blur_View.isHidden = false
            
            UIView.animate(withDuration: 0.5, // Duration of the animation in seconds
                           delay: 0, // Delay before the animation starts
                           options: [.curveEaseInOut], // Animation options
                           animations: {
                self.blur_View.alpha = 1 // Animate the alpha to 1 (fully opaque)
            }, completion: nil) // Completion block, if you need to execute some code after the animation
            
            return
            
        } else {
            
            UserDefaults.standard.set(runCount + 1, forKey: "RunCount")
        }
        
        let index = Constants.USERDEFAULTS.integer(forKey: "callThemeSelectedIndex")
        let navigate: UIViewController

        switch index {
        case 0:
            navigate = storyboard?.instantiateViewController(withIdentifier: "ThemeOneVC") as! ThemeOneVC
        case 1:
            navigate = storyboard?.instantiateViewController(withIdentifier: "ThemeTwoVC") as! ThemeTwoVC
        case 2:
            navigate = storyboard?.instantiateViewController(withIdentifier: "TheameThreeVC") as! TheameThreeVC
        default:
            navigate = storyboard?.instantiateViewController(withIdentifier: "ThemeTwoVC") as! ThemeTwoVC
        }

        // Set the transition style to cross dissolve (fade)
        navigate.modalTransitionStyle = .crossDissolve

        // Push the view controller onto the navigation stack with animation
        if let navigationController = navigationController {
            UIView.transition(with: navigationController.view, duration: 0.2, options: .transitionCrossDissolve, animations: {
                navigationController.pushViewController(navigate, animated: false)
            }, completion: nil)
        } else {
            // If navigationController is nil (e.g., not embedded in a navigation controller), present the view controller modally
            navigate.modalPresentationStyle = .fullScreen
            present(navigate, animated: true, completion: nil)
        }
        
       
      }

}

// tbl_Caller Cell
class tbl_Caller_Cell:UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var imgArrowIcon: UIImageView!
    @IBOutlet weak var lblSelectedName: UILabel!
}

// tbl_Caller_ID Cell
class tbl_Caller_ID_Cell:UITableViewCell {
 
    @IBOutlet weak var lblName: MarqueeLabel!
    @IBOutlet weak var img_Dp: UIImageView!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var lblVoice: MarqueeLabel!
    
    @IBOutlet weak var bg_View: UIView!
    
    @IBOutlet weak var img_EditIcon: UIImageView!
}




