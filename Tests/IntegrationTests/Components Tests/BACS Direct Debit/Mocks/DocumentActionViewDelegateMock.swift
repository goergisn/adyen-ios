//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import Foundation

internal final class DocumentActionViewDelegateMock: DocumentActionViewDelegate {
    var onDidComplete: (() -> Void)?
    
    func didComplete() {
        onDidComplete?()
    }
    
    var onMainButtonTap: ((UIView, Downloadable) -> Void)?

    func mainButtonTap(sourceView: UIView, downloadable: Downloadable) {
        onMainButtonTap?(sourceView, downloadable)
    }
}
