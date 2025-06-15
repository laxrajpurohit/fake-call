//
//  Constants.swift
//  Bankable Solution
//
//  Created by Appster on 09/05/17.
//  Copyright © 2017 alm. All rights reserved.
//
//com.googleusercontent.apps.313192316404-ghum6vmr956psnjv486841c1ut1pbsvf gmail URL type
import Foundation
import UIKit

class Constants {
    
    public static var arrVoiceUrl = [URL]()
    public static var arrRingToneUrl = [URL]()
    public static var ISDownloadingUrl = false

        
    public static let NetworkUnavailable = "Network unavailable. Please check your internet connectivity"
    
    public static let USERDEFAULTS = UserDefaults.standard
    public static var ROOTVIEW = UIApplication.shared.windows.filter {$0.isKeyWindow}.last?.rootViewController
    
    public static let DEVICE_TYPE = "iOS"
    
    public static let PRIVACY = "https://docs.google.com/document/d/1wjWnZxuY9X9gUo0FN80uRwxbWsl0G-IsKTnUtm7BQn8/edit?usp=drivesdk"
    public static let TERMS = "https://docs.google.com/document/d/1MFPj3dKCi0gEb1GzInWLgy_nvqtBhBULb3-IL4kPEbA/edit?usp=drivesdk"

//    public static let REVANUE_API = "appl_hRDqNmLzuwnaMHzKqoToqTZaMYM"
//    public static let entitlementID = "clickTochat_entitlement"
    
    public static let PRODUCT_MONTH = "locate_month"
    public static let PRODUCT_YEAR = "locate_year"
        
    public static let BANNER = "ca-app-pub-3940256099942544/2435281174"
//    public static let INTERTIALS = "ca-app-pub-7202906887840059/3982484954"
//    public static let OPEN = "ca-app-pub-3940256099942544/3419835294"
//    public static let NATIVE = "ca-app-pub-3940256099942544/2247696110"
    
    public static let storyBoard = UIStoryboard(name: "Main", bundle:Bundle.main)
    public static let Home = UIStoryboard(name: "Home", bundle:Bundle.main)
        
    public static let ADS_API = "http://99-99apps.tech/API/Location_Tracker/ads.json"
    
    public static let BASE_URL = "https://ligerinfotech.com/phone_tracker/"
    
    // USER
    public static let REGISTER = "register"
    public static let SET_USER_LOCATION = "set_location"
    
    // MEMBERS
    public static let ADD_INDIVIDUAL = "add_individual_member"
    public static let GET_INDIVIDUAL = "get_individual_member"
    
    public static let ADD_GROUP = "add_group_member"
    public static let GET_GROUP = "get_group_member"
    public static let GET_GROUP_MEMBERS = "get_group_member_details"
    
    public static let SEND_INVITATION = "send_invitation"
    
    public static let GET_NOTIFICATION = "get_notification_list"
    public static let ACCEPT_INVITATION = "accept_invitation"
    public static let DELETE_INVITATION = "reject_invitation"
    
    public static let DELETE_INDIVIDUAL = "delete_individual_member"
    public static let DELETE_GROUP = "delete_group"
    public static let DELETE_GROUP_MEMBER = "delete_group_member"
    
    public static let DELETE_ACCOUNT = "delete_account"
    
    public static let EN_TOKER =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJpZ25vcmUiLCJwbGF0Zm9ybSI6IndlYiIsImV4cCI6MTY4MDU5MDYzODIyNX0.bm6LhUvkTnyL4-KTen695hyyqbOYRTVBQLA4wSMzDa4"
    public static let BASE_URL_REMOVEBG1 = "https://be-prod-web.snapedit.app/api/rmbg/v1"
//    public static let BASE_URL_REMOVEBG1 = "https://app.pfpmaker.com/api/v2/trial/profilepic/"


}
