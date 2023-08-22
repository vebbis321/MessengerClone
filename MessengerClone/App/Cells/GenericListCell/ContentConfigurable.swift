//
//  ContentConfigurable.swift
//  Messenger_2
//
//  Created by Vebjorn Daniloff on 7/11/23.
//

import UIKit

protocol ContentConfigurable: UIContentConfiguration, Hashable {
    associatedtype T: Hashable
    var viewModel: T? { get set }
    init()
}

extension ContentConfigurable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(viewModel)
    }
}
