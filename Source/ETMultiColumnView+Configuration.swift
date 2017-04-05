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
    public struct Configuration: Hashable {

        // MARK: - Variables
        // MARK: public

        /// Array of configuration for each column
        public let columns: [Column]

        /// Background color of contentView
        public let backgroundColor: UIColor?

        public var hashValue: Int {
            return columns.reduce(0) { $0 ^ $1.hashValue }
        }

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
    public struct Column: Hashable {

        // MARK: - Variables
        // MARK: public

        public let layout: Layout
        public let viewProvider: ViewProvider

        public var hashValue: Int {
            return layout.hashValue ^ viewProvider.hashValue
        }

        // MARK: internal

        var calculatedInnerSize: CGSize?

        // MARK: - Initialization

        public init(layout: Layout, content viewProvider: ViewProvider) {
            self.layout = layout
            self.viewProvider = viewProvider
        }
    }
}

// MARK: - Configuration.Column.Layout

public extension ETMultiColumnView.Configuration.Column {

    /// Layout properties
    ///
    /// - relative: relative size column
    /// - fixed: fixed size column (size as parameter)
    public enum Layout: Hashable {

        public var hashValue: Int {
            if case let .rel(b, e, a) = self { return b.reduce(0) { $0 ^ $1.hashValue } ^ e.hashValue ^ a.hashValue }
            if case let .fix(w, b, e, a) = self { return w.hashValue ^ b.reduce(0) { $0 ^ $1.hashValue } ^ e.hashValue ^ a.hashValue }
            return 0
        }

        // MARK: - Cases

        case rel(borders: [Border], edges: Edges, verticalAlignment: VerticalAlignment)
        case fix(outWidth: CGFloat, borders: [Border], edges: Edges, verticalAlignment: VerticalAlignment)
        case fit(maxOutWidth: CGFloat, borders: [Border], edges: Edges, verticalAlignment: VerticalAlignment)

        // MARK: - Builders

        public static func relative(borders borders: [Border] = [], edges: Edges = .zero, verticalAlignment: VerticalAlignment = .top) -> Layout {
            return .rel(borders: borders, edges: edges, verticalAlignment: verticalAlignment)
        }

        public static func fixed(outWidth width: CGFloat, borders: [Border] = [], edges: Edges = .zero, verticalAlignment: VerticalAlignment = .top) -> Layout {
            return .fix(outWidth: width, borders: borders, edges: edges, verticalAlignment: verticalAlignment)
        }

        public static func fitContent(maxOutWidth maxWidth: CGFloat = CGFloat.max, borders: [Border] = [], edges: Edges = .zero, verticalAlignment: VerticalAlignment = .top) -> Layout {
            return .fit(maxOutWidth: maxWidth, borders: borders, edges: edges, verticalAlignment: verticalAlignment)
        }
    }
}

// MARK: - Configuration.Column.Layout additions

public extension ETMultiColumnView.Configuration.Column.Layout {

    public enum Border: Hashable {
        case left(width: CGFloat, color: UIColor)

        public var hashValue: Int {
            if case let .left(w, c) = self { return w.hashValue ^ c.hashValue}
            return 0
        }
    }

    public enum VerticalAlignment: Hashable {
        case top
        case middle
        case bottom

        public var hashValue: Int {
            switch self {
            case .top: return 11
            case .middle: return 22
            case .bottom: return 33
            }
        }
    }
}

// MARK: - Configuration.Column.Layout.Edges

public extension ETMultiColumnView.Configuration.Column.Layout {

    public enum Edges: Hashable {

        public var hashValue: Int {
            if case let .inner(t, l, b, r) = self { return t.hashValue ^ l.hashValue ^ b.hashValue ^ r.hashValue }
            return 0
        }

        // MARK: - Cases

        case inner(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat)
        case zero

        // MARK: - Builders

        public static func insets(top top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Edges {
            return .inner(top: top, left: left, bottom: bottom, right: right)
        }

        public static func insets(vertical vertical: CGFloat = 0, horizontal: CGFloat = 0) -> Edges {
            return .inner(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        }

        public static func insets(all all: CGFloat = 0) -> Edges {
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