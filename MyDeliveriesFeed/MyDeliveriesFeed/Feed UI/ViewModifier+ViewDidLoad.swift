//
//  ViewModifier+ViewDidLoad.swift
//  MyDeliveriesFeed
//
//  Created by Ryan Neil Stroud on 31/3/2024.
//

import SwiftUI

extension View {
    func viewDidLoad(_ action: @escaping () -> Void) -> some View {
        modifier(ViewDidLoadModifier(action: action))
    }
}

private struct ViewDidLoadModifier: ViewModifier {
    private let action: () -> Void
    @State private var viewDidLoad = false
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if viewDidLoad { return }
                viewDidLoad = true
                
                action()
            }
    }
}
