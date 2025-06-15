//
//  Extension.swift
//  Fake Call
//
//  Created by mac on 03/04/24.
//

import Foundation
import UIKit
extension UIView {
    
    func addBlurToView() {
        var blurEffect: UIBlurEffect!
        blurEffect = UIBlurEffect(style: .systemChromeMaterial)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = self.bounds
        blurredEffectView.alpha = 0.5
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredEffectView.layer.cornerRadius = Utils().IpadorIphone(value: 40)
        blurredEffectView.layer.masksToBounds = true
//        blurredEffectView.layer.zPosition =  0
//        view.sendSubviewToBack(blurredEffectView)
        self.addSubview(blurredEffectView)
      }
    
      func removeBlurFromView() {
        for subview in self.subviews {
          if subview is UIVisualEffectView {
            subview.removeFromSuperview()
          }
        }
      }

    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension UIImageView {
    
    func addBlurToViews() {
        var blurEffect: UIBlurEffect!
        blurEffect = UIBlurEffect(style: .systemThinMaterialDark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = self.bounds
        blurredEffectView.alpha = 1.0
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurredEffectView)
    }
    
    func removeBlurFromViews() {
        for subview in self.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
    }
    
    func roundCornerss(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

