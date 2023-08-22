//
//  UIPreview.swift
//  Messenger
//
//  Created by Vebjørn Daniloff on 2/14/23.
//

import SwiftUI

// MARK: - Preview for viewController
struct UIViewControllerPreview<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: ViewController

    init(_ builder: @escaping () -> ViewController) {
        viewController = builder()
    }

    func makeUIViewController(context _: Context) -> some UIViewController {
        return viewController
    }

    func updateUIViewController(_: UIViewControllerType, context _: Context) {
        // Not needed
    }
}

// MARK: - UIViewPreview
struct UIViewPreview<View: UIView>: UIViewRepresentable {
    let view: View

    init(_ builder: @escaping () -> View) {
        view = builder()
    }

    func makeUIView(context _: Context) -> some UIView {
        return view
    }

    func updateUIView(_: UIViewType, context _: Context) {
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }
}
