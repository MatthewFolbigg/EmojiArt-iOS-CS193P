//
//  EmojiArtDocument.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 28/06/2021.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published private(set) var emojiArt: EmojiArtModel

    init() {
        emojiArt = EmojiArtModel()
        //MARK: - TESTING
        emojiArt.addEmoji("⌚️", at: (-200, -100), size: 80)
        emojiArt.addEmoji("🔭", at: (-100, -50), size: 80)
        emojiArt.addEmoji("🛴", at: (200, 100), size: 50)
        //MARK: - TESTING END
    }
    
    //Convienience variables direct from model
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }

    //MARK: - Intents
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(where: { $0.id == emoji.id } ) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(where: { $0.id == emoji.id } ) {
            let currentSize = emojiArt.emojis[index].size
            let newSize = CGFloat(currentSize) * scale
            emojiArt.emojis[index].size = Int(newSize.rounded(.toNearestOrAwayFromZero))
        }
    }
    
}
