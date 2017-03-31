//
//  ETMultiColumnViewError.swift
//  ETMultiColumnView
//
//  Created by Petr Urban on 24/01/2017.
//
//

import Foundation

extension ETMultiColumnView {

    public enum Error: Swift.ErrorType {
        case columnsCountMissmatch(description: String)
        case invalidWidth()
        case insufficientWidth(description: String)
    }
}
