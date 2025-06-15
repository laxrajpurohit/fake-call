//
//  CallThemeVC.swift
//  Fake Call
//
//  Created by mac on 11/04/24.
//

import UIKit
import GoogleMobileAds

class CallThemeVC: UIViewController,GADBannerViewDelegate {

    @IBOutlet weak var clv_callTheam: UICollectionView!
    
    @IBOutlet weak var bannerAds_VIew: GADBannerView!
    
    var arrCallTheam = ["theme 1","theme 2","theme 3"]
    var selectionChanged = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        if selectionChanged, Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
            AdMob.sharedInstance()?.loadInste()
        }
    }
}

extension CallThemeVC {
    // Set Up UI
    func setUpUI() {
        if Utils().isConnectedToNetwork() {
            bannerAds_VIew.adUnitID = Constants.BANNER
            bannerAds_VIew.adSize = GADAdSizeBanner
            bannerAds_VIew.rootViewController = self
            bannerAds_VIew.delegate = self
            bannerAds_VIew.load(GADRequest())
        }
        
        // Premium User To Hide Ads View
        if Constants.USERDEFAULTS.value(forKey: "Premium") != nil {
            bannerAds_VIew.isHidden = true
        } else {
            bannerAds_VIew.isHidden = false
        }
        
        
        setUpCollection()
        setUpNavigationBar()
    }
    
    // MARK: - set collection
    func setUpCollection() {
        DispatchQueue.main.async { [self] in
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
            
            let width: CGFloat = self.clv_callTheam.bounds.width / 3
            let  height: CGFloat = self.clv_callTheam.bounds.height / 2.5
            let size = CGSize(width: width, height: height)
            
            layout.itemSize = size
            self.clv_callTheam.collectionViewLayout = layout
            self.clv_callTheam.reloadData()
        }
    }

    // Set Up Navigation Bar
    func setUpNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Call theme"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black] // Change the color here if different
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    // Calculate Image React
    func calculateClientRectOfImageInUIImageView(imageView:UIImageView) -> CGRect {
        let imgViewSize = imageView.frame.size // Size of UIImageView
        let imgSize = imageView.image?.size ?? CGSize.zero // Size of the image, currently displayed

        // Calculate the aspect, assuming imageView.contentMode == .scaleAspectFit

        let scaleW = imgViewSize.width / imgSize.width
        let scaleH = imgViewSize.height / imgSize.height
        let aspect = min(scaleW, scaleH)

        var imageRect = CGRect(origin: .zero, size: CGSize(width: imgSize.width * aspect, height: imgSize.height * aspect))

        // Center image

        imageRect.origin.x = (imgViewSize.width - imageRect.size.width) / 2
        imageRect.origin.y = (imgViewSize.height - imageRect.size.height) / 2

        // Add imageView offset

        imageRect.origin.x += imageView.frame.origin.x
        imageRect.origin.y += imageView.frame.origin.y

        return imageRect
    }
}


// Collection View Delegate Method
extension CallThemeVC:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return arrCallTheam.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clv_callTheam", for: indexPath) as! clv_callTheam
        cell.img_CallTheam.layer.cornerRadius = Utils().IpadorIphone(value: 12)
        cell.img_CallTheam.layer.masksToBounds = true
        
        cell.img_CallTheam.image = UIImage(named: arrCallTheam[indexPath.row])
        let imageRect = calculateClientRectOfImageInUIImageView(imageView:  cell.img_CallTheam)

            
        let index = Constants.USERDEFAULTS.integer(forKey: "callThemeSelectedIndex")
        let isPremiumUser = Constants.USERDEFAULTS.value(forKey: "Premium") != nil
        let isSelectedRow = index == indexPath.row

        if !isPremiumUser && indexPath.row > 0 {
            cell.img_Select.image = UIImage(named: "Lock")
            cell.img_CallTheam.layer.borderWidth = 0
        } else {
            if isSelectedRow {
                cell.img_Select.image = UIImage(named: "right tick")
                cell.img_CallTheam.frame = CGRect(x: imageRect.origin.x, y: imageRect.origin.y, width: imageRect.width, height: imageRect.height)
                cell.img_CallTheam.layer.borderWidth = Utils().IpadorIphone(value: 3)
                cell.img_CallTheam.layer.borderColor = #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1)
            } else {
                cell.img_Select.image = UIImage(named: "blank")
                cell.img_CallTheam.layer.borderWidth = 0
            }
        }

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath : IndexPath) {
        
        if indexPath.row > 0 {
            if Constants.USERDEFAULTS.value(forKey: "Premium") == nil {
                let primiumVCvc = self.storyboard?.instantiateViewController(withIdentifier: "primiumVC") as! primiumVC
                primiumVCvc.modalPresentationStyle = .fullScreen
                present(primiumVCvc, animated: true)

            } else {
                Constants.USERDEFAULTS.set(indexPath.row,forKey: "callThemeSelectedIndex")
                selectionChanged = true
                clv_callTheam.reloadData()

            }
        } else {
            Constants.USERDEFAULTS.set(indexPath.row,forKey: "callThemeSelectedIndex")
            selectionChanged = true
            clv_callTheam.reloadData()

        }
        
    }
    
}

// clv_callTheam_Cell
class clv_callTheam:UICollectionViewCell {
    @IBOutlet weak var img_CallTheam: UIImageView!
    @IBOutlet weak var img_Select: UIImageView!
}


