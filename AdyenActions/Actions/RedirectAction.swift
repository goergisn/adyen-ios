//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user is redirected to a URL.
public struct RedirectAction: Decodable {
    
    /// Defines the type of redirect flow utilized by the `RedirectAction` object.
    public enum RedirectType: String, Decodable {
        // swiftlint:disable redundant_string_enum_value
        case redirect = "redirect"
        case nativeRedirect = "nativeRedirect"

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let type = try container.decode(String.self)
            self = RedirectType(rawValue: type) ?? .redirect
        }
    }

    /// The URL to which to redirect the user.
    public let url: URL

    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String?

    internal let type: RedirectType

    /// Native redirect data.
    public let nativeRedirectData: String?
    
    internal let paymentMethodType: String?
    
    /// Initializes a redirect action.
    ///
    /// - Parameters:
    ///   - url: The URL to which to redirect the user.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    ///   - type: The redirect flow  used by the action. Defaults to `redirect`.
    ///   - nativeRedirectData: Native redirect data. Defaults to `nil`.
    ///   - paymentMethodType: The type of the payment method.
    public init(
        url: URL,
        paymentData: String?,
        type: RedirectType = .redirect,
        nativeRedirectData: String? = nil,
        paymentMethodType: String? = nil
    ) {
        self.url = url
        self.paymentData = paymentData
        self.type = type
        self.nativeRedirectData = nativeRedirectData
        self.paymentMethodType = paymentMethodType
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(URL.self, forKey: .url)
        self.paymentData = try container.decodeIfPresent(String.self, forKey: .paymentData)
        self.type = try container.decode(RedirectType.self, forKey: .type)
        self.nativeRedirectData = try container.decodeIfPresent(String.self, forKey: .nativeRedirectData)
        self.paymentMethodType = try container.decodeIfPresent(String.self, forKey: .paymentMethodType)
    }

    // MARK: - Private

    private enum CodingKeys: CodingKey {
        case url
        case paymentData
        case type
        case nativeRedirectData
        case paymentMethodType
    }
}
