//
//  EmojiArtModel.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 28/06/2021.
//

import Foundation

struct EmojiArtModel: Codable {
    
    var background: Background = Background.blank
    var emojis: [Emoji] = []
    
    init() {}
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(fileUrl: URL) throws {
        let data = try Data(contentsOf: fileUrl)
        self = try EmojiArtModel(json: data)
    }
    
    //MARK: - Emoji
    //These are the emoji added to the canvas
    struct Emoji: Identifiable, Hashable, Codable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    private var uniqueEmojiId = 0
    mutating func addEmoji(_ text: String, at location: (x:Int, y:Int), size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: location.x, y: location.y, size: size, id: uniqueEmojiId))
    }
    
    mutating func removeEmoji(_ emoji: Emoji) {
        emojis.remove(emoji)
    }
    
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}


