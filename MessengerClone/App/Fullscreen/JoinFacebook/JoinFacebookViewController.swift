//
//  JoinFacebookVC.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/20/23.
//

import SwiftUI

final class JoinFacebookViewController: BaseCreateAccountViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let childView = UIHostingController(rootView: JoinFacebookView(getStartedTapped: { [weak self] in
            self?.coordinator?.goToAddNameVC()
        }))
        addChild(childView)
        contentView.addSubview(childView.view)
        childView.didMove(toParent: self)

        childView.view.pin(to: contentView)
    }
}
