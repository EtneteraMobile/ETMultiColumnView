//
//  ViewController.swift
//  Example
//
//  Created by Jan Čislinský on 03/04/2017.
//  Copyright © 2017 Etnetera, a. s. All rights reserved.
//

import UIKit
import ETMultiColumnView

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let col1 = ETMultiColumnView.Configuration.Column(layout: .relative(), content: PlaceholderProvider())
        let col2 = ETMultiColumnView.Configuration.Column(layout: .relative(), content: PlaceholderProvider())
        let line1 = ETMultiColumnView.Configuration(columns: [col1, col2])

        let lineView = ETMultiColumnView(with: line1)
        view.addSubview(lineView)
        lineView.frame = view.bounds
        try! lineView.customize(with: line1)
    }
}


struct PlaceholderProvider: ViewProvider {
    var hashValue: Int = 1
    var reuseId: String = "1"

    func make() -> UIView {
        let view = UIView()
        view.backgroundColor = makeBackground()
        return view
    }

    func customize(view view: UIView) {}

    func size(for width: CGFloat) -> CGSize {
        return CGSize(width: width, height: round(width / 2.0))
    }
}

private func makeBackground() -> UIColor {
    return UIColor.init(white: 0.0, alpha: CGFloat(Double(arc4random_uniform(100)) / 100.0))
}
