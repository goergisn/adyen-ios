//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

internal enum ThreeDSActionHandlerResult: Decodable {

    case action(Action)

    case details(AdditionalDetails)

    // MARK: - Coding

    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ActionType.self, forKey: .type)

        switch type {
        case .action:
            let action = try container.decode(Action.self, forKey: .action)
            self = .action(action)
        case .completed:
            let result = try container.decode(ThreeDSResult.self, forKey: .details)
            self = .details(ThreeDS2Details.completed(result))
        }
    }

    private enum ActionType: String, Decodable {
        case action
        case completed
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case details
        case action
    }
}
