//
//  Withable.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation

protocol Withable {}

extension Withable where Self: AnyObject {
    @discardableResult
    func with<T>(_ property: ReferenceWritableKeyPath<Self, T>, setTo value: T) -> Self {
        self[keyPath: property] = value
        return self
    }
}
