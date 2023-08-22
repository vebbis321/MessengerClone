//
//  ImageOnCircle.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/21/23.
//

import SwiftUI

struct ImageOnCircle: View {
    let icon: String
    let radius: CGFloat
    let backgroundColor: Color
    var squareSide: CGFloat {
        (2.0.squareRoot() * radius) * 0.6
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: radius * 2, height: radius * 2)
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: squareSide)
                .frame(maxHeight: squareSide)
                .foregroundColor(.white)
        }
    }
}
