//
//  Configuration.swift
//  ETMultiColumnView
//
//  Created by Petr Urban on 24/01/2017.
//
//

import UIKit

// MARK: - Configuration

public extension ETMultiColumnView {

    /// ETMultiColumnView configuration structure
    struct Configuration: Hashable {

        // MARK: - Variables
        // MARK: public

        /// Array of configuration for each column
        public let columns: [Column]

        /// Background color of contentView
        public let backgroundColor: UIColor?

        // MARK: - Initialization

        public init(columns: [Column], backgroundColor: UIColor? = nil) {
            self.columns = columns
            self.backgroundColor = backgroundColor
        }
    }
}

public func ==(lhs: ETMultiColumnView.Configuration, rhs: ETMultiColumnView.Configuration) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

// MARK: - Configuration.Column

public extension ETMultiColumnView.Configuration {

    /// Column configuration structure of ETMultiColumnView
    struct Column: Hashable {

        // MARK: - Variables
        // MARK: public

        public let layout: Layout
        public let viewProvider: ViewProvider

        // MARK: internal

        var calculatedInnerSize: CGSize?

        // MARK: - Initialization

        public init(layout: Layout, content viewProvider: ViewProvider) {
            self.layout = layout
            self.viewProvider = viewProvider
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(layout.hashValue)
            hasher.combine(viewProvider.hashValue)
        }
    }
}

// MARK: - Configuration.Column.Layout

public extension ETMultiColumnView.Configuration.Column {

    /// Layout properties
    ///
    /// - relative: relative size column
    /// - fixed: fixed size column (size as parameter)
    enum Layout: Hashable {
        // MARK: - Cases

        case rel(borders: [Border], edges: Edges, verticalAlignment: VerticalAlignment)
        case fix(outWidth: CGFloat, borders: [Border], edges: Edges, verticalAlignment: VerticalAlignment)
        case fit(maxOutWidth: CGFloat, borders: [Border], edges: Edges, verticalAlignment: VerticalAlignment)

        // MARK: - Builders

        public static func relative(borders: [Border] = [], edges: Edges = .zero, verticalAlignment: VerticalAlignment = .top) -> Layout {
            return .rel(borders: borders, edges: edges, verticalAlignment: verticalAlignment)
        }

        public static func fixed(outWidth width: CGFloat, borders: [Border] = [], edges: Edges = .zero, verticalAlignment: VerticalAlignment = .top) -> Layout {
            return .fix(outWidth: width, borders: borders, edges: edges, verticalAlignment: verticalAlignment)
        }

        public static func fitContent(maxOutWidth maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude, borders: [Border] = [], edges: Edges = .zero, verticalAlignment: VerticalAlignment = .top) -> Layout {
            return .fit(maxOutWidth: maxWidth, borders: borders, edges: edges, verticalAlignment: verticalAlignment)
        }
    }
}

// MARK: - Configuration.Column.Layout additions

public extension ETMultiColumnView.Configuration.Column.Layout {

    enum Border: Hashable {
        case left(width: CGFloat, color: UIColor)
    }

    enum VerticalAlignment: Hashable {
        case top
        case middle
        case bottom
    }
}

// MARK: - Configuration.Column.Layout.Edges

public extension ETMultiColumnView.Configuration.Column.Layout {

    enum Edges: Hashable {
        // MARK: - Cases

        case inner(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)
        case zero

        // MARK: - Builders

        public static func insets(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Edges {
            return .inner(top: top, left: left, bottom: bottom, right: right)
        }

        public static func insets(vertical: CGFloat = 0, horizontal: CGFloat = 0) -> Edges {
            return .inner(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        }

        public static func insets(all: CGFloat = 0) -> Edges {
            return .inner(top: all, left: all, bottom: all, right: all)
        }

        // MARK: - Insets

        /// Returns `EdgeInset` generated from self
        ///
        /// - Returns: space around content (`EdgeInset`)
        public var insets: Insets {
            switch self {
            case let .inner(top: top, left: left, bottom: bottom, right: right):
                return Insets(top: top, left: left, bottom: bottom, right: right)
            default:
                return Insets(top: 0, left: 0, bottom: 0, right: 0)
            }
        }

        /// Insets
        ///
        /// - top: space from top
        /// - left: space from left
        /// - bottom: space from bottom
        /// - right: space from right
        public struct Insets {
            public let top: CGFloat
            public let left: CGFloat
            public let bottom: CGFloat
            public let right: CGFloat

            public var vertical: CGFloat {
                return top + bottom
            }

            public var horizontal: CGFloat {
                return left + right
            }
        }
    }
}


// MARK: - Equatable

public func ==(lhs: ETMultiColumnView.Configuration.Column, rhs: ETMultiColumnView.Configuration.Column) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public func ==(lhs: ETMultiColumnView.Configuration.Column.Layout, rhs: ETMultiColumnView.Configuration.Column.Layout) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public func ==(lhs: ETMultiColumnView.Configuration.Column.Layout.Border, rhs: ETMultiColumnView.Configuration.Column.Layout.Border) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public func ==(lhs: ETMultiColumnView.Configuration.Column.Layout.VerticalAlignment, rhs: ETMultiColumnView.Configuration.Column.Layout.VerticalAlignment) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

public func ==(lhs: ETMultiColumnView.Configuration.Column.Layout.Edges, rhs: ETMultiColumnView.Configuration.Column.Layout.Edges) -> Bool {
    return lhs.hashValue == rhs.hashValue
}
