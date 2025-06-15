//
//  Created URL.swift
//  Bg Remover
//
//  Created by mac on 20/09/23.
//

import Foundation
import Photos
import UIKit
import MobileCoreServices

class CreateURL:NSObject {
    func requestImageData(for asset: PHAsset, filename: String, completion: @escaping (Data) -> Void) {
        let options = PHImageRequestOptions()
        PHImageManager.default().requestImageDataAndOrientation(for: asset, options: options) { data, _, orientation, _ in
            guard let imageData = data else {
                return
            }
            completion(imageData)
        }
    }
    
    func saveFile(data: Data?, fileName: String) -> String? {
        
        let fileURL = self.documentsUrl().appendingPathComponent(fileName)
        if let imageData = data {
            try? imageData.write(to: fileURL, options: .atomicWrite)
            return fileName
        }
        print("Error saving image")
        return nil
    }
    
    func documentsUrl() -> URL {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsUrl
    }
    
    func requestImageDatas(for image: UIImage, completion: @escaping (Data) -> Void) {
            autoreleasepool {
                guard let cgImage = image.cgImage else {
                    return
                }
                let data = NSMutableData()
                guard let destination = CGImageDestinationCreateWithData(data as CFMutableData, kUTTypeJPEG, 1, nil) else {
                    return
                }
                let options: [NSObject: AnyObject] = [
                    kCGImageDestinationLossyCompressionQuality: 0.5 as NSNumber
                ]
                CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)
                CGImageDestinationFinalize(destination)
                completion(data as Data)
            }
        }
    
    func convertFileURLToData(fileURL: URL, completion: @escaping (Data) -> Void) {
            do {
                let data = try Data(contentsOf: fileURL)
                completion(data)
            } catch {
                print("Error reading data from file URL: \(error)")
            }
        }
}

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(timeIntervalSince1970 * 1000)
    }
}



