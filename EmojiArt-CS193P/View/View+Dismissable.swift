//
//  View+Dismissable.swift
//  EmojiArt-CS193P
//
//  Created by Matthew Folbigg on 31/07/2021.
//

import SwiftUI

extension View {
    @ViewBuilder
    func wrappedInNavigationViewToEnableDismissal(_ dismiss: (() -> Void)? = nil) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            NavigationView {
                self
                    .navigationBarTitleDisplayMode(.inline)
                    .dismissable(withAction: dismiss)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            self
        }
    }
    
    @ViewBuilder
    func dismissable(withAction dismiss: (() -> Void)? = nil) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            self.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: dismiss, label: { Text("Close") })
                }
            }
        } else {
            self
        }
    }
}
