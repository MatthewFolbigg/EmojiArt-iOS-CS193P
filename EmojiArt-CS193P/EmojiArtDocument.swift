//
//  EmojiArtDocument.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 28/06/2021.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

class EmojiArtDocument: ObservableObject, ReferenceFileDocument {
    
    //MARK:- iOS Document
    typealias Snapshot = Data
    static var readableContentTypes: [UTType] = [UTType.emojiart]
    static var writableContentTypes: [UTType] = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArtModel(json: data)
            fetchBackgroundImageData()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    //MARK: - Model and Init
    init() {
        emojiArt = EmojiArtModel()
    }
    
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageData()
            }
        }
    }
    
    //Convienience variables direct from model
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
        
    //MARK: Background Image
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
            
        case .imageData(let data): backgroundImage = UIImage(data: data)
        case .blank: break
        }
    }
    
    //MARK: - Intents
    func setBackground(_ background: EmojiArtModel.Background, undoManger: UndoManager?) {
        undoablyPerform(actionName: "Set Background", with: undoManger) {
            emojiArt.background = background
        }
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat, undoManger: UndoManager?) {
        undoablyPerform(actionName: "Add \(emoji)", with: undoManger) {
            emojiArt.addEmoji(emoji, at: location, size: Int(size))
        }
    }
    
    func removeEmoji(_ emoji: EmojiArtModel.Emoji, undoManger: UndoManager?) {
        undoablyPerform(actionName: "Removed \(emoji)", with: undoManger) {
            emojiArt.removeEmoji(emoji)
        }
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize, undoManger: UndoManager?) {
        undoablyPerform(actionName: "Moved \(emoji)", with: undoManger) {
            if let index = emojiArt.emojis.firstIndex(where: { storedEmoji in storedEmoji.id == emoji.id } ) {
                emojiArt.emojis[index].x += Int(offset.width)
                emojiArt.emojis[index].y += Int(offset.height)
            }
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat, undoManger: UndoManager?) {
        undoablyPerform(actionName: "Scaled \(emoji)", with: undoManger) {
            if let index = emojiArt.emojis.firstIndex(where: { $0.id == emoji.id } ) {
                let currentSize = emojiArt.emojis[index].size
                let newSize = CGFloat(currentSize) * scale
                emojiArt.emojis[index].size = Int(newSize.rounded(.toNearestOrAwayFromZero))
            }
        }
    }
    
    //MARK: - Undo
    private func undoablyPerform(actionName: String, with undoManager: UndoManager? = nil, action: () -> Void) {
        let oldEmojiArt = emojiArt
        action()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(actionName: actionName, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(actionName)
    }
    
}

extension UTType {
    static let emojiart = UTType(exportedAs: "com.emojiart.cs193p")
}
