//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
@testable import AdyenDropIn
import Foundation
import XCTest

final class PresentationDelegateMock: NavigationDelegate {

    var doDismiss: (((() -> Void)?) -> Void)?

    func dismiss(completion: (() -> Void)?) {
        doDismiss?(completion)
    }

    // MARK: - presentComponent

    var presentComponentCallsCount = 0
    var presentComponentCalled: Bool {
        presentComponentCallsCount > 0
    }

    var presentComponentReceivedComponent: PresentableComponent?
    var doPresent: ((_ component: PresentableComponent) throws -> Void)?

    func present(component: PresentableComponent) {
        presentComponentCallsCount += 1
        presentComponentReceivedComponent = component
        
        do {
            try doPresent?(component)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

}
