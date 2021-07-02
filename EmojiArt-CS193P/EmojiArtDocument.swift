//
//  EmojiArtDocument.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 28/06/2021.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            autoSave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageData()
            }
        }
    }
    
    private struct Autosave {
        static let filename = "Autosaved.emojiart"
        static var url: URL? {
            let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return docDirectory?.appendingPathComponent(filename)
        }
    }
    
    private func autoSave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    //MARK: - Persistence
    private func save(to url: URL) {
        let thisFunc = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArt.json()
            try data.write(to: url)
        } catch let encodeError where encodeError is EncodingError {
            print("Encoding Error: \(encodeError.localizedDescription)")
        } catch {
            print("\(thisFunc): \(error)")
        }
        
    }
    
        
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
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus: ImageFetchStatus = .idle
    
    enum ImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    DispatchQueue.main.async { [weak self] in
                        self?.backgroundImageFetchStatus = .idle
                        if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                            self?.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        case .imageData(let data): backgroundImage = UIImage(data: data)
        case .blank: break
        }
    }
    
    //MARK: - Intents
    func setBackground(_ background: EmojiArtModel.Background) {
        print("Background set to \(background)")
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func removeEmoji(_ emoji: EmojiArtModel.Emoji) {
        emojiArt.removeEmoji(emoji)
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
