//
//  DefaultCreateAccountView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/21/23.
//
import SwiftUI

struct BaseCreateAccountView<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea(.all)

            VStack(alignment: .center, spacing: 20) {
                content
                Spacer()
            }
        }
    }
}
