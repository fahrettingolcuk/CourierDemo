//
//  UIStackView + Extensions.swift
//  Extensions
//
//  Created by Fahreddin Gölcük on 2.12.2021.
//

import Foundation
import UIKit

public extension UIStackView {
    static func create(
        arrangedSubViews: [UIView] = [],
        axis: NSLayoutConstraint.Axis = .vertical,
        alignment: UIStackView.Alignment = .fill,
        distribution: UIStackView.Distribution = .fill,
        spacing: CGFloat = .leastNormalMagnitude,
        tamic: Bool = true
    ) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: arrangedSubViews)
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = tamic
        return stackView
    }
}
