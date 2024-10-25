//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user is redirected to an app.
public class NativeRedirectAction: RedirectAction {

    /// Native redirect data.
    public let nativeRedirectData: String?

    /// Initializes a native redirect action.
    ///
    /// - Parameters:
    ///   - url: The URL to which to redirect the user.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    ///   - nativeRedirectData: Native redirect data.
    public init(url: URL, paymentData: String?, nativeRedirectData: String? = nil) {
        self.nativeRedirectData = nativeRedirectData
        super.init(url: url, paymentData: paymentData)
    }

    public required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let url = try container.decode(URL.self, forKey: CodingKeys.url)
        let paymentData = try container.decodeIfPresent(String.self, forKey: CodingKeys.paymentData)
        self.nativeRedirectData = try container.decodeIfPresent(String.self, forKey: CodingKeys.nativeRedirectData)
        super.init(url: url, paymentData: paymentData)
    }

    // MARK: - CodingKeys

    private enum CodingKeys: CodingKey {
        case url
        case paymentData
        case nativeRedirectData
    }
}
