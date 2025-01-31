//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen

class AnalyticsFlavorTests: XCTestCase {

    var sut: AnalyticsFlavor!

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }

    func testAnalyticsFlavorValueWhenFlavorIsComponentsMatchesFlavorType() throws {
        // Given
        let expectedFlavorValue = "components"

        // When
        sut = .components(type: .affirm)

        // Then
        XCTAssertEqual(expectedFlavorValue, sut.value)
    }

    func testAnalyticsFlavorValueWhenFlavorIsDropInMatchesFlavorType() throws {
        // Given
        let expectedFlavorValue = "dropin"

        // When
        sut = .dropIn(paymentMethods: ["scheme", "affirm", "atome"])

        // Then
        XCTAssertEqual(expectedFlavorValue, sut.value)
    }
}
