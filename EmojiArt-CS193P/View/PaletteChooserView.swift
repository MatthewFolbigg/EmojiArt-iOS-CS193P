//
//  PaletteChooserView.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 07/07/2021.
//

import SwiftUI

struct PaletteChooserView: View {
    
    let emojiFontSize: CGFloat
    var emojiFont: Font { .system(size: emojiFontSize) }
    let testEmojis = "📺🔭🐮🛩🛴🎙"
    
    @EnvironmentObject var store: PaletteStore
    @SceneStorage("paletteChooser.paletteIndex") private var currentPaletteIndex: Int = 0
    
    var body: some View {
        let palette = store.palette(at: currentPaletteIndex)
        HStack {
            paletteControlButton
            body(for: palette)
        }
        .clipped()
    }
    
    var paletteControlButton : some View {
        Button {
            withAnimation {
                currentPaletteIndex = (currentPaletteIndex + 1) % store.palettes.count
                print("Tap")
            }
        } label: {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu { contextMenu }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
            paletteToEdit = store.palette(at: currentPaletteIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus") {
            store.insetPalette(named: "New", emojis: "", at: currentPaletteIndex)
            paletteToEdit = store.palette(at: currentPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            currentPaletteIndex = store.removePalette(at: currentPaletteIndex)
        }
        AnimatedActionButton(title: "Manage Palettes", systemImage: "slider.vertical.3") {
            isManagingPalettes = true
        }
        goToMenuItem
    }
    
    var goToMenuItem: some View {
        Menu {
            ForEach(store.palettes) { palette in
                AnimatedActionButton(title: palette.name) {
                    if let index = store.palettes.firstIndex(where: { $0.id == palette.id} ) {
                        currentPaletteIndex = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
    }
    
    //MARK:- Body
    func body(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojisView(emojis: palette.emojis)
                .font(emojiFont)
        }
        .id(palette.id)
        .transition(rollTrasitions)
        .popover(item: $paletteToEdit) { palette in
            PaletteEditorView(palette: $store.palettes[currentPaletteIndex])
                .wrappedInNavigationViewToEnableDismissal() {
                    paletteToEdit = nil
                }
        }
        .sheet(isPresented: $isManagingPalettes) {
            PaletteManagerView()
        }
    }
    
    @State private var paletteToEdit: Palette?
    @State private var isManagingPalettes: Bool = false
    
    var rollTrasitions: AnyTransition {
        AnyTransition.asymmetric(insertion: .offset(x: 0, y: emojiFontSize * 2), removal: .offset(x: 0, y: -emojiFontSize * 2))
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

//struct PaletteChooserView_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
