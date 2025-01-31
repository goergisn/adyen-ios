//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class FormPickerItemTests: XCTestCase {
    
    override func run() {
        AdyenDependencyValues.runTestWithValues {
            $0.imageLoader = ImageLoaderMock()
        } perform: {
            super.run()
        }
    }
    
    func testPresentation() throws {
        
        let presentViewControllerExpectation = expectation(description: "presenter.presentViewController was called")
        let dismissViewControllerExpectation = expectation(description: "presenter.dismissViewController was called")
        
        var presentedViewController: FormPickerSearchViewController<FormPickerElement>?
        
        let mockPresenter = PresenterMock { viewController, animated in
            presentedViewController = viewController as? FormPickerSearchViewController<FormPickerElement>
            presentViewControllerExpectation.fulfill()
        } dismiss: { animated in
            dismissViewControllerExpectation.fulfill()
        }
        
        let formPickerItem = FormPickerItem(
            preselectedValue: nil,
            selectableValues: [FormPickerElement(identifier: "Identifier", title: "Title", subtitle: "Subtitle")],
            title: "",
            placeholder: "",
            style: .init(),
            presenter: mockPresenter
        )
        
        // Setting up formPickerItem
        _ = FormPickerItemView(item: formPickerItem)
        
        formPickerItem.selectionHandler()
        
        wait(for: [presentViewControllerExpectation], timeout: 10)
        
        setupRootViewController(presentedViewController!)
        
        let searchViewController = presentedViewController!.viewControllers.first as! SearchViewController
        searchViewController.viewModel.interfaceState.results?.first?.selectionHandler?()
        
        wait(for: [dismissViewControllerExpectation], timeout: 10)
    }
    
    func testAssertions() throws {
        
        let formPickerItem = FormPickerItem<FormPickerElement>(
            preselectedValue: nil,
            selectableValues: [],
            title: "",
            placeholder: "",
            style: .init(),
            presenter: nil
        )
        
        // Test resetValue()
        
        let resetValueException = expectation(description: "resetValue() should throw an exception")
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "'resetValue()' needs to be implemented on 'FormPickerItem<FormPickerElement>'")
            resetValueException.fulfill()
        }
        
        formPickerItem.resetValue()
        
        wait(for: [resetValueException], timeout: 10)
        
        // Test updateValidationFailureMessage()
        
        let updateValidationFailureMessageException = expectation(description: "updateValidationFailureMessage() should throw an exception")
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "'updateValidationFailureMessage()' needs to be implemented on 'FormPickerItem<FormPickerElement>'")
            updateValidationFailureMessageException.fulfill()
        }
        
        formPickerItem.updateValidationFailureMessage()
        
        wait(for: [updateValidationFailureMessageException], timeout: 10)
        
        // Test updateFormattedValue()
        
        let updateFormattedValueException = expectation(description: "updateFormattedValue() should throw an exception")
        
        AdyenAssertion.listener = { assertion in
            XCTAssertEqual(assertion, "'updateFormattedValue()' needs to be implemented on 'FormPickerItem<FormPickerElement>'")
            updateFormattedValueException.fulfill()
        }
        
        formPickerItem.updateFormattedValue()
        
        wait(for: [updateFormattedValueException], timeout: 10)
        
        AdyenAssertion.listener = nil
    }
}
