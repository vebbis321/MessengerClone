//
//  jee.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 7/11/23.
//

import SwiftUI

// TODO: Add async image and option to add image when users create account
struct CustomSDWebImageView: View {
    var url: URL?
    var body: some View {
        Image("ProfileImage")
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .frame(width: 40, height: 40)
    }
}
