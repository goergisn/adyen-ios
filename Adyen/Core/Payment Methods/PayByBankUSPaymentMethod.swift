//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// PayByBank US payment method.
public struct PayByBankUSPaymentMethod: PaymentMethod {
    public let type: PaymentMethodType
    
    public var name: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
