//
//  EmojiArtDocument.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 28/06/2021.
//

import SwiftUI
import Combine

class EmojiArtDocument: ObservableObject {
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            scheduleAutoSave()
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageData()
            }
        }
    }
    
    //MARK: - Persistence
    private struct Autosave {
        static let filename = "Autosaved.emojiart"
        static var url: URL? {
            let docDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            return docDirectory?.appendingPathComponent(filename)
        }
        static let timeInterval = 4.0
    }
    
    private var autosaveTimer: Timer?
    
    private func scheduleAutoSave() {
        autosaveTimer?.invalidate()
        autosaveTimer = Timer.scheduledTimer(withTimeInterval: Autosave.timeInterval, repeats: false) { _ in
            self.autosave()
        }
    }
    
    private func autosave() {
        if let url = Autosave.url {
            save(to: url)
        }
    }
    
    private func save(to url: URL) {
        let thisFunc = "\(String(describing: self)).\(#function)"
        do {
            let data: Data = try emojiArt.json()
            try data.write(to: url)
            print("Save Successful")
        } catch let encodeError where encodeError is EncodingError {
            print("Encoding Error: \(encodeError.localizedDescription)")
        } catch {
            print("\(thisFunc): \(error)")
        }
        
    }
    
    //MARK: - Init
    init() {
        if let url = Autosave.url, let autosavedEmojiArt = try? EmojiArtModel(fileUrl: url) {
            emojiArt = autosavedEmojiArt
            fetchBackgroundImageData()
        } else {
            emojiArt = EmojiArtModel()
            //MARK: - TESTING
            emojiArt.addEmoji("⌚️", at: (-200, -100), size: 80)
            emojiArt.addEmoji("🔭", at: (-100, -50), size: 80)
            emojiArt.addEmoji("🛴", at: (200, 100), size: 50)
            //MARK: - TESTING END
        }
    }
        
    //Convienience variables direct from model
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus: ImageFetchStatus = .idle
    
    //MARK: Network
    enum ImageFetchStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
    
    private var backgroundImageFetchCancellable: AnyCancellable?
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            backgroundImageFetchStatus = .fetching
            backgroundImageFetchCancellable?.cancel()
            let session = URLSession.shared
            let publisher = session.dataTaskPublisher(for: url)
                .map { (data, urlResponse) in UIImage(data: data) }
                .replaceError(with: nil)
                .receive(on: DispatchQueue.main)
            backgroundImageFetchCancellable = publisher
                .sink(receiveValue: { [weak self] image in
                        self?.backgroundImageFetchStatus = image != nil ? .idle : .failed(url)
                        self?.backgroundImage = image
                })
            
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let imageData = try? Data(contentsOf: url) {
//                    DispatchQueue.main.async { [weak self] in
//                        self?.backgroundImageFetchStatus = .idle
//                        if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
//                            self?.backgroundImage = UIImage(data: imageData)
//                        }
//                        if self?.backgroundImage == nil {
//                            self?.backgroundImageFetchStatus = .failed(url)
//                        }
//                    }
//                }
//            }
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
        if let index = emojiArt.emojis.firstIndex(where: { storedEmoji in storedEmoji.id == emoji.id } ) {
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
