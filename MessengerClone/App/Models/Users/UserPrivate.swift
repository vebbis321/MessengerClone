//
//  UserPrivate.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/28/23.
//

import FirebaseFirestoreSwift
import Foundation

struct UserPrivate: Codable {
    @DocumentID var id: String? = UUID().uuidString
    let uuid: String
    var name: String
    let profileImageUrlString: String?
    var email: String
    var dateOfBirth: Int
}
