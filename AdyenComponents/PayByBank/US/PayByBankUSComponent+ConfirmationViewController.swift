//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
@_spi(AdyenInternal) import Adyen

extension PayByBankUSComponent {
    
    internal class ConfirmationViewController: UIViewController {
        
        private enum Constants {
            static let topPadding: CGFloat = 16
            static let bottomPadding: CGFloat = 8
            static let subtitleLabelSpacing: CGFloat = 10
            static let supportedBankLogosSpacing: CGFloat = 26
        }
        
        private let model: Model
        
        internal lazy var headerImageView: UIImageView = {
            UIImageView()
        }()
        
        internal let supportedBankLogosView: SupportedPaymentMethodLogosView
        
        internal lazy var titleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            return titleLabel
        }()
        
        internal lazy var subtitleLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            return titleLabel
        }()
        
        internal lazy var messageLabel: UILabel = {
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            return titleLabel
        }()
        
        internal lazy var submitButton: SubmitButton = {
            let buttonStyle = ButtonStyle(
                title: TextStyle(font: .preferredFont(forTextStyle: .headline), color: .white),
                cornerRounding: .fixed(8),
                background: UIColor.Adyen.defaultBlue
            )
            
            return SubmitButton(style: buttonStyle)
        }()
        
        public init(model: Model) {
            self.model = model
            
            supportedBankLogosView = SupportedPaymentMethodLogosView(
                imageUrls: model.supportedBankLogoURLs,
                trailingText: model.supportedBanksMoreText
            )
            
            super.init(nibName: nil, bundle: nil)
        }
        
        override public func viewDidLoad() {
            super.viewDidLoad()
            
            headerImageView.adyen.apply(model.style.headerImage)
            
            titleLabel.text = model.title
            titleLabel.adyen.apply(model.style.title)
            
            subtitleLabel.text = model.subtitle
            subtitleLabel.adyen.apply(model.style.subtitle)
            
            messageLabel.text = model.message
            messageLabel.adyen.apply(model.style.message)
            
            submitButton.title = model.submitTitle
            submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
            
            let contentStack = UIStackView(arrangedSubviews: [
                headerImageView,
                titleLabel,
                supportedBankLogosView,
                subtitleLabel,
                messageLabel
            ])
            contentStack.spacing = 0
            contentStack.axis = .vertical
            contentStack.alignment = .center
            contentStack.setCustomSpacing(Constants.subtitleLabelSpacing, after: subtitleLabel)
            contentStack.setCustomSpacing(Constants.supportedBankLogosSpacing, after: supportedBankLogosView)
            
            let contentButtonStack = UIStackView(arrangedSubviews: [
                contentStack,
                submitButton
            ])
            contentButtonStack.spacing = 32
            contentButtonStack.axis = .vertical
            contentButtonStack.alignment = .fill
            
            view.addSubview(contentButtonStack)
            contentButtonStack.adyen.anchor(
                inside: view.layoutMarginsGuide,
                with: .init(
                    top: Constants.topPadding,
                    left: 0,
                    bottom: Constants.bottomPadding,
                    right: 0
                )
            )
            
            model.loadHeaderImage(for: headerImageView)
            
            configureConstraints()
        }
        
        @available(*, unavailable)
        public required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func submitTapped() {
            submitButton.showsActivityIndicator = true
            model.continueHandler()
        }
        
        override public var preferredContentSize: CGSize {
            get {
                view.adyen.minimalSize
            }

            // swiftlint:disable:next unused_setter_value
            set { AdyenAssertion.assertionFailure(message: """
            PreferredContentSize is overridden for this view controller.
            getter - returns minimum possible content size.
            setter - no implemented.
            """) }
        }
        
        private func configureConstraints() {
            
            let constraints = [
                headerImageView.widthAnchor.constraint(equalToConstant: model.headerImageViewSize.width),
                headerImageView.heightAnchor.constraint(equalToConstant: model.headerImageViewSize.height)
            ]

            headerImageView.setContentHuggingPriority(.required, for: .horizontal)
            
            NSLayoutConstraint.activate(constraints)
        }
        
        override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            super.traitCollectionDidChange(previousTraitCollection)
            headerImageView.layer.borderColor = model.style.headerImage.borderColor?.cgColor ?? UIColor.Adyen.componentSeparator.cgColor
        }
    }
}

// MARK: - Model

extension PayByBankUSComponent.ConfirmationViewController {
    
    internal class Model {
        
        internal let headerImageUrl: URL
        internal let supportedBankLogoURLs: [URL]
        internal let supportedBanksMoreText: String
        internal let title: String
        internal let subtitle: String
        internal let message: String
        internal let submitTitle: String
        
        internal let style: PayByBankUSComponent.Style
        internal let headerImageViewSize = CGSize(width: 80, height: 52)
        
        internal let continueHandler: () -> Void
        
        private let imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()
        private var imageLoadingTask: AdyenCancellable? {
            willSet { imageLoadingTask?.cancel() }
        }
        
        internal init(
            title: String,
            headerImageUrl: URL,
            supportedBankLogoNames: [String],
            style: PayByBankUSComponent.Style,
            localizationParameters: LocalizationParameters?,
            logoUrlProvider: LogoURLProvider,
            continueHandler: @escaping () -> Void
        ) {
            self.headerImageUrl = headerImageUrl
            self.supportedBankLogoURLs = supportedBankLogoNames.map { logoUrlProvider.logoURL(withName: $0) }
            self.supportedBanksMoreText = localizedString(.payByBankAISDDMore, localizationParameters)
            self.title = title
            self.subtitle = localizedString(.payByBankAISDDDisclaimerHeader, localizationParameters)
            self.message = localizedString(.payByBankAISDDDisclaimerBody, localizationParameters)
            self.submitTitle = localizedString(.payByBankAISDDSubmit, localizationParameters)
            self.style = style
            self.continueHandler = continueHandler
        }
        
        internal func loadHeaderImage(for imageView: UIImageView) {
            imageLoadingTask = imageView.load(url: headerImageUrl, using: imageLoader)
        }
    }
}
