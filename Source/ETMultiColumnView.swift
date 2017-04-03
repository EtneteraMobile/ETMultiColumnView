//
//  ETMultiColumnView.swift
//  ETMultiColumnView
//
//  Created by Jan Čislinský on 20/01/2017.
//
//

import UIKit

public protocol MultiColumnConfigurable {
    init(with config: ETMultiColumnView.Configuration)
    func customize(with config: ETMultiColumnView.Configuration) throws
    static func identifier(with config: ETMultiColumnView.Configuration) -> String
    static func height(with config: ETMultiColumnView.Configuration, width: CGFloat) throws -> CGFloat
}

/// Configurable multi-column view
public final class ETMultiColumnView: UIView, MultiColumnConfigurable {
    
    // MARK: - Variables
    // MARK: private
    
    /// Cell configuration structure
    private var config: Configuration
    private let borderLayer: CALayer
    private let path = UIBezierPath()
    
    // MARK: - Initialization
    
    /// The only ETMultiColumnView constructor.
    /// There is set up reuseIdentifier for given content. Subviews are createdl.
    public init(with config: Configuration) {
        self.config = config
        borderLayer = CALayer()

        super.init(frame: .zero)

        setupSubviews()
        layer.addSublayer(borderLayer)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Content
    // MARK: - private

    /// Setup subviews based on current configuration.
    private func setupSubviews() {
        config.columns.forEach { columnConfig in
            addSubview(columnConfig.viewProvider.make())
            borderLayer.addSublayer(CAShapeLayer())
        }
    }

    /// Customize columns with content from current configuration.
    private func customizeColumns() throws {
        let subviewsCount = subviews.count
        var lastRightEdge: CGFloat = 0.0

        let columnsWithSizes = try config.columnsWithSizes(in: frame.size.width)
        let maxHeight = columnsWithSizes.maxHeight

        borderLayer.frame = bounds

        for (offset, columnWrapper) in columnsWithSizes.enumerate() {
            guard offset < subviewsCount else { return }
            let subview = subviews[offset]

            subview.frame = makeFrame(for: columnWrapper, x: lastRightEdge, maxHeight: maxHeight)
            config.columns[offset].viewProvider.customize(view: subview)
            adjustBorder(on: borderLayer, at: offset, x: lastRightEdge, columnWrapper)

            lastRightEdge += columnWrapper.size.width
        }

        // Adjusts height of view accrding maxHeight
        frame = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: maxHeight))
    }

    private func makeFrame(for columnWrapper: ETMultiColumnView.Configuration.ColumnWrapper, x: CGFloat, maxHeight: CGFloat) -> CGRect {
        let edgeInsets = columnWrapper.edges.insets
        let columnWidth = columnWrapper.size.width
        let inWidth = columnWidth - edgeInsets.horizontal
        let inHeight = columnWrapper.size.height - edgeInsets.vertical
        let contentSize = CGSize(width: inWidth, height: inHeight)
        let top: CGFloat

        switch columnWrapper.alignment {
        case .bottom:
            top = maxHeight - contentSize.height - edgeInsets.bottom
        case .middle:
            top = (maxHeight - contentSize.height)/2.0
        case .top:
            top = edgeInsets.top
        }

        return CGRect(origin: CGPoint(x: x + edgeInsets.left, y: top), size: contentSize).integral
    }

    private func adjustBorder(on border: CALayer, at idx: Int, x: CGFloat, _ wrapper: ETMultiColumnView.Configuration.ColumnWrapper) {
        let layer = border.sublayers?[idx]
        let columnSize = CGSize(width: wrapper.size.width, height: frame.height)
        layer?.frame = CGRect(origin: CGPoint(x: x, y: 0), size: columnSize)
        if wrapper.borders.isEmpty {
            hideBorders(column: layer)
        }
        wrapper.borders.forEach {
            switch $0 {
            case let .left(width: borderWidth, color: borderColor):
                showLeftBorder(column: layer, width: borderWidth, color: borderColor)
            }
        }
    }

    /// Will show left border with given properties (color, width)
    ///
    /// - Parameters:
    ///   - layer: expects CAShapeLayer
    ///   - width: border width
    ///   - color: border color
    private func showLeftBorder(column layer: CALayer?, width: CGFloat, color: UIColor) {
        guard let sublayer = layer as? CAShapeLayer else { return }

        path.removeAllPoints()
        path.moveToPoint(.zero)
        path.addLineToPoint(CGPoint(x: 0, y: frame.height))

        sublayer.path = path.CGPath
        sublayer.strokeColor = color.CGColor
        sublayer.lineWidth = width
    }

    private func hideBorders(column layer: CALayer?) {
        guard let sublayer = layer as? CAShapeLayer else { return }
        sublayer.path = nil
    }

    // MARK: - Actions

    // MARK: public

    /// Customize cell with content. When layout missmatch configurations occurs, Error is thrown.
    ///
    /// - Parameter config: cell configuration
    /// - Throws: `ETMultiColumnViewError.columnsCountMissmatch`, `ETMultiColumnViewError.heighMissmatch`
    public func customize(with config: Configuration) throws {
        guard self.config.columns.count == config.columns.count else {
            let errorDescription = "expected: \(self.config.columns.count) columns, got: \(config.columns.count) columns"
            throw ETMultiColumnView.Error.columnsCountMissmatch(description: errorDescription)
        }

        // Updates local config
        self.config = config

        // Adjusts background
        backgroundColor = config.backgroundColor

        // Customizes content according new configuration
        try customizeColumns()
    }
}

// MARK: - Static

public extension ETMultiColumnView {

    /// Returns unique identifier for given configuration
    ///
    /// - Parameter config: cell configuration
    /// - Returns: unique string - hash from cell configuaration layout parameters
    public static func identifier(with config: ETMultiColumnView.Configuration) -> String {
        let cellId = NSStringFromClass(ETMultiColumnView.self)
        let columnsId = config.columns.reduce("") { return $0 + $1.viewProvider.reuseId }

        return cellId + columnsId
    }

    /// Returns height of cell for given configuration
    ///
    /// - Parameter config: cell configuration
    /// - Returns: height of cell for given configuration
    public static func height(with config: ETMultiColumnView.Configuration, width: CGFloat) throws -> CGFloat {
        let columnsWithSizes = try config.columnsWithSizes(in: width)
        return columnsWithSizes.maxHeight
    }
}

// MARK: - Helpers

private extension CollectionType where Generator.Element == ETMultiColumnView.Configuration.ColumnWrapper {

    var maxHeight: CGFloat {
        return self.maxElement({ $0.size.height < $1.size.height })?.size.height ?? 0.0
    }
}
