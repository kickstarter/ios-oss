import Library
import Prelude
import UIKit

public final class RestrictedCreatorViewController: UIViewController {
  // MARK: Properties

  private let titleLabel = UILabel()

  // Shows the details of why the creator is restricted. The text is passed in.
  private let descriptionLabel = UILabel() // UITextField()

  // OK button. When tapped, dismisses the entire view controller.
  private let okButton = UIButton()

  // The creator accountability button is a UILabel instead of a UIButton as a workaround
  // since Apple's UIButton doesn't support multiple lines of text.
  private let creatorAccountabilityButton = UILabel()

  // Content scroll view. Required to display entire message for large font sizes.
  private let scrollView = UIScrollView()

  // Stack view containing everything in the view.
  private let contentStackView = UIStackView()

  // MARK: Configuration

  public static func configuredWith(
    message: String
  ) -> RestrictedCreatorViewController {
    let vc = RestrictedCreatorViewController.instantiate()
    vc.descriptionLabel.text = message

    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.configureViews()
    self.bindStyles()
    self.setupConstraints()

    self.okButton.addTarget(
      self, action: #selector(self.okButtonTapped),
      for: .touchUpInside
    )

    self.creatorAccountabilityButton.isUserInteractionEnabled = true
    let creatorAccountabilityGesture = UITapGestureRecognizer(
      target: self,
      action: #selector(self.creatorAccountabilityButtonTapped)
    )
    self.creatorAccountabilityButton.addGestureRecognizer(creatorAccountabilityGesture)
  }

  private func configureViews() {
    self.view.addSubview(self.scrollView)
    self.scrollView.addSubview(self.contentStackView)
    self.contentStackView.addArrangedSubviews(
      self.titleLabel,
      self.descriptionLabel,
      self.creatorAccountabilityButton,
      self.okButton
    )
  }

  public override func bindStyles() {
    super.bindStyles()

    self.view.backgroundColor = UIColor.ksr_white
    self.view.insetsLayoutMarginsFromSafeArea = true
    self.view.layoutMargins = UIEdgeInsets(top: Styles.grid(4))

    self.titleLabel.text = Strings.project_project_notices_header()
    self.titleLabel.numberOfLines = 0
    self.titleLabel.font = .ksr_title3().bolded
    self.titleLabel.accessibilityTraits.insert(.header)

    self.descriptionLabel.numberOfLines = 0
    self.descriptionLabel.font = .ksr_callout()

    self.okButton.setTitle(Strings.general_alert_buttons_ok(), for: .normal)
    _ = self.okButton
      |> blackButtonStyle

    self.creatorAccountabilityButton.attributedText = self.attributedCreatorAccountabilityButtonTitle()
    self.creatorAccountabilityButton.numberOfLines = 0
    self.creatorAccountabilityButton.accessibilityTraits.insert(.button)

    self.scrollView.translatesAutoresizingMaskIntoConstraints = false
    self.scrollView.insetsLayoutMarginsFromSafeArea = true
    self.scrollView.layoutMargins = UIEdgeInsets(topBottom: 0, leftRight: Styles.grid(4))
    self.scrollView.contentInset = UIEdgeInsets(
      top: Styles.grid(2),
      left: 0,
      bottom: Styles.grid(4),
      right: 0
    )

    self.contentStackView.translatesAutoresizingMaskIntoConstraints = false
    self.contentStackView.axis = .vertical
    self.contentStackView.spacing = Styles.grid(3)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.scrollView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
      self.scrollView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
      self.scrollView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
      self.scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

      self.contentStackView.leadingAnchor
        .constraint(equalTo: self.scrollView.layoutMarginsGuide.leadingAnchor),
      self.contentStackView.trailingAnchor
        .constraint(equalTo: self.scrollView.layoutMarginsGuide.trailingAnchor),
      self.contentStackView.widthAnchor.constraint(equalTo: self.scrollView.layoutMarginsGuide.widthAnchor),
      self.contentStackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
      self.contentStackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor)
    ])
  }

  private func attributedCreatorAccountabilityButtonTitle() -> NSAttributedString {
    let attributes: String.Attributes = [
      .font: UIFont.ksr_callout(),
      .underlineStyle: NSUnderlineStyle.single.rawValue
    ]

    return NSMutableAttributedString(
      string: Strings.project_project_notices_notice_sheet_cta(),
      attributes: attributes
    )
  }

  // MARK: - Selectors

  @objc private func creatorAccountabilityButtonTapped() {
    self.presentHelpWebViewController(with: .trust, presentationStyle: .formSheet)
  }

  @objc private func okButtonTapped() {
    self.navigationController?.dismiss(animated: true)
  }
}
