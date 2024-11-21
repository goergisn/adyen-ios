//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenEncryption)
    import AdyenEncryption
#endif
import Foundation

/// Contains the details provided by the gift card component with meal voucher payment method.
public struct MealVoucherDetails: PartialPaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?

    /// The brand of a payment method .
    public let brand: PaymentMethodType

    /// The payment method type.
    public let type: PaymentMethodType = mealVoucherPaymentMethodType

    /// The encrypted card number.
    public let encryptedCardNumber: String

    /// The encrypted security code.
    public let encryptedSecurityCode: String
    
    /// The encrypted expiration month.
    public let encryptedExpiryMonth: String?

    /// The encrypted expiration year.
    public let encryptedExpiryYear: String?
    
    /// Initializes the meal voucher payment details.
    ///
    /// - Parameters:
    ///   - paymentMethod: The used gift card payment method.
    ///   - encryptedCard: The encrypted card .
    public init(paymentMethod: MealVoucherPaymentMethod, encryptedCard: EncryptedCard) throws {
        guard let number = encryptedCard.number,
              let securityCode = encryptedCard.securityCode else { throw GiftCardComponent.Error.cardEncryptionFailed }

        self.brand = paymentMethod.type
        self.encryptedCardNumber = number
        self.encryptedSecurityCode = securityCode
        self.encryptedExpiryYear = encryptedCard.expiryYear
        self.encryptedExpiryMonth = encryptedCard.expiryMonth
    }
}
