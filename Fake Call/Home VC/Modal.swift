//
//  File.swift
//  Fake Call
//
//  Created by mac on 29/04/24.
//

import Foundation

struct MusicData: Codable {
    let voice: [Voice]
    let ringtons: [Ringtone]
    
    private enum CodingKeys: String, CodingKey {
        case voice = "Voice"
        case ringtons = "Ringtons"
    }
}


struct Voice: Codable {
    let name: String
    let voiceUrl: URL
    
    private enum CodingKeys: String, CodingKey {
        case name
        case voiceUrl = "voice_url"
    }
}

struct Ringtone: Codable {
    let name: String
    let ringUrl: URL
    
    private enum CodingKeys: String, CodingKey {
        case name
        case ringUrl = "ring_url"
    }
}


struct WallpaperCollection {
    let collection: [String]
    let love: [String]
    let nature: [String]
    let wallpaper: [String]
    var iosWallpaper: [String]
}

extension WallpaperCollection: Decodable {
    private enum CodingKeys: String, CodingKey {
        case collection
        case love
        case nature
        case wallpaper
        case iosWallpaper = "ios_wallpaper"
    }
}
