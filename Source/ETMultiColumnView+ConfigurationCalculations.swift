//
//  ETMultiColumnView+ConfigurationCalculations.swift
//  ETMultiColumnView
//
//  Created by Jan Čislinský on 17/02/2017.
//
//

import UIKit

// MARK: - Configuration.columnsWithSizes

public extension ETMultiColumnView.Configuration {

    public struct ColumnWrapper {
        let column: ETMultiColumnView.Configuration.Column
        let size: CGSize
        let edges: Column.Layout.Edges
        let borders: [Column.Layout.Border]
        let alignment: Column.Layout.VerticalAlignment
    }

    internal func columnsWithSizes(in width: CGFloat) throws -> [ColumnWrapper] {

        // Is width valid
        guard width > 0.0 else { throw ETMultiColumnView.Error.invalidWidth() }

        // Calculates fixed columns width sum
        var relativeColumnsCount = 0
        let fixedColumnsWidthSum = columns.reduce(CGFloat(0.0)) {
            guard let width = $1.layout.fixedWidth() else {
                relativeColumnsCount += 1
                return $0
            }
            return $0 + width
        }

        let remainingWidth = width - fixedColumnsWidthSum

        // Is width sufficient
        guard remainingWidth > 0.0 else {
            let description = "Sum width of fixed colums is longer than column width (fixedColumnsWidthSum=\(fixedColumnsWidthSum), columnWidth=\(width))."
            throw ETMultiColumnView.Error.insufficientWidth(description: description)
        }

        let relativeColumnWidth = floor(remainingWidth / CGFloat(relativeColumnsCount))

        // Calculates columns frame
        let result:[ColumnWrapper] = try columns.map {
            let edges: Column.Layout.Edges
            let width: CGFloat
            let borders: [Column.Layout.Border]
            let alignment: Column.Layout.VerticalAlignment

            switch $0.layout {
            case let .rel(borders: b, edges: e, verticalAlignment: a):
                borders = b
                width = relativeColumnWidth
                edges = e
                alignment = a
            case let .fix(width: w, borders: b, edges: e, verticalAlignment: a):
                borders = b
                width = w
                edges = e
                alignment = a
            }

            let verticalEdges = edges.insets.vertical
            let horizontalEdges = edges.insets.horizontal

            let inWidth = width - horizontalEdges
            guard inWidth > 0 else {
                let description = "Horizontal edges are longer than cell width (horizontalEdges=\(horizontalEdges), columnWidth=\(width))."
                throw ETMultiColumnView.Error.insufficientWidth(description: description)
            }

            let height: CGFloat

            let size = $0.viewProvider.size(for: inWidth)
            height = size.height
            guard size.width <= inWidth else {
                let description = "Width of custom view is loonger than given width of cell content view (provider.viewSize().width=\(size.width), inWidth=\(inWidth))."
                throw ETMultiColumnView.Error.insufficientWidth(description: description)
            }

            return ColumnWrapper(column: $0, size: CGSize(width: width, height: height + verticalEdges), edges: edges, borders: borders, alignment: alignment)
        }
        
        return result
    }
}
