//
//  Core Data.swift
//  Bg Remover
//
//  Created by mac on 16/01/24.
//

import Foundation
import CoreData
import UIKit


struct CallerIds {
    var name = ""
    var voice = ""
    var number = ""
    var fonts = String()
    var fontColor = String()
    var dpImage = String()
    var timestamp = String()
    var VoiceUrl = URL(string: "")
    var isDefault = Bool()
    var isEmptyDp = Bool()
}


class IMAGEDATA {
    
    func SaveData(context : NSManagedObjectContext, CallerIds : CallerIds?) -> Bool {
        
        let entity = NSEntityDescription.entity(forEntityName: "CallerId",in: context)!
        let data = NSManagedObject(entity: entity,insertInto: context)
        data.setValue(CallerIds?.name, forKey: "name")
        data.setValue(CallerIds?.voice, forKey: "voice")
        data.setValue(CallerIds?.number, forKey: "number")
        data.setValue(CallerIds?.dpImage, forKey: "dpimage")
        data.setValue(CallerIds?.VoiceUrl, forKey: "voiceUrl")
        data.setValue(CallerIds?.timestamp, forKey: "timestamp")
        data.setValue(CallerIds?.fonts, forKey: "fonts")
        data.setValue(CallerIds?.fontColor, forKey: "fontColor")
        data.setValue(CallerIds?.isDefault, forKey: "isDefault")
        data.setValue(CallerIds?.isEmptyDp, forKey: "isEmptyDp")

        do {
            try context.save()
            print("Save")
            return true
        } catch {
            return false
        }
    }
      
    func fetchImage(context : NSManagedObjectContext,complation : @escaping (([CallerId]) -> ())) {
        var arrReminder = [CallerId]()
        let fetchRequest = NSFetchRequest<CallerId>(entityName: "CallerId")
        do {
            arrReminder = try context.fetch(fetchRequest)
            complation(arrReminder)
        } catch {
            complation([CallerId]())
        }
    }
    
    func deleteImages(context: NSManagedObjectContext, selectedProduct: CallerId) -> Bool {
        
        do {
            try context.save()
            return true
        } catch {
            print("Error deleting image: \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteImage(context : NSManagedObjectContext,selectedProduct : CallerId) -> Bool {
        context.delete(selectedProduct)
        do {
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func fetchImageDate(context: NSManagedObjectContext,ascending: Bool, complation: @escaping (([CallerId]) -> ())) {
        var arrReminder = [CallerId]()
        let fetchRequest = NSFetchRequest<CallerId>(entityName: "CallerId")
        
        let sortDescriptor = NSSortDescriptor(key: "imageDate", ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            arrReminder = try context.fetch(fetchRequest)
            complation(arrReminder)
        } catch {
            complation([CallerId]())
        }
    }
    
    func updateFonts(context: NSManagedObjectContext, callerId: CallerIds?) -> Bool {
        guard let callerId = callerId else { return false }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CallerId")
        fetchRequest.predicate = NSPredicate(format: "timestamp = %@", callerId.timestamp)

        do {
            if let result = try context.fetch(fetchRequest) as? [NSManagedObject], let data = result.first {
                // Update the fonts attribute only
                data.setValue(callerId.fonts, forKey: "fonts")
                data.setValue(callerId.fontColor, forKey: "fontColor")

                do {
                    try context.save()
                    return true
                } catch {
                    print("Error saving context: \(error)")
                    return false
                }
            } else {
                print("CallerId with timestamp \(callerId.timestamp) not found")
                return false
            }
        } catch {
            print("Error fetching CallerId: \(error)")
            return false
        }
    }

    func updateData(context : NSManagedObjectContext, CallerId : CallerIds?) -> Bool {
        let fetchRequest = NSFetchRequest<CallerId>(entityName: "CallerId")
        fetchRequest.predicate = NSPredicate(format: "timestamp = %@", CallerId!.timestamp)
        do {
            let value = try context.fetch(fetchRequest)
            let data = value[0] as NSManagedObject
            data.setValue(CallerId?.name, forKey: "name")
            data.setValue(CallerId?.voice, forKey: "voice")
            data.setValue(CallerId?.number, forKey: "number")
            data.setValue(CallerId?.dpImage, forKey: "dpimage")
            data.setValue(CallerId?.VoiceUrl, forKey: "voiceUrl")
            data.setValue(CallerId?.timestamp, forKey: "timestamp")
            data.setValue(CallerId?.isEmptyDp, forKey: "isEmptyDp")

//            if !(CallerId?.fontColor.isEmpty)! {
                data.setValue(CallerId?.fontColor, forKey: "fontColor")
//            }
//            if !(CallerId?.fonts.isEmpty)! {
                data.setValue(CallerId?.fonts, forKey: "fonts")
//            }
            data.setValue(CallerId?.isDefault, forKey: "isDefault")
            do {
                try context.save()
                return true
            } catch {
                return false
            }
        } catch {
            return false
        }
    }
    
    
    func updateVoice(context : NSManagedObjectContext, CallerId : CallerIds?) -> Bool {
        let fetchRequest = NSFetchRequest<CallerId>(entityName: "CallerId")
        fetchRequest.predicate = NSPredicate(format: "timestamp = %@", CallerId!.timestamp)
        do {
            let value = try context.fetch(fetchRequest)
            let data = value[0] as NSManagedObject
            data.setValue(CallerId?.voice, forKey: "voice")
            data.setValue(CallerId?.VoiceUrl, forKey: "voiceUrl")
            do {
                try context.save()
                return true
            } catch {
                return false
            }
        } catch {
            return false
        }
    }
}


