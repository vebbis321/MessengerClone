//
//  SideMenuView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/20/23.
//

import FirebaseAuth
import SwiftUI

struct SideMenuView: View {
    @State var selectedRow: SideMenuRow = .chats
    var showSettingsSheet: () -> Void

    // MARK: - body
    var body: some View {
        VStack {
            headerRow(
                name: Auth.auth().currentUser?.displayName ?? "",
                url: .init(string: "https://iphf.org/wp-content/uploads/2016/08/stevejobs-crop.jpg")
            )
            .padding(.bottom, 20)
            .padding(.horizontal, 10)
            VStack(spacing: 0) {
                ForEach(SideMenuRow.allCases, id: \.self) { row in
                    menuRow(row: row)
                        .padding(10)
                        .background(selectedRow == row ? Color.gray.opacity(0.1) : .clear)
                        .cornerRadius(10)
                        .onTapGesture {
                            selectedRow = row
                        }
                }
                Spacer()
            }
        }
        .ignoresSafeArea(.all)
    }

    // MARK: - Private properties
    @ViewBuilder
    private func headerRow(name: String, url: URL?) -> some View {
        HStack(spacing: 15) {
            Button {
                // userRowTapped
            } label: {
                CustomSDWebImageView(url: url)

                HStack(spacing: 5) {
                    Text(name)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.85)
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 16, weight: .medium, design: .default))
            }
            .foregroundColor(.primary)

            Spacer()

            Button {
                // settings tapped
                showSettingsSheet()
            } label: {
                Image(systemName: "gearshape.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 25)
            }
        }
    }

    @ViewBuilder
    private func menuRow(row: SideMenuRow) -> some View {
        HStack(spacing: 15) {
            ZStack {
                Color.gray.opacity(0.2)

                Image(systemName: row.icon)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .frame(maxHeight: 20)
            }
            .frame(width: 40, height: 40)
            .cornerRadius(10)

            Text(row.rawValue)
                .font(.system(size: 16, weight: .medium, design: .default))

            Spacer()
        }
    }
}

//
// struct SideMenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        SideMenuView(showSettingsSheet: <#() -> ()#>)
//    }
// }
