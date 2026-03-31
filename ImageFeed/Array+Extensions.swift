//
//  Array+Extensions.swift
//  ImageFeed
//
//  Created by Moxa on 30/03/26.
//

import Foundation

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
