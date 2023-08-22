//
//  LaunchView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/1/23.
//

import SwiftUI

struct LaunchView: View {
    private let iconSize = UIScreen.main.bounds.size.height * 0.07

    @State private var animate = false
    @State private var size = 0.2
    @State private var opacity = 0.2

    var body: some View {
        ZStack {
            Color.theme.background.edgesIgnoringSafeArea(.all)

            VStack(alignment: .center) {
                Spacer()
                Image("Icon")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .opacity(opacity)
                    .scaleEffect(size)

                Spacer()

                VStack(alignment: .center, spacing: 3) {
                    Text("from")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Image("MetaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: iconSize / 4)
                }
                .padding(.bottom, 5)
                .opacity(opacity)
                .scaleEffect(size)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                animate.toggle()
                size = 1
                opacity = 1
            }
        }
    }
}

// struct LaunchView_Previews: PreviewProvider {
//    static var previews: some View {
//        LaunchView()
//    }
// }
