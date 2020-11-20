import KsApi
import Library
import Prelude
import UIKit

final class EmailVerificationViewController: UIViewController, MessageBannerViewControllerPresenting {
  // MARK: - Properties

  private lazy var activityIndicatorView: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(frame: .zero)
    view.startAnimating()
    return view
  }()

  private lazy var contentVStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var contentHStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var imageView: UIImageView = { UIImageView(frame: .zero) }()
  private lazy var footerLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var footerStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var messageLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var resendButton: UIButton = { UIButton(type: .custom) }()
  private lazy var rootScrollView: UIScrollView = { UIScrollView(frame: .zero) }()
  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var skipButton: UIButton = { UIButton(type: .custom) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  private let viewModel: EmailVerificationViewModelType = EmailVerificationViewModel()
  internal var messageBannerViewController: MessageBannerViewController?

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.messageBannerViewController = self.configureMessageBannerViewController(on: self)

    self.configureSubviews()
    self.setupConstraints()

    self.resendButton.addTarget(self, action: #selector(self.resendButtonTapped), for: .touchUpInside)
    self.skipButton.addTarget(self, action: #selector(self.skipButtonTapped), for: .touchUpInside)

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> \.backgroundColor .~ .white

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.contentHStackView
      |> contentHStackViewStyle

    _ = self.contentVStackView
      |> contentVStackViewStyle

    _ = self.footerStackView
      |> footerStackViewStyle(self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory)

    _ = self.imageView
      |> UIImageView.lens.image .~ Library.image(named: "email-icon-light")

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.messageLabel
      |> messageLabelStyle

    _ = self.skipButton
      |> skipButtonStyle

    _ = self.footerLabel
      |> footerLabelStyle

    _ = self.resendButton
      |> resendButtonStyle
  }

  // MARK: - Views

  private func configureSubviews() {
    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.contentHStackView, self.activityIndicatorView, self.footerStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.contentVStackView], self.contentHStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.imageView, self.titleLabel, self.messageLabel, self.skipButton], self.contentVStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.footerLabel, self.resendButton], self.footerStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.contentVStackView.setCustomSpacing(Styles.grid(5), after: self.imageView)
  }

  // MARK: - Constraints

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalTo: self.rootScrollView.widthAnchor),
      self.rootStackView.heightAnchor.constraint(greaterThanOrEqualTo: self.rootScrollView.heightAnchor)
    ])
  }

  // MARK: - View model

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.activityIndicatorIsHidden
      .observeForUI()
      .observeValues { [weak self] hidden in
        // set alpha instead of isHidden to avoid stackview bouncing when this is shown.
        self?.activityIndicatorView.alpha = hidden ? 0 : 1
      }

    self.footerStackView.rac.hidden = self.viewModel.outputs.footerStackViewIsHidden

    self.viewModel.outputs.notifyDelegateDidComplete
      .observeForUI()
      .observeValues { [weak self] in
        guard let _ = self else { return }

        // notify delegate
      }

    self.viewModel.outputs.showSuccessBannerWithMessage
      .observeForUI()
      .observeValues { [weak self] message in
        self?.messageBannerViewController?.showBanner(with: .success, message: message)
      }

    self.viewModel.outputs.showErrorBannerWithMessage
      .observeForUI()
      .observeValues { [weak self] error in
        self?.messageBannerViewController?.showBanner(with: .error, message: error)
      }
  }

  // MARK: - Actions

  @objc func resendButtonTapped() {
    self.viewModel.inputs.resendButtonTapped()
  }

  @objc func skipButtonTapped() {
    self.viewModel.inputs.skipButtonTapped()
  }
}

// MARK: - Styles

private let skipButtonStyle: ButtonStyle = { (button: UIButton) in
  button
    |> UIButton.lens.titleLabel.textAlignment .~ .center
    |> UIButton.lens.titleLabel.font .~ UIFont.ksr_subhead().bolded
    |> UIButton.lens.titleColor(for: .normal) .~ .ksr_green_500
    |> UIButton.lens.title(for: .normal) %~ { _ in
      localizedString(
        key: "Ill_do_this_later",
        defaultValue: "I'll do this later"
      )
    }
}

private let resendButtonStyle: ButtonStyle = { (button: UIButton) in
  button
    |> UIButton.lens.titleLabel.font .~ .ksr_footnote()
    |> UIButton.lens.titleColor(for: .normal) .~ .ksr_green_500
    |> UIButton.lens.title(for: .normal) %~ { _ in
      localizedString(
        key: "Resend_email",
        defaultValue: "Resend email"
      )
    }
}

private let contentHStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.axis .~ .horizontal
    |> \.alignment .~ .center
}

private let contentVStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.spacing .~ Styles.grid(3)
    |> \.axis .~ .vertical
    |> \.alignment .~ .center
}

private let footerLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textAlignment .~ .center
    |> \.font .~ .ksr_footnote()
    |> \.textColor .~ .ksr_soft_black
    |> \.text %~ { _ in
      localizedString(
        key: "Cant_find_it",
        defaultValue: "Can't find it?"
      )
    }
    |> \.numberOfLines .~ 0
}

private func footerStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  return { (stackView: UIStackView) in
    stackView
      |> \.axis .~ (isAccessibilityCategory ? .vertical : .horizontal)
  }
}

private let messageLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textAlignment .~ .center
    |> \.font .~ .ksr_callout()
    |> \.textColor .~ .ksr_soft_black
    |> \.text %~ { _ in
      localizedString(
        key: "Check_your_inbox_to_complete_this_simple_step",
        defaultValue: "Check your inbox to complete this simple step."
      )
    }
    |> \.numberOfLines .~ 0
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.layoutMargins .~ .init(topBottom: Styles.grid(2), leftRight: Styles.grid(5))
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.axis .~ .vertical
    |> \.alignment .~ .center
    |> \.spacing .~ Styles.grid(3)
}

private let titleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.textAlignment .~ .center
    |> \.font .~ UIFont.ksr_title3().bolded
    |> \.textColor .~ .ksr_soft_black
    |> \.text %~ { _ in
      localizedString(
        key: "Verify_your_email_address",
        defaultValue: "Verify your email address"
      )
    }
    |> \.numberOfLines .~ 0
}
