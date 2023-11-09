//
//  ErrorService.swift
//  rps-ios
//
//  Created by serika on 2023/11/9.
//

import Foundation
import Combine

@MainActor
class ErrorService: ObservableObject {
    @Published var showError = false
    @Published var errorMessage: String? = nil
    
    var timer: Cancellable? {
        willSet {
            timer?.cancel()
        }
    }
    
    init() {
        Box.shared.errorSubject
            .map { $0?.localizedDescription }
            .assign(to: &$errorMessage)
        Box.shared.errorSubject
            .map { $0 != nil }
            .assign(to: &$showError)
        Box.shared.errorSubject
            .filter { $0 != nil }
            .delay(for: 3, scheduler: RunLoop.main)
            .map { _ in false }
            .assign(to: &$showError)
    }
}
