//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

extension FormCardNumberItemView {
    
    /// Custom view housing up to 2 sub views for brand logos.
    internal class DualBrandView: UIView {
        
        private enum Constant {
            static let iconSize = CGSize(width: 24, height: 16)
            static let placeholderImage = UIImage(named: "ic_card_front", in: .cardInternalResources, compatibleWith: nil)
        }
        
        private let style: ImageStyle
        internal let childItemViews: [any AnyFormItemView] = []
        
        /// Closure that's called when a selection is made between the brands
        private let onBrandSelection: (Int) -> Void
        
        private lazy var stackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [primaryLogoView, secondaryLogoView])
            stackView.axis = .horizontal
            stackView.spacing = 4
            return stackView
        }()
        
        /// First view to display the current brand or the placeholder image.
        internal private(set) lazy var primaryLogoView: UIImageView = createEmptyImageView()
        
        /// View to display the second brand for dual-branded cards. Hidden otherwise.
        internal private(set) lazy var secondaryLogoView: UIImageView = {
            let imageView = createEmptyImageView()
            imageView.isHidden = true
            return imageView
        }()
        
        private lazy var primaryGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(primaryLogoTapped))
        
        private lazy var secondaryGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(secondaryLogoTapped))
        
        private let selectedViewAlpha: CGFloat = 1
        
        private let unselectedViewAlpha: CGFloat = 0.3
        
        private var primaryLogoUrl: URL?
        private var secondaryLogoUrl: URL?
        private let imageLoader: ImageLoading
        private var imageLoadingTasks = [AdyenCancellable]()
        
        internal init(
            style: ImageStyle,
            imageLoader: ImageLoading = ImageLoaderProvider.imageLoader(),
            onBrandSelection: @escaping ((Int) -> Void)
        ) {
            self.style = style
            self.onBrandSelection = onBrandSelection
            self.imageLoader = imageLoader
            
            super.init(frame: .zero)
            addSubview(stackView)
            stackView.adyen.anchor(inside: self)
            setPlaceholderView()
        }
        
        @available(*, unavailable)
        internal required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setPlaceholderView() {
            primaryLogoView.image = Constant.placeholderImage
        }
        
        internal func updateCurrentLogos(_ logos: [FormCardLogosItem.CardTypeLogo]) {
            resetLogos()
            guard !logos.isEmpty else {
                setPlaceholderView()
                return
            }
            setupLogoViews(from: logos)
        }
        
        private func setupLogoViews(from logos: [FormCardLogosItem.CardTypeLogo]) {
            guard let firstLogo = logos.first else { return }
            let secondLogo = logos.adyen[safeIndex: 1]
            
            primaryLogoUrl = firstLogo.url
            secondaryLogoUrl = secondLogo?.url
            
            primaryLogoView.alpha = selectedViewAlpha
            primaryLogoView.accessibilityValue = firstLogo.type.name
            primaryLogoView.isAccessibilityElement = true
            
            // dual branded. allow selection but initially neither is selected
            if let secondLogo {
                primaryLogoView.alpha = unselectedViewAlpha
                
                secondaryLogoView.alpha = unselectedViewAlpha
                secondaryLogoView.accessibilityValue = secondLogo.type.name
                secondaryLogoView.isHidden = false
                
                primaryLogoView.addGestureRecognizer(primaryGestureRecognizer)
                secondaryLogoView.addGestureRecognizer(secondaryGestureRecognizer)
            }
            
            secondaryLogoView.isAccessibilityElement = !secondaryLogoView.isHidden
            
            updateAccessibilityValues()
            
            updateLogos()
        }
        
        @objc private func primaryLogoTapped() {
            guard primaryLogoView.alpha != selectedViewAlpha else { return }
            primaryLogoView.alpha = selectedViewAlpha
            secondaryLogoView.alpha = unselectedViewAlpha
            onBrandSelection(0)
            updateAccessibilityValues()
        }
        
        @objc private func secondaryLogoTapped() {
            guard secondaryLogoView.alpha != selectedViewAlpha else { return }
            secondaryLogoView.alpha = selectedViewAlpha
            primaryLogoView.alpha = unselectedViewAlpha
            onBrandSelection(1)
            updateAccessibilityValues()
        }
        
        private func resetLogos() {
            primaryLogoUrl = nil
            secondaryLogoUrl = nil

            primaryLogoView.image = Constant.placeholderImage
            primaryLogoView.alpha = selectedViewAlpha
            primaryLogoView.removeGestureRecognizer(primaryGestureRecognizer)
            secondaryLogoView.image = Constant.placeholderImage
            secondaryLogoView.isHidden = true
            secondaryLogoView.alpha = unselectedViewAlpha
            secondaryLogoView.removeGestureRecognizer(secondaryGestureRecognizer)
        }
        
        private func createEmptyImageView() -> UIImageView {
            let imageView = UIImageView()
            imageView.image = Constant.placeholderImage
            imageView.adyen.round(using: style.cornerRounding)
            imageView.layer.masksToBounds = style.clipsToBounds
            imageView.layer.borderWidth = style.borderWidth
            imageView.layer.borderColor = style.borderColor?.cgColor
            imageView.backgroundColor = style.backgroundColor
            imageView.isUserInteractionEnabled = true
            imageView.widthAnchor.constraint(equalToConstant: Constant.iconSize.width).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: Constant.iconSize.height).isActive = true
            return imageView
        }
        
        private func updateAccessibilityValues() {
            if secondaryLogoView.isHidden {
                primaryLogoView.accessibilityTraits = .image
                return
            }
            
            primaryLogoView.accessibilityTraits = .button
            secondaryLogoView.accessibilityTraits = .button
            
            primaryLogoView.accessibilityMarkAsSelected(primaryLogoView.alpha == selectedViewAlpha)
            secondaryLogoView.accessibilityMarkAsSelected(secondaryLogoView.alpha == selectedViewAlpha)
        }
        
        override public func didMoveToWindow() {
            super.didMoveToWindow()
            updateLogos()
        }
        
        private func updateLogos() {
            imageLoadingTasks.forEach { $0.cancel() }
            
            guard let primaryLogoUrl else { return }
            
            var imageLoadingTasks = [primaryLogoView.load(
                url: primaryLogoUrl,
                using: imageLoader,
                placeholder: Constant.placeholderImage
            )]
            
            if let secondaryLogoUrl {
                imageLoadingTasks.append(
                    secondaryLogoView.load(
                        url: secondaryLogoUrl,
                        using: imageLoader,
                        placeholder: Constant.placeholderImage
                    )
                )
            }
            
            self.imageLoadingTasks = imageLoadingTasks
        }
    }
}
