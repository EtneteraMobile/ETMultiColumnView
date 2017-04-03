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

        // Calculates fitContent columns width
        let precalculatedColumns: [Column] = columns.map {
            if case .fit(maxWidth: let maxWidth, borders: _, edges: let edges, verticalAlignment: _) = $0.layout {
                var col = $0
                col.calculatedSize = col.viewProvider.size(for: (min(width, maxWidth) - edges.insets.horizontal))
                return col
            } else {
                return $0
            }
        }

        // Calculates fixed+fit columns width sum
        var relativeColumnsCount = 0
        let reservedColumnsWidth = precalculatedColumns.reduce(CGFloat(0.0)) { a, x in
            if case .fix(width: let width, borders: _, edges: _, verticalAlignment: _) = x.layout {
                return a + width
            } else if case .fit(maxWidth: _, borders: _, edges: _, verticalAlignment: _) = x.layout {
                return a + (x.calculatedSize?.width ?? 0.0)
            } else {
                relativeColumnsCount += 1
                return a
            }
        }

        let remainingWidth = width - reservedColumnsWidth

        // Is width sufficient
        guard remainingWidth >= 0.0 else {
            let description = "Sum width of fixed and fit colums is greater than available width (reservedColumnsWidth=\(reservedColumnsWidth), columnWidth=\(width))."
            throw ETMultiColumnView.Error.insufficientWidth(description: description)
        }

        let relativeColumnWidth = (remainingWidth > 0 ? floor(remainingWidth / CGFloat(relativeColumnsCount)) : 0.0)

        // Calculates columns frame
        let result:[ColumnWrapper] = try precalculatedColumns.map {
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
            case let .fit(maxWidth: _, borders: b, edges: e, verticalAlignment: a):
                borders = b
                width = $0.calculatedSize?.width ?? 0.0
                edges = e
                alignment = a
            }

            let verticalEdges = edges.insets.vertical
            let horizontalEdges = edges.insets.horizontal

            let inWidth = width - horizontalEdges
            guard inWidth >= 0 else {
                let description = "Horizontal edges are longer than cell width (horizontalEdges=\(horizontalEdges), columnWidth=\(width))."
                throw ETMultiColumnView.Error.insufficientWidth(description: description)
            }

            if inWidth == 0.0 {
                // Hides column
                return ColumnWrapper(column: $0, size: .zero, edges: .zero, borders: [], alignment: alignment)
            } else {
                let height: CGFloat

                let size = $0.calculatedSize ?? $0.viewProvider.size(for: inWidth)
                height = size.height
                guard size.width <= inWidth else {
                    let description = "Width of custom view is loonger than given width of cell content view (provider.viewSize().width=\(size.width), inWidth=\(inWidth))."
                    throw ETMultiColumnView.Error.insufficientWidth(description: description)
                }

                return ColumnWrapper(column: $0, size: CGSize(width: width, height: height + verticalEdges), edges: edges, borders: borders, alignment: alignment)
            }
        }
        
        return result
    }
}
