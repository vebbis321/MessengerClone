//
//  JoinFacebookView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/20/23.
//

import SwiftUI

struct JoinFacebookView: View {
    var getStartedTapped: (() -> Void)?

    @State var text = ""
    @State var validation: String = ""

    var body: some View {
        BaseCreateAccountView {
            Image("CreateFacebookAccount")
                .resizable()
                .scaledToFit()
                .cornerRadius(3)

            Text(
                """
                You'll need a Facebook account to use Messenger. \
                Create an account to connect with friends, family and \
                people who share your interests.
                """
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 15, weight: .regular))

            AuthButtonView(title: "Get Started") {
                getStartedTapped?()
            }
        }
    }
}
