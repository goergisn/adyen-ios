//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard
import XCTest

final class CardComponentEventTests: XCTestCase {
    
    private var method: CardPaymentMethod {
        .init(
            type: .card,
            name: "Test name",
            fundingSource: .credit,
            brands: [.visa, .americanExpress, .masterCard]
        )
    }
    
    func testViewDidLoadShouldSendInitialCall() throws {
        // Given
        let analyticsProviderMock = AnalyticsProviderMock()
        let context = Dummy.context(with: analyticsProviderMock)
        let sut = CardComponent(paymentMethod: method,
                                context: context,
                                configuration: CardComponent.Configuration())

        // When
        sut.viewDidLoad(viewController: sut.cardViewController)

        // Then
        XCTAssertEqual(analyticsProviderMock.initialEventCallsCount, 1)
        XCTAssertEqual(analyticsProviderMock.infos.count, 1)
        let infoType = analyticsProviderMock.infos.first?.type
        XCTAssertEqual(infoType, .rendered)

    }

    func testCardNumberFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let cardNumberItemView: FormTextItemView<FormCardNumberItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        )

        testFocusEvents(for: cardNumberItemView,
                        target: .cardNumber,
                        analyticsProviderMock: analyticsProviderMock)
    }
    
    func testCardNumberValidationEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let cardNumberItemView: FormTextItemView<FormCardNumberItem> = try XCTUnwrap(
            sut.cardViewController.view.findView(with: "AdyenCard.FormCardNumberContainerItem.numberItem")
        )
        
        populate(textItemView: cardNumberItemView, with: "4444")
        cardNumberItemView.textFieldDidEndEditing(cardNumberItemView.textField)
        
        let validationEvent = analyticsProviderMock.infos[2]
        
        XCTAssertEqual(validationEvent.type, .validationError)
        XCTAssertEqual(validationEvent.target, .cardNumber)
    }

    func testExpiryDateFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let expiryDateItemView: FormTextItemView<FormCardExpiryDateItem> = try XCTUnwrap(sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.expiryDateItem"))

        testFocusEvents(for: expiryDateItemView,
                        target: .expiryDate,
                        analyticsProviderMock: analyticsProviderMock)
    }

    func testSecurityCodeFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        let sut = makeSUT(analyticsProviderMock: analyticsProviderMock)

        let securityCodeItemView: FormCardSecurityCodeItemView = try XCTUnwrap(sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.securityCodeItem"))

        testFocusEvents(for: securityCodeItemView,
                        target: .securityCode,
                        analyticsProviderMock: analyticsProviderMock)
    }

    func testHolderNameFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardComponent.Configuration()
        config.showsHolderNameField = true
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let holderNameItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.holderNameItem"))

        testFocusEvents(for: holderNameItemView,
                        target: .holderName,
                        analyticsProviderMock: analyticsProviderMock)
    }

    func testAuthItemFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardComponent.Configuration()
        config.koreanAuthenticationMode = .show
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let authItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.additionalAuthCodeItem"))

        testFocusEvents(for: authItemView,
                        target: .taxNumber,
                        analyticsProviderMock: analyticsProviderMock)
    }

    func testAuthPasswordFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardComponent.Configuration()
        config.koreanAuthenticationMode = .show
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)

        let authPasswordItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.additionalAuthPasswordItem"))

        testFocusEvents(for: authPasswordItemView,
                        target: .authPassWord,
                        analyticsProviderMock: analyticsProviderMock)
    }
    
    func testSocialSecurityFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardComponent.Configuration()
        config.socialSecurityNumberMode = .show
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)
        
        let socialSecurityItemView: FormTextItemView<FormTextInputItem> = try XCTUnwrap(sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.socialSecurityNumberItem"))
        
        testFocusEvents(for: socialSecurityItemView,
                        target: .boletoSocialSecurityNumber,
                        analyticsProviderMock: analyticsProviderMock)
    }
    
    func testPostalCodeFocusEvents() throws {
        let analyticsProviderMock = AnalyticsProviderMock()
        var config = CardComponent.Configuration()
        config.billingAddress.mode = .postalCode
        let sut = makeSUT(with: config, analyticsProviderMock: analyticsProviderMock)
        
        let postalCodeItemView: FormTextItemView<FormPostalCodeItem> = try XCTUnwrap(sut.cardViewController.view.findView(with: "AdyenCard.CardComponent.postalCodeItem"))
        
        testFocusEvents(for: postalCodeItemView,
                        target: .addressPostalCode,
                        analyticsProviderMock: analyticsProviderMock)
    }
    
    private func testFocusEvents(
        for field: FormTextItemView<some FormTextItem>,
        target: AnalyticsEventTarget,
        analyticsProviderMock: AnalyticsProviderMock
    ) {
        analyticsProviderMock.clearAll()
        
        field.textFieldDidBeginEditing(field.textField)
        field.textFieldDidEndEditing(field.textField)
        
        let firstInfoEvent = analyticsProviderMock.infos[0]
        let secondInfoEvent = analyticsProviderMock.infos[1]
        
        XCTAssertEqual(firstInfoEvent.type, .focus)
        XCTAssertEqual(firstInfoEvent.target, target)
        
        XCTAssertEqual(secondInfoEvent.type, .unfocus)
        XCTAssertEqual(secondInfoEvent.target, target)
    }
    
    private func makeSUT(with configuration: CardComponent.Configuration = .init(), analyticsProviderMock: AnalyticsProviderMock) -> CardComponent {
        let context = Dummy.context(with: analyticsProviderMock)
        let cardComponent = CardComponent(paymentMethod: method,
                                          context: context,
                                          configuration: configuration)
        cardComponent.viewController.loadViewIfNeeded()
        
        return cardComponent
    }

}