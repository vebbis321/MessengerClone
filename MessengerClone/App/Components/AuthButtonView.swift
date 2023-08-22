//
//  AuthButtonView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/20/23.
//

import SwiftUI

struct AuthButtonView: View {
    var title: String
    var action: (() -> Void)?
    var body: some View {
        Button {
            action?()
        } label: {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                Text(title)
                    .foregroundColor(.theme.buttonText)
                    .font(.system(size: 17, weight: .regular))
                    .padding(.vertical, 15)
                Spacer()
            }
        }
        .background(Color.theme.button)
        .cornerRadius(3)
    }
}
