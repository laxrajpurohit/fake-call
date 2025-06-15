//
//  FirstPremiumSubscriptionVC.swift
//  Fake Call
//
//  Created by mac on 01/05/24.
//

import UIKit

class FirstPremiumSubscriptionVC: UIViewController , UIScrollViewDelegate{

    @IBOutlet weak var tbl_Plans: UITableView!
    
    @IBOutlet weak var btn_Cancle: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btn_Plans: UIButton!
    @IBOutlet weak var plans_VIew: UIView!
    @IBOutlet weak var plans_VIew_Height: NSLayoutConstraint!
    @IBOutlet weak var tbl_Height: NSLayoutConstraint!
    @IBOutlet weak var btn_Continue: UIButton!
    @IBOutlet weak var clv_Review: UICollectionView!
    @IBOutlet weak var features_VIew: UIView!
    
    @IBOutlet weak var img_View: UIImageView!
    @IBOutlet weak var clv_Bottam: NSLayoutConstraint!
    
    var arrTIme = ["Monthly","Yearly","LifeTime"]
    var arrPrice = ["$1.99","$4.99","$9.99"]
    
    var arrReviewerName = ["Very use full app","Endless Laughter!","The app is feel like a real call","I love the idea behind this app","Great app","Never a Dull Moment!","A Lifesaver for Social Situations!"]
    
    var arrReview = ["This app has saved me from various situations where i wanted to just be out of it, it's one of my mosttt fav app.",
                     "This app is a prankster's dream!😌 I love customize each call with different themes and wallpapers.",
                     "Helps to move out of conversation or places.👍 Saved me lot of times.",
                     "it's been a blast using it to prank my friends. Especially when I'm switching between features.",
                     "The app is great and is definitely getting me out of so many situations. Thank yo so much",
                     "I can't stop laughing at this app! The voices are spot-on, and the option ringtones add so much fun.",
                     "Fake Call is absolutely fantastic—it's my go-to whenever I need a polite yet effective exit strategy from any situation."]
    
    var index = 1
    var currentIndex = 0
    var isExpanded = false
    var timer = Timer()
    public var IsCompletionHandlerNav: ((Bool) -> Void)?


    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        setUpUI()        
    }
    
    @IBAction func btn_ViewPlans(_ sender: Any) {
        // Determine the target heights based on the current state
        DispatchQueue.main.async { [self] in
            var targetTblHeight: CGFloat
            var targetPlansViewHeight: CGFloat
            let targetClvBottam: CGFloat


            if isExpanded {
                // If currently expanded, set heights to collapse
                targetTblHeight = Utils().IpadorIphone(value: 0)
                
                targetPlansViewHeight = Utils().IpadorIphone(value: 215)
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    targetPlansViewHeight =  270
                } else {
                    targetPlansViewHeight = 215
                }
                
                targetClvBottam = Utils().IpadorIphone(value: 200)
                btn_Plans.setTitle("View plans", for: .normal)
                
            } else {
                // If currently collapsed, set heights to expand
                targetTblHeight = Utils().IpadorIphone(value: 260)
//                if UIDevice.current.userInterfaceIdiom == .pad {
//                    targetTblHeight =  300
//                } else {
//                    targetTblHeight = 260
//                }
//
                targetPlansViewHeight = Utils().IpadorIphone(value: 425)
                
//                if UIDevice.current.userInterfaceIdiom == .pad {
//                    targetPlansViewHeight =  500
//                } else {
//                    targetPlansViewHeight = 434
//                }
                
                targetClvBottam = Utils().IpadorIphone(value: 420)

                btn_Plans.setTitle("View Less", for: .normal)
                
            }
            
            // Animate the height changes
            UIView.animate(withDuration: 0.3) {
                self.tbl_Height.constant = targetTblHeight
                self.plans_VIew_Height.constant = targetPlansViewHeight
                self.clv_Bottam.constant = targetClvBottam
                self.view.layoutIfNeeded() // Ensure layout updates immediately
            }
            
            // Toggle the flag for the next click
            isExpanded.toggle()
        }

    }
    
    @IBAction func tap_Cancel(_ sender: Any) {
        
        self.dismiss(animated: true) {
            self.IsCompletionHandlerNav!(true)
            
            let navController = self.storyboard?.instantiateViewController(withIdentifier: "OfferVC") as! OfferVC
                   navController.IsCompletionHandlerNavs = { bool in
                       navController.dismiss(animated:true) { [self] in
                           let navgation = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                           navgation.modalPresentationStyle = .fullScreen
                           present(navgation, animated: true)
                       }
                   }

            }

    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
         if (scrollView.contentOffset.y <= -50) {
            self.img_View.transform = CGAffineTransformMakeScale(1 - (offset.y - -50)/200, 1 - (offset.y - -50)/200)
        }
    }

}

  

extension FirstPremiumSubscriptionVC {
    // set Up UI
    func setUpUI() {
        DispatchQueue.main.async { [self] in
            self.btn_Cancle.isHidden = true

            plans_VIew.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
//            plans_VIew.layer.masksToBounds = true
            plans_VIew.layer.cornerRadius = 10
            btn_Plans.setTitle("View plans", for: .normal)
            tbl_Height.constant = Utils().IpadorIphone(value: 0)
            plans_VIew_Height.constant =  Utils().IpadorIphone(value: 215)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                plans_VIew_Height.constant =  270
            } else {
                plans_VIew_Height.constant = 215
            }
            
//            if Device.DeviceType.IS_Small {
//                plans_VIew_Height.constant = Utils().IpadorIphone(value: 270)
//            } else {
//                plans_VIew_Height.constant = Utils().IpadorIphone(value: 420)
//
//            }

            btn_Continue.layer.cornerRadius = 12
            btn_Continue.layer.masksToBounds = true
            features_VIew.layer.cornerRadius = 16
            features_VIew.layer.masksToBounds = true
            
            
            plans_VIew.layer.shadowColor = UIColor.black.cgColor
            plans_VIew.layer.shadowOpacity = 0.3
            plans_VIew.layer.shadowOffset = .zero
            plans_VIew.layer.shadowRadius = 5


//            setUpCollection()
        }
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(scrollCollReview), userInfo: nil, repeats: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.btn_Cancle.isHidden = false
        }
        
    }
    
    // MARK: - set collection
    func setUpCollection() {
        DispatchQueue.main.async {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 0
            layout.scrollDirection = .horizontal
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            let width: CGFloat = self.clv_Review.bounds.width
            let  height: CGFloat = self.clv_Review.bounds.height
            let size = CGSize(width: width, height: height)
            layout.itemSize = size
            self.clv_Review.collectionViewLayout = layout
            self.clv_Review.reloadData()
        }
        
    }
    
    // Auto Scroll review
    @objc func scrollCollReview() {
         DispatchQueue.main.async { [self] in
        
        let nextIndex = (currentIndex + 1) % 7
        let indexPath = IndexPath(item: nextIndex, section: 0)
        clv_Review.scrollToItem(at: indexPath, at: .right, animated: true)
        currentIndex = nextIndex
    }
        
      
    }
    

}


// TableView Delegate Methods
extension FirstPremiumSubscriptionVC:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTIme.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tbl_Plans_Cell", for: indexPath) as! tbl_Plans_Cell
        cell.selectionStyle = .none
        cell.bg_View.layer.cornerRadius = 12
        cell.bg_View.layer.masksToBounds = true
        cell.lbl_PlanTime.text = arrTIme[indexPath.row]
        cell.lbl_PlanPrice.text = arrPrice[indexPath.row]
        cell.lbl_FreeTrial.isHidden = true
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        cell.layer.backgroundColor = UIColor.red.cgColor
        
        if indexPath.row == index {
            cell.bg_View.layer.borderWidth = 2
            cell.bg_View.layer.borderColor = #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1)
            let color = #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 0.5)
            cell.bg_View.layer.backgroundColor = color.cgColor
            cell.img_RightTick.image = UIImage(named: "rightTick")
            cell.lbl_PlanTime.textColor = Utils().RGBColor(red: 104, green: 206, blue: 103)
            cell.lbl_PlanPrice.textColor = Utils().RGBColor(red: 104, green: 206, blue: 103)

        } else {
            cell.bg_View.layer.borderWidth = 0
            cell.bg_View.layer.backgroundColor = Utils().RGBColor(red: 246, green: 246, blue: 246).cgColor
            cell.img_RightTick.image = UIImage(named: "blankRing")
            cell.lbl_PlanTime.textColor = .label
            cell.lbl_PlanPrice.textColor = .label

        }
        
        if indexPath.row == 1 {
            cell.topConstant_Plans.constant =  Utils().IpadorIphone(value: 12)
            cell.lbl_FreeTrial.isHidden = false

        } else {
            cell.topConstant_Plans.constant = Utils().IpadorIphone(value: 22)
            cell.lbl_FreeTrial.isHidden = true

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        index = indexPath.row
        tbl_Plans.reloadData()
        
    }
    
}

// CollectionView Delegate Methods
extension FirstPremiumSubscriptionVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrReview.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clv_Review_Cell", for: indexPath) as! clv_Review_Cell
        cell.bg_View.layer.cornerRadius = 16
        cell.bg_View.layer.masksToBounds = true
        
        cell.lbl_Reviews.text = arrReview[indexPath.row]
        cell.lbl_ReviewerName.text = arrReviewerName[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == clv_Review {
            let width = collectionView.bounds.width
            let height = collectionView.bounds.height
            return CGSize(width: width, height: height)
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    //       func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //           let pageWidth = scrollView.frame.size.width
    //           let currentPage = Int(scrollView.contentOffset.x / pageWidth)
    //           pageController.currentPage = currentPage
    //       }
    //
}

// tbl_Plans Cell
class tbl_Plans_Cell:UITableViewCell {
    
    @IBOutlet weak var lbl_FreeTrial: UILabel!
    @IBOutlet weak var bg_View: UIView!
    @IBOutlet weak var lbl_PlanTime: UILabel!
    @IBOutlet weak var lbl_PlanPrice: UILabel!
    @IBOutlet weak var img_RightTick: UIImageView!
    @IBOutlet weak var topConstant_Plans: NSLayoutConstraint!
    
}

// clv_Review Cell
class clv_Review_Cell:UICollectionViewCell {
    
    @IBOutlet weak var bg_View: UIView!
    @IBOutlet weak var lbl_ReviewerName: UILabel!
    @IBOutlet weak var lbl_Reviews: UILabel!
 
}
