//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

internal final class WeChatPayAdditionalDetails: AdditionalDetails {
    
    internal let resultCode: String
    
    internal init(resultCode: String) {
        self.resultCode = resultCode
    }
    
}
