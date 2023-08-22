//
//  MediaModel.swift
//  Messenger_2
//
//  Created by Vebjørn Daniloff on 4/20/23.
//

import PhotosUI
import UIKit

struct MediaModel: Hashable {
    var selectedIdx: Int?
    var asset: PHAsset

    func hash(into hasher: inout Hasher) {
        hasher.combine(asset)
        hasher.combine(selectedIdx)
    }
}
