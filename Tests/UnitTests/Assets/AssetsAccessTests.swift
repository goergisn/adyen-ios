//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import XCTest

class AssetsAccessTests: XCTestCase {

    func testCoreResourcesAccess() throws {
        XCTAssertNotNil(UIImage(named: "verification_false", in: Bundle.coreInternalResources, compatibleWith: nil))
    }

    func testActionResourcesAccess() throws {
        XCTAssertNotNil(UIImage(named: "mbway", in: Bundle.actionsInternalResources, compatibleWith: nil))
        XCTAssertNotNil(UIImage(named: "blik", in: Bundle.actionsInternalResources, compatibleWith: nil))
    }
}
