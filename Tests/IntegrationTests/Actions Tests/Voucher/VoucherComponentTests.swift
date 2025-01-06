//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
import UIKit
import XCTest

class VoucherComponentTests: XCTestCase {

    var sut: VoucherComponent!

    var presentationDelegate: PresentationDelegateMock!

    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    override func setUp() {
        super.setUp()
        presentationDelegate = PresentationDelegateMock()
        sut = VoucherComponent(context: Dummy.context)
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "test_table")
        sut.presentationDelegate = presentationDelegate
    }

    func testDokuVoucherComponent() throws {
        let action = try AdyenCoder.decode(dokuIndomaretAction) as VoucherAction

        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            presentationDelegateExpectation.fulfill()
        }

        sut.handle(action)

        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testEContextATMVoucherComponent() throws {
        let action = try AdyenCoder.decode(econtextATMAction) as VoucherAction
        
        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            presentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testBoletoVoucherComponent() throws {
        let action = try AdyenCoder.decode(boletoAction) as VoucherAction
        
        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            presentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testOXXOVoucherComponent() throws {
        let action = try AdyenCoder.decode(oxxoAction) as VoucherAction
        
        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            self.setupRootViewController(component.viewController)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            let optionsButton: UIButton! = component.viewController.view.findView(with: "AdyenActions.VoucherComponent.voucherView.secondaryButton")
            XCTAssertNotNil(optionsButton)
            XCTAssertEqual(optionsButton.titleLabel?.text, "More options")
            
            optionsButton.sendActions(for: .touchUpInside)
            
            wait(for: .milliseconds(300))
            
            let alertSheet = try! XCTUnwrap(UIViewController.topPresenter() as? UIAlertController)
            
            let expectedActionTitles = [
                "Copy code",
                "Download PDF",
                "Read instructions",
                "Cancel"
            ]
            
            XCTAssertEqual(alertSheet.actions.map(\.title), expectedActionTitles)
            XCTAssertEqual(alertSheet.actions.count, expectedActionTitles.count)
            
            presentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testMultibancoVoucherComponent() throws {
        let action = try AdyenCoder.decode(multibancoVoucher) as VoucherAction
        
        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            self.setupRootViewController(component.viewController)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            let optionsButton: UIButton! = component.viewController.view.findView(with: "AdyenActions.VoucherComponent.voucherView.secondaryButton")
            XCTAssertNotNil(optionsButton)
            XCTAssertEqual(optionsButton.titleLabel?.text, "More options")
            
            optionsButton.sendActions(for: .touchUpInside)
            
            let alertSheet = try waitUntilTopPresenter(isOfType: UIAlertController.self)
            
            let expectedActionTitles = [
                "Copy code",
                "Save as image",
                "Cancel"
            ]
            
            XCTAssertEqual(alertSheet.actions.map(\.title), expectedActionTitles)
            XCTAssertEqual(alertSheet.actions.count, expectedActionTitles.count)
            
            presentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testEContextStoresVoucherComponent() throws {
        let action = try AdyenCoder.decode(econtextStoresAction) as VoucherAction
        
        let presentationDelegateExpectation = expectation(description: "Expect presentationDelegate.present() to be called.")
        presentationDelegate.doPresent = { [self] component in
            let component = component as! PresentableComponentWrapper
            XCTAssert(component.component === sut)
            
            let view = sut.view
            
            XCTAssertNotNil(view)
            
            checkViewModel(view!.model, forAction: action)
            
            presentationDelegateExpectation.fulfill()
        }
        
        sut.handle(action)
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func checkViewModel(
        _ model: VoucherView.Model,
        forAction action: VoucherAction
    ) {
        XCTAssertEqual(model.style.mainButton, sut.configuration.style.mainButton)
        XCTAssertEqual(model.style.secondaryButton, sut.configuration.style.secondaryButton)
        XCTAssertEqual(model.style.amountLabel, sut.configuration.style.amountLabel)
        XCTAssertEqual(model.style.currencyLabel, sut.configuration.style.currencyLabel)
        XCTAssertEqual(model.style.codeConfirmationColor, sut.configuration.style.codeConfirmationColor)
        XCTAssertEqual(model.style.backgroundColor, sut.configuration.style.backgroundColor)
        
        let comps = action.anyAction.totalAmount.formattedComponents
        
        XCTAssertEqual(model.amount, comps.formattedValue)
        XCTAssertEqual(model.currency, comps.formattedCurrencySymbol)
        XCTAssertEqual(
            model.logoUrl,
            LogoURLProvider.logoURL(
                withName: action.anyAction.paymentMethodType.rawValue,
                environment: Dummy.apiContext.environment,
                size: .medium
            )
        )
        XCTAssertEqual(model.mainButtonType == .addToAppleWallet, sut.canAddPasses(action: action.anyAction))
    }
    
}
