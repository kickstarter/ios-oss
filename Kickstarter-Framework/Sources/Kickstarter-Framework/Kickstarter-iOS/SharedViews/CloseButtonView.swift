import KDS
import Library
import UIKit

/// A UIKit close button with liquid glass effect using iOS 26+ native APIs.
final class CloseButtonView: UIView {
  private let onClose: () -> Void

  private lazy var button: UIButton = {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false

    var configuration: UIButton.Configuration

    if #available(iOS 26.0, *) {
      configuration = UIButton.Configuration.glass()
    } else {
      configuration = UIButton.Configuration.plain()
    }

    if let iconImage = image(named: "icon--cross") {
      configuration.image = iconImage.withRenderingMode(.alwaysTemplate)
      configuration.imagePadding = 0
    }

    configuration.baseForegroundColor = LegacyColors.ksr_support_700.uiColor()

    configuration.contentInsets = NSDirectionalEdgeInsets(
      top: 12,
      leading: 12,
      bottom: 12,
      trailing: 12
    )

    if #available(iOS 26.0, *) {
      configuration.background.cornerRadius = 22
      configuration.background.backgroundColor = .clear
    }

    button.configuration = configuration

    if #available(iOS 26.0, *) {
      button.backgroundColor = .clear
      button.layer.shadowColor = UIColor.black.cgColor
      button.layer.shadowOffset = CGSize(width: 0, height: 1)
      button.layer.shadowRadius = 3.0
      button.layer.shadowOpacity = 0.08
      button.clipsToBounds = false
    }

    return button
  }()

  init(onClose: @escaping () -> Void) {
    self.onClose = onClose
    super.init(frame: .zero)
    self.setupView()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    if #available(iOS 26.0, *) {
      self.button.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2.0
      self.button.layer.shadowPath = UIBezierPath(
        roundedRect: self.button.bounds,
        cornerRadius: self.button.layer.cornerRadius
      ).cgPath
    } else {
      self.button.layer.cornerRadius = min(self.bounds.width, self.bounds.height) / 2.0
      self.button.layer.masksToBounds = true
    }
  }

  private func setupView() {
    self.translatesAutoresizingMaskIntoConstraints = false

    self.button.addTarget(self, action: #selector(self.buttonTapped), for: .touchUpInside)
    self.addSubview(self.button)
    NSLayoutConstraint.activate([
      self.button.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      self.button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      self.button.widthAnchor.constraint(equalToConstant: 44),
      self.button.heightAnchor.constraint(equalToConstant: 44),
      self.widthAnchor.constraint(equalToConstant: 44),
      self.heightAnchor.constraint(equalToConstant: 44)
    ])

    self.accessibilityLabel = Strings.accessibility_projects_buttons_close()
    self.accessibilityHint = Strings.Closes_project()
    self.isAccessibilityElement = true
    self.accessibilityTraits = .button
  }

  @objc private func buttonTapped() {
    self.onClose()
  }
}
