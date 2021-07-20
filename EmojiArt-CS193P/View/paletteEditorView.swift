//
//  paletteEditorView.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 08/07/2021.
//

import SwiftUI

struct PaletteEditorView: View {
    
    @Binding var palette: Palette
    
    var body: some View {
        Form {
            nameSection
            addEmojiSection
            removeEmojiSection
        }
        .navigationTitle("Edit \(palette.name)")
        .frame(minWidth: 300, minHeight: 400)
    }
    
    var nameSection: some View {
        Section(header: Text("Name")) {
            TextField("Name", text: $palette.name)
        }
    }
    
    @State private var emojisToAdd = ""
    var addEmojiSection: some View {
        Section(header: Text("Add Emoji")) {
            TextField("", text: $emojisToAdd)
                .onChange(of: emojisToAdd, perform: { emojis in
                    addEmojis(emojis)
                })
        }
    }
    
    var removeEmojiSection: some View {
        Section(header: Text("Remove Emoji")) {
            let emojis = palette.emojis.map { String($0) }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .onTapGesture {
                            withAnimation {
                                palette.emojis.removeAll(where: { String($0) == emoji } )
                            }
                        }
                }
            }
            .font(.system(size: 40))
        }
    }
    
    func addEmojis(_ emojis: String) {
        withAnimation {
            palette.emojis = (emojis + palette.emojis)
                .filter( {$0.isEmoji })
        }
    }
    
    
}







struct paletteEditorView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditorView(palette: .constant(PaletteStore(named: "Testing").palette(at: 0)))
            .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/300.0/*@END_MENU_TOKEN@*/, height: 400))
    }
}
