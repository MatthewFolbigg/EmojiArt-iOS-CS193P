//
//  PaletteManagerView.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 20/07/2021.
//

import SwiftUI

struct PaletteManagerView: View {
    @EnvironmentObject var store: PaletteStore
    @Environment(\.presentationMode) var presentationMode
    
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
        List {
            ForEach(store.palettes) { palette in
                let index = store.index(for: palette) ?? 0
                NavigationLink(destination: PaletteEditorView(palette: $store.palettes[index])) {
                    VStack(alignment: .leading) {
                        Text(palette.name)
                        Text(palette.emojis)
                    }
                }
            }
            .onDelete { indexSet in
                store.palettes.remove(atOffsets: indexSet)
            }
            .onMove { indices, newOffset in
                store.palettes.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .navigationTitle("Edit Palettes")
        .navigationBarTitleDisplayMode(.inline)
        .dismissable(withAction: { presentationMode.wrappedValue.dismiss() })
        .toolbar {
            ToolbarItem { EditButton() }
        }
        .environment(\.editMode, $editMode)
        }
    }
}

struct PaletteManagerView_Previews: PreviewProvider {
    static var previews: some View {
        PaletteManagerView()
            .previewDevice("iPhone 8")
            .environmentObject(PaletteStore(named: "Test"))
    }
}
