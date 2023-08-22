//
//  SettingsView.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 3/21/23.
//

import FirebaseAuth
import SwiftUI

struct SettingsView: View {
    // MARK: - body
    var body: some View {
        List {
            Section {
                ForEach(ListRows.allCases, id: \.self) { rowData in
                    row(
                        icon: rowData.icon,
                        text: rowData.rawValue,
                        imageBackgroundColor: rowData.backgroundColor
                    )
                }
            }

            Section {
                Button {
                    try? Auth.auth().signOut()
                } label: {
                    row(
                        icon: "rectangle.portrait.and.arrow.right",
                        text: "Log out",
                        imageBackgroundColor: .black
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Private Properties
    @ViewBuilder
    private func row(icon: String, text: String, imageBackgroundColor: Color) -> some View {
        HStack {
            ImageOnCircle(icon: icon, radius: 15, backgroundColor: imageBackgroundColor)
            Text(text)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}
