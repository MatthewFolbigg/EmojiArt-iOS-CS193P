//
//  EmojiArt_CS193PApp.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 28/06/2021.
//

import SwiftUI

@main
struct EmojiArt_CS193PApp: App {
    @StateObject var document = EmojiArtDocument()
    @StateObject var paletteStore = PaletteStore(named: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
                .environmentObject(paletteStore)
        }
    }
}
