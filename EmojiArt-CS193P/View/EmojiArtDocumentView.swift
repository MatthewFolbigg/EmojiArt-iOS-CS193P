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
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCoords((0,0), in: geometry))
                )
                .clipped()
                .gesture(doubleTapToZoom(in: geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                        .scaleEffect(4)
                } else {
                    ForEach(document.emojis) {emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji, in: geometry))
                    }
                }
            }
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geometry)
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
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
                        size: defaultEmojiFontSize / zoomScale
                    )
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
            x: frameCenter.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: frameCenter.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
        return convertedCoord
    }
    
    private func convertToEmojiCoords(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int,  y: Int) {
        let frame = geometry.frame(in: .local)
        let frameCenter = CGPoint(x: frame.midX, y: frame.midY)
        let x = (CGFloat(location.x) - panOffset.width - frameCenter.x) / zoomScale
        let y = (CGFloat(location.y) - panOffset.height - frameCenter.y) / zoomScale
        return (Int(x), Int(y))
    }
    
    //MARK: - Backgroud Image Adjustments
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            idleZoomScale = min(hZoom, vZoom)
            idlePanOffset = CGSize.zero
        }
    }
    
    //MARK: - Gestures
    @State private var idleZoomScale: CGFloat = 1
    @GestureState private var pinchGestureZoomScale: CGFloat = 1
    private var zoomScale: CGFloat {
        idleZoomScale * pinchGestureZoomScale
    }
    
    @State private var idlePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    private var panOffset: CGSize {
        let width = (idlePanOffset.width + gesturePanOffset.width) * zoomScale
        let height = (idlePanOffset.height + gesturePanOffset.height) * zoomScale
        return CGSize(width: width, height: height)
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .onEnded { endPanValue in
                idlePanOffset = idlePanOffset + (endPanValue.translation / zoomScale)
            }
            .updating($gesturePanOffset) { latestDragGestureValue, OurLinkedGestureState, _ in
                OurLinkedGestureState = latestDragGestureValue.translation / zoomScale
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .onEnded { gestureEndScale in
                idleZoomScale *= gestureEndScale
            }
            .updating($pinchGestureZoomScale) { latestGestureScale, OurLinkedGestureState, _ in
                OurLinkedGestureState = latestGestureScale
            }
    }
    
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture{
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
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
