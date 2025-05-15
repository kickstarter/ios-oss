import Library
import UIKit

final class AlertBanner: UIView {
  // MARK: - Properties

  public var button = UIButton(configuration: .plain())
  private let title = UILabel()
  private let subtitle = UILabel()
  private var buttonAction: (() -> Void)? = nil

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureViews()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)

    self.configureViews()
  }

  private func configureViews() {
    self.backgroundColor = Colors.Background.Danger.subtle.uiColor()
    self.layer.cornerRadius = Styles.cornerRadius
    self.layer.masksToBounds = true
    self.translatesAutoresizingMaskIntoConstraints = false

    let leadingEdgeBar = UIView()
    leadingEdgeBar.backgroundColor = Colors.Text.Accent.Red.bolder.uiColor()
    leadingEdgeBar.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(leadingEdgeBar)

    let icon = UIImageView()
    icon.image = Library.image(named: "icon--alert")
    icon.tintColor = Colors.Icon.danger.uiColor()
    icon.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(icon)

    self.title.numberOfLines = 0
    self.title.font = UIFont.ksr_body(size: 15).weighted(.medium)
    self.title.accessibilityTraits.insert(.header)

    self.subtitle.numberOfLines = 0
    self.subtitle.font = UIFont.ksr_body(size: 15)

    // Bordered button; can be moved to a shared class once the new design system is ready for it.
    self.button.setBackgroundColor(LegacyColors.ksr_support_300.uiColor(), for: .highlighted)
    self.button.layer.borderColor = LegacyColors.ksr_support_300.uiColor().cgColor
    self.button.layer.borderWidth = 1
    self.button.layer.cornerRadius = Styles.cornerRadius
    self.button.configurationUpdateHandler = { button in
      switch button.state {
      case .highlighted, .selected:
        button.configuration?.background.backgroundColor = LegacyColors.ksr_support_300.uiColor()
      default:
        button.configuration?.background.backgroundColor = .clear
      }
    }
    self.button.addTarget(
      self,
      action: #selector(self.buttonTapped),
      for: .touchUpInside
    )

    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.spacing = Styles.grid(2)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.addArrangedSubviews(self.title, self.subtitle, self.button)
    self.addSubview(stackView)

    let padding = Styles.grid(3)
    NSLayoutConstraint.activate([
      leadingEdgeBar.widthAnchor.constraint(equalToConstant: Styles.cornerRadius),
      leadingEdgeBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      leadingEdgeBar.topAnchor.constraint(equalTo: self.topAnchor),
      leadingEdgeBar.bottomAnchor.constraint(equalTo: self.bottomAnchor),

      icon.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
      icon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: padding),
      icon.widthAnchor.constraint(equalToConstant: padding),
      icon.heightAnchor.constraint(equalToConstant: padding),

      stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: padding),
      stackView.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: Styles.grid(1)),
      stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -padding),
      stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -padding)
    ])
  }

  // MARK: - Data configuration

  public func configureWith(
    title: String,
    subtitle: String,
    buttonTitle: String,
    buttonAction: @escaping () -> Void
  ) {
    self.buttonAction = buttonAction

    self.title.text = title
    self.subtitle.text = subtitle

    let attributedButtonTitle = AttributedString(
      buttonTitle,
      attributes: AttributeContainer([
        NSAttributedString.Key.font: UIFont.ksr_body(size: 16).weighted(.medium),
        NSAttributedString.Key.foregroundColor: LegacyColors.ksr_black.uiColor()
      ])
    )
    self.button.configuration?.attributedTitle = attributedButtonTitle
  }

  // MARK: - Selectors

  @objc fileprivate func buttonTapped() {
    self.buttonAction?()
  }
}
