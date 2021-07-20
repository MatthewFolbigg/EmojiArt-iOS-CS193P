//
//  PaletteStore.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 04/07/2021.
//

import Foundation

struct Palette: Identifiable, Codable {
    var name: String
    var emojis: String
    var id: Int
    
    fileprivate init(named name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}


class PaletteStore: ObservableObject {
    
    let name: String
    
    @Published var palettes: [Palette] = [] {
        didSet {
            storeInUserDefaults()
        }
    }
    
    var userDefaultsKey: String { "PaletteStore\(name)" }
    
    private func storeInUserDefaults() {
        let json = try? JSONEncoder().encode(palettes)
        UserDefaults.standard.set(json, forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefaults() {
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decodedPalettes = try? JSONDecoder().decode([Palette].self, from: jsonData) {
                self.palettes = decodedPalettes
            }
        }
    }
    
    init(named name: String) {
        self.name = name
        restoreFromUserDefaults()
        if palettes.isEmpty {
            insetPalette(named: "Sports", emojis: "⚽️🏀🏈⚾️🥎🎾🏐🏉🥏🎱🪀🏓🏸🏒🏑🥍🏏🪃🥅⛳️🏹🎣🥊🥋🛹⛷🏂🪂🏄‍♂️🧗‍♀️")
            insetPalette(named: "Music", emojis: "🎧🎷🎺🎸🪕🎻🥁🎹🎼🎤🪘")
        } else {
            print("Loaded Palettes from user defaults")
        }
    }
    
    //MARK: - Intents
    
    func index(for palette: Palette) -> Int? {
        if let index = palettes.firstIndex(where: { $0.id == palette.id }) {
            return index
        } else {
            return nil
        }
    }
    
    func palette(at index: Int) -> Palette {
        //Will alway return a palette even if an out of bounds index is provided.
        let safeIndex = min(max(index, 0), palettes.count - 1)
        return palettes[safeIndex]
    }
    
    func removePalette(at index: Int) -> Int {
        if palettes.count > 1, palettes.indices.contains(index) {
            palettes.remove(at: index)
        }
        return index % palettes.count
    }
    
    func insetPalette(named name: String, emojis: String? = nil, at index: Int = 0) {
        let unique = (palettes.max(by: { $0.id < $1.id })?.id ?? 0) + 1
        let palette = Palette(named: name, emojis: emojis ?? "", id: unique)
        let safeIndex = min(max(index, 0), palettes.count)
        palettes.insert(palette, at: safeIndex)
    }
    
}
