//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes an action in which the user is redirected to a URL.
public struct RedirectAction: Decodable {
    
    /// The URL to which to redirect the user.
    public let url: URL
    
    /// The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    public let paymentData: String?
    
    /// Native redirect data.
    public let nativeRedirectData: String?
    
    internal let paymentMethodType: String?
    
    /// Initializes a redirect action.
    ///
    /// - Parameters:
    ///   - url: The URL to which to redirect the user.
    ///   - paymentData: The server-generated payment data that should be submitted to the `/payments/details` endpoint.
    ///   - nativeRedirectData: Native redirect data.
    ///   - paymentMethodType: The type of the payment method.
    public init(
        url: URL,
        paymentData: String?,
        nativeRedirectData: String? = nil,
        paymentMethodType: String? = nil
    ) {
        self.url = url
        self.paymentData = paymentData
        self.nativeRedirectData = nativeRedirectData
        self.paymentMethodType = paymentMethodType
    }
}
