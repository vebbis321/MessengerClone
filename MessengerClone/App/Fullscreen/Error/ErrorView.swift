//
//  ErrorView.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 5/15/23.
//

import SwiftUI

struct ErrorView: View {
    let error: MessengerError
    let retryAction: (() -> Void)?
    var body: some View {
        ZStack {
            Color.theme.background.edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 15) {
                Text("Error")
                Text(error.localizedDescription)
                if let retryAction {
                    Button(action: retryAction) {
                        Text("Retry")
                            .bold()
                            .foregroundColor(.theme.buttonText)
                    }
                }
            }
        }
    }
}
