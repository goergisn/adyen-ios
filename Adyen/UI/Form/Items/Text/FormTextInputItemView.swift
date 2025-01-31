//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form view representing a plain text input.
@_spi(AdyenInternal)
public final class FormTextInputItemView: FormTextItemView<FormTextInputItem> {

    // MARK: - Initializers

    /// Initializes the text item view.
    /// - Parameter item: The item represented by the view.
    public required init(item: FormTextInputItem) {
        super.init(item: item)

        observe(item.$isEnabled) { [weak self] isEnabled in
            guard let self else { return }
            self.textField.isEnabled = isEnabled
            if isEnabled {
                self.updateValidationStatus()
                self.textField.textColor = item.style.text.color
            } else {
                self.resetValidationStatus()
                self.textField.textColor = item.style.text.disabledColor
            }
        }
        
        observe(item.isHidden) { [weak self] isHidden in
            if isHidden {
                self?.resignFirstResponder()
            }
        }
        
        item.focusHandler = { [weak self] in
            self?.becomeFirstResponder()
        }
    }
}
