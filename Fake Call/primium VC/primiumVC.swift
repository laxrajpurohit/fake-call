//
//  primiumVC.swift
//  Fake Call
//
//  Created by mac on 02/05/24.
//

import UIKit

class primiumVC: UIViewController {

    @IBOutlet weak var tbl_Plans: UITableView!
    @IBOutlet weak var bg_View: UIView!
    @IBOutlet weak var btn_Plans: UIButton!
    
    @IBOutlet weak var bgView_Height: NSLayoutConstraint!
    @IBOutlet weak var btn_Cancle: UIButton!
    @IBOutlet weak var lbl_Plans: UILabel!
    @IBOutlet weak var clv_Review: UICollectionView!
    
    @IBOutlet weak var img_VIew: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
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
    var timer = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    @IBAction func tap_Cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btn_UpgradePlans(_ sender: Any) {
        
    }
    
}

extension primiumVC {
    // set Up UI
    func setUpUI() {
        DispatchQueue.main.async { [self] in
            if Device.DeviceType.IS_Small {
                bgView_Height.constant = Utils().IpadorIphone(value: 390)
            } else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    bgView_Height.constant = 580

                } else {
                    bgView_Height.constant = 400

                }

            }
            scrollView.delegate = self
            btn_Cancle.isHidden = true
            btn_Plans.setTitle("Try It Free", for: .normal)
            navigationController?.isNavigationBarHidden = true
            bg_View.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            bg_View.layer.cornerRadius = 10
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(scrollCollReview), userInfo: nil, repeats: true)
            setUpCollection()
            btn_Plans.layer.cornerRadius = 12
            btn_Plans.layer.masksToBounds = true

            bg_View.layer.shadowColor = UIColor.black.cgColor
            bg_View.layer.shadowOpacity = 0.3
            bg_View.layer.shadowOffset = .zero
            bg_View.layer.shadowRadius = 5

        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.btn_Cancle.isHidden = false
        }
    }
    
    // Auto Scroll review
    @objc func scrollCollReview() {
            let nextIndex = (currentIndex + 1) % 7
            let indexPath = IndexPath(item: nextIndex, section: 0)
            clv_Review.scrollToItem(at: indexPath, at: .right, animated: true)
            currentIndex = nextIndex
    }
    
    // MARK: - set collection
    func setUpCollection() {
        DispatchQueue.main.async { [self] in
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
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
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
         if (scrollView.contentOffset.y <= -50) {
            self.img_VIew.transform = CGAffineTransformMakeScale(1 - (offset.y - -50)/120, 1 - (offset.y - -50)/120)
        }
    }

}

// TableView Delegate Methods
extension primiumVC:UITableViewDelegate,UITableViewDataSource {
    
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
        cell.layer.backgroundColor = UIColor.clear.cgColor
        
        if indexPath.row == index {
            cell.bg_View.layer.borderWidth = 2
            cell.bg_View.layer.borderColor = #colorLiteral(red: 0.4079999924, green: 0.8080000281, blue: 0.4040000141, alpha: 1)
            let color = #colorLiteral(red: 0.4078431373, green: 0.8078431373, blue: 0.4039215686, alpha: 0.5)
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
            cell.topConstant_Plans.constant = Utils().IpadorIphone(value: 12)
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
        
        if indexPath.row == 0 {
            btn_Plans.setTitle("Continue", for: .normal)

        } else if indexPath.row == 1 {
            btn_Plans.setTitle("Try It Free", for: .normal)

        } else {
            btn_Plans.setTitle("Continue", for: .normal)

        }
    }
        
}

// Collection Delegate Methods
extension primiumVC:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return arrReview.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clv_Review_Cell", for: indexPath) as! clv_Review_Cell
        cell.lbl_Reviews.text = arrReview[indexPath.row]
        cell.lbl_ReviewerName.text = arrReviewerName[indexPath.row]
        
        cell.bg_View.layer.cornerRadius = 16
        cell.bg_View.layer.masksToBounds = true

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
    }
        
}




