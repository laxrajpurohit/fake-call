//
//  ChooseWallpaperVC.swift
//  Fake Call
//
//  Created by mac on 08/04/24.
//

import UIKit
import Kingfisher
import ProgressHUD

class ChooseWallpaperVC: UIViewController {

    @IBOutlet weak var clv_WallPaper: UICollectionView!
    @IBOutlet weak var clv_Height: NSLayoutConstraint!
    
    @IBOutlet weak var chooseFromBg_View: UIView!
    
    var wallpaperArray: [String] = []
    var selectedIndex = -1
    var Index = -1
    var downloadCounter = 0

    var savedFileName = [String]()
    var DpImage = UIImage()
    var afterImage = UIImage()
    var beforeImage = UIImage()
    var wallpaperCollection: WallpaperCollection?
    var isHandleBlackImage = false
    var selectionChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()
        SetUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        switch Index {

        case 0:
                Constants.USERDEFAULTS.set(0,forKey: "BeforeCallIndex")
        case 1:
                Constants.USERDEFAULTS.set(0,forKey: "DuringCallIndex")
        case 2:
                Constants.USERDEFAULTS.set(0,forKey: "AfterCallIndex")

        default:break;
        }
        
        if selectionChanged, Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
            AdMob.sharedInstance()?.loadInste()
        }
    }

    @IBAction func tap_ChooseFromGallery(_ sender: Any) {
        if Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
            let primiumVCvc = self.storyboard?.instantiateViewController(withIdentifier: "primiumVC") as! primiumVC
            primiumVCvc.modalPresentationStyle = .fullScreen
            present(primiumVCvc, animated: true)

        } else {
            openImagePicker()
        }

    }
    
}

extension ChooseWallpaperVC {
    
    // Set Up UI
    func SetUI() {
        fetchData(for: "ios_wallpaper")

        setUpCollection()

        let index =  Constants.USERDEFAULTS.integer(forKey: "HandleblackImage")
        if index == 1 {
            isHandleBlackImage = true
        }
        
    }
    
    // MARK: - set collection
    func setUpCollection() {
        DispatchQueue.main.async { [self] in
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            if UIDevice.current.userInterfaceIdiom == .pad {
                
                let width: CGFloat = self.clv_WallPaper.bounds.width / 4
                let  height: CGFloat = self.clv_WallPaper.bounds.height - 40
                let size = CGSize(width: width, height: height)
                layout.itemSize = size
                self.clv_WallPaper.collectionViewLayout = layout
                self.clv_WallPaper.reloadData()
            } else {
                
                let width: CGFloat = self.clv_WallPaper.bounds.width / 3
                let  height: CGFloat = self.clv_WallPaper.bounds.height - 40
                let size = CGSize(width: width, height: height)
                layout.itemSize = size
                self.clv_WallPaper.collectionViewLayout = layout
                self.clv_WallPaper.reloadData()
            }

          
        }
    }
    
    // Open Image Picker
    func openImagePicker() {
          let imagePicker = UIImagePickerController()
          imagePicker.delegate = self
          imagePicker.sourceType = .photoLibrary
          imagePicker.allowsEditing = false
          present(imagePicker, animated: true, completion: nil)
      }
    
    // Call Api Wallpaper
    func fetchData(for category: String) {
        guard let url = URL(string: "https://apptrendz.com/API/fake_call/wallpaper.json") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let jsonData = data else {
                print("No data received")
                return
            }
            
            // Parse JSON data
            do {
                let decodedData = try JSONDecoder().decode(WallpaperCollection.self, from: jsonData)
                self.wallpaperCollection = decodedData
                
                // Reload collection view on the main thread
                DispatchQueue.main.async {
                    self.clv_WallPaper.reloadData()
                }
                
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }


}

// MARK: - Collection Methods
extension ChooseWallpaperVC:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return wallpaperCollection?.iosWallpaper.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clv_WallPaper_Cell", for: indexPath) as! clv_WallPaper_Cell
        
        DispatchQueue.main.async { [self] in
            clv_Height.constant = clv_WallPaper.contentSize.height
        }
        
        cell.img_WallPaper.layer.cornerRadius = 8
        cell.img_WallPaper.layer.masksToBounds = true
        
        var lastSelectedIndex = 0
        
        let imageUrlString = wallpaperCollection?.iosWallpaper[indexPath.row]
        _ = URL(string: imageUrlString!)
            let cache = ImageCache.default
            var options: KingfisherOptionsInfo = []
            cache.memoryStorage.config.totalCostLimit = 500 * 1024 * 1024
            cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
            
            let size = CGSize(width: 500, height: 500)
            let processor = DownsamplingImageProcessor(size: size)
            options = [.processor(processor), .targetCache(cache)]

        
        switch Index {
            
        case 0:

            if indexPath.row == 0 {
                
                cell.img_WallPaper.image = beforeImage
//                cell.img_AppIcon.isHidden = false

                if isHandleBlackImage {
                    cell.img_AppIcon.isHidden = true

                } else {
                    cell.img_AppIcon.isHidden = false

                }
                
//
            } else {
                cell.img_AppIcon.isHidden = false
                
                cell.img_WallPaper.downloadImage(url: imageUrlString!, placeHolder: nil) { [weak self] error in
                    guard self != nil else { return }
                    if let error = error {
                        print("Failed to download image: \(error)")
                    }
                }

        }
            
             if  indexPath.row == 1 {
              cell.img_AppIcon.isHidden = true

            }
            
            if let beforeCallIndex = Constants.USERDEFAULTS.value(forKey: "BeforeCallIndex") as? Int {
                lastSelectedIndex = beforeCallIndex
                // Continue with using `lastSelectedIndex` safely
            } else {
                lastSelectedIndex = 0
            }
            
        case 1:
            cell.img_AppIcon.isHidden = true

            _ = DpImage
            if indexPath.row == 0 {
                cell.img_WallPaper.image = DpImage
            } else {
                cell.img_WallPaper.downloadImage(url: imageUrlString!, placeHolder: nil) { [weak self] error in
                    guard self != nil else { return }
           
                    if let error = error {
                        print("Failed to download image: \(error)")
                    }
                }
                
            }
            
            if let beforeCallIndex = Constants.USERDEFAULTS.value(forKey: "DuringCallIndex") as? Int {
                lastSelectedIndex = beforeCallIndex
                // Continue with using `lastSelectedIndex` safely
            } else {
                lastSelectedIndex = 0
            }
        case 2:
            cell.img_AppIcon.isHidden = false

            if indexPath.row == 0 {
                cell.img_WallPaper.image = afterImage
            } else {

                cell.img_WallPaper.downloadImage(url: imageUrlString!, placeHolder: nil) { [weak self] error in
                    guard self != nil else { return }
              
                    if let error = error {
                        print("Failed to download image: \(error)")
                    }
                }
                
                
            }
            
            if let beforeCallIndex = Constants.USERDEFAULTS.value(forKey: "AfterCallIndex") as? Int {
                lastSelectedIndex = beforeCallIndex
                // Continue with using `lastSelectedIndex` safely
            } else {
                lastSelectedIndex = 0
            }
        default:break;
        }
        
        
        if lastSelectedIndex == indexPath.row {
            cell.img_Select.image = UIImage(named: "right tick")
            cell.img_WallPaper.layer.borderWidth = 3
            cell.img_WallPaper.layer.borderColor = Utils().RGBColor(red: 104, green: 206, blue: 103).cgColor
            
            switch Index {
                
            case 0:
                let value = wallpaperCollection?.iosWallpaper[0]
                wallpaperCollection?.iosWallpaper[0] = value!
                    Constants.USERDEFAULTS.set(savedFileName, forKey: "ImageUrls")
                    Constants.USERDEFAULTS.set(0,forKey: "BeforeCallIndex")
                
            case 1:
                if lastSelectedIndex == 0 {
                    let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
                    
                    if let pngData = DpImage.jpegData(compressionQuality: 0.7) {
                        let imageFilter = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)
                        wallpaperCollection?.iosWallpaper[0] = imageFilter!
                        Constants.USERDEFAULTS.set(savedFileName, forKey: "ImageUrls")
                    }
                    
                    //                    Constants.USERDEFAULTS.set(savedFileName[indexPath.row],forKey: "DuringCall")
                    
                } else {
                    //                    Constants.USERDEFAULTS.set(savedFileName[indexPath.row],forKey: "DuringCall")
                    
                }
                
                Constants.USERDEFAULTS.set(indexPath.row,forKey: "DuringCallIndex")
                
            case 2:
                let value = wallpaperCollection?.iosWallpaper[0]

                wallpaperCollection?.iosWallpaper[0] = value!
                Constants.USERDEFAULTS.set(savedFileName, forKey: "ImageUrls")
                Constants.USERDEFAULTS.set(indexPath.row,forKey: "AfterCallIndex")

            default:break;
            }
            
            
        } else {
            cell.img_Select.image = UIImage(named: "blank")
            cell.img_WallPaper.layer.borderWidth = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        //        Constants.USERDEFAULTS.set(selectedIndex, forKey: "")
//        if indexPath.row == 0 {
//        return
//        }
//
        switch Index {
            
        case 0:
            Constants.USERDEFAULTS.set(indexPath.row,forKey: "BeforeCallIndex")
            if indexPath.row == 1 {
                Constants.USERDEFAULTS.set(indexPath.row,forKey: "HandleblackImage")
            } else {
                Constants.USERDEFAULTS.set(indexPath.row,forKey: "HandleblackImage")
            }
        case 1:
            Constants.USERDEFAULTS.set(indexPath.row,forKey: "DuringCallIndex")
        case 2:
            Constants.USERDEFAULTS.set(indexPath.row,forKey: "AfterCallIndex")
            
        default:break;
        }
        
        
        
        switch Index {
            
        case 0:
            Constants.USERDEFAULTS.set(wallpaperCollection?.iosWallpaper[indexPath.row],forKey: "BeforeCall")
            
        case 1:
            Constants.USERDEFAULTS.set(wallpaperCollection?.iosWallpaper[indexPath.row],forKey: "DuringCall")
            
        case 2:
            Constants.USERDEFAULTS.set(wallpaperCollection?.iosWallpaper[indexPath.row],forKey: "AfterCall")
        default:break;
        }
        
        Constants.USERDEFAULTS.set(false,forKey: "Empty Image")
        Constants.USERDEFAULTS.set(1, forKey: "DuringCallFirstTimeIndex")
         selectionChanged = true
        clv_WallPaper.reloadData()
    }
    
//
}

// Image PickerController Delegate Methods
extension ChooseWallpaperVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    // Delegate method called when image selection is done
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Handle the selected image
        if let pickedImage = info[.originalImage] as? UIImage {
            
            let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
            
            if let pngData = pickedImage.jpegData(compressionQuality: 0.7) {
                let image = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)
                switch Index {
                    
                case 0: Constants.USERDEFAULTS.set(image,forKey: "BeforeCall")
                       Constants.USERDEFAULTS.set(0,forKey: "BeforeCallIndex")
                case 1: Constants.USERDEFAULTS.set(image,forKey: "DuringCall")
                       Constants.USERDEFAULTS.set(0,forKey: "DuringCallIndex")
//                       savedFileName[0] = image!
//                      Constants.USERDEFAULTS.set(savedFileName, forKey: "ImageUrls")

                case 2: Constants.USERDEFAULTS.set(image,forKey: "AfterCall")
                      Constants.USERDEFAULTS.set(0,forKey: "AfterCallIndex")
                    
                default:break;
                }
            }
        }
        

        // Dismiss the image picker
        picker.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    // Delegate method called when image selection is canceled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the image picker
        picker.dismiss(animated: true, completion: nil)
    }
}

// Clv WallPaper Cell
class clv_WallPaper_Cell:UICollectionViewCell {
    
    @IBOutlet weak var img_WallPaper: UIImageView!
    
    @IBOutlet weak var img_AppIcon: UIImageView!
    @IBOutlet weak var img_Select: UIImageView!
    
}

