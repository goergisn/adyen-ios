//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
@_spi(AdyenInternal) @testable import AdyenActions
@testable import AdyenDropIn
import XCTest

final class PollingHandlerMock: AnyPollingHandler {
    
    var context: AdyenContext {
        Dummy.context
    }

    var delegate: ActionComponentDelegate?

    var onHandle: ((_ action: PaymentDataAware) -> Void)?

    func handle(_ action: PaymentDataAware) {
        onHandle?(action)
    }

    var onDidCancel: (() -> Void)?

    func didCancel() {
        onDidCancel?()
    }
}

struct AwaitActionHandlerProviderMock: AnyPollingHandlerProvider {

    var onAwaitHandler: ((_ paymentMethodType: AwaitPaymentMethod) -> AnyPollingHandler)?
    var onQRHandler: ((_ paymentMethodType: QRCodePaymentMethod) -> AnyPollingHandler)?

    func handler(for paymentMethodType: AwaitPaymentMethod) -> AnyPollingHandler {
        onAwaitHandler?(paymentMethodType) ?? PollingHandlerMock()
    }
    
    func handler(for qrPaymentMethodType: QRCodePaymentMethod) -> AnyPollingHandler {
        onQRHandler?(qrPaymentMethodType) ?? PollingHandlerMock()
    }
}

extension AwaitAction: Equatable {
    public static func == (lhs: AwaitAction, rhs: AwaitAction) -> Bool {
        lhs.paymentData == rhs.paymentData && lhs.paymentMethodType == rhs.paymentMethodType
    }
}

class AwaitComponentTests: XCTestCase {

    func testLocalizationWithCustomTableName() {

        let sut = AwaitComponent(context: Dummy.context)
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)
        let presentationDelegate = PresentationDelegateMock()
        sut.presentationDelegate = presentationDelegate

        let presentationExpectation = expectation(description: "expect presentation delegate to be called")
        presentationDelegate.doPresent = { component in
            let messageLabel: UILabel! = component.viewController.view.findView(by: "messageLabel")
            let spinnerLabel: UILabel! = component.viewController.view.findView(by: "spinnerTitleLabel")

            XCTAssertEqual(messageLabel.text, "Confirm your payment on the MB WAY app -- Test")
            XCTAssertEqual(spinnerLabel.text, "Waiting for confirmation -- Test")

            presentationExpectation.fulfill()
        }

        sut.handle(AwaitAction(paymentData: "data", paymentMethodType: .mbway))

        waitForExpectations(timeout: 2, handler: nil)
    }

    func testRequiresKeyboardInput() {
        let sut = AwaitViewController(viewModel: AwaitComponentViewModel(icon: "icon", message: "message", spinnerTitle: "spinner title"))

        let wrapperViewController = WrapperViewController(
            child: ModalViewController(rootViewController: sut, navBarType: .regular)
        )

        XCTAssertFalse(wrapperViewController.requiresKeyboardInput)
    }

    func testActionHandling() {
        var style = AwaitComponentStyle()
        style.backgroundColor = UIColor.green
        style.message = TextStyle(font: UIFont.systemFont(ofSize: 15), color: UIColor.red, textAlignment: .center)
        style.spinnerTitle = TextStyle(font: UIFont.systemFont(ofSize: 21), color: UIColor.blue, textAlignment: .left)

        let action = AwaitAction(paymentData: "data", paymentMethodType: .mbway)

        let handlerExpectation = expectation(description: "AwaitActionHandler.handle() must be called.")
        let handlerProvider = AwaitActionHandlerProviderMock(onAwaitHandler: { type in
            XCTAssertEqual(type, AwaitPaymentMethod.mbway)
                
            let handler = PollingHandlerMock()
            handler.onHandle = {
                XCTAssertTrue($0.paymentData == action.paymentData)
                handlerExpectation.fulfill()
            }
                
            return handler
        }, onQRHandler: nil)

        let sut = AwaitComponent(context: Dummy.context, awaitComponentBuilder: handlerProvider)
        sut.configuration.style = style
        sut.configuration.localizationParameters = LocalizationParameters(tableName: "AdyenUIHost", keySeparator: nil)

        let presentationDelegate = PresentationDelegateMock()
        let waitExpectation = expectation(description: "Wait for the presentationDelegate to be called.")
        presentationDelegate.doPresent = { [weak self] component in
            guard let self else { return }
            
            XCTAssertNotNil(component.viewController as? AwaitViewController)
            let viewController = component.viewController as! AwaitViewController
            viewController.loadViewIfNeeded()

            let view = viewController.awaitView

            XCTAssertEqual(view.messageLabel.textColor, UIColor.red)
            XCTAssertEqual(view.messageLabel.textAlignment, .center)
            XCTAssertEqual(view.messageLabel.font, UIFont.systemFont(ofSize: 15))

            XCTAssertEqual(view.spinnerTitleLabel.textColor, UIColor.blue)
            XCTAssertEqual(view.spinnerTitleLabel.textAlignment, .left)
            XCTAssertEqual(view.spinnerTitleLabel.font, UIFont.systemFont(ofSize: 21))
            XCTAssertEqual(view.activityIndicatorView.color, UIColor.blue)
            XCTAssertEqual(view.backgroundColor, .green)

            waitExpectation.fulfill()
        }

        sut.presentationDelegate = presentationDelegate

        sut.handle(action)

        waitForExpectations(timeout: 5, handler: nil)
    }

}
