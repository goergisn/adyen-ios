//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

extension UIProgressView {
    convenience public init(style: ProgressViewStyle) {
        self.init()
        
        backgroundColor = style.backgroundColor
        progressTintColor = style.progressTintColor
        trackTintColor = style.trackTintColor
    }
}
