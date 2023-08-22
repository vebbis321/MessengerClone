//
//  View.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/21/23.
//

import SwiftUI

// MARK: - modify
extension View {
    func modify<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}
