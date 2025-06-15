//
//  CallerIdVC.swift
//  Fake Call
//
//  Created by mac on 06/04/24.
//

import UIKit
import Kingfisher
import CoreData
import ProgressHUD
import GoogleMobileAds

class CallerIdVC: UIViewController {

    
    @IBOutlet weak var btn_save: UIButton!
    @IBOutlet weak var contentHeight: NSLayoutConstraint!
    @IBOutlet weak var tbl_CallerID: UITableView!
    @IBOutlet weak var lbl_PlusConten: UILabel!
    @IBOutlet weak var watchAdsView: UIView!
    @IBOutlet weak var bulrView: UIView!
    
    @IBOutlet weak var btn_Skip_Ad: UIButton!
    @IBOutlet weak var btn_Watch_Ad: UIButton!
    
    var arrImg = [String]()
    var arrName = [String]()
    var arrPhone = [String]()
    var arrVoice = [String]()
    var arrfontColor = [String]()
    var arrfont = [String]()
    var arrBool = [Bool]()
    var arrVoiceUrl = [URL]()
    var arrEmptyDpBool = [Bool]()

    var backbutton = UIButton()

    var arrSearch = [CallerId]()
    var filteredIndices = [Int]()
    var isSave = false
    
    var arrDuringImage = [UIImage?]()

    var contacts = CallerIds()

    var index = 0
    var cellSelectIndex = 0
    var cellSelectSerchIndex = 0
    var serchSelectIndex = -1
    var arrCllerIds = [CallerId]()
    
    var isSelectedCallerId = false
    var isSerach = false
    var isDefaultImage = false
    var isCloseAd = false
    
    let searchController: UISearchController = {
           let searchController = UISearchController(searchResultsController: nil)
           searchController.searchBar.placeholder = "Search"
           searchController.searchBar.searchBarStyle = .minimal
           searchController.searchBar.text = ""
           searchController.definesPresentationContext = true
           searchController.obscuresBackgroundDuringPresentation = false
           searchController.hidesNavigationBarDuringPresentation = true
           return searchController
      }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpNavigationBar()
        tbl_CallerID.keyboardDismissMode = .onDrag // or .interactive
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(handleContactDetails(_:)), name: Notification.Name("NewContactDetails"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpNavigationBar()
        fetchCallerData()
    }

    override func viewWillDisappear(_ animated: Bool) {
//        if isCloseAd {
        if isSave {
            if filteredIndices.count != 0 {
                let selectedIndex = filteredIndices[cellSelectIndex]
                Constants.USERDEFAULTS.set(selectedIndex, forKey: "selectedCallerIdIndex")
                
            } else {
                self.index = cellSelectIndex
                Constants.USERDEFAULTS.set(index, forKey: "selectedCallerIdIndex")
            }
            
            Constants.USERDEFAULTS.set(true, forKey: "Empty Image")
            
            let index = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
            
            if let savedImageDataArray = UserDefaults.standard.array(forKey: "savedImagesDuration") as? [Data] {
                // Convert array of Data back to array of UIImage
                let savedImages = savedImageDataArray.compactMap { UIImage(data: $0) }
                arrDuringImage = savedImages
            }
            
            
            if arrDuringImage.count >= index {
                let valueAtIndex = arrDuringImage.remove(at: index)
                
                let filterUrl = "IMG_\(Date().currentTimeMillis()).png"
                
                if let pngData = valueAtIndex!.pngData() {
                    let imageFilter = CreateURL().saveFile(data: pngData as Data, fileName: filterUrl)
                    if isDefaultImage {
                        Constants.USERDEFAULTS.set(pngData,forKey: "DuringCall")
                        
                    } else {
                        Constants.USERDEFAULTS.set(imageFilter,forKey: "DuringCall")
                    }
                }
                
                arrDuringImage.insert(valueAtIndex, at: 0)
            }
            
            
            let imageDataArray = arrDuringImage.compactMap { Utils().imageData(from: $0!) }
            
            // Save the array of Data to UserDefaults
            UserDefaults.standard.set(imageDataArray, forKey: "savedImagesDuration")
        } else {
            Constants.USERDEFAULTS.set(0, forKey: "selectedCallerIdIndex")
            
        }
        
//        } else {
//            Constants.USERDEFAULTS.set(0, forKey: "selectedCallerIdIndex")
//
//        }
        
        //        let index =  Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
        //
        //        Constants.USERDEFAULTS.set(arrName[index], forKey: "Name")
        //        Constants.USERDEFAULTS.set(arrPhone[index], forKey: "number")
        //        Constants.USERDEFAULTS.set(arrVoice[index], forKey: "voice")
        //        Constants.USERDEFAULTS.set(arrImg[index], forKey: "dpImageUrl")
        
    }
 
    @IBAction func btn_TapSave(_ sender: Any) {
//
        isSave = true
        
        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
            arrCllerIds = Ids
        
            isDefaultImage = arrCllerIds[cellSelectIndex].isDefault
            
        }
        
        if btn_save.isEnabled == true {
            if Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
//                backbutton.isHidden = true
//                bulrView.fadeIn()
//                bulrView.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0.6)
//                animateShowFromBottom(view: watchAdsView)
                let navController = storyboard?.instantiateViewController(withIdentifier: "popPremiumVc") as? popPremiumVc
                let nav = UINavigationController(rootViewController: navController!)
                nav.modalPresentationStyle = .custom
                self.present(nav, animated: false, completion: nil)


            } else {
              navigationController?.popViewController(animated: true)

            }
        }
    }
    
    @IBAction func tap_WatchAd(_ sender: Any) {

    }
    
    @IBAction func tap_SkipAd(_ sender: Any) {
        dismiss(animated: true)
        let naviget = storyboard?.instantiateViewController(withIdentifier: "primiumVC") as! primiumVC
        naviget.modalPresentationStyle = .fullScreen
        present(naviget, animated: true)
        
    }
    
    @IBAction func hide_WatchAd_View(_ sender: Any) {
//        backbutton.isHidden = false
//        bulrView.fadeOut()
//        bulrView.removeBlurFromView()
//        animateHideFromBottom(view: watchAdsView)


    }
    
}

extension CallerIdVC {
    
    // Set UP UI
    func setUpUI() {
        btn_save.layer.cornerRadius = 12
        btn_save.layer.masksToBounds = true
        btn_save.isEnabled = false
        
        navigationController?.navigationBar.layer.zPosition = 0
        bulrView.layer.zPosition = 1

    }
    
    // Set Up Navigation Bar
    func setUpNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Caller Id"

        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        let buttonImage = UIImage(named: "plus") // Make sure to replace "yourButtonImage" with your image name
            backbutton = UIButton(type: .custom)
        backbutton.setImage(buttonImage, for: .normal)
        backbutton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        backbutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // Adjust frame as needed

           // Wrap the button in a UIBarButtonItem
           let barButtonItem = UIBarButtonItem(customView: backbutton)

           // Assign the bar button item to the right side of the navigation bar
           navigationItem.rightBarButtonItem = barButtonItem
    }
        
    // Fetch caller Data
    func fetchCallerData() {
        
        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
            let index = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
            self.arrCllerIds = Ids

            if arrCllerIds.count >= index {
                let valueAtIndex = arrCllerIds.remove(at: index)
                arrCllerIds.insert(valueAtIndex, at: 0)
            }
            
            print(arrCllerIds)
            
//            arrSearch = arrCllerIds
            
            arrName = arrCllerIds.compactMap { $0.name }
            arrPhone = arrCllerIds.compactMap { $0.number }
            arrImg = arrCllerIds.compactMap { $0.dpimage }
            arrVoice = arrCllerIds.compactMap { $0.voice }
            arrfontColor = arrCllerIds.compactMap { $0.fontColor }
            arrfont = arrCllerIds.compactMap { $0.fonts }
            arrBool = arrCllerIds.compactMap { $0.isDefault }
            arrVoiceUrl = arrCllerIds.compactMap { $0.voiceUrl }
            arrEmptyDpBool = arrCllerIds.compactMap { $0.isEmptyDp }
            // Update Index In DataBase
            for i in 0..<arrName.count {
                contacts.name = arrName[i]
                contacts.voice = arrVoice[i]
                contacts.number = arrPhone[i]
                contacts.dpImage = arrImg[i]
                contacts.fontColor = arrfontColor[i]
                contacts.fonts = arrfont[i]
                contacts.isDefault = arrBool[i]
                contacts.isEmptyDp = arrEmptyDpBool[i]
                if i < arrVoiceUrl.count {
                       contacts.VoiceUrl = arrVoiceUrl[i]
                   } else {
                       print("Error: arrVoiceUrl index \(i) is out of range")
                       // Handle this case appropriately (e.g., set a default value)
                       // contacts.VoiceUrl = someDefaultValue
                   }
                
                let timestamp = Ids[i].timestamp
                contacts.timestamp = timestamp!

                let updateData = IMAGEDATA().updateData(context: self.context, CallerId: contacts)
                if updateData {
                    print("updateData")
                } else {
                    print("Noooo updateData")
                }
            }
            tbl_CallerID.reloadData()
        }
    }
    
    // Delete Data From Database
    func deleteData(Product: CallerId) {
        let del = IMAGEDATA().deleteImage(context: self.context, selectedProduct: Product)
        if del {
            print("yes")
        } else {
            print("Noooo")
        }
    }
    
    // Tap Plus Button
    @objc func buttonTapped() {
        let nav = storyboard?.instantiateViewController(withIdentifier: "ContactDetailsVC") as! ContactDetailsVC
        nav.isAddNewID = true
        Constants.USERDEFAULTS.set(true, forKey: "isAddNewIDForRightTick")
        navigationController?.pushViewController(nav, animated: true)
        
    }
    
    @objc func handleContactDetails(_ notification: Notification) {
 
        
    }
    

}

// Search Bar Delegate Methods
extension CallerIdVC:UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        lbl_PlusConten.isHidden = false
        contentHeight.constant = Utils().IpadorIphone(value: 0)
        return  true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        serchSelectIndex = -1
        cellSelectIndex = -1
        btn_save.isEnabled = false
          if searchBar.text == "" {
              lbl_PlusConten.isHidden = true
              contentHeight.constant = 0
              print(arrCllerIds.count)
              arrSearch = arrCllerIds
              isSerach = false
              filteredIndices.removeAll()
              IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
                  _ = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
//                  self.arrCllerIds = Ids
                  
                  arrName = Ids.map { $0.name ?? "" }
                  arrPhone = Ids.map { $0.number ?? "" }
                  arrImg = Ids.map { $0.dpimage ?? "" }
              }

          } else {
              lbl_PlusConten.isHidden = true
              contentHeight.constant = 0

              isSerach = true
              // Filter arrCllerIds based on the search text
              arrSearch = arrCllerIds.filter { item in
                  guard let name = item.name else { return false }
                  return name.range(of: searchText, options: .caseInsensitive) != nil
              }
              
              arrName = arrSearch.map { $0.name ?? "" }
              arrPhone = arrSearch.map { $0.number ?? "" }
              arrImg = arrSearch.map { $0.dpimage ?? "" }

              var Idss = [CallerId]()
              IMAGEDATA().fetchImage(context: self.context) {  Ids in
                  Idss = Ids
              }

              var filteredIndices: [Int] = []

              guard let searchText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !searchText.isEmpty else {
                  // Handle if searchBar.text is nil, empty, or contains only whitespace characters
                  self.filteredIndices = []
                  print("Filtered Indices: []")
                  return
              }

              let searchTextLowercased = searchText.lowercased()  // Convert searchText to lowercase
              let searchTextUppercased = searchText.uppercased()  // Convert searchText to uppercase

              for index in 0..<Idss.count {
                  if let name = Idss[index].name {
                      let nameLowercased = name.lowercased()  // Convert name to lowercase
                      let nameUppercased = name.uppercased()  // Convert name to uppercase

                      // Check if name contains searchText in either case
                      if nameLowercased.contains(searchTextLowercased) || nameUppercased.contains(searchTextUppercased) {
                          // Add the index to filteredIndices if the name contains the search text
                          filteredIndices.append(index)
                      }
                  }
              }

              if filteredIndices.isEmpty {
                  print("No matching items found")
              } else {
                  self.filteredIndices = filteredIndices
                  print("Filtered Indices: \(filteredIndices)")
              }

          }

          tbl_CallerID.reloadData()
      }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSerach = false
        lbl_PlusConten.isHidden = false
        btn_save.isEnabled = false
        contentHeight.constant = Utils().IpadorIphone(value: 32)
        cellSelectIndex = 0

        filteredIndices.removeAll()
        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
            _ = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
            self.arrCllerIds = Ids
            
            //            arrSearch = arrCllerIds
            
            arrName = arrCllerIds.compactMap { $0.name }
            arrPhone = arrCllerIds.compactMap { $0.number }
            arrImg = arrCllerIds.compactMap { $0.dpimage }
            
            tbl_CallerID.reloadData()
        }
       }
    
}

// Table View Delegate Methods
extension CallerIdVC:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tbl_CallerID_Cell", for: indexPath) as! tbl_CallerID_Cell
//        btn_save.isEnabled = true

        DispatchQueue.main.async {
            cell.img_Dp.layer.cornerRadius = cell.img_Dp.bounds.height / 2
            cell.img_Dp.clipsToBounds = true
            cell.bg_View.layer.cornerRadius = 16
        }
        
        let vidPath = CreateURL().documentsUrl().appendingPathComponent(arrImg[indexPath.row])
        let imageURL = URL(string: vidPath.absoluteString)
        let provider = LocalFileImageDataProvider(fileURL: imageURL!)
        cell.img_Dp.kf.setImage(with: provider, placeholder: UIImage(named: "img_place"))
        
        cell.lbl_Name.text = arrName[indexPath.row]
        cell.lbl_MoNumber.text = arrPhone[indexPath.row]
        
        if !isSerach  {
            if cellSelectIndex == indexPath.row {
                cell.bg_View.layer.borderWidth = 2
                cell.bg_View.layer.borderColor = Utils().RGBColor(red: 104, green: 206, blue: 103).cgColor
                cell.bg_View.layer.backgroundColor = Utils().RGBColor(red: 0, green: 122, blue: 255,alpha: 0.05).cgColor

            } else {
//                btn_save.isEnabled = false
                cell.bg_View.layer.borderWidth = 0
                cell.bg_View.layer.backgroundColor = UIColor.systemBackground.cgColor
            }
        } else {
            
            if serchSelectIndex == indexPath.row {
                cell.bg_View.layer.borderWidth = 2
                cell.bg_View.layer.borderColor = Utils().RGBColor(red: 104, green: 206, blue: 103).cgColor
                cell.bg_View.layer.backgroundColor = Utils().RGBColor(red: 0, green: 122, blue: 255,alpha: 0.05).cgColor
            } else {
                cell.bg_View.layer.borderWidth = 0
                cell.bg_View.layer.backgroundColor = UIColor.systemBackground.cgColor
            }
        }
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Utils().IpadorIphone(value: 101)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        btn_save.isEnabled = true

        cellSelectIndex = indexPath.row
        cellSelectSerchIndex = indexPath.row
        if isSerach {
            serchSelectIndex = indexPath.row
        }
        
        let userInfo: [AnyHashable: Any] = ["index": index]
        NotificationCenter.default.post(name: Notification.Name("selectedCallerIdIndex"), object: nil, userInfo: userInfo)
        Constants.USERDEFAULTS.set(0, forKey: "DuringCallFirstTimeIndex")
        isSelectedCallerId = false

        if !isSerach {
            if indexPath.row != 0 {
                btn_save.isEnabled = true
            }
        } else {
            btn_save.isEnabled = true
        }
        
        tbl_CallerID.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Check if the indexPath belongs to section 1
        var arrData = [CallerId]()
        IMAGEDATA().fetchImage(context: self.context) {  Ids in
            arrData = Ids
        }
        var object = Bool()
        if indexPath.section == 0 {
            if isSerach {
                if arrSearch[indexPath.row].name == nil {
                    object = true

                } else {
                    object = arrSearch[indexPath.row].isDefault

                }
            } else {
                object = arrData[indexPath.row].isDefault

            }
            if object {
                return false
            }
           return true
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        var selectedIndex = Int()
        IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
           print(Ids)
            if editingStyle == .delete {
                // Remove the item from your data source
                
                let alert = UIAlertController(title: "Delete Contact", message: "Are you sure you want to delete \(arrName[indexPath.row])?", preferredStyle: .alert)

                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [self] _ in

                if Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
                    AdMob.sharedInstance()?.loadInste()
                }
                
                    DispatchQueue.main.async { [self] in
                    arrName.remove(at: indexPath.row)
                    arrPhone.remove(at: indexPath.row)
                    arrImg.remove(at: indexPath.row)

                        if isSerach {
                            deleteData(Product: arrSearch[indexPath.row])
                            selectedIndex = filteredIndices[indexPath.row]
                            
//                            selectedIndex += 1
//                            serchSelectIndex -= 1
//                            for i in 0..<arrName.count {
//
//                                serchSelectIndex = i
//                            }
//                            cellSelectIndex -= 1

                            
                        } else {
                            deleteData(Product: Ids[indexPath.row])
                            selectedIndex = indexPath.row
                            cellSelectIndex -= 1
                        }
                    
                
                    // Delete the row from the table view
                    tableView.deleteRows(at: [indexPath], with: .fade)
                        
                        if isSerach {
                            
                            isSerach = false
                            lbl_PlusConten.isHidden = false
                            btn_save.isEnabled = false
                            contentHeight.constant = Utils().IpadorIphone(value: 32)
                            cellSelectIndex = 0
                            searchController.searchBar.text = ""
                            filteredIndices.removeAll()
                            IMAGEDATA().fetchImage(context: self.context) { [self] Ids in
                                _ = Constants.USERDEFAULTS.integer(forKey: "selectedCallerIdIndex")
                                self.arrCllerIds = Ids
                                
                                //            arrSearch = arrCllerIds
                                
                                arrName = arrCllerIds.compactMap { $0.name }
                                arrPhone = arrCllerIds.compactMap { $0.number }
                                arrImg = arrCllerIds.compactMap { $0.dpimage }
                                
                                tbl_CallerID.reloadData()
                            }
                        }
                       
                        
                        
                    if let savedImageDataArray = UserDefaults.standard.array(forKey: "savedImagesDuration") as? [Data] {
                        // Convert array of Data back to array of UIImage
                        let savedImages = savedImageDataArray.compactMap { UIImage(data: $0) }
                        arrDuringImage = savedImages
                    }
                       let a =   arrDuringImage.remove(at:selectedIndex)

                    let imageDataArray = arrDuringImage.compactMap { Utils().imageData(from: $0!) }

                    UserDefaults.standard.set(imageDataArray, forKey: "savedImagesDuration")

                }
                }

                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

                alert.addAction(deleteAction)
                alert.addAction(cancelAction)

                present(alert, animated: true, completion: nil)

            }
        }
    }
    
    @objc func menuButtonTapped(_ sender: UIButton) {
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            // Dismiss the keyboard when the user starts scrolling
        tbl_CallerID.endEditing(true)
        
        }
    
}


// tbl_CallerID_Cell
class tbl_CallerID_Cell:UITableViewCell {
    
    @IBOutlet weak var img_Dp: UIImageView!
    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var lbl_MoNumber: UILabel!
    @IBOutlet weak var bg_View: UIView!
    @IBOutlet weak var btn_Menu: UIButton!
    
}

extension UIImage {
    func withBorder(color: UIColor, width: CGFloat) -> UIImage? {
        let newSize = CGSize(width: self.size.width + 2 * width, height: self.size.height + 2 * width)
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        // Draw the border
        let borderRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(width)
        context.stroke(borderRect)
        
        // Draw the original image in the center
        let imageRect = CGRect(x: width, y: width, width: self.size.width, height: self.size.height)
        self.draw(in: imageRect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension UIView {
        
    func fadeIn(duration: TimeInterval = 0.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in }) {
        self.alpha = 0.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.isHidden = false
            self.alpha = 1.0
        }, completion: completion)
    }
    
    func fadeOut(duration: TimeInterval = 0.0, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in }) {
        self.alpha = 1.0
        
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }) { (completed) in
            self.isHidden = true
            completion(true)
        }
    }
    
}
