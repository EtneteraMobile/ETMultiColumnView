//
//  ViewProvider.swift
//  ETMultiColumnView
//
//  Created by Petr Urban on 13/02/2017.
//
//

import UIKit
import ETMultiColumnBadgeViewProvider
import ETMultiColumnLabelProvider

/// Protocol describes mandatory functionality of instance that is able to be
/// used in column of `ETMultiColumnView`.
public protocol ViewProvider {

    /// Hash value for comparison of multiple instances with different content
    var hashValue: Int { get }

    /// Reuse identifier used for reuse
    var reuseId: String { get }

    /// Returns new instance of view that is presented in column of cell.
    func make() -> UIView

    /// Customizes given view with content.
    func customize(view view: UIView)

    /// Returns size of view respecting given width. Height should be dynamicaly
    /// calculated based on content.
    func size(for width: CGFloat) -> CGSize
}

// Marks providers with protocol

extension BadgeViewProvider: ViewProvider {}
extension LabelProvider: ViewProvider {}