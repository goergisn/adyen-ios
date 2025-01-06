//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public final class PostalCodeValidator: LengthValidator, StatusValidator {
    
    public func validate(_ value: String) -> ValidationStatus {
        if super.isValid(value) {
            return .valid
        }
        
        if value.isEmpty {
            return .invalid(AddressAnalyticsValidationError.postalCodeEmpty)
        }
        
        return .invalid(AddressAnalyticsValidationError.postalCodePartial)
    }
    
    override public func isValid(_ value: String) -> Bool {
        validate(value).isValid
    }
    
}
