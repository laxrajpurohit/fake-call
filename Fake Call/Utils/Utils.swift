//
//  Utils.swift
//  SwiftDemo
//
//  Created by Redspark on 19/12/17.
//  Copyright © 2017 Redspark. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration
import EventKit
import StoreKit
import QuickLook

class Utils: NSObject {
    
    static var shadowOpacity = Float()
    static var shadowRadius = CGFloat()
    static var shadowOffset = CGFloat()
    static var shadowOffsetSize = CGSize.zero

    static var shadowColor:CGColor!

    func isConnectedToNetwork() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func showAlert(_ message: String) {
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
        
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController!.present(alert, animated: true, completion: nil)
        
    }
    
    func showDialouge(_ title: String,_ message: String, view: UIViewController){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
        view.present(alert, animated: true, completion: nil)
    }
    
    func showAlertControllerWith(title:String, message:String?, onVc:UIViewController , style: UIAlertController.Style = .alert, buttons:[String], completion:((Bool,Int)->Void)?) -> Void {

         let alertController = UIAlertController.init(title: title, message: message, preferredStyle: style)
         for (index,title) in buttons.enumerated() {
             let action = UIAlertAction.init(title: title, style: UIAlertAction.Style.default) { (action) in
                 completion?(true,index)
             }
             alertController.addAction(action)
         }

         onVc.present(alertController, animated: true, completion: nil)
     }

    func ShowLoader(text: String) {

         self.HideLoader()
         let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
         let backgroundView = UIView()
         let backView = UIView()
         backgroundView.frame = CGRect.init(x: 0, y: 0, width: window!.bounds.width, height: window!.bounds.height)
         backView.frame = CGRect.init(x: 0, y: 0, width: 80, height: 80)
         backView.layer.cornerRadius = 10
         backView.layer.masksToBounds = true
         backView.center = window!.center
         backView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
         backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
         backgroundView.tag = 475647

         var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
         activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
         activityIndicator.center = window!.center
         activityIndicator.hidesWhenStopped = true
         activityIndicator.style = .large
         activityIndicator.color = .white
         activityIndicator.startAnimating()
         backgroundView.addSubview(backView)
         backgroundView.addSubview(activityIndicator)
         let label = UILabel()
         label.frame = CGRect.init(x: 5, y: backView.frame.origin.y + 5, width: backView.bounds.width - 10, height: 10)
         label.center = CGPoint(x: window!.bounds.width / 2, y: window!.bounds.height / 2 + 25)
         label.text = text
         label.textAlignment = .center
         label.font = UIFont.systemFont(ofSize: 9)
         label.textColor = .white
         backgroundView.addSubview(label)
         window?.addSubview(backgroundView)
    }

    func HideLoader() {
        
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if let background = window?.viewWithTag(475647){
            background.removeFromSuperview()
        }

    }

    func resizeImage(image: UIImage) -> UIImage {
        
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = 800.0
        let maxWidth: Float = 800.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 1.0
        //50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img!.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
    }
    
    func height(forText text: String?, font: UIFont?, withinWidth width: CGFloat) -> CGFloat {
        
        let constraint = CGSize(width: width, height: 20000.0)
        var size: CGSize
        var boundingBox: CGSize? = nil
        if let aFont = font {
            boundingBox = text?.boundingRect(with: constraint, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: aFont], context: nil).size
        }
        size = CGSize(width: ceil((boundingBox?.width)!), height: ceil((boundingBox?.height)!))
        return size.height
    }
    
    func ConvertDate(date: Date) -> String {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        let resultString = inputFormatter.string(from: date)
        return resultString
    }
    
    func ConvertStringToDate1(stringDate: String) -> String {
        
        let dateFormatterUK = DateFormatter()
        dateFormatterUK.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatterUK.date(from: stringDate)!
        dateFormatterUK.dateFormat = "dd MMM yyyy hh:mm a"
        let resultString = dateFormatterUK.string(from: date)
        return resultString
    }
    
    func ConvertStringToDate(stringDate: String) -> Date {
        
        let dateFormatterUK = DateFormatter()
        dateFormatterUK.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatterUK.date(from: stringDate)!
        return date
    }
    
    func getImageFromDocumentDirectory(fileName: String) -> UIImage? {
        let fileURL = CreateURL().documentsUrl().appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func IpadorIphone(value:Double) -> Double{
        if UIDevice.current.userInterfaceIdiom == .pad {
            return ((value / 2) * 3)
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            return value
        } else {
            return value
        }
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func hexStringFromColor(color: UIColor) -> String {
        let components = color.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0

        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        print(hexString)
        return hexString
     }
    
    func getPastTime(for date : Date) -> String {

        var secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }

        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day

        if secondsAgo < minute  {
            if secondsAgo < 2{
                return "just now"
            }else{
                return "\(secondsAgo) secs"
            }
        } else if secondsAgo < hour {
            let min = secondsAgo/minute
            if min == 1{
                return "\(min) min"
            }else{
                return "\(min) mins"
            }
        } else if secondsAgo < day {
            let hr = secondsAgo/hour
            if hr == 1{
                return "\(hr) hr"
            } else {
                return "\(hr) hrs"
            }
        } else if secondsAgo < week {
            let day = secondsAgo/day
            if day == 1{
                return "Yesterday"
            }else{
                
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/mm/yyyy"
              //  formatter.locale = Locale(identifier: "en_US")
                let strDate: String = formatter.string(from: date)
                return strDate
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/mm/yyyy"
          //  formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate
        }
    }
    
    func getAllCountry() -> [String] {
        
        var countries: [String] = []
        for code in NSLocale.isoCountryCodes  {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
        }
        return countries
    }
    
    func getLabelsInView(view: UIView) -> [UILabel] {
        var results = [UILabel]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UILabel {
                results += [labelView]
            } else {
                results += getLabelsInView(view: subview)
            }
        }
        return results
    }
    
    func getButtonsInView(view: UIView) -> [UIButton] {
        var results = [UIButton]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UIButton {
                results += [labelView]
            } else {
                results += getButtonsInView(view: subview)
            }
        }
        return results
    }
    
    func getTextfieldsInView(view: UIView) -> [UITextField] {
        var results = [UITextField]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UITextField {
                results += [labelView]
            } else {
                results += getTextfieldsInView(view: subview)
            }
        }
        return results
    }
    
    func getTextviewInView(view: UIView) -> [UITextView] {
        var results = [UITextView]()
        for subview in view.subviews as [UIView] {
            if let labelView = subview as? UITextView {
                results += [labelView]
            } else {
                results += getTextviewInView(view: subview)
            }
        }
        return results
    }
        
    func giveRating()  {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var RateUsCount : Int = 0
            if(Constants.USERDEFAULTS.value(forKey: "isRate") != nil){
                RateUsCount = Constants.USERDEFAULTS.value(forKey: "isRate") as! Int
                RateUsCount += 1
                Constants.USERDEFAULTS.set(RateUsCount, forKey: "isRate")
            }
            else{
                Constants.USERDEFAULTS.set(RateUsCount, forKey: "isRate")
            }
            
            if(RateUsCount > 3){
                Constants.USERDEFAULTS.removeObject(forKey: "isRate")
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    func createMaskImage(from image: UIImage) -> UIImage? {
          guard let cgImage = image.cgImage else {
              return nil
          }
          
          let colorSpace = CGColorSpaceCreateDeviceGray()
          let bitmapInfo = CGImageAlphaInfo.none.rawValue
          
          // Create a bitmap context with the size of the image
          if let context = CGContext(data: nil,
                                     width: cgImage.width,
                                     height: cgImage.height,
                                     bitsPerComponent: 8,
                                     bytesPerRow: 0,
                                     space: colorSpace,
                                     bitmapInfo: bitmapInfo) {
              
              // Draw the image on the context, converting it to grayscale
              context.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
              
              // Create a CGImage from the context
              if let maskImage = context.makeImage() {
                  // Create a UIImage from the CGImage
                  let maskedUIImage = UIImage(cgImage: maskImage)
                  return maskedUIImage
              }
          }
          
          return nil
      }
    
    func applyMaskToImage(originalImage: UIImage, maskImage: UIImage) -> UIImage? {
           autoreleasepool {
               guard let originalCGImage = originalImage.cgImage,
                     let maskCGImage = maskImage.cgImage else {
                   return nil
               }
               
               let imageSize = CGSize(width: originalCGImage.width, height: originalCGImage.height)
               
               guard let bitmapContext = CGContext(data: nil,
                                                   width: Int(imageSize.width),
                                                   height: Int(imageSize.height),
                                                   bitsPerComponent: 8,
                                                   bytesPerRow: 0,
                                                   space: CGColorSpaceCreateDeviceRGB(),
                                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                   return nil
               }
               
               bitmapContext.clip(to: CGRect(origin: .zero, size: imageSize), mask: maskCGImage)
               bitmapContext.draw(originalCGImage, in: CGRect(origin: .zero, size: imageSize))
               
               guard let finalCGImage = bitmapContext.makeImage() else {
                   return nil
               }
               
               let finalUIImage = UIImage(cgImage: finalCGImage)
               
               // Convert the UIImage to PNG representation
               guard let pngData = finalUIImage.pngData() else {
                   return nil
               }
               
               // Create a new UIImage from the PNG data
               guard let pngImage = UIImage(data: pngData) else {
                   return nil
               }
               
               return pngImage
           }
       }

    func setupHome() {
        
        DispatchQueue.main.async {
            
            guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
                return
            }

            let rootViewController = Constants.storyBoard.instantiateViewController(withIdentifier: "Homevc") as? HomeVC

            let navigationController = UINavigationController(rootViewController: rootViewController!)
            navigationController.isNavigationBarHidden = true

            window.rootViewController = navigationController
            window.makeKeyAndVisible()

            let options: UIView.AnimationOptions = .transitionCrossDissolve
            UIView.transition(with: window, duration: 0.3, options: options, animations: {}, completion:
            { completed in
                // maybe do something on completion here
            })
        }
    }

    
    func imageFromBase64(_ base64: String) -> UIImage? {
        if let url = URL(string: base64), let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    func extractObjectFromImage(_ inputImage: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: inputImage) else {
            return nil
        }
        
        // Create an alpha mask
        let filter = CIFilter(name: "CIMaskToAlpha")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let alphaMask = filter.outputImage {
            // Apply the alpha mask to the original image
            let blendedFilter = CIFilter(name: "CIBlendWithAlphaMask")!
            blendedFilter.setValue(ciImage, forKey: kCIInputImageKey)
            blendedFilter.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
            blendedFilter.setValue(alphaMask, forKey: kCIInputMaskImageKey)
            
            if let outputImage = blendedFilter.outputImage {
                // Convert CIImage to UIImage
                let context = CIContext(options: nil)
                if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                    let extractedUIImage = UIImage(cgImage: cgImage)
                    return extractedUIImage
                }
            }
        }
        return nil
    }
    
    func withShadow(imageView:UIImageView ,shadowOpacity:Float,shadowRadius:CGFloat,shadowOffset:CGFloat,shadowColor:UIColor) {
         imageView.layer.shadowOpacity = shadowOpacity
         imageView.layer.shadowRadius = shadowRadius / 2
         imageView.layer.shadowOffset = CGSizeMake(shadowOffset + (shadowOffset / 2), 3.5)
         imageView.layer.shadowColor =  shadowColor.cgColor
        
        Utils.shadowOpacity = shadowOpacity
        Utils.shadowRadius = shadowRadius
        Utils.shadowOffset = shadowOffset 
        Utils.shadowColor = shadowColor.cgColor
    }
    
    func withShadows(imageView:UIImageView ,shadowOpacity:Float,shadowRadius:CGFloat,shadowOffset:CGFloat,shadowColor:CGColor) {
        imageView.layer.shadowOpacity = shadowOpacity
        imageView.layer.shadowRadius = shadowRadius / 2
        imageView.layer.shadowOffset = CGSizeMake(shadowOffset + (shadowOffset / 12), 10)
        imageView.layer.shadowColor =  shadowColor
        
        Utils.shadowOpacity = shadowOpacity
        Utils.shadowRadius = shadowRadius
        Utils.shadowRadius = shadowOffset
        Utils.shadowColor = shadowColor
    }
    
    func getGlobleShadowValue(imageView:UIImageView,tag:Int ) {
                
//        if let savedUserdefaultData = UserDefaults.standard.data(forKey: "shadowValuesStoreDic") {
//            // Unarchive the Data back to the original array format
//            if let decodedArray = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedUserdefaultData) as? [Int: [String: Any]] {
//
//                Utils.shadowOpacity = decodedArray[tag]?["savedShadowColor"] as! Float
//                Utils.shadowRadius = CGFloat(decodedArray[tag]?["savedShadowColor"] as! Float)
//                Utils.shadowOffset = CGFloat(decodedArray[tag]?["savedShadowColor"] as! Float)
//                Utils.shadowColor = decodedArray[tag]?["savedShadowColor"] as! Float as! CGColor
//            }
//        }
        
//        var color = UIColor()
//        if let savedUserdefaultData = UserDefaults.standard.data(forKey: "userdefaultShadowValues") {
//            // Unarchive the Data back to the original array format
//            if let decodedArray = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedUserdefaultData) as? [Int: [String: Any]] {
//
//                if  decodedArray[tag]?["shadowOpacity"]  != nil  {
//
//                        if decodedArray[tag]?["savedShadowColor"] != nil {
//                            color = Utils().hexStringToUIColor(hex: (decodedArray[tag]?["savedShadowColor"]!)! as! String)
//                            imageView.layer.shadowColor = color.cgColor
//                        }
//
//                    if decodedArray[tag]?["shadowOpacity"] is NSNumber {
//                        imageView.layer.shadowOpacity = Float(truncating: decodedArray[tag]?["shadowOpacity"] as! NSNumber)
//                        imageView.layer.shadowRadius =  CGFloat(truncating: decodedArray[tag]?["shadowRadius"] as! NSNumber)
//                        // imgView.layer.shadowOffset = CGSize(width: 5, height: 5)
//                        imageView.layer.shadowOffset = CGSizeMake(decodedArray[tag]?["offset"] as! CGFloat, 7)
//
//                    } else {
//                        imageView.layer.shadowOpacity = decodedArray[tag]?["shadowOpacity"] as! Float
//                        imageView.layer.shadowRadius =  CGFloat(decodedArray[tag]?["shadowRadius"] as! Float)
//                        // imgView.layer.shadowOffset = CGSize(width: 5, height: 5)
//                        imageView.layer.shadowOffset = CGSizeMake(decodedArray[tag]?["offset"] as! CGFloat, 7)
//
//                    }
//
//                } else {
//                    imageView.layer.shadowOpacity = Utils.shadowOpacity
//                    imageView.layer.shadowRadius = Utils.shadowRadius
//                    imageView.layer.shadowOffset = CGSizeMake(Utils.shadowOffset , 7)
//                    imageView.layer.shadowColor =  Utils.shadowColor
//
//                }
//            }
//        }
         
        imageView.layer.shadowOpacity = Utils.shadowOpacity
        imageView.layer.shadowRadius = Utils.shadowRadius
//        imageView.layer.shadowOffset = CGSizeMake(Utils.shadowOffsetSize , 7)
        imageView.layer.shadowOffset =  Utils.shadowOffsetSize
        imageView.layer.shadowColor =  Utils.shadowColor

        
                
    
    }
    
    func hexStringFromCGColor(_ color: CGColor) -> String? {
        // Get the color space
        guard let components = color.components, components.count >= 3 else {
            return nil
        }

        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)

    }
    
    
    func getImageAspectRatio(width:Int , height:Int) -> Double {
        
        
        // Calculate the greatest common divisor (GCD) of width and height
        func gcd(_ a: Int, _ b: Int) -> Int {
            if b == 0 {
                return a
            }
            return gcd(b, a % b)
        }
        
        let intWidth = Int(width)
        let intHeight = Int(height)
        let divisor = gcd(intWidth, intHeight)
        let simplifiedWidth = CGFloat(width) / CGFloat(divisor)
        let simplifiedHeight = CGFloat(height) / CGFloat(divisor)
        
        // Predefined common aspect ratios
        let commonRatios: [(Int, Int)] = [(4, 3), (16, 9), (9, 16), (3, 4), (1, 1)]
        
        var closestRatio = commonRatios.first!
        var minDifference = abs(simplifiedWidth / simplifiedHeight - CGFloat(closestRatio.0) / CGFloat(closestRatio.1))
        
        // Find the closest common aspect ratio
        for ratio in commonRatios {
            let difference = abs(simplifiedWidth / simplifiedHeight - CGFloat(ratio.0) / CGFloat(ratio.1))
            if difference < minDifference {
                minDifference = difference
                closestRatio = ratio
            }
        }
        
        // Calculate the ratio as a Double
        let ratio = Double(closestRatio.0) / Double(closestRatio.1)
        
        return ratio
    }
    
    func showAlert(title:String , message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            // Handle OK button tap
        }
        
        alertController.addAction(okAction)
        
        // Present the alert
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }

    func RGBColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    func imageData(from image: UIImage) -> Data? {
        return image.jpegData(compressionQuality: 0.9) // Use JPEG representation
    }
    
    func presentAlert(title: String, message: String, cancelTitle: String, discardTitle: String, discardAction: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default, handler: nil)
        
        let discardAction = UIAlertAction(title: discardTitle, style: .destructive) { _ in
            discardAction()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(discardAction)
        
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
}

extension UIColor {
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let redInt = Int(red * 255)
            let greenInt = Int(green * 255)
            let blueInt = Int(blue * 255)

            return String(format: "#%02X%02X%02X", redInt, greenInt, blueInt)
        }

        return "#000000" // Default to black if unable to get components
    }
}

extension CGColor {
    func toHexString() -> String {
        guard let components = self.components, components.count >= 3 else {
            return "#000000" // Default to black if unable to get components
        }

        let red = Int(components[0] * 255)
        let green = Int(components[1] * 255)
        let blue = Int(components[2] * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
extension UIWindow {
    static var statusBarBackgroundColor: UIColor?
}


