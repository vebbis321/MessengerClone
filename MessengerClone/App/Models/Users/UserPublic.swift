//
//  UserPublic.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/28/23.
//

import FirebaseFirestoreSwift
import UIKit

struct UserPublic: Codable, Hashable {
    @DocumentID var id: String? = UUID().uuidString
    let uuid: String
    let name: String
    let profileImageUrlString: String?
    var keywords: [String]
}

extension UserPublic {
    init(cachedUser: CachedUser) {
        self.uuid = cachedUser.uuid
        self.name = cachedUser.name
        self.profileImageUrlString = cachedUser.profileImageUrl
        self.keywords = []
    }
}
