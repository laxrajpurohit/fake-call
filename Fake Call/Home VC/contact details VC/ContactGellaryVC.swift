//
//  ContactGellaryVC.swift
//  Fake Call
//
//  Created by mac on 17/04/24.
//

import UIKit
import Kingfisher
import PhotoCircleCrop
import YKPhotoCircleCrop
import ProgressHUD
import Alamofire
import SDWebImage

class ContactGellaryVC: UIViewController, YKCircleCropViewControllerDelegate {

    @IBOutlet weak var clv_category: UICollectionView!
    @IBOutlet weak var clv_Photos: UICollectionView!
    
    @IBOutlet weak var clv_Photos_Height: NSLayoutConstraint!
    @IBOutlet weak var clv_Category_Height: NSLayoutConstraint!
    
    @IBOutlet weak var notch_View: UIView!
    
    @IBOutlet weak var lbl_CategoryName: UILabel!
    
    var photoArray: [String] = []
    var categoryIconArray: [String] = ["photo","collection","love","nature","wallpaper"]
    var categoryNameArray: [String] = ["Photo","Collection","Love","Nature","Wallpaper"]
    var savedPhotosUrl = [String]()
    let circleCropController = YKCircleCropViewController()
    var image = UIImage()
    
    var selectCategoryIndex = 1
    var downloadCounter = 0

    var wallpaperCollection: WallpaperCollection?
    var activityIndicator: UIActivityIndicatorView!

    var wallpaper = [String]()

    var imageData: [String: [String]] = [:]
    var currentCategory: String?
    var pickedImageWallpaper = String()
    
    let cache = ImageCache.default
    var options: KingfisherOptionsInfo = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetUI()
    }
    
    // Tap Cancle
    @IBAction func tap_Cancle(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    
}

extension ContactGellaryVC {
    
    // Set Up UI
    func SetUI() {
        notch_View.layer.cornerRadius = 2
        notch_View.layer.masksToBounds = true

        setUpCollection()
        fetchData(for: "collection")
        
        // Initialize activity indicator
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)

    }
    
    // MARK: - set collection
    func setUpCollection() {
        DispatchQueue.main.async { [self] in
            
            cache.memoryStorage.config.totalCostLimit = 500 * 1024 * 1024
            cache.diskStorage.config.sizeLimit = 500 * 1024 * 1024
            
            let sizdee = CGSize(width: 500, height: 500)
            let processor = DownsamplingImageProcessor(size: sizdee)
            options = [.processor(processor), .targetCache(cache)]
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            let layouts: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            
            layouts.minimumLineSpacing = 0
            layouts.minimumInteritemSpacing = 0
            layouts.scrollDirection = .horizontal
            layouts.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            
            let width: CGFloat = self.clv_Photos.bounds.width / 3 
            let  height: CGFloat = self.clv_Photos.bounds.height - 40
            let size = CGSize(width: width, height: height)
            
            let widths: CGFloat = self.clv_category.bounds.width / Utils().IpadorIphone(value: 4)
            let  heights: CGFloat = self.clv_category.bounds.height
            let sizse = CGSize(width: widths, height: heights)
            
            layout.itemSize = size
            self.clv_Photos.collectionViewLayout = layout
            self.clv_Photos.reloadData()
            
            layouts.itemSize = sizse
            self.clv_category.collectionViewLayout = layouts
            self.clv_category.reloadData()
        }
    }
    
    // open Image Picker
    func openImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false // Set to true if you want to allow image editing
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
        

      }
    
    // Call Wallpaper Api
    func fetchData(for category: String) {
        
        if let url = URL(string: "https://apptrendz.com/API/fake_call/wallpaper.json") {
            AF.request(url).responseJSON { [self] response in
                switch response.result {
                case .success(let value):
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: value)
                        let decodedData = try JSONDecoder().decode(WallpaperCollection.self, from: jsonData)
                        DispatchQueue.main.async {
                            
                            self.wallpaperCollection = decodedData
                            self.wallpaper = self.wallpaperCollection!.collection
                            
                            self.clv_Photos.reloadData()
                            self.clv_category.reloadData()
                            
                            self.stopLoading()
                            
                        }
                    } catch {
                        print("JSON Decoding Error: \(error)")
                    }
                    
                case .failure(let error):
                    print("API Request Error: \(error)")
                }
            }
        }

        
//        guard let url = URL(string: "https://apptrendz.com/API/fake_call/wallpaper.json") else {
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                print("Error fetching data: \(error)")
//                return
//            }
//
//            guard let jsonData = data else {
//                print("No data received")
//                return
//            }
//
//            // Parse JSON data
//            do {
//                let decodedData = try JSONDecoder().decode(WallpaperCollection.self, from: jsonData)
//                self.wallpaperCollection = decodedData
//                self.wallpaper = self.wallpaperCollection!.collection
//                // Update current category
//                DispatchQueue.main.async {
//                    self.clv_Photos.reloadData()
//                }
//
//            } catch {
//                print("Error decoding JSON: \(error)")
//            }
//        }.resume()
    }
    
    // Function to start the activity indicator animation
    func startLoading() {
           activityIndicator.startAnimating()
           // Optionally disable user interaction while loading
           view.isUserInteractionEnabled = false
       }

    // Function to stop the activity indicator animation
     func stopLoading() {
         activityIndicator.stopAnimating()
         view.isUserInteractionEnabled = true
     }

    
}

extension ContactGellaryVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    // Delegate method called when image selection is done
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            // Handle the selected image
            if let pickedImage = info[.originalImage] as? UIImage {
                let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
                if let pngData = pickedImage.jpegData(compressionQuality: 0.7) {
                    self.pickedImageWallpaper = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)!
                }
                
                let circleCropController = YKCircleCropViewController()
                circleCropController.image = pickedImage
                circleCropController.delegate = self
                DispatchQueue.main.async {
                    self.present(circleCropController, animated: true, completion: nil)
                }
            }
            
        }
        
        
        
        // Dismiss the image picker
        //           picker.dismiss(animated: true, completion: nil)
    }
    
    // Delegate method called when image selection is canceled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the image picker
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// Circle CropView Controller Delegate
extension ContactGellaryVC:CircleCropViewControllerDelegate {
    
    func circleCropDidCropImage(_ image: UIImage) {
        let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
        if let pngData = image.jpegData(compressionQuality: 0.7) {
            let imageFilter = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)
            let userInfo: [AnyHashable: Any] = ["pickedImage": imageFilter!, "btn_SaveEnabled": true]
            NotificationCenter.default.post(name: Notification.Name("pickedImagWithCrop"), object: nil, userInfo: userInfo)
            
            let userInfos: [AnyHashable: Any] = ["pickedImage": pickedImageWallpaper, "btn_SaveEnabled": true]
            NotificationCenter.default.post(name: Notification.Name("pickedImage"), object: nil, userInfo: userInfos)

        }
    }
    
    func circleCropDidCancel() {
    }

}


// Collection View Delegate
extension ContactGellaryVC:UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clv_category {
            return categoryIconArray.count
        } else {
            return wallpaper.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        DispatchQueue.main.async { [self] in
            clv_Photos_Height.constant = clv_Photos.contentSize.height
            clv_Category_Height.constant = clv_category.contentSize.height
//            ProgressHUD.animate(interaction: false)
        }

        
        if collectionView == clv_category {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clv_category_Cell", for: indexPath) as! clv_category_Cell
            cell.img_CategoryIcon.image = UIImage(named: categoryIconArray[indexPath.row])
            cell.lbl_CategoryName.text = categoryNameArray[indexPath.row]
            DispatchQueue.main.async {
                cell.img_CategoryIcon.layer.cornerRadius = cell.img_CategoryIcon.bounds.height / 2
                cell.bg_View.layer.cornerRadius = cell.bg_View.bounds.height / 2
            }
            if indexPath.row == selectCategoryIndex {
                cell.bg_View.layer.borderWidth = 2
                cell.bg_View.layer.borderColor = #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1)//UIColor.systemBlue.cgColor
                cell.bg_View.layer.masksToBounds = true
                cell.lbl_CategoryName.textColor = #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1)
                lbl_CategoryName.text = categoryNameArray[indexPath.row]

            } else {
                cell.bg_View.layer.borderWidth = 0
                cell.lbl_CategoryName.textColor = UIColor.secondaryLabel

            }
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clv_Photos_Cell", for: indexPath) as! clv_Photos_Cell

            let imageUrlString = wallpaper[indexPath.item]
            if let imageUrl = URL(string: imageUrlString) {
               print(imageUrl)
                
//                    cell.img_Photos.kf.setImage(with: imageUrl, placeholder: UIImage(named: "img_place"), options: options)
//                cell.img_Photos.kf.setImage(with: imageUrl, placeholder: UIImage(named: "img_placeholder"), options: options)
//                { [self] result in
//                    print(result)
//                              switch result {
//                              case .success(_):
//                               stopLoading()
//                              case .failure(_):
//                                  stopLoading()
//                              }
//                          }
                let thumbnailSize = CGSize(width: 200, height: 200)
                _ = DownsamplingImageProcessor(size: thumbnailSize)
                
                cell.img_Photos.kf.indicatorType = .activity
                let imageUrlString = wallpaper[indexPath.item]
         
                cell.img_Photos.downloadImage(url: imageUrlString, placeHolder: nil) { [weak self] error in
                    guard self != nil else { return }
                    if let error = error {
                        print("Failed to download image: \(error)")
                    }
                }
                
                
//                cell.img_Photos.kf.setImage(with: imageUrl, placeholder: nil, options: [.processor(processor)], progressBlock: nil) { result in
//                        switch result {
//                        case .success(_):
//                            print("Image loaded successfully!")
//                            // Image is now set in imageView
//                        case .failure(let error):
//                            print("Error loading image: \(error)")
//                        }
//                    }
                }
                
//                DispatchQueue.main.async {
////                        self.stopLoading()
//                    cell.img_Photos.kf.setImage(
//                        with: imageUrl,
//                        placeholder: UIImage(named: "placeholder_image"),
//                        options: options,
//                        completionHandler: { result in
//                            // Hide loading indicator once image loading is completed or failed
//                         
//                            // Handle any errors or completion as needed
//                            switch result {
//                            case .success(_):
//                                // Image loaded successfully
//                                break
//                            case .failure(let error):
//                                print("Error loading image: \(error)")
//                            }
//                        }
//                    )
//                }
            

            DispatchQueue.main.async {
                cell.img_Photos.layer.cornerRadius = 8
                cell.img_Photos.layer.masksToBounds = true
            }
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == clv_category {
            if indexPath.row != 0 {
                selectCategoryIndex = indexPath.row

            }
            DispatchQueue.main.async { [self] in
                
                if indexPath.row == 0 {
                    openImagePicker()
                } else if indexPath.row == 1 {
                    if let wallpaperCollection = self.wallpaperCollection {
                            self.wallpaper = wallpaperCollection.collection
                        }
                    
                }  else if indexPath.row == 2 {
                    if let wallpaperCollection = self.wallpaperCollection {
                        self.wallpaper = wallpaperCollection.love
                    }
                    
                }  else if indexPath.row == 3 {
                    if let wallpaperCollection = self.wallpaperCollection {
                               self.wallpaper = wallpaperCollection.nature
                           }
                    
                }  else if indexPath.row == 4 {
                    if let wallpaperCollection = self.wallpaperCollection {
                              self.wallpaper = wallpaperCollection.wallpaper
                          }
                }
                
                clv_category.reloadData()
                clv_Photos.reloadData()
            }

        } else {
                
            _ = URL(string:wallpaper[indexPath.row])
                //            loadImage(from:imageURL!)
                pickedImageWallpaper = wallpaper[indexPath.row]
//                let userInfo: [AnyHashable: Any] = ["pickedImage": wallpaper[indexPath.row], "btn_SaveEnabled": true]
//                NotificationCenter.default.post(name: Notification.Name("pickedImage"), object: nil, userInfo: userInfo)
                startLoading()

                
                let imageView = UIImageView()
                imageView.downloadImagse(url:wallpaper[indexPath.row], placeHolder: nil) { result in
                    switch result {
                    case .success(let image):
                        // Use the downloaded image
                        self.stopLoading()
                        self.image = image
                        let circleCropController = CircleCropViewController()
                        circleCropController.image = self.image
                        circleCropController.delegate = self
                        self.present(circleCropController, animated: true, completion: nil)
                    case .failure(let error):
                        // Handle download failure
                        print("Failed to download image: \(error.localizedDescription)")
                    }
                }

        }

    }
    
}

// clv_category Collection Cell
class clv_category_Cell:UICollectionViewCell {
    
    @IBOutlet weak var bg_View: UIView!
    @IBOutlet weak var img_CategoryIcon: UIImageView!
    @IBOutlet weak var lbl_CategoryName: UILabel!
}

// clv_Photos Collection Cell
class clv_Photos_Cell:UICollectionViewCell {
   
    @IBOutlet weak var img_Photos: UIImageView!
    
}


extension UIImageView {
    
//    func downloadImage(url: String, placeHolder: UIImage?, completion: @escaping (Error?) -> Void) {
//        guard let url = URL(string: url) else {
//            completion(URLError(.badURL))
//            return
//        }
//
//        self.sd_imageIndicator = SDWebImageActivityIndicator.medium // Add a loader indicator
//        self.sd_imageIndicator?.startAnimatingIndicator()
//        self.sd_setImage(with: url, placeholderImage: placeHolder, options: [], completed: { (image, error, cacheType, imageURL) in
//            self.sd_imageIndicator?.stopAnimatingIndicator()
//            completion(error)
//        })
//    }
    
    func downloadImage(url: String, placeHolder: UIImage?, completion: @escaping (Error?) -> Void) {
            guard let url = URL(string: url) else {
                completion(URLError(.badURL))
                return
            }
            
            self.sd_imageIndicator = SDWebImageActivityIndicator.medium
            self.sd_imageIndicator?.startAnimatingIndicator()
            
            // Options to prioritize high quality and retry on failure
            let options: SDWebImageOptions = [.retryFailed, .highPriority, .scaleDownLargeImages]
            
            self.sd_setImage(with: url, placeholderImage: placeHolder, options: options) { [weak self] (image, error, cacheType, imageURL) in
                self?.sd_imageIndicator?.stopAnimatingIndicator()
                
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                }
                
                // Optionally handle the case where the image is nil (e.g., show an error placeholder)
                if image == nil {
                    self?.image = UIImage(named: "errorPlaceholder") // Replace with your error placeholder image
                }
                
                completion(error)
            }
        }
    
    func downloadImagse(url: String, placeHolder: UIImage?, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let imageURL = URL(string: url) else {
            let error = NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            completion(.failure(error))
            return
        }
        
        self.sd_imageIndicator = SDWebImageActivityIndicator.medium
        self.sd_imageIndicator?.startAnimatingIndicator()
        
        self.sd_setImage(with: imageURL, placeholderImage: placeHolder, options: [], completed: { (image, error, cacheType, imageURL) in
            self.sd_imageIndicator?.stopAnimatingIndicator()
            
            if let error = error {
                completion(.failure(error))
            } else if let image = image {
                completion(.success(image))
            } else {
                let unknownError = NSError(domain: "UnknownError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                completion(.failure(unknownError))
            }
        })
    }
}
