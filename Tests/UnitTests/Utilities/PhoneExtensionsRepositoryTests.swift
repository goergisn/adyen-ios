//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class PhoneExtensionsRepositoryTests: XCTestCase {

    func testQiwiWalletCodes() throws {
        let query = PhoneExtensionsQuery(paymentMethod: .qiwiWallet)
        XCTAssertEqual(query.codes, PhoneNumberPaymentMethod.qiwiWallet.codes)
    }

    func testQuery() {
        let query = PhoneExtensionsQuery(codes: ["US", "RU"])
        let extensions: [PhoneExtension] = PhoneExtensionsRepository.get(with: query)

        XCTAssertEqual(extensions.count, 2)
        XCTAssertNotNil(extensions.first { $0.value == "+1" })
        XCTAssertNotNil(extensions.first { $0.value == "+7" })
    }

    func testQueryNonValidCodes() {
        let query = PhoneExtensionsQuery(codes: ["UYF", "DK"])
        let extensions: [PhoneExtension] = PhoneExtensionsRepository.get(with: query)

        XCTAssertEqual(extensions.count, 1)
        XCTAssertNotNil(extensions.first { $0.value == "+45" })
    }

}
