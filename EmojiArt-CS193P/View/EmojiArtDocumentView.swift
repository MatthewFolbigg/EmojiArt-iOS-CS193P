//
//  EmojiArtDocumentView.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 28/06/2021.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    
    @ObservedObject var document: EmojiArtDocument
    let testEmojis = "📺🔭🐮🛩🛴🎙"
    let defaultEmojiFontSize: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }

    //MARK: - Document Body
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    backgroundImage(image: document.backgroundImage)
                        .position(convertFromEmojiCoords((0,0), in: geometry))
                )
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                        .scaleEffect(4)
                } else {
                    ForEach(document.emojis) {emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .position(position(for: emoji, in: geometry))
                    }
                }
            }
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geometry)
            }
        }
    }
  
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = false
        found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(.url(url.imageURL))
        }
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCoords(location, in: geometry),
                        size: defaultEmojiFontSize)
                }
            }
        }
        return found
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
        
    //MARK: Emoji Positioning
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        return convertFromEmojiCoords((emoji.x, emoji.y), in: geometry)
    }
    
    private func convertFromEmojiCoords(_ location: (x: Int,  y: Int), in geometry: GeometryProxy) -> CGPoint {
        let frame = geometry.frame(in: .local)
        let frameCenter = CGPoint(x: frame.midX, y: frame.midY)
        let convertedCoord = CGPoint(
            x: frameCenter.x + CGFloat(location.x),
            y: frameCenter.y + CGFloat(location.y)
        )
        return convertedCoord
    }
    
    private func convertToEmojiCoords(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int,  y: Int) {
        let frame = geometry.frame(in: .local)
        let frameCenter = CGPoint(x: frame.midX, y: frame.midY)
        let x = CGFloat(location.x) - frameCenter.x
        let y = CGFloat(location.y) - frameCenter.y
        return (Int(x), Int(y))
    }
    
    //MARK: - Emoji Palette
    var palette: some View {
        ScrollingEmojisView(emojis: testEmojis)
            .font(.system(size: defaultEmojiFontSize))
    }
    
}


struct backgroundImage: View {
    var image: UIImage?

    var body: some View {
        if image != nil {
            Image(uiImage: image!)
        }
    }
}

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
    
}












//MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
