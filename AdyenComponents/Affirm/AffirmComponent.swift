//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// Configuration for Affirm Component
public typealias AffirmComponentConfiguration = PersonalInformationConfiguration

/// A component that provides a form for Affirm payment.
public final class AffirmComponent: AbstractPersonalInformationComponent, Observer {
    
    private enum ViewIdentifier {
        static let billingAddress = "billingAddressItem"
        static let deliveryAddress = "deliveryAddressItem"
        static let deliveryAddressToggle = "deliveryAddressToggleItem"
    }
    
    // MARK: - Items
    
    /// :nodoc:
    private let personalDetailsHeaderItem: FormLabelItem
    
    /// :nodoc:
    internal let deliveryAddressToggleItem: FormToggleItem

    // MARK: - Initializers
    
    /// Initializes the Affirm component.
    /// - Parameters:
    ///   - paymentMethod: The Affirm payment method.
    ///   - apiContext: The component's API context.
    ///   - adyenContext: The Adyen context.
    ///   - configuration: The component's configuration.
    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext,
                adyenContext: AdyenContext,
                configuration: AffirmComponentConfiguration) {
        personalDetailsHeaderItem = FormLabelItem(text: "", style: configuration.style.sectionHeader)
        deliveryAddressToggleItem = FormToggleItem(style: configuration.style.toggle)
        
        let fields: [PersonalInformation] = [
            .custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 2))),
            .custom(CustomFormItemInjector(item: personalDetailsHeaderItem.addingDefaultMargins())),
            .firstName,
            .lastName,
            .email,
            .phone,
            .address,
            .custom(CustomFormItemInjector(item: deliveryAddressToggleItem)),
            .deliveryAddress,
            .custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 1)))
        ]
        
        super.init(paymentMethod: paymentMethod,
                   apiContext: apiContext,
                   adyenContext: adyenContext,
                   fields: fields,
                   configuration: configuration)

        setupItems()
    }
    
    // MARK: - Private
    
    /// :nodoc:
    private func setupItems() {
        personalDetailsHeaderItem.text = localizedString(.boletoPersonalDetails, configuration.localizationParameters)
        emailItem?.autocapitalizationType = .none
        
        setupDeliveryAddressItem()
        setupDeliveryAddressToggleItem()
        setupShopperInformation()
    }
    
    /// :nodoc:
    private func setupDeliveryAddressItem() {
        deliveryAddressItem?.title = localizedString(.deliveryAddressSectionTitle, configuration.localizationParameters)
    }
    
    /// :nodoc:
    private func setupDeliveryAddressToggleItem() {
        guard let deliveryAddressItem = deliveryAddressItem else { return }
        deliveryAddressToggleItem.title = localizedString(.affirmDeliveryAddressToggleTitle, configuration.localizationParameters)
        deliveryAddressToggleItem.value = false
        deliveryAddressToggleItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                                           postfix: ViewIdentifier.deliveryAddressToggle)
        bind(deliveryAddressToggleItem.publisher, to: deliveryAddressItem, at: \.isHidden.wrappedValue, with: { !$0 })
    }
    
    /// :nodoc:
    private func setupShopperInformation() {
        if configuration.shopperInformation?.deliveryAddress != nil {
            deliveryAddressToggleItem.value = true
        }
    }
    
    // MARK: - Public
    
    /// :nodoc:
    override public func submitButtonTitle() -> String {
        localizedString(.confirmPurchase, configuration.localizationParameters)
    }
    
    /// :nodoc:
    override public func createPaymentDetails() -> PaymentMethodDetails {
        guard let firstName = firstNameItem?.value,
              let lastName = lastNameItem?.value,
              let emailAddress = emailItem?.value,
              let telephoneNumber = phoneItem?.value,
              let billingAddress = addressItem?.value,
              let deliveryAddress = deliveryAddressItem?.value else {
            fatalError("There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        
        let shopperName = ShopperName(firstName: firstName, lastName: lastName)
        let affirmDetails = AffirmDetails(paymentMethod: paymentMethod,
                                          shopperName: shopperName,
                                          telephoneNumber: telephoneNumber,
                                          emailAddress: emailAddress,
                                          billingAddress: billingAddress,
                                          deliveryAddress: deliveryAddressToggleItem.value ? deliveryAddress : billingAddress)
        return affirmDetails
    }
    
    /// :nodoc:
    override public func phoneExtensions() -> [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .generic)
        return PhoneExtensionsRepository.get(with: query)
    }
}
