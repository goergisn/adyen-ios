//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenActions
@testable @_spi(AdyenInternal) import AdyenCard
import Foundation

final class AnyThreeDS2ActionHandlerMock: AnyThreeDS2ActionHandler {
    var presentationDelegate: (any Adyen.PresentationDelegate)?
    
    var threeDSRequestorAppURL: URL?

    var mockedFingerprintResult: Result<ThreeDSActionHandlerResult, Error>?

    func handle(_ action: ThreeDS2FingerprintAction, completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        guard let result = mockedFingerprintResult else { assertionFailure(); return }
        completionHandler(result)
    }

    var mockedChallengeResult: Result<ThreeDSActionHandlerResult, Error>?

    func handle(_ action: ThreeDS2ChallengeAction, completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void) {
        guard let result = mockedChallengeResult else { assertionFailure(); return }
        completionHandler(result)
    }
}
