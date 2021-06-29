//
//  selected.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 29/06/2021.
//

import SwiftUI

struct Selectable: ViewModifier {
    
    var isSelected: Bool
    var size: CGFloat
    var color: Color = DrawingConstants.color
    
    func body(content: Content) -> some View {
        ZStack {
            Circle()
                .stroke(lineWidth: DrawingConstants.selectionWidth)
                .foregroundColor(isSelected ? color : .clear)
                .background(isSelected ? color.opacity(0.3) :  Color.clear).clipShape(Circle())
                .frame(width: size + DrawingConstants.selectionSpacing, height: size + DrawingConstants.selectionSpacing)
            content
        }
    }
    
    struct DrawingConstants {
        static var selectionSpacing: CGFloat = 30
        static var selectionWidth: CGFloat = 5
        static var color: Color = .blue
    }
    
}
    


extension View {
    func selectable(_ isSelected: Bool, size: CGFloat) -> some View {
        self.modifier(Selectable(isSelected: isSelected, size: size))
    }
}
