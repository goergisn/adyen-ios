//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension Result {
    
    var failure: Failure? {
        switch self {
        case .success:
            return nil
        case let .failure(failure):
            return failure
        }
    }
}
