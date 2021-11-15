//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension CardEncryptor.Card {
    /// Encrypts the card as a token.
    ///
    /// - Parameters:
    ///   - publicKey: The public key to use for encryption (format "Exponent|Modulus").
    ///   - holderName: The card holder name.
    /// - Returns: A string token containig encrypted card data.
    /// - Throws: `CardEncryptor.Error.encryptionFailed` if the encryption failed,
    ///  maybe because the card public key is an invalid one, or for any other reason.
    /// - Throws: `CardEncryptor.Error.invalidEncryptionArguments` when trying to encrypt a card with  card number, securityCode,
    /// expiryMonth, and expiryYear, all of them are nil.
    func encryptedToToken(publicKey: String, holderName: String?) throws -> String {
        guard !isEmpty else {
            throw CardEncryptor.Error.invalidEncryptionArguments
        }
        var card = CardEncryptor.Card(number: number,
                                      securityCode: securityCode,
                                      expiryMonth: expiryMonth,
                                      expiryYear: expiryYear,
                                      generationDate: generationDate)
        card.holder = holderName
        return try encryptCard(publicKey: publicKey, card: card)
    }
}

extension CardEncryptor.Card {
    func encryptedNumber(publicKey: String, date: Date) throws -> String? {
        guard let number = number else { return nil }
        var card = CardEncryptor.Card(number: number)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }

    func encryptedSecurityCode(publicKey: String, date: Date) throws -> String? {
        guard let securityCode = securityCode else { return nil }
        var card = CardEncryptor.Card(securityCode: securityCode)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }

    func encryptedExpiryMonth(publicKey: String, date: Date) throws -> String? {
        guard let expiryMonth = expiryMonth else { return nil }
        var card = CardEncryptor.Card(expiryMonth: expiryMonth)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }

    func encryptedExpiryYear(publicKey: String, date: Date) throws -> String? {
        guard let expiryYear = expiryYear else { return nil }
        var card = CardEncryptor.Card(expiryYear: expiryYear)
        card.generationDate = date
        return try encryptCard(publicKey: publicKey, card: card)
    }

    private func encryptCard(publicKey: String, card: CardEncryptor.Card) throws -> String {
        guard let encodedCard = card.jsonData() else { throw CardEncryptor.Error.invalidEncryptionArguments }

        do {
            return try Cryptor.encrypt(data: encodedCard, publicKey: publicKey)
        } catch {
            throw CardEncryptor.Error.encryptionFailed
        }
    }
}