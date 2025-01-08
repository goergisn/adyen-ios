//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

internal protocol BACSConfirmationViewProtocol: FormViewProtocol {
    func setUserInteraction(enabled: Bool)
}

internal class BACSConfirmationViewController: FormViewController, BACSConfirmationViewProtocol {

    // MARK: - Properties

    internal weak var presenter: BACSConfirmationPresenterProtocol?

    // MARK: - Initializers

    internal init(
        title: String,
        scrollEnabled: Bool,
        styleProvider: FormComponentStyle,
        localizationParameters: LocalizationParameters? = nil
    ) {
        super.init(
            scrollEnabled: scrollEnabled,
            style: styleProvider,
            localizationParameters: localizationParameters
        )
        self.title = title
    }

    // MARK: - View life cycle

    override internal func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }

    // MARK: - BACSConfirmationViewProtocol

    internal func setUserInteraction(enabled: Bool) {
        view.isUserInteractionEnabled = enabled
    }
}
