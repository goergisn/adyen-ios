//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen
@testable @_spi(AdyenInternal) import AdyenCard

final class DualBrandViewTests: XCTestCase {
    var sut: FormCardNumberItemView.DualBrandView!
    private var imageLoader: MockImageLoader!
    var brandSelectionCount: Int!
    
    override func setUp() {
        super.setUp()
        
        brandSelectionCount = 0
        imageLoader = MockImageLoader()
        sut = FormCardNumberItemView.DualBrandView(
            style: brandImageStyle,
            imageLoader: imageLoader
        ) { _ in
            self.brandSelectionCount += 1
        }
    }
    
    override func tearDown() {
        sut = nil
        imageLoader = nil
        brandSelectionCount = nil
        super.tearDown()
    }
    
    func testUpdateCurrentLogos_WhenResettingLoadedImages_ShouldResetToPlaceholder() {
        // Given: Set up dual brand state with loaded images
        let placeholderImage = UIImage(named: "ic_card_front", in: .cardInternalResources, compatibleWith: nil)
        let visaImage = UIImage()
        let bcmcImage = UIImage()
            
        let dualBrandLogos = [
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://example.com/visa.png")!, type: .visa),
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://example.com/bcmc.png")!, type: .bcmc)
        ]
            
        imageLoader.mockImages = [
            dualBrandLogos[0].url: visaImage,
            dualBrandLogos[1].url: bcmcImage
        ]
            
        // Load initial dual brand state
        sut.updateCurrentLogos(dualBrandLogos)
            
        // Simulate image loading completion
        imageLoader.completeLoading()
            
        // Verify initial state
        XCTAssertEqual(sut.primaryLogoView.image, visaImage, "Primary logo should show visa image")
        XCTAssertEqual(sut.secondaryLogoView.image, bcmcImage, "Secondary logo should show bcmc image")
        XCTAssertFalse(sut.secondaryLogoView.isHidden, "Secondary logo should be visible")
        XCTAssertEqual(sut.primaryLogoView.alpha, 0.3, accuracy: 0.001, "Primary logo is not selected")
        XCTAssertEqual(sut.secondaryLogoView.alpha, 0.3, accuracy: 0.001, "Secondary logo is not selected")

        // When: Update with empty logos array
        sut.updateCurrentLogos([])
            
        // Then
        XCTAssertEqual(sut.primaryLogoView.image, placeholderImage, "Primary logo should show placeholder")
        XCTAssertEqual(sut.primaryLogoView.alpha, 1.0, "Primary logo should have full opacity")
        XCTAssertTrue(sut.secondaryLogoView.isHidden, "Secondary logo should be hidden")
        XCTAssertEqual(imageLoader.loadedURLs.count, 2, "Should have loaded exactly 2 images before reset")

        XCTAssertFalse(sut.primaryLogoView.gestureRecognizers?.isEmpty == false, "Primary logo should not have gesture recognizers")
        XCTAssertFalse(sut.secondaryLogoView.gestureRecognizers?.isEmpty == false, "Secondary logo should not have gesture recognizers")

        // Verify no new image loading attempts after reset
        let previousLoadedUrlsCount = imageLoader.loadedURLs.count
        sut.didMoveToWindow() // Trigger potential image loading
        XCTAssertEqual(imageLoader.loadedURLs.count, previousLoadedUrlsCount, "No new images should be loaded after reset")

        simulateTapOnPrimaryLogo()
        simulateTapOnSecondaryLogo()
        XCTAssertEqual(brandSelectionCount, 0, "Brand selection should not be possible after reset")
    }

    func testUpdateCurrentLogos_changingFromDualToSingle_resetsAndShowsSingleBrand() {
        // Given: Set up dual brand state
        let dualBrandLogos = [
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://example.com/visa.png")!, type: .visa),
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://example.com/bcmc.png")!, type: .bcmc)
        ]
        sut.updateCurrentLogos(dualBrandLogos)
        
        // When: Update with single brand
        let singleBrandLogo = [
            FormCardLogosItem.CardTypeLogo(url: URL(string: "https://example.com/amex.png")!, type: .americanExpress)
        ]
        sut.updateCurrentLogos(singleBrandLogo)
        
        // Then
        XCTAssertTrue(sut.secondaryLogoView.isHidden, "Secondary logo should be hidden")
        XCTAssertEqual(sut.primaryLogoView.alpha, 1.0, "Primary logo should have full opacity")
        XCTAssertFalse(sut.primaryLogoView.gestureRecognizers?.isEmpty == false, "Primary logo should not have gesture recognizers")
        
        // Verify brand selection is not possible
        simulateTapOnPrimaryLogo()
        XCTAssertEqual(brandSelectionCount, 0, "Brand selection should not be possible with single brand")
    }
    
    // MARK: - Helper Methods
    
    private func simulateTapOnPrimaryLogo() {
        if let gestureRecognizer = sut.primaryLogoView.gestureRecognizers?.first {
            gestureRecognizer.state = .recognized
        }
    }
    
    private func simulateTapOnSecondaryLogo() {
        if let gestureRecognizer = sut.secondaryLogoView.gestureRecognizers?.first {
            gestureRecognizer.state = .recognized
        }
    }
    
    private var brandImageStyle: ImageStyle = .init(
        borderColor: nil,
        borderWidth: 0.0,
        cornerRadius: 0.0,
        clipsToBounds: true,
        contentMode: .scaleAspectFit
    )

}

private class MockImageLoader: ImageLoading {
    var loadedURLs: [URL] = []
    var mockImages: [URL: UIImage] = [:]
    private var completions: [(UIImage?) -> Void] = []
    
    func load(
        url: URL,
        completion: @escaping ((UIImage?) -> Void)
    ) -> AdyenCancellable {
        loadedURLs.append(url)
        completions.append(completion)
        return MockCancellable()
    }

    func completeLoading() {
        for (index, completion) in completions.enumerated() {
            if index < loadedURLs.count,
               let image = mockImages[loadedURLs[index]] {
                completion(image)
            }
        }
        completions.removeAll()
    }
}

private struct MockCancellable: AdyenCancellable {
    func cancel() {}
}
