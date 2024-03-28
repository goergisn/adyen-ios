//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation
import QuartzCore
import UIKit

@_spi(AdyenInternal)
extension NSTextAlignment: AdyenCompatible {}

@_spi(AdyenInternal)
public extension AdyenScope where Base == NSTextAlignment {
    var caAlignmentMode: CATextLayerAlignmentMode {
        switch base {
        case .center:
            return .center
        case .justified:
            return .justified
        case .left:
            return .left
        case .right:
            return .right
        case .natural:
            return .natural
        default:
            return .center
        }
    }
}
