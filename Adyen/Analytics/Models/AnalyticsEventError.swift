//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Represents an error in the analytics scheme that indicates the flow was interrupted due to an error in the SDK.
@_spi(AdyenInternal)
public struct AnalyticsEventError: AnalyticsEvent {
    
    public var id: String = UUID().uuidString
    
    public var timestamp = Int(Date().timeIntervalSince1970)
     
    public var component: String
    
    public var errorType: ErrorType
    
    public var code: String?
    
    public var message: String?
    
    public enum ErrorType: String, Encodable {
        case network = "Network"
        case implementation = "Implementation"
        case `internal` = "Internal"
        case api = "ApiError"
        case sdk = "SdkError"
        case thirdParty = "ThirdParty"
        case generic = "Generic"
        case redirect = "Redirect"
        case threeDS2 = "ThreeDS2"
    }
    
    public init(component: String, type: ErrorType) {
        self.component = component
        self.errorType = type
    }
}
