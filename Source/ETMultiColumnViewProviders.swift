//
//  ViewProvider.swift
//  ETMultiColumnView
//
//  Created by Petr Urban on 13/02/2017.
//
//

import UIKit

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

    /// Returns size of view respecting given width constraints. Height should
    /// be dynamicaly calculated based on content.
    ///
    /// - Note: Returned size.width should be lower than given widhtContraint.
    func boundingSize(widthConstraint width: CGFloat) -> CGSize
}
