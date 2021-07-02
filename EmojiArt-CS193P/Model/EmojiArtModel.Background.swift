//
//  EmojiArtModel.Background.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 28/06/2021.
//

import Foundation

extension EmojiArtModel {
    
    enum Background: Equatable, Codable {
        
        case blank
        case url(URL)
        case imageData(Data)
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var data: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let url = try? container.decode(URL.self, forKey: CodingKeys.url) {
                self = .url(url)
            } else if let imageData = try? container.decode(Data.self, forKey: CodingKeys.imageData) {
                self = .imageData(imageData)
            } else {
                self = .blank
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .url(let url): try container.encode(url, forKey: .url)
            case .imageData(let data): try container.encode(data, forKey: .imageData)
            case.blank: break
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case url = "url"
            case imageData = "image_data"
        }
    }
    
}
