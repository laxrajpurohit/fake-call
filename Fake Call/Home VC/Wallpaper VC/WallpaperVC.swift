//
//  WallpaperVC.swift
//  Fake Call
//
//  Created by mac on 08/04/24.
//

import UIKit
import Kingfisher
class WallpaperVC: UIViewController {

    @IBOutlet weak var img_BeforeCall_WallPaper: UIImageView!
    @IBOutlet weak var img_DuringCall_WallPaper: UIImageView!
    @IBOutlet weak var img_AfterCall_WallPaper: UIImageView!
    
    @IBOutlet weak var bg_BeforeCall_View: UIView!
    @IBOutlet weak var bg_DuringCall_View: UIView!
    @IBOutlet weak var bg_AfterCall_View: UIView!
    @IBOutlet weak var bg_ReturnHome_View: UIView!
    
    @IBOutlet weak var img_BeforeAppIcon: UIImageView!
    
    @IBOutlet weak var switch_GoHomePage: UISwitch!
    var index = -1
    var Dpimage = UIImage()
    var afterImage = UIImage()
    var beforeImage = UIImage()
    var isDefaultImage = Bool()
    var arrcallerids = [CallerId]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Wallpaper"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black] // Change the color here if different
        navigationController?.navigationBar.titleTextAttributes = textAttributes

        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Wallpaper"
        getWallPaperImage()
    }

    // Tap Before Call Button
    @IBAction func tap_BeforCall(_ sender: Any) {
        
        let navigate = storyboard?.instantiateViewController(withIdentifier: "ChooseWallpaperVC") as! ChooseWallpaperVC
        navigate.Index = 0
        navigate.beforeImage = img_BeforeCall_WallPaper.image ?? UIImage(named: "defaultImage")!
        index = 0
//        navigate.isFromWallpaperVc = true
        navigationController?.pushViewController(navigate, animated: true)
        
    }
    
    // Tap During Call Button=
    @IBAction func tap_DuringCall(_ sender: Any) {
        let indext = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")

        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
            arrcallerids = Ids
            isDefaultImage = arrcallerids[indext].isDefault
            }
        
        if isDefaultImage {
            
            showAlert()
        } else {
            let navigate = storyboard?.instantiateViewController(withIdentifier: "ChooseWallpaperVC") as! ChooseWallpaperVC
            navigate.Index = 1
            navigate.DpImage = img_DuringCall_WallPaper.image!
            index = 1
            navigationController?.pushViewController(navigate, animated: true)

        }
        
        
    }
    
    // Tap After Call Button
    @IBAction func tap_AfterCall(_ sender: Any) {
        let navigate = storyboard?.instantiateViewController(withIdentifier: "ChooseWallpaperVC") as! ChooseWallpaperVC
        navigate.Index = 2
        navigate.afterImage = img_AfterCall_WallPaper.image!

        index = 2
        navigationController?.pushViewController(navigate, animated: true)

        
    }
    
    // Tap Direct Home Page
    @IBAction func switch_DirectHomePage(_ sender: UISwitch) {
        
        Constants.USERDEFAULTS.set(sender.isOn, forKey: "DirectHomePage")
        print(sender.isOn)
    }
    
}

extension WallpaperVC {
    
    // Set Up UI
    func setUI() {
        img_BeforeCall_WallPaper.layer.cornerRadius = 16
        img_DuringCall_WallPaper.layer.cornerRadius = 16
        img_AfterCall_WallPaper.layer.cornerRadius = 16
        
        bg_BeforeCall_View.layer.cornerRadius = 16
        bg_DuringCall_View.layer.cornerRadius = 16
        bg_AfterCall_View.layer.cornerRadius = 16
        
        bg_ReturnHome_View.layer.cornerRadius = 16


        img_BeforeCall_WallPaper.layer.masksToBounds = true
        img_DuringCall_WallPaper.layer.masksToBounds = true
        img_AfterCall_WallPaper.layer.masksToBounds = true
        
        bg_BeforeCall_View.layer.masksToBounds = true
        bg_DuringCall_View.layer.masksToBounds = true
        bg_AfterCall_View.layer.masksToBounds = true

        bg_ReturnHome_View.layer.masksToBounds = true

        let gotoDirectHome = Constants.USERDEFAULTS.bool(forKey: "DirectHomePage")
        switch_GoHomePage.isOn = gotoDirectHome
        
    }
    
    // getWall Paper Image From UserDefault
    func getWallPaperImage() {
        
            let cache = ImageCache.default
            var options: KingfisherOptionsInfo = []
            cache.memoryStorage.config.totalCostLimit = 500 * 1024 * 1024
            cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
            
            let size = CGSize(width: 300, height: 300)
            let processor = DownsamplingImageProcessor(size: size)
            options = [.processor(processor), .targetCache(cache)]

        
            if let imageDataBeforeCall = Constants.USERDEFAULTS.string(forKey: "BeforeCall") {
                if imageDataBeforeCall == "https://apptrendz.com/API/fake_call/images/ios_wallpaper/ios_Wallpaper-1.png" {
                    img_BeforeAppIcon.isHidden = true
                } else {
                    img_BeforeAppIcon.isHidden = false
                }
                
                _ = URL(string: "")
                if let imageURL = URL(string: imageDataBeforeCall), imageURL.scheme == "https" {
//                    img_BeforeCall_WallPaper.kf.setImage(with: imageURL, placeholder: UIImage(named: "img_place"), options: options)
                    
                    img_BeforeCall_WallPaper.downloadImage(url: imageDataBeforeCall, placeHolder: nil) { [weak self] error in
                        guard self != nil else { return }
               
                        if let error = error {
                            print("Failed to download image: \(error)")
                        }
                    }

                } else {
                    let vidPath = CreateURL().documentsUrl().appendingPathComponent(imageDataBeforeCall)
                    let imageURL = URL(string: vidPath.absoluteString)
                    let Url = LocalFileImageDataProvider(fileURL: imageURL!)
                    img_BeforeCall_WallPaper.kf.setImage(with: Url, placeholder: UIImage(named: "img_place"), options: options)

                }

//                if Constants.USERDEFAULTS.string(forKey: "SaveBlackWallPaper") == imageDataBeforeCall {
//                    img_BeforeAppIcon.isHidden = true
//                } else {
//                    img_BeforeAppIcon.isHidden = false
//                }
                

                
            } else {
                img_BeforeCall_WallPaper.image = UIImage(named: "Wallpaper")
            }
        
        
            // Retrieve image data from UserDefaults for "DuringCall"
            if let imageDataDuringCall = Constants.USERDEFAULTS.string(forKey: "DuringCall") {
                if let imageURL = URL(string: imageDataDuringCall), imageURL.scheme == "https" {
//                    img_DuringCall_WallPaper.kf.setImage(with: imageUrl, placeholder: UIImage(named: "img_place"), options: options)
                    img_DuringCall_WallPaper.downloadImage(url: imageDataDuringCall, placeHolder: nil) { [weak self] error in
                        guard self != nil else { return }
               
                        if let error = error {
                            print("Failed to download image: \(error)")
                        }
                    }

                } else {
                    let vidPath = self.documentsUrl().appendingPathComponent(imageDataDuringCall)
                    let imageURL = URL(string: vidPath.absoluteString)
                    let Url = LocalFileImageDataProvider(fileURL: imageURL!)
                    img_DuringCall_WallPaper.kf.setImage(with: Url, placeholder: UIImage(named: "img_place"), options: options)
                }

            } else {
                img_DuringCall_WallPaper.image = UIImage(named: "Wallpaper")
                
            }
            
            // Retrieve image data from UserDefaults for "AfterCall"
            if let imageDataAfterCall = Constants.USERDEFAULTS.string(forKey: "AfterCall") {
                _ = URL(string: "")
                if let imageURL = URL(string: imageDataAfterCall), imageURL.scheme == "https" {
                    
                    img_AfterCall_WallPaper.downloadImage(url: imageDataAfterCall, placeHolder: nil) { [weak self] error in
                        guard self != nil else { return }
               
                        if let error = error {
                            print("Failed to download image: \(error)")
                        }
                    }
                } else {
                    let vidPath = self.documentsUrl().appendingPathComponent(imageDataAfterCall)
                    let imageURL = URL(string: vidPath.absoluteString)
                    let Url = LocalFileImageDataProvider(fileURL: imageURL!)
                    img_AfterCall_WallPaper.kf.setImage(with: Url, placeholder: UIImage(named: "img_place"), options: options)

                }
            } else {
                img_AfterCall_WallPaper.image = UIImage(named: "Wallpaper")
                
            }
        
    }
    
    // documents Url
    func documentsUrl() -> URL {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsUrl
    }

    // show Alert
    func showAlert() {
            // Create an alert controller
            let alertController = UIAlertController(title: "", message: "You cannot change the During Call Wallpaper of the default caller ID.", preferredStyle: .alert)
            
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
}
