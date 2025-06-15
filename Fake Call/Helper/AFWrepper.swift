//
//  AFWrepper.swift
//  OfferTreat
//
//  Created by Redspark on 15/05/18.
//  Copyright © 2018 Redspark. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AFWrapper: NSObject{
    static var currentDataRequest: DataRequest?
    static func cancelCurrentRequest() {
        currentDataRequest?.cancel()
    }
 
    class func PostDataForRemoveBG (params: [String : AnyObject], apikey: String, completion: @escaping (Any) -> Void, failure:@escaping (Error) -> Void){
          
            let strURL = apikey
            let url = URL(string: strURL)
                            
            let manager = Alamofire.Session.default
            manager.session.configuration.timeoutIntervalForRequest = 120
        
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(Constants.EN_TOKER)",
                "Accept": "application/json"
            ]
            
           currentDataRequest = AF.upload(multipartFormData: { multipartFormData in
                for (key, value) in params {
                  if (key == "input_image" || key == "file" || key == "mask_brush") {
                      let data = params[key] as! Data
                      let r = arc4random()
                      let filename = "file\(r).jpg"
                      multipartFormData.append(data, withName: key, fileName: filename, mimeType: "image/jpeg")
                    }
                    else{
                        multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                    }
                }
                
            }, to: url!, headers: headers)
                .responseJSON { response in
                    switch (response.result) {
                    case .success (let JSON):
                        let jsonResponse = JSON as! NSDictionary
                       // print(jsonResponse)
                        completion(jsonResponse)
                        Utils().HideLoader()
                    case .failure(let error):
                        failure(error)
                        Utils().HideLoader()
                        break
                  }
              }
        }
    
    class func PostMethod (params: [String : AnyObject], apikey: String, completion: @escaping (Any) -> Void, failure:@escaping (Error) -> Void){
        if Utils().isConnectedToNetwork() == false{
            Utils().showAlert("Please check your internet connection and try again.")
            Utils().HideLoader()
            return
        }
        
        let strURL = apikey
        let url = URL(string: strURL)
        
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = 120
        manager.session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        manager.session.configuration.urlCache = nil
        manager.request(url!, method: .post, parameters: params)
            .responseJSON
        {
            response in
            switch (response.result)
            {
            case .success (let JSON):
                let jsonResponse = JSON as! NSDictionary
                // print(jsonResponse)
                completion(jsonResponse)
                Utils().HideLoader()
            case .failure(let error):
                Utils().HideLoader()
                Utils().showAlert("Please check your internet connection and try again.")
                failure(error)
                break
            }
        }
    }
    
    class func GetMethod (params: [String : AnyObject], apikey: String, completion: @escaping (Any) -> Void, failure:@escaping (Error) -> Void) {
        if Utils().isConnectedToNetwork() == false {
            Utils().showAlert("Please check your internet connection and try again.")
            Utils().HideLoader()
            return
        }
        
        let strURL = apikey
        let url = URL(string: strURL)
        
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = 120
        
        manager.request(url!, method: .get, parameters: params)
            .responseJSON
        {
            response in
            
            switch (response.result)
            {
            case .success (let JSON):
                let jsonResponse = JSON as! NSDictionary
                // print(jsonResponse)
                completion(jsonResponse)
            case .failure(let error):
                failure(error)
                break
            }
        }
    }
    
    class func PostDataForRestore (params: [String : AnyObject], apikey: String, completion: @escaping (Any) -> Void, failure:@escaping (Error) -> Void){
        
        if Utils().isConnectedToNetwork() == false {
            Utils().showAlert("Please check your internet connection and try again.")
            Utils().HideLoader()
            return
        }
        
        let strURL = apikey
        let url = URL(string: strURL)
        //print(params)
        // print(strURL)
        
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = 120
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                if (key == "image"){
                    let image = params[key] as! UIImage
                    let resizeImage =  Utils().resizeImage(image: image)
                    let data = resizeImage.jpegData(compressionQuality: 0.9)
                    let r = arc4random()
                    let filename = "file\(r).jpg"
                    multipartFormData.append(data!, withName: key, fileName: filename, mimeType: "image/jpeg")
                }
                else{
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            
        }, to: url!)
            .responseJSON { response in
                
                let data = response.data
                if(data!.count > 0){
                    completion(data as Any)
                    Utils().HideLoader()
                }
                else{
                    completion(Data())
                    Utils().showAlert("something went wrong")
                    Utils().HideLoader()
                }
            }
    }
    
    class func PostDataForRetouch (params: [String : AnyObject], apikey: String, completion: @escaping (Any) -> Void, failure:@escaping (Error) -> Void){
        
        if Utils().isConnectedToNetwork() == false {
            Utils().showAlert("Please check your internet connection and try again.")
            Utils().HideLoader()
            return
        }
        
        let strURL = apikey
        let url = URL(string: strURL)
        //print(params)
        // print(strURL)
        
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = 120
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                if (key == "myfile"){
                    let image = params[key] as! UIImage
                    let resizeImage =  Utils().resizeImage(image: image)
                    let data = resizeImage.compress(to: 2500)
                    let r = arc4random()
                    let filename = "file\(r).jpg"
                    multipartFormData.append(data, withName: key, fileName: filename, mimeType: "image/jpeg")
                }
                else{
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            
        }, to: url!)
            .responseJSON { response in
                
                if let returnData = String(data: response.data!, encoding: .utf8) {
                    completion(returnData)
                    Utils().HideLoader()
                } else {
                    completion("")
                    Utils().showAlert("something went wrong")
                    Utils().HideLoader()
                }
            }
    }
    
    class func PostDataForAge (params: [String : AnyObject], apikey: String, completion: @escaping (Any) -> Void, failure:@escaping (Error) -> Void){
        
        if Utils().isConnectedToNetwork() == false {
            Utils().showAlert("Please check your internet connection and try again.")
            Utils().HideLoader()
            return
        }
        
        let strURL = apikey
        let url = URL(string: strURL)
        // print(params)
        // print(strURL)
        
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = 120
        
        AF.upload(multipartFormData: { multipartFormData in
            for (key, value) in params {
                if (key == "picture"){
                    let image = params[key] as! UIImage
                    let resizeImage =  Utils().resizeImage(image: image)
                    let data = resizeImage.compress(to: 1024)
                    let r = arc4random()
                    let filename = "file\(r).jpg"
                    multipartFormData.append(data, withName: key, fileName: filename, mimeType: "image/jpeg")
                }
                else{
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            
        }, to: url!)
            .responseJSON { response in
                
                let data = response.data
                if(data!.count > 0){
                    completion(data as Any)
                    Utils().HideLoader()
                }
                else{
                    completion(Data())
                    Utils().showAlert("something went wrong")
                    Utils().HideLoader()
                }
            }
    }
}


extension UIImage {
    
    func resizeByByte(maxByte: Int, completion: @escaping (Data) -> Void) {
        var compressQuality: CGFloat = 1
        var imageData = Data()
        var imageByte = self.jpegData(compressionQuality: 1)?.count
        
        while imageByte! > maxByte {
            imageData = self.jpegData(compressionQuality: compressQuality)!
            imageByte = self.jpegData(compressionQuality: compressQuality)?.count
            compressQuality -= 0.1
        }
        
        if maxByte > imageByte! {
            completion(imageData)
        } else {
            completion(self.jpegData(compressionQuality: 1)!)
        }
    }
}

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }
    
    func compress(to kb: Int, allowedMargin: CGFloat = 0.2) -> Data {
        let bytes = kb * 1024
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        var complete = false
        while(!complete) {
            if let data = holderImage.jpegData(compressionQuality: 1.0) {
                let ratio = data.count / bytes
                if data.count < Int(CGFloat(bytes) * (1 + allowedMargin)) {
                    complete = true
                    return data
                } else {
                    let multiplier:CGFloat = CGFloat((ratio / 5) + 1)
                    compression -= (step * multiplier)
                }
            }

            guard let newImage = holderImage.resized(withPercentage: compression) else { break }
            holderImage = newImage
        }
        return Data()
    }
    
    func compressToPNG(to kb: Int, allowedMargin: CGFloat = 0.2) -> Data {
        let bytes = kb * 1024
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        var complete = false

        while !complete {
            if let data = holderImage.pngData() {
                let ratio = data.count / bytes
                if data.count < Int(CGFloat(bytes) * (1 + allowedMargin)) {
                    complete = true
                    return data
                } else {
                    let multiplier: CGFloat = CGFloat((ratio / 5) + 1)
                    compression -= (step * multiplier)
                }
            }

            guard let newImage = holderImage.resized(withPercentage: compression) else { break }
            holderImage = newImage
        }
        return Data()
    }
    
    func compressImageToPNG(image: UIImage, targetSizeInMB: Double) -> Data? {
        let targetSizeInBytes = Int(targetSizeInMB * 1024 * 1024)
        
        var imageData = image.pngData()
        
        while let data = imageData, data.count > targetSizeInBytes {
            // If the image size is still larger than the target size, you may want to adjust the image size or other parameters.
            // For example, you could resize the image using image resizing techniques.
            
            // For now, we break out of the loop without further compression.
            break
        }
        
        return imageData
    }
}


