//
//  TextEditVC.swift
//  Fake Call
//
//  Created by mac on 17/04/24.
//

import UIKit
import Kingfisher
import MarqueeLabel

class TextEditVC: UIViewController {

    @IBOutlet weak var cancel_VIew: UIView!
    @IBOutlet weak var done_View: UIView!
    @IBOutlet weak var textEdit_View: UIView!
    
    @IBOutlet weak var clockBg_View: UIImageView!
    @IBOutlet weak var msgBg_View: UIImageView!
    @IBOutlet weak var img_Wallpaper: UIImageView!
    
    @IBOutlet weak var lbl_Name: MarqueeLabel!
    
    @IBOutlet weak var clv_Text: UICollectionView!
    @IBOutlet weak var clv_Color: UICollectionView!
        
    @IBOutlet weak var lbl_Tital: UILabel!
    @IBOutlet weak var font_Slider: UISlider!
    
    @IBOutlet weak var btn_Done: UIButton!
    var Name = String()
    var textSelectedIndex = 0
    var ColorSelectedIndex = -1
    var contacts = CallerIds()
    var arrcallerids = [CallerId]()

    var arrTextImage = ["Text 1","Text 2","Text 3","Text 4"]
    var arrColor = [UIColor]()
    
    var FontName = String()
    var FontColor = UIColor.white
    
    
    var wallpaper = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

        SetUI()
    }
    
    // Status Bar Hidden
    override var prefersStatusBarHidden: Bool {
        return true // Set to true to hide the status bar
    }
    
    // tap_Cancel
    @IBAction func tap_Cancel(_ sender: Any) {
        
        navigationController?.popViewController(animated: true)
        let vc = self.navigationController?.viewControllers.last as! ContactDetailsVC
        vc.isCancle = false
        
    }
    
    // tap_Done
    @IBAction func tap_Done(_ sender: Any) {
        let userInfo: [AnyHashable: Any] = ["FontName": FontName, "FontColor": FontColor.toHexString()]
        NotificationCenter.default.post(name: Notification.Name("textFontAndColor"), object: nil, userInfo: userInfo)
        navigationController?.popViewController(animated: true)
        let vc = self.navigationController?.viewControllers.last as! ContactDetailsVC
        vc.isCancle = true

    }
    
    // tap_font_Slider
    @IBAction func tap_TextSlider(_ sender: UISlider) {
        let steps: [Float] = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]  // Including 0.0 and 1.0 for completeness
        btn_Done.isEnabled = true
        done_View.backgroundColor = Utils().RGBColor(red: 104, green: 206, blue: 103)
        // Calculate the nearest step value
        let sliderValue = sender.value
        let nearestStep = steps.min(by: { abs($0 - sliderValue) < abs($1 - sliderValue) }) ?? 0.0
        
        // Set the slider value to the nearest step
        sender.value = nearestStep
        
        if textSelectedIndex == 0 {
            switch sender.value {
            case 0.0 :
                lbl_Name.font = UIFont.init(name:"SFProText-Thin" , size: 55)
                FontName = "SFProText-Thin"
            case 0.2 :
                lbl_Name.font = UIFont.init(name:"SFProText-Medium" , size: 55)
                FontName = "SFProText-Regular"

            case 0.6 :
                lbl_Name.font = UIFont.init(name:"SFProText-Semibold" , size: 55)
                FontName = "SFProText-Semibold"

            case 0.8 :
                lbl_Name.font = UIFont.init(name:"SFProText-Bold" , size: 55)
                FontName = "SFProText-Bold"

            case 1.0 :
                lbl_Name.font = UIFont.init(name:"SFProText-Heavy" , size: 55)
                FontName = "SFProText-Heavy"

            default:
                break;
            }

        } else if textSelectedIndex == 1 {
            switch sender.value {
            case 0.0 :
                lbl_Name.font = UIFont.init(name:"SFProRounded-Thin" , size: 55)
                FontName = "SFProRounded-Thin"
            case 0.2 :
                lbl_Name.font = UIFont.init(name:"SFProRounded-Regular" , size: 55)
                FontName = "SFProRounded-Regular"

            case 0.6 :
                lbl_Name.font = UIFont.init(name:"SFProRounded-Semibold" , size: 55)
                FontName = "SFProRounded-Semibold"

            case 0.8 :
                lbl_Name.font = UIFont.init(name:"SFProRounded-Bold" , size: 55)
                FontName = "SFProRounded-Bold"

            case 1.0 :
                lbl_Name.font = UIFont.init(name:"SFProRounded-Heavy" , size: 55)
                FontName = "SFProRounded-Heavy"

                
            default:
                break;
            }
        }  else if textSelectedIndex == 2 {
            switch sender.value {
            case 0.0 :
                lbl_Name.font = UIFont.init(name:"PlayfairDisplay-Regular" , size: 55)
                FontName = "PlayfairDisplay-Regular"
            case 0.2 :
                lbl_Name.font = UIFont.init(name:"PlayfairDisplay-Medium" , size: 55)
                FontName = "PlayfairDisplay-Medium"
            case 0.6 :
                lbl_Name.font = UIFont.init(name:"PlayfairDisplay-Semibold" , size: 55)
                FontName = "PlayfairDisplay-Semibold"
            case 0.8 :
                lbl_Name.font = UIFont.init(name:"PlayfairDisplay-Bold" , size: 55)
                FontName = "PlayfairDisplay-Bold"
            case 1.0 :
                lbl_Name.font = UIFont.init(name:"PlayfairDisplay-Black" , size: 55)
                FontName = "PlayfairDisplay-Black"
            default:
                break;
            }
        } else if textSelectedIndex == 3 {
            switch sender.value {
            case 0.0 :
                lbl_Name.font = UIFont.init(name:"SF Mono Light" , size: 55)
                FontName = "SF Mono Light"
            case 0.2 :
                lbl_Name.font = UIFont.init(name:"SF Mono Medium" , size: 55)
                FontName = "SF Mono Medium"

            case 0.6 :
                lbl_Name.font = UIFont.init(name:"SF Mono Semibold" , size: 55)
                FontName = "SF Mono Semibold"

            case 0.8 :
                lbl_Name.font = UIFont.init(name:"SF Mono Bold" , size: 55)
                FontName = "SF Mono Bold"

            case 1.0 :
                lbl_Name.font = UIFont.init(name:"SF Mono Heavy" , size: 55)
                FontName = "SF Mono Heavy"

            default:
                break;
            }
        }

   
    }
    
}

extension TextEditVC {
    
    // Set UP UI
    func SetUI() {
        navigationController?.isNavigationBarHidden = true
        btn_Done.isEnabled = false
        done_View.backgroundColor = Utils().RGBColor(red: 104, green: 206, blue: 103)
        lbl_Name.scrollDuration = 8.0

        cancel_VIew.layer.cornerRadius = 12
        done_View.layer.cornerRadius = 12
        cancel_VIew.layer.masksToBounds = true
        done_View.layer.masksToBounds = true
        
        clockBg_View.layer.cornerRadius = clockBg_View.bounds.height / 2
        msgBg_View.layer.cornerRadius = msgBg_View.bounds.height / 2
        
        lbl_Name.textColor = FontColor
        
        
        DispatchQueue.main.async {
            self.textEdit_View.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        }
//        textEdit_View.addBlurToView(zPosition: 0, view: textEdit_View)
        
        textEdit_View.layer.zPosition = 0
        clv_Text.layer.zPosition = 1
        clv_Color.layer.zPosition = 1
        font_Slider.layer.zPosition = 1
        lbl_Tital.layer.zPosition = 1
        
        lbl_Name.layer.borderWidth = 3
        lbl_Name.layer.borderColor = Utils().RGBColor(red: 255, green: 255, blue: 255,alpha: 0.6).cgColor
        lbl_Name.layer.cornerRadius = 12
        lbl_Name.layer.masksToBounds = true

        setUpCollection()
        lbl_Name.text = Name
        
        arrColor = [
            UIColor(red: 0/255, green: 255/255, blue: 56/255, alpha: 1.0),
            UIColor(red: 0/255, green: 87/255, blue: 255/255, alpha: 1.0),
            UIColor(red: 219/255, green: 0/255, blue: 255/255, alpha: 1.0),
            UIColor(red: 99/255, green: 30/255, blue: 111/255, alpha: 1.0),
            UIColor(red: 0/255, green: 178/255, blue: 255/255, alpha: 1.0),
            UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1.0),
            UIColor(red: 166/255, green: 31/255, blue: 105/255, alpha: 1.0),
            UIColor(red: 252/255, green: 115/255, blue: 0/255, alpha: 1.0),
            UIColor(red: 129/255, green: 12/255, blue: 168/255, alpha: 1.0),
            UIColor(red: 242/255, green: 146/255, blue: 29/255, alpha: 1.0),
            UIColor(red: 230/255, green: 250/255, blue: 3/255, alpha: 1.0),
            UIColor(red: 200/255, green: 255/255, blue: 212/255, alpha: 1.0)
        ]
        
        img_Wallpaper.image = wallpaper
        
        // set Color Selection Border Accoding Selected Color
        for (index,value) in arrColor.enumerated() {
            if value == FontColor {
                ColorSelectedIndex = index
            }
        }
 
    }
    
    // set UP collection
    func setUpCollection() {
        //        DispatchQueue.main.async { [self] in
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        var clv_Textwidth = Double()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let layouts: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layouts.minimumLineSpacing = 0
        layouts.minimumInteritemSpacing = 0
        layouts.scrollDirection = .horizontal
        layouts.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        if UIDevice.current.userInterfaceIdiom == .pad {
            clv_Textwidth = 2
        } else {
            clv_Textwidth = 4.8
        }
        

        let width: CGFloat = self.clv_Text.bounds.width / clv_Textwidth
        let  height: CGFloat = self.clv_Text.bounds.height
        let size = CGSize(width: width, height: height)
        
        let widths: CGFloat = self.clv_Color.bounds.width / 4
        let  heights: CGFloat = self.clv_Color.bounds.height
        let sizse = CGSize(width: widths, height: heights)

        layout.itemSize = size
        self.clv_Text.collectionViewLayout = layout
        self.clv_Text.reloadData()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            layouts.itemSize = sizse
            self.clv_Color.collectionViewLayout = layouts
            self.clv_Color.reloadData()
            
        }

        
    }
    
    //  open the color picker
    func openColorPicker() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true, completion: nil)
    }

}

// clv
extension TextEditVC:UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clv_Text {
            return arrTextImage.count
        } else {
            return arrColor.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == clv_Text {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clv_Text_Cell", for: indexPath) as! clv_Text_Cell
            cell.img_TextView.image = UIImage(named: arrTextImage[indexPath.row])
            cell.textBorder_View.layer.borderWidth = 2.5
            cell.textBorder_View.layer.borderColor = Utils().RGBColor(red: 104, green: 206, blue: 103).cgColor
            cell.textBorder_View.layer.backgroundColor = UIColor.clear.cgColor
            
            cell.textBorder_View.layer.cornerRadius = 12
            cell.textBorder_View.layer.masksToBounds = true
            
            if textSelectedIndex == indexPath.row {
                cell.textBorder_View.layer.borderWidth = 2.5
                cell.textBorder_View.layer.borderColor = Utils().RGBColor(red: 104, green: 206, blue: 103).cgColor
                
            } else {
                cell.textBorder_View.layer.borderWidth = 0
                
            }
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "clv_Color_Cell", for: indexPath) as! clv_Color_Cell
            //        cell.border_VIew.isHidden = true
            cell.colorBg_View.layer.cornerRadius = cell.colorBg_View.bounds.height / 2
            cell.border_VIew.layer.cornerRadius = cell.border_VIew.bounds.height / 2
            cell.border_VIew.backgroundColor = .clear
        
            if indexPath.row == 0 {
                cell.colorBg_View.backgroundColor = .clear
                if let backgroundImage = UIImage(named: "color piker") {
                    let backgroundLayer = CALayer()
                    backgroundLayer.contents = backgroundImage.cgImage
                    backgroundLayer.frame = cell.colorBg_View.bounds
                    backgroundLayer.contentsGravity = .resizeAspectFill
                    backgroundLayer.masksToBounds = true
                    
                    cell.colorBg_View.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                    cell.colorBg_View.layer.insertSublayer(backgroundLayer, at: 0)
                }
            } else {
                cell.colorBg_View.backgroundColor = arrColor[indexPath.row]
                cell.colorBg_View.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            }
            
            
            if ColorSelectedIndex == indexPath.row {
                cell.border_VIew.layer.borderWidth = 3
                cell.border_VIew.layer.borderColor = Utils().RGBColor(red: 104, green: 206, blue: 103).cgColor

                // Ensure arrColor has a valid index
                if ColorSelectedIndex != 0 {
                    lbl_Name.textColor = arrColor[ColorSelectedIndex]
                    FontColor = lbl_Name.textColor
                } else {
                  cell.border_VIew.layer.borderWidth = 0
                   openColorPicker()
                }
            } else {
                cell.border_VIew.layer.borderWidth = 0
            }

            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        btn_Done.isEnabled = true
        done_View.backgroundColor = Utils().RGBColor(red: 104, green: 206, blue: 103)

        if collectionView == clv_Text {
            font_Slider.value = 0.5

            textSelectedIndex = indexPath.row
            clv_Text.reloadData()
            
            if indexPath.row == 0 {
                lbl_Name.font = UIFont.init(name:"SFProText-Semibold" , size: 55)
            } else if indexPath.row == 1 {
                lbl_Name.font = UIFont.init(name:"SFProRounded-Semibold" , size: 55)

            } else if indexPath.row == 2 {
                lbl_Name.font = UIFont.init(name:"PlayfairDisplay-Semibold" , size: 55)

            } else if indexPath.row == 3 {
                lbl_Name.font = UIFont.init(name:"SF Mono Semibold" , size: 55)

            }
            
        } else {
            
            ColorSelectedIndex = indexPath.row
            clv_Color.reloadData()
        }
        
    }
    
}

@available(iOS 14.0, *)
extension TextEditVC:UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        lbl_Name.textColor = selectedColor
        FontColor = selectedColor
    }
 
}


// clv_Text Cell
class clv_Text_Cell:UICollectionViewCell {
    @IBOutlet weak var img_TextView: UIImageView!
    
    @IBOutlet weak var textBorder_View: UIView!
}

// clv_Color Cell
class clv_Color_Cell:UICollectionViewCell {
    
    @IBOutlet weak var colorBg_View: UIView!
    
    @IBOutlet weak var border_VIew: UIView!
}


extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([
            .traits: [
                UIFontDescriptor.TraitKey.weight: weight
            ]
        ])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
