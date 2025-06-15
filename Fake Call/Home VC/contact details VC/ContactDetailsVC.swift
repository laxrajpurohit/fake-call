//
//  ContactDetailsVC.swift
//  Fake Call
//
//  Created by mac on 04/04/24.
//

import UIKit
import ContactsUI
import MarqueeLabel
import Kingfisher
import CoreData
import GoogleMobileAds


struct ContectID {
    var name = ""
    var voice = ""
    var number = ""
    var fonts = String()
    var fontColor = String()
    var dpImage = UIImage()
    var VoiceUrl = URL(string: "")
}

class ContactDetailsVC: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var profileBg_View: UIView!
    @IBOutlet weak var voiceBg_View: UIView!
    
    @IBOutlet weak var camera_BgView: UIView!
    @IBOutlet weak var img_EditPhoto: UIImageView!
    @IBOutlet weak var img_ProfilePic: UIImageView!
    @IBOutlet weak var img_ResponseToCall: UIImageView!
    @IBOutlet weak var img_DuringCall: UIImageView!
    
    @IBOutlet weak var img_Arrow: UIImageView!
    @IBOutlet weak var lbl_SelectedVoice: UILabel!
    @IBOutlet weak var lbl_ResponseCallName: MarqueeLabel!
    @IBOutlet weak var lbl_DuringCallName: MarqueeLabel!
    
    @IBOutlet weak var adsVIew_height: NSLayoutConstraint!
    @IBOutlet weak var bannerAds_View: GADBannerView!
    @IBOutlet weak var txt_Name: UITextField!
    @IBOutlet weak var txt_MoNumber: UITextField!

    @IBOutlet weak var btn_Save: UIButton!
    @IBOutlet weak var btn_EditPhoto: UIButton!
    
    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var btn_EditDp: UIButton!
    @IBOutlet weak var btn_Voice: UIButton!
    @IBOutlet weak var btn_ShowContact: UIButton!
    
    var name = ""
    var voice = ""
    var number = ""
    var dpImage = UIImage()

    var text1 = String()
    var text2 = String()
    let defaultDuringCallImage = UIImage(named: "Wallpaper")
    
    var isAddNewID = false
    var isEmptyDp = false
    var isEmptyDpImage = false
    var selectionChanged = false
    var isCancle = false
    var isChangeInVc = false
    
    var receivedFontName = String()
    var receivedCOlor = String()
    var receiveAudio = URL(string: "https://www.None.com")
    var selectedAudio = URL(string: "https://www.None.com")
    
    var contact = ContectID()
    var contacts = CallerIds()
    var arrcallerids = [CallerId]()
    var arrcalleridssss = [CallerId]()

    var isDefaultImage = Bool()
    var arrDuringImage = [UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
//        img_ResponseToCall.addBlurToViews()
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDataNotification(_:)), name: Notification.Name("selectedVoice"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDataNotificationFontsAndColor(_:)), name: Notification.Name("textFontAndColor"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDataNotificationpickedImage(_:)), name: Notification.Name("pickedImage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDataNotificationpickedImageWithCrop(_:)), name: Notification.Name("pickedImagWithCrop"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        btn_Save.isEnabled = true
        if selectionChanged {
            btn_Save.isEnabled = true
        }
        
       if txt_Name.text == "" {
            btn_Save.isEnabled = false
            print(btn_Save.isEnabled)
       } else {
           btn_Save.isEnabled = true
       }
    }
    
    // Tap ContectShow
    @IBAction func tap_ContectShow(_ sender: Any) {
        showContactsPicker()
    }
    
    // Tap Voice
    @IBAction func tap_Voice(_ sender: Any) {
        let navigate = storyboard?.instantiateViewController(withIdentifier: "VoiceVC") as! VoiceVC
        navigate.isAddNewID = isAddNewID
        navigate.lastselectedUrl = selectedAudio
        navigationController?.pushViewController(navigate, animated: true)

    }
    
    // Tap Save
    @IBAction func tap_Save(_ sender: Any) {
       
        
        Constants.USERDEFAULTS.set(true, forKey: "isAddNewID")

        if isAddNewID {
            if txt_Name.text == "" || txt_Name.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                Utils().showAlert("Please Fill in The Name")
            } else {
                if Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "primiumVC") as! primiumVC
                    vc.modalPresentationStyle = .fullScreen
                    present(vc, animated: true)
                } else {
                    saveNewCallerId()
                }
            }
        } else {
            
            if txt_Name.text == "" || txt_Name.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
                Utils().showAlert("Please Fill in The Name")
            } else {
                updatesCallerId()
            }
            
            
            if  img_ProfilePic.image == UIImage(named: "Empty Image") {
                Constants.USERDEFAULTS.set(false,forKey: "Empty Image")
                
                if  (Constants.USERDEFAULTS.integer(forKey: "DuringCallFirstTimeIndex") == 0) {
                    Constants.USERDEFAULTS.set(0,forKey: "DuringCallIndex")
                }
                
            } else {
                Constants.USERDEFAULTS.set(false,forKey: "Empty Image")
                Constants.USERDEFAULTS.set(0,forKey: "DuringCallIndex")
            }
            
            let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
            
            if let pngData = img_DuringCall.image!.jpegData(compressionQuality: 0.7) {
                let imageFilter = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)
                Constants.USERDEFAULTS.set(imageFilter,forKey: "DuringCall")
            }
            
            self.navigationController?.popViewController(animated: true)
            let userInfo: [AnyHashable: Any] = ["image": img_DuringCall.image!]
            NotificationCenter.default.post(name: Notification.Name("ImgDuringCall"), object: nil, userInfo: userInfo)
            
            
            if let homeVC = self.navigationController?.viewControllers.last as? HomeVC {
                // Successfully casted to HomeVC
                homeVC.imgCallDuration = img_DuringCall.image!
            } else {
                // Handle case where view controller is not of type HomeVC
                print("Last view controller is not HomeVC or navigation controller is nil.")
            }
        }
    }
    
    // Tap EditImage
    @IBAction func tap_EditImage(_ sender: Any) {
//
        showPhotoActionSheet()
    }
    
}

extension ContactDetailsVC {
    
    // Set UI
    func setUpUI() {
        lbl_DuringCallName.scrollDuration = 8.0
        lbl_ResponseCallName.scrollDuration = 8.0
        

        if Utils().isConnectedToNetwork() {
            bannerAds_View.adUnitID = Constants.BANNER
            bannerAds_View.adSize = GADAdSizeBanner
            bannerAds_View.rootViewController = self
            bannerAds_View.delegate = self
            bannerAds_View.load(GADRequest())
        }
        
        // Premium User To Hide Ads View
        // Premium User To Hide Ads View
        if Constants.USERDEFAULTS.value(forKey: "Premium") != nil {
            adsVIew_height.constant = 0
        } else {
            adsVIew_height.constant = 60
        }
        
        DispatchQueue.main.async { [self] in
            setNavigationBaar()
            lbl_SelectedVoice.text = "None"
            profileBg_View.layer.cornerRadius = 20
            profileBg_View.layer.masksToBounds = true
            voiceBg_View.layer.cornerRadius = 12
            voiceBg_View.layer.masksToBounds = true
            img_ResponseToCall.layer.cornerRadius = 6
            img_ResponseToCall.layer.masksToBounds = true
            img_DuringCall.layer.cornerRadius = 6
            img_DuringCall.layer.masksToBounds = true
            btn_Save.layer.cornerRadius = 12
            btn_Save.layer.masksToBounds = true
            btn_Save.isEnabled = false
            txt_Name.layer.cornerRadius = 6
            txt_Name.layer.masksToBounds = true
            txt_MoNumber.layer.cornerRadius = 6
            txt_MoNumber.layer.masksToBounds = true
            
            img_ProfilePic.layer.cornerRadius =  img_ProfilePic.bounds.height / 2
            img_ProfilePic.layer.masksToBounds = true
            img_ProfilePic.layer.borderWidth = 2
            img_ProfilePic.layer.borderColor = Utils().RGBColor(red: 82, green: 159, blue: 253).cgColor
            img_ProfilePic.image = contact.dpImage
//            lbl_ResponseCallName.semanticContentAttribute = .forceRightToLeft // Set semantic content attribute to force RTL
            
            camera_BgView.layer.cornerRadius =  camera_BgView.bounds.height / 2
            camera_BgView.layer.backgroundColor = UIColor.lightGray.cgColor
            camera_BgView.layer.masksToBounds = true
            camera_BgView.layer.borderWidth = 1.5
            camera_BgView.layer.borderColor = UIColor.white.cgColor
            camera_BgView.layer.masksToBounds = true
            
            txt_Name.delegate = self
            txt_MoNumber.delegate = self
            
            // Disiss Keybord
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tapGesture.cancelsTouchesInView = false // Allow touches to pass through to underlying views
            self.view.addGestureRecognizer(tapGesture)
            
            
            if isAddNewID {
               img_ProfilePic.image = UIImage(named: "Empty Image")
                isEmptyDpImage = true
                isEmptyDp = true
            } else {
                let index = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")

                IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
                    arrcallerids = Ids
                    isDefaultImage = arrcallerids[index].isDefault
                    isEmptyDp = arrcallerids[index].isEmptyDp
                    selectedAudio = arrcallerids[index].voiceUrl
                    }
                
                if isDefaultImage {
                    txt_Name.isUserInteractionEnabled = false
                    txt_MoNumber.isUserInteractionEnabled = false
                    camera_BgView.isUserInteractionEnabled = false
                    btn_ShowContact.isUserInteractionEnabled = false
                    btn_Voice.isUserInteractionEnabled = false
                    btn_EditDp.isUserInteractionEnabled = false
                    img_Arrow.isHidden = true
                } else {
                    txt_Name.isUserInteractionEnabled = true
                    txt_MoNumber.isUserInteractionEnabled = true
                    camera_BgView.isUserInteractionEnabled = true
                    btn_ShowContact.isUserInteractionEnabled = true
                    btn_Voice.isUserInteractionEnabled = true
                    btn_EditDp.isUserInteractionEnabled = true
                    img_Arrow.isHidden = false
                }
                
                txt_Name.text = contact.name
                txt_MoNumber.text = contact.number
                lbl_SelectedVoice.text = contact.voice
                lbl_DuringCallName.text = contact.name
                lbl_ResponseCallName.text = contact.name

                let cache = ImageCache.default
                var options: KingfisherOptionsInfo = []
                cache.memoryStorage.config.totalCostLimit = 500 * 1024 * 1024
                cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
                
                let size = CGSize(width: 700, height: 700)
                let processor = DownsamplingImageProcessor(size: size)
                options = [.processor(processor), .targetCache(cache)]
//
                
                if let imageDataBeforeCall = Constants.USERDEFAULTS.string(forKey: "DuringCall") {
                  
                    if let imageURL = URL(string: imageDataBeforeCall), imageURL.scheme == "https" {
                        let imageUrl = URL(string: imageDataBeforeCall)
                        img_DuringCall.kf.setImage(with: imageUrl, placeholder: UIImage(named: "img_place"), options: options)
                        img_ResponseToCall.kf.setImage(with: imageUrl, placeholder: UIImage(named: "img_place"), options: options)


                    } else {
                        let vidPath = CreateURL().documentsUrl().appendingPathComponent(imageDataBeforeCall)
                        let imageURL = URL(string: vidPath.absoluteString)
                        let provider = LocalFileImageDataProvider(fileURL: imageURL!)
                        img_DuringCall.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"), options: options)
                        img_ResponseToCall.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"), options: options)
                    }

                }
            }            
           
            let Name = UIView(frame: CGRect(x: 0, y: 0, width: Utils().IpadorIphone(value: 8), height: txt_Name.frame.height))
            txt_Name.leftView = Name
            txt_Name.leftViewMode = .always

            
            let Number = UIView(frame: CGRect(x: 0, y: 0, width: Utils().IpadorIphone(value: 8), height: txt_MoNumber.frame.height))
            txt_MoNumber.leftView = Number
            txt_MoNumber.leftViewMode = .always
            
            fetchCallerData()
            
            // Default Id Save Button Remove
            if isDefaultImage {
                btn_Save.isHidden = true
            } else {
                btn_Save.isHidden = false
            }
        }
    }
    
    // Set Navigation Bar
    func setNavigationBaar() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Caller Id"
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
 
    func showContactsPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        // You can set additional properties of the contact picker here, such as displaying specific types of contacts, or setting a predicate to filter contacts.

        // Present the contact picker
        present(contactPicker, animated: true, completion: nil)
    }
        
    // Dismiss Keyboard
    @objc func dismissKeyboard() {
        // Resign first responder status of active text field
        self.view.endEditing(true)
    }
    
    // Tap Back Button
    @objc func customButtonTapped() {
        if selectionChanged || isCancle || isChangeInVc {
            
            if isAddNewID {
                Utils().presentAlert(title: "Discard Save?", message: "Are you sure want to discard this changes?", cancelTitle: "Cancel", discardTitle:  "Discard") {
                    self.navigationController?.popViewController(animated: true)
                }

            } else {
                Utils().presentAlert(title: "Discard Changes?", message: "Are you sure want to discard this changes?", cancelTitle: "Cancel", discardTitle:  "Discard") {
                    self.navigationController?.popViewController(animated: true)
                }

            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
    // Extract name and phoneNumber from userInfo
    @objc func handleTextDataNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let voice = userInfo["selectedVoiceName"] as? String {
                lbl_SelectedVoice.text = voice
                
            }
            
            if let voiceUrl = userInfo["selectedVoice"] as? URL {
                 print(voiceUrl)
                receiveAudio = voiceUrl
                selectedAudio = voiceUrl
                Constants.USERDEFAULTS.set(voiceUrl, forKey: "selectedVoiceFromUpdate")
            }
            
            if let selectionChanged = userInfo["selectionChanged"] as? Bool {
                self.selectionChanged = selectionChanged
            }
        }
    }
    
    // Get FontName And Font Color
    @objc func handleTextDataNotificationFontsAndColor(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
               // Retrieve FontName from userInfo
               if let fontName = userInfo["FontName"] as? String {
                   // Use fontName as needed
                   receivedFontName = fontName
                   lbl_DuringCallName.font = UIFont.init(name:receivedFontName , size: 17)
                   lbl_ResponseCallName.font = UIFont.init(name:receivedFontName , size: 17)
                   Constants.USERDEFAULTS.set(fontName, forKey: "fontNameFromUpdate")

               }

               // Retrieve FontColor from userInfo
               if let fontColorHexString = userInfo["FontColor"] as? String {
                   receivedCOlor = fontColorHexString
                   lbl_DuringCallName.textColor = Utils().hexStringToUIColor(hex: receivedCOlor)
                   lbl_ResponseCallName.textColor = Utils().hexStringToUIColor(hex: receivedCOlor)
                   Constants.USERDEFAULTS.set(fontColorHexString, forKey: "fontColorFromUpdate")
               }
           }
    }

    // get Image
    @objc func handleTextDataNotificationpickedImage(_ notification: Notification) {
        isChangeInVc = true

        if let userInfo = notification.userInfo as? [String: Any] {
            // Retrieve FontName from userInfo
            
                let cache = ImageCache.default
                var options: KingfisherOptionsInfo = []
                cache.memoryStorage.config.totalCostLimit = 500 * 1024 * 1024
                cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
                
                let size = CGSize(width: 500, height: 500)
                let processor = DownsamplingImageProcessor(size: size)
                options = [.processor(processor), .targetCache(cache)]
                isEmptyDp = false
                 isEmptyDpImage = false

            if let pickedImage = userInfo["pickedImage"] as? String {
                let imageURL = URL(string:pickedImage)
                _ = LocalFileImageDataProvider(fileURL: imageURL!)
                var imageUrl = URL(string: "")
                if let imageURL = URL(string: pickedImage), imageURL.scheme == "https" {
                    imageUrl = URL(string: pickedImage)
                    img_DuringCall.kf.setImage(with: imageUrl, placeholder: UIImage(named: "img_place"), options: options)
                    img_ResponseToCall.kf.setImage(with: imageUrl, placeholder: UIImage(named: "img_place"), options: options)
                    
                    img_DuringCall.downloadImage(url: "\(imageURL)", placeHolder: nil) { [weak self] error in
                        guard self != nil else { return }
                        if let error = error {
                            print("Failed to download image: \(error)")
                        }
                    }
                    
                    img_ResponseToCall.downloadImage(url: "\(imageURL)", placeHolder: nil) { [weak self] error in
                        guard self != nil else { return }
                        if let error = error {
                            print("Failed to download image: \(error)")
                        }
                    }

                } else {
                    let vidPath = CreateURL().documentsUrl().appendingPathComponent(pickedImage)
                    let imageURL = URL(string: vidPath.absoluteString)
                    let Url = LocalFileImageDataProvider(fileURL: imageURL!)
                    
                    img_DuringCall.kf.setImage(with: Url, placeholder: UIImage(named: "img_place"), options: options)
                    img_ResponseToCall.kf.setImage(with: Url, placeholder: UIImage(named: "img_place"), options: options)

                }



            }
            
            if let btn_SaveEnabled = userInfo["btn_SaveEnabled"] as? Bool {
                // Access the btn_SaveEnabled flag
                
                btn_Save.isEnabled = btn_SaveEnabled
            }
        }

    }
    
    @objc func handleTextDataNotificationpickedImageWithCrop(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            // Retrieve FontName from userInfo
            if let pickedImage = userInfo["pickedImage"] as? String {
                    let vidPath = CreateURL().documentsUrl().appendingPathComponent(pickedImage)
                    let imageURL = URL(string: vidPath.absoluteString)
                    let provider = LocalFileImageDataProvider(fileURL: imageURL!)
                    img_ProfilePic.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"))
            }
            
            if let btn_SaveEnabled = userInfo["btn_SaveEnabled"] as? Bool {
                // Access the btn_SaveEnabled flag
                btn_Save.isEnabled = btn_SaveEnabled
                let isNameEmpty = txt_Name.text?.isEmpty ?? true
                let isMoNumberEmpty = txt_MoNumber.text?.isEmpty ?? true
                
                // Disable the save button if both text fields are empty
                btn_Save.isEnabled = !(isNameEmpty && isMoNumberEmpty)
                print(btn_Save.isEnabled)

            }
            isEmptyDp = false
            isEmptyDpImage = false
            self.dismiss(animated: true)
        }
    }
    
    // Fetch caller Id IN DataBase
    func fetchCallerData() {
        
        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
            self.arrcallerids = Ids
            let index = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
            if isAddNewID {
            } else {
                lbl_DuringCallName.font = UIFont.init(name:arrcallerids[index].fonts! , size: 17)
                lbl_ResponseCallName.font = UIFont.init(name:arrcallerids[index].fonts! , size: 17)
                lbl_DuringCallName.textColor = Utils().hexStringToUIColor(hex: arrcallerids[index].fontColor!)
                lbl_ResponseCallName.textColor = Utils().hexStringToUIColor(hex: arrcallerids[index].fontColor!)
                
                Constants.USERDEFAULTS.set(arrcallerids[index].fontColor!, forKey: "fontColorFromUpdate")
                Constants.USERDEFAULTS.set(arrcallerids[index].fonts!, forKey: "fontNameFromUpdate")
                Constants.USERDEFAULTS.set(arrcallerids[index].voiceUrl!, forKey: "selectedVoiceFromUpdate")

            }
        }
    }
    
    // Function to display the action sheet
    func showPhotoActionSheet() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Choose Photo action
        let choosePhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
            // Handle choose photo action
            //
            let naviget = self.storyboard?.instantiateViewController(withIdentifier: "ContactGellaryVC") as! ContactGellaryVC
            self.present(naviget, animated: true)
        }
        alertController.addAction(choosePhotoAction)
        
        // Edit Photo action
        if txt_Name.text != "" {
            let editPhotoAction = UIAlertAction(title: "Edit Text", style: .default) { _ in
            // Handle edit photo action
            if self.txt_Name.text == "" {
                let alertController = UIAlertController(title:"", message: "Please Fill in the Name Input First.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    print("OK tapped")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                
                let naviget = self.storyboard?.instantiateViewController(withIdentifier: "TextEditVC") as! TextEditVC
                naviget.Name = self.txt_Name.text!
                naviget.FontColor = self.lbl_DuringCallName.textColor!
                
                naviget.wallpaper = self.img_DuringCall.image!
                self.navigationController?.pushViewController(naviget, animated: true)
            }
        }
        alertController.addAction(editPhotoAction)
    }
        
        // Remove Photo action
        if !isEmptyDp {
            let removePhotoAction = UIAlertAction(title: "Remove Photo", style: .destructive) { [self] _ in
                
                if img_ProfilePic.image != UIImage(named: "Empty Image") {
                    if !isAddNewID {
                        let indexs = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
                        img_ProfilePic.image = UIImage(named: "Empty Image")
                        let timestamp = arrcallerids[indexs].timestamp
                        contacts.timestamp = timestamp!
                        contacts.isEmptyDp = true
                        if img_ProfilePic.image != nil {
                            let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
                            if let jpegData = img_ProfilePic.image!.jpegData(compressionQuality: 0.7) {
                                let imageFilter = CreateURL().saveFile(data: jpegData as Data, fileName: filterUrl)
                                contacts.dpImage = imageFilter!
                            }
                        }
                        
                        let update = updateDpImage(context: context, CallerId: contacts)
                        if update {
                            print("Yes")
                        }
                        
                        
                        img_DuringCall.image = UIImage(named: "Wallpaper")!
                        img_ResponseToCall.image = UIImage(named: "Wallpaper")!

                        if let savedImageDataArray = UserDefaults.standard.array(forKey: "savedImagesDuration") as? [Data] {
                            // Convert array of Data back to array of UIImage
                            let savedImages = savedImageDataArray.compactMap { UIImage(data: $0) }
                            arrDuringImage = savedImages
                        }
                        
                        isEmptyDpImage = true
                        isEmptyDp = true

                        let a = arrDuringImage[0]
                        print(a)
                        
                        //            let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
                        //            if let jpegData = img_ProfilePic.image!.jpegData(compressionQuality: 0.7) {
                        //                let imageFilter = CreateURL().saveFile(data: jpegData as Data, fileName: filterUrl)
                        //                contacts.dpImage = imageFilter!
                        //            }
                        
                        arrDuringImage[0] = UIImage(named: "Wallpaper")!
                        
                        let imageDataArray = arrDuringImage.compactMap { Utils().imageData(from: $0) }
                        
                        UserDefaults.standard.set(imageDataArray, forKey: "savedImagesDuration")
                        
                        
                        let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
                        if let pngData = UIImage(named: "Wallpaper")!.jpegData(compressionQuality: 0.5) {
                            let imageFilter = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)
                            Constants.USERDEFAULTS.set(imageFilter,forKey: "DuringCall")
                        }
                        
                    } else {
                        DispatchQueue.main.async { [self] in
                            img_ProfilePic.image = UIImage(named: "Empty Image")
                            img_DuringCall.image = UIImage(named: "Wallpaper")!
                            img_ResponseToCall.image = UIImage(named: "Wallpaper")!
                            isEmptyDpImage = true
                            isEmptyDp = true
                        }

                    }
                }
                else {
                    DispatchQueue.main.async { [self] in
                        img_ProfilePic.image = UIImage(named: "Empty Image")
                        img_DuringCall.image = UIImage(named: "Wallpaper")!
                        img_ResponseToCall.image = UIImage(named: "Wallpaper")!
                    }
                }
                
            }
            alertController.addAction(removePhotoAction)
        }
        
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // Present the action sheet
        present(alertController, animated: true, completion: nil)
        
        if let popoverController = alertController.popoverPresentationController {
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
        
    }
    
    // Add New Caqller Id
    func saveNewCallerId() {
        let userInfo: [AnyHashable: Any] = ["name": txt_Name.text ?? "", "Voice": lbl_SelectedVoice.text ?? "","number": txt_MoNumber.text ?? "","Dp":img_ProfilePic.image ?? ""]
        NotificationCenter.default.post(name: Notification.Name("NewContactDetails"), object: nil, userInfo: userInfo)
        
        if let name = txt_Name.text {
            contacts.name = name
        } else {
            contacts.name = ""
        }
        
        if let voice = lbl_SelectedVoice.text {
            contacts.voice = voice
        } else {
            contacts.voice = "''"
        }
        
        if img_ProfilePic.image != nil {
            let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
            if let jpegData = img_ProfilePic.image!.jpegData(compressionQuality: 0.7) {
                let imageFilter = CreateURL().saveFile(data: jpegData as Data, fileName: filterUrl)
                contacts.dpImage = imageFilter!
            }
        }
        
        if let number = txt_MoNumber.text {
            contacts.number = number
        } else {
            contacts.number = ""
        }
        
        if !receivedFontName.isEmpty {
            contacts.fonts = receivedFontName
        } else {
            contacts.fonts = ""
        }
        
        
        if receivedCOlor != "" {
            contacts.fontColor = receivedCOlor
        } else {
            contacts.fontColor = "#FFFFFF"
        }
        
        
        if receiveAudio != nil {
            contacts.VoiceUrl = receiveAudio
        } else {
            contacts.VoiceUrl = URL(string: "https://www.None.com")
        }
        
        if isEmptyDpImage {
            contacts.isEmptyDp = true
        } else {
            contacts.isEmptyDp = false

        }

        let addImage = IMAGEDATA().SaveData(context: self.context, CallerIds: contacts)
        if addImage {
            print("yess")
        } else {
            print("Noooo")
        }
        
        Constants.USERDEFAULTS.set(0, forKey: "selectedCallerIdIndex")
        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
            self.arrcallerids = Ids
            let lastIndex = arrcallerids.endIndex
            let valueAtIndex = arrcallerids.remove(at: lastIndex - 1)
            arrcallerids.insert(valueAtIndex, at: 0)

            
            for i in 0..<arrcallerids.count {
                contacts.name = arrcallerids[i].name!
                contacts.voice = arrcallerids[i].voice!
                contacts.number = arrcallerids[i].number!
                contacts.dpImage = arrcallerids[i].dpimage!
                contacts.fontColor = arrcallerids[i].fontColor!
                contacts.fonts = arrcallerids[i].fonts!
                contacts.isDefault = arrcallerids[i].isDefault
                contacts.isEmptyDp = arrcallerids[i].isEmptyDp

                if arrcallerids[i].voiceUrl != nil {
                    contacts.VoiceUrl = arrcallerids[i].voiceUrl
                } else {
                    contacts.VoiceUrl = URL(string: "none")
                }
//
                contacts.timestamp = "\(Date().currentTimeMillis())"

                let Delete = IMAGEDATA().deleteImage(context: self.context, selectedProduct: arrcallerids[i])
                if Delete {
                    print("Yes Save")
                } else {
                    print("Noooo Save")
                }

                let save = IMAGEDATA().SaveData(context: self.context, CallerIds: contacts)
                if save {
                    print("Yes Save")
                } else {
                    print("Noooo Save")
                }
            }
        }
            
        
        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
            self.arrcallerids = Ids
        }
        let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
        
        if let image = img_DuringCall.image, let pngData = image.jpegData(compressionQuality: 0.7) {
            let imageFilter = CreateURL().saveFile(data: pngData, fileName: filterUrl)
            Constants.USERDEFAULTS.set(imageFilter, forKey: "DuringCall")
            // Constants.USERDEFAULTS.set(0, forKey: "DuringCallIndex")
        } else {
            // Handle the case where img_DuringCall.image is nil
            print("Error: img_DuringCall.image is nil")
        }
        
        if let savedImageDataArray = UserDefaults.standard.array(forKey: "savedImagesDuration") as? [Data] {
            // Convert array of Data back to array of UIImage
            let savedImages = savedImageDataArray.compactMap { UIImage(data: $0) }
            arrDuringImage = savedImages
        }
        
        arrDuringImage.insert((img_DuringCall.image ?? UIImage(named: "Wallpaper"))!, at: 0)
        let imageDataArray = arrDuringImage.compactMap { Utils().imageData(from: $0) }
        
        // Save the array of Data to UserDefaults
        UserDefaults.standard.set(imageDataArray, forKey: "savedImagesDuration")
        
//        Utils().setupHome()
        
        let viewControllers: [UIViewController] = navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is HomeVC {
                navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    
    // Updates Caller Id
    func updatesCallerId() {
        
        if let name = txt_Name.text {
            contacts.name = name
        } else {
            contacts.name = ""
        }
        
        if let voice = lbl_SelectedVoice.text {
            contacts.voice = voice
        } else {
            contacts.voice = "None"
        }
        
        if let image = img_ProfilePic.image {
            let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
            if let jpegData = image.jpegData(compressionQuality: 0.7) {
                let imageFilter = CreateURL().saveFile(data: jpegData as Data, fileName: filterUrl)
                contacts.dpImage = imageFilter!
            }
            
        }
        
        if let number = txt_MoNumber.text {
            contacts.number = number
        } else {
            contacts.number = ""
        }
        
        if let fontName = Constants.USERDEFAULTS.string(forKey: "fontNameFromUpdate") {
            receivedFontName = fontName
        } else {
            // Handle the case where the key doesn't exist or the value is nil
            receivedFontName = "" // You can set a default font name here
        }

        if !receivedFontName.isEmpty {
            contacts.fonts = receivedFontName
        } else {
            contacts.fonts = ""
        }
        
        if let fontColor = Constants.USERDEFAULTS.string(forKey: "fontColorFromUpdate") {
            receivedCOlor = fontColor
        } else {
            // Handle the case where the key doesn't exist or the value is nil
            receivedCOlor = "#FFFFFF" // You can set a default font name here
        }

        if !receivedCOlor.isEmpty {
            contacts.fontColor = receivedCOlor
        } else {
            contacts.fontColor = "#FFFFFF"
        }
        
        
        if let selectedVoice = Constants.USERDEFAULTS.url(forKey: "selectedVoiceFromUpdate") {
            receiveAudio = selectedVoice
        } else {
            // Handle the case where the key doesn't exist or the value is nil
            receiveAudio = URL(string: "https://www.None.com")
        }
        
        
        if receiveAudio != nil {
            contacts.VoiceUrl = receiveAudio
        } else {
            contacts.VoiceUrl = receiveAudio
        }
        
        if isEmptyDpImage {
            contacts.isEmptyDp = true
        } else {
            contacts.isEmptyDp = false

        }
        
        let indexs = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
        let timestamp = arrcallerids[indexs].timestamp
        contacts.timestamp = timestamp!
        
        let update = IMAGEDATA().updateData(context: self.context, CallerId: contacts)
        if update {
            print("Yes")
        }
        
            if let savedImageDataArray = UserDefaults.standard.array(forKey: "savedImagesDuration") as? [Data] {
                // Convert array of Data back to array of UIImage
                let savedImages = savedImageDataArray.compactMap { UIImage(data: $0) }
                arrDuringImage = savedImages
            }
        
            arrDuringImage[0] = img_DuringCall.image!
            let imageDataArray = arrDuringImage.compactMap { Utils().imageData(from: $0) }
            
            // Save the array of Data to UserDefaults
            UserDefaults.standard.set(imageDataArray, forKey: "savedImagesDuration")
            
        }

    // Updates Dp Image From DataBase
    func updateDpImage(context: NSManagedObjectContext, CallerId: CallerIds?) -> Bool {
        let timestamp = CallerId!.timestamp
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CallerId")
        fetchRequest.predicate = NSPredicate(format: "timestamp = %@", timestamp)

        do {
            if let result = try context.fetch(fetchRequest) as? [NSManagedObject], let data = result.first {
                // Update only the dpimage attribute
                data.setValue(CallerId?.dpImage, forKey: "dpimage")
                data.setValue(CallerId?.isEmptyDp, forKey: "isEmptyDp")

                // Save the context
                try context.save()
                return true
            } else {
                return false
            }
        } catch {
            print("Error updating CallerId entity: \(error)")
            return false
        }
    }
        
}

// TextField Delegates
extension ContactDetailsVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Ensure text field is processed on the main queue
        isChangeInVc = true
        if textField.text == "" {
            if (string == " ") {
                return false
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if textField == self.txt_Name {
                // Calculate updated text
                let currentText = textField.text ?? ""
                guard let textRange = Range(range, in: currentText) else {
                    if self.txt_Name.text != "" {
                        self.lbl_ResponseCallName.text = self.txt_Name.text
                        self.lbl_DuringCallName.text = self.txt_Name.text

                    } else {
                        self.lbl_ResponseCallName.text = "NAME"
                        self.lbl_DuringCallName.text = "NAME"

                    }
                    return
                }

                let updatedText = currentText.replacingCharacters(in: textRange, with: string)
                
                // Update labels based on updated text
                if updatedText.isEmpty {
                    self.lbl_ResponseCallName.text = "NAME"
                    self.lbl_DuringCallName.text = "NAME"
                } else {
                    self.lbl_ResponseCallName.text = updatedText
                    self.lbl_DuringCallName.text = updatedText
                }
                
                // Update stored text for later use
                self.text1 = updatedText
                
                // Check if name text is empty to enable/disable save button
//                self.updateSaveButtonState()
            }
            
            if textField ==  self.txt_MoNumber {
                
                // Calculate updated text
                let currentText = textField.text ?? ""
                guard let textRange = Range(range, in: currentText) else {
                    self.txt_MoNumber.text = ""
                    return }
                let updatedText = currentText.replacingCharacters(in: textRange, with: string)
                self.text2 = updatedText
            }
            
            self.updateSaveButtonState()

            
            // Handle other text fields if needed (e.g., txt_MoNumber)
        }
        // Always return true to allow the text change

        return true
    }

    func updateSaveButtonState() {
        let trimmedText = text1.trimmingCharacters(in: .whitespacesAndNewlines)
        let numberText = text2.trimmingCharacters(in: .whitespacesAndNewlines)

        let isNameEmpty = trimmedText.isEmpty
        let isMoNumberEmpty = numberText.isEmpty

        btn_Save.isEnabled = !isNameEmpty || !isMoNumberEmpty
    }

    func textFieldDidChange(_ textField: UITextField) {
            // Check if both text fields have text
           
        }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           // Dismiss the keyboard
           textField.resignFirstResponder()
           return true
       }
    
}

// CN Contact PickerDelegate
extension ContactDetailsVC: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        // Handle the selected contact here
        let firstName = contact.givenName
        let lastName = contact.familyName
        let fullName = "\(firstName) \(lastName)"
        
        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
        
        txt_Name.text = fullName
        txt_MoNumber.text = phoneNumber
        
        lbl_DuringCallName.text = fullName
        lbl_ResponseCallName.text = fullName
        
        if txt_Name.text == "" || txt_Name.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            btn_Save.isEnabled = false
        } else {
            btn_Save.isEnabled = true
        }
        
        isChangeInVc = true

        
        if let imageData = contact.thumbnailImageData {
            let contactImage = UIImage(data: imageData)
            // Assign the contact image to your desired UIImageView
            img_ProfilePic.image = contactImage
            img_ResponseToCall.image = contactImage
            img_DuringCall.image = contactImage
            isEmptyDp = false
             isEmptyDpImage = false
        } else {
            isEmptyDp = true
             isEmptyDpImage = true
            // Use a default image if no contact image is available
            img_ProfilePic.image = UIImage(named: "Empty Image")
//            Constants.USERDEFAULTS.set(true,forKey: "Empty Image")
//
//            Constants.USERDEFAULTS.set(-1,forKey: "DuringCallIndex")
            Constants.USERDEFAULTS.set(0, forKey: "DuringCallFirstTimeIndex")

            if   img_ProfilePic.image == UIImage(named: "Empty Image") && (Constants.USERDEFAULTS.integer(forKey: "DuringCallFirstTimeIndex") == 0) {
                let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
//                dpImage = defaultDuringCallImage!
                if let pngData = defaultDuringCallImage!.jpegData(compressionQuality: 0.7) {
                        let imageFilter = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)
                        Constants.USERDEFAULTS.set(imageFilter,forKey: "DuringCall")
                    }
            }
            
            if let imageDataBeforeCall = Constants.USERDEFAULTS.string(forKey: "DuringCall") {
              
                let vidPath = CreateURL().documentsUrl().appendingPathComponent(imageDataBeforeCall)
                let imageURL = URL(string: vidPath.absoluteString)
                let provider = LocalFileImageDataProvider(fileURL: imageURL!)
                img_DuringCall.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"))
                img_ResponseToCall.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"))
            }
            
            img_ProfilePic.layer.backgroundColor = UIColor.systemGray.cgColor
            
        }
    
        // You can extract other information from the selected contact as needed
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        // Handle cancellation if needed
        
    }
}


extension UIViewController {
    
    var context: NSManagedObjectContext {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        
        // Perform access to managed object context on the main queue
        return appDelegate.persistentContainer.viewContext
    }
    
}
