//
//  OnBoadingVC.swift
//  Fake Call
//
//  Created by mac on 03/04/24.
//

import UIKit
import Alamofire
import ProgressHUD

class OnBoadingVC: UIViewController {

    @IBOutlet weak var clv_Onboarding: UICollectionView!
    @IBOutlet weak var btn_Next: UIButton!
    var arrVoiceName = [URL]()
    var arrVoiceUrl = [URL]()
    
    var arrRingtoneName = [URL]()
    var arrRingToneUrl = [URL]()
    var isCompletedVoice = false
    
    var arrImg = ["img 1","img 2","img 3"]
    var arrText = ["Need an Exit? Politely Vanish with Fake Call!😜","Hilarious Fake Calls Are\njust a Click Away!😉","Prank Your Friends with Celebrity Voices!😁"]

    var counter = 0
    var index = 0
    var index2 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UIApplication.didEnterBackgroundNotification.rawValue), object: nil)
//                  NotificationCenter.default.addObserver(self, selector: #selector(Did_EnterBackground(_:)),
//                                                         name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @IBAction func Tap_Next(_ sender: Any) {
        if counter < arrText.count {
            counter += 1
            
            if counter == 2 {
                // Update button title to "Prank Now!"
                    
                    btn_Next.setTitle("Prank Now!", for: .normal)
                    btn_Next.layoutIfNeeded()


            } else if counter == 3 {
                // Reset counter to 0
                counter = 0
                
                // Navigate to FeedbackVC
                let feedBackVC = storyboard?.instantiateViewController(withIdentifier: "FeedBackVC") as! FeedBackVC
                navigationController?.pushViewController(feedBackVC, animated: true) // Use animated transition
                
                return // Exit early after navigation to prevent further execution
            } else {
                // Default case: Update button title to "Next!"
                btn_Next.setTitle("Next", for: .normal)
//                btn_Next.imageEdgeInsets = UIEdgeInsets(top: 0, left: Utils().IpadorIphone(value: 110), bottom: 0, right:0 )
//                btn_Next.titleEdgeInsets = UIEdgeInsets(top: 0, left: Utils().IpadorIphone(value: -30), bottom: 0, right: 0)
            }
            
            // Scroll/select item in collection view based on updated counter
            let index = IndexPath(item: counter, section: 0)
            clv_Onboarding.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
            clv_Onboarding.selectItem(at: index, animated: true, scrollPosition: .centeredHorizontally)
        }

//        navigate.modalPresentationStyle = .fullScreen
//        navigate.isFromSetting = true
//               self.present(navigate, animated: true)
        
    }
    
}

extension OnBoadingVC {
    
    // Set Up UI
    func setUpUI () {
        btn_Next.layer.cornerRadius = Utils().IpadorIphone(value: 12)
        btn_Next.layer.masksToBounds = true
        btn_Next.setTitle("Next", for: .normal)
//        btn_Next.imageEdgeInsets = UIEdgeInsets(top: 0, left: Utils().IpadorIphone(value: 110), bottom: 0, right:0 )
//        btn_Next.titleEdgeInsets = UIEdgeInsets(top: 0, left: Utils().IpadorIphone(value: -30), bottom: 0, right: 0)

        setUpCollection()
//        callApiSounds()
    }
    
    // MARK: - set collection
    func setUpCollection() {
        DispatchQueue.main.async { [self] in
            
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let width: CGFloat = self.clv_Onboarding.bounds.width
            let  height: CGFloat = self.clv_Onboarding.bounds.height
            let size = CGSize(width: width, height: height)
            layout.itemSize = size
            self.clv_Onboarding.collectionViewLayout = layout
            self.clv_Onboarding.reloadData()
        }
    }

    // make Root
    func makeRootVC(storyBoardName : String, vcName : String) {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        let mainStoryBoard = UIStoryboard(name: storyBoardName, bundle: nil)
        let redViewController = mainStoryBoard.instantiateViewController(withIdentifier: vcName)
        window?.rootViewController = redViewController
        window?.makeKeyAndVisible()
    }
    
    func fetchData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }
        task.resume()
    }

}

// CollectionView Delegate Methods
extension OnBoadingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImg.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clv_Onboarding", for: indexPath) as! clv_Onboarding
        DispatchQueue.main.async { [self] in
            cell.img_Photos.image = UIImage(named: arrImg[indexPath.row])
            cell.lbl_Text.text = arrText[indexPath.row]
            cell.lbl_Text.textColor = Utils().RGBColor(red: 52, green: 61, blue: 67)

            if indexPath.row == 0 {
                let attributedText = NSMutableAttributedString(string: arrText[indexPath.row])
                let range1 = (arrText[0] as NSString).range(of: "Need an Exit?")
                attributedText.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1), range: range1)
                cell.lbl_Text.attributedText = attributedText
            } else if indexPath.row == 1 {
                let attributedText = NSMutableAttributedString(string: arrText[indexPath.row])
                let range2 = (arrText[1] as NSString).range(of: "Fake Calls")
                attributedText.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1), range: range2)
                cell.lbl_Text.attributedText = attributedText
            } else {
                let attributedText = NSMutableAttributedString(string: arrText[indexPath.row])
                let range2 = (arrText[2] as NSString).range(of: "Celebrity Voices!😁")
                attributedText.addAttribute(.foregroundColor, value: #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1), range: range2)
                cell.lbl_Text.attributedText = attributedText
                
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visiblerect = CGRect(origin: clv_Onboarding.contentOffset, size: clv_Onboarding.frame.size)
        let visiblePoint = CGPoint(x: visiblerect.midX , y: visiblerect.midY)
        if let visibleIndexPath = clv_Onboarding.indexPathForItem(at: visiblePoint) {
            counter = visibleIndexPath.row
        }

        if counter == 2 {
            btn_Next.setTitle("Prank Now!", for: .normal)
//            btn_Next.imageEdgeInsets = UIEdgeInsets(top: 0, left: Utils().IpadorIphone(value: 190), bottom: 0, right: 0)
//            btn_Next.titleEdgeInsets = UIEdgeInsets(top: 0, left: Utils().IpadorIphone(value: -50), bottom: 0, right: 0)
            
        } else if counter == 3 {
            counter = 0
        } else {
            btn_Next.setTitle("Next", for: .normal)
//            btn_Next.imageEdgeInsets = UIEdgeInsets(top: 0, left: Utils().IpadorIphone(value: 110), bottom: 0, right:0 )
//            btn_Next.titleEdgeInsets = UIEdgeInsets(top: 0, left: Utils().IpadorIphone(value: -30), bottom: 0, right: 0)
            
        }
    }
    
}

extension Notification.Name {
    static let audioDownloadInProgress = Notification.Name("audioDownloadInProgress")
    static let audioDownloadCompleted = Notification.Name("audioDownloadCompleted")
}


class clv_Onboarding:UICollectionViewCell {
    
    @IBOutlet weak var img_Photos: UIImageView!
    @IBOutlet weak var lbl_Text: UILabel!
    
}
