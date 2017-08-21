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
            if case .fit(maxOutWidth: let maxWidth, borders: _, edges: let edges, verticalAlignment: _) = $0.layout {
                var col = $0
                col.calculatedInnerSize = col.viewProvider.boundingSize(widthConstraint: (min(width, maxWidth) - edges.insets.horizontal))
                return col
            } else {
                return $0
            }
        }

        // Calculates fixed+fit columns width sum
        var relativeColumnsCount = 0
        let reservedColumnsWidth = precalculatedColumns.reduce(CGFloat(0.0)) { a, x in
            if case .fix(outWidth: let width, borders: _, edges: _, verticalAlignment: _) = x.layout {
                return a + width
            } else if case .fit(maxOutWidth: _, borders: _, edges: let e, verticalAlignment: _) = x.layout {
                return a + (x.calculatedInnerSize == nil ? 0.0 : x.calculatedInnerSize!.width + e.insets.horizontal)
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
        let result:[ColumnWrapper] = try precalculatedColumns.map { col in
            let edges: Column.Layout.Edges
            let outWidth: CGFloat
            let borders: [Column.Layout.Border]
            let alignment: Column.Layout.VerticalAlignment

            switch col.layout {
            case let .rel(borders: b, edges: e, verticalAlignment: a):
                borders = b
                outWidth = relativeColumnWidth
                edges = e
                alignment = a
            case let .fix(outWidth: w, borders: b, edges: e, verticalAlignment: a):
                borders = b
                outWidth = w
                edges = e
                alignment = a
            case let .fit(maxOutWidth: _, borders: b, edges: e, verticalAlignment: a):
                borders = b
                outWidth = (col.calculatedInnerSize == nil ? 0.0 : col.calculatedInnerSize!.width + e.insets.horizontal)
                edges = e
                alignment = a
            }

            let verticalEdges = edges.insets.vertical
            let horizontalEdges = edges.insets.horizontal

            let inWidth = outWidth - horizontalEdges

            if inWidth <= 0 {
                // Relative column can have width = 0
                if case .rel = col.layout {
                    // Hides column
                    return ColumnWrapper(column: col, size: .zero, edges: .zero, borders: [], alignment: alignment)
                } else {
                    let description = "InWidth is negative or 0, horizontal edges are longer than cell width (horizontalEdges=\(horizontalEdges), columnWidth=\(outWidth))."
                    throw ETMultiColumnView.Error.insufficientWidth(description: description)
                }
            }

            let size: CGSize
            if let calculated = col.calculatedInnerSize {
                size = calculated
            } else {
                let boundingSize = col.viewProvider.boundingSize(widthConstraint: inWidth)
                size = CGSize(width: max(inWidth, boundingSize.width), height: boundingSize.height)
            }
            let height = size.height
            guard size.width <= inWidth else {
                let description = "Width of custom view is loonger than given width of cell content view (provider.viewSize().width=\(size.width), inWidth=\(inWidth))."
                throw ETMultiColumnView.Error.insufficientWidth(description: description)
            }

            return ColumnWrapper(column: col, size: CGSize(width: ceil(outWidth), height: ceil(height + verticalEdges)), edges: edges, borders: borders, alignment: alignment)
        }
        
        return result
    }
}
