import UIKit

private let buttonContentInsets = NSDirectionalEdgeInsets(
  top: Styles.grid(2),
  leading: Styles.grid(2),
  bottom: Styles.grid(2),
  trailing: Styles.grid(2)
)

private let buttonWithImageContentInsets = NSDirectionalEdgeInsets(
  top: 8.5,
  leading: Styles.grid(2),
  bottom: 8.5,
  trailing: Styles.grid(2)
)

public protocol KSRButtonStyleConfiguration {
  // Button config
  var buttonConfiguration: UIButton.Configuration { get }
  // Background
  var backgroundColor: UIColor { get }
  var highlightedBackgroundColor: UIColor { get }
  var disabledBackgroundColor: UIColor { get }
  // Title
  var titleColor: UIColor { get }
  var highlightedTitleColor: UIColor { get }
  var disabledTitleColor: UIColor { get }
  var font: UIFont { get }
  // Border
  var borderWidth: CGFloat { get }
  var borderColor: UIColor { get }
  var highlightedBorderColor: UIColor { get }
  var disabledBorderColor: UIColor { get }
  var cornerRadius: CGFloat { get }
}

extension UIButton {
  public func applyStyleConfiguration(_ styleConfig: KSRButtonStyleConfiguration) {
    self.configuration = styleConfig.buttonConfiguration

    self.configuration?.contentInsets = buttonContentInsets

    self.configuration?.background.cornerRadius = styleConfig.cornerRadius

    self.configuration?.imagePadding = Styles.grid(1)
    self.configuration?.imagePlacement = .leading

    self.configuration?.titleLineBreakMode = .byTruncatingMiddle
    self.configuration?.titleAlignment = .center

    self.tintColor = styleConfig.titleColor

    self.configurationUpdateHandler = { [unowned self] _ in
      self.updateColors(with: styleConfig)
      self.updateContentInsets()
    }

    self.configuration?.titleTextAttributesTransformer =
      UIConfigurationTextAttributesTransformer { [unowned self] config in
        var newConfig = config
        newConfig.font = styleConfig.font
        newConfig.foregroundColor = self.tintColor
        return newConfig
      }

    self.configuration?.imageColorTransformer = UIConfigurationColorTransformer { [unowned self] _ in
      self.tintColor
    }
  }

  private func updateContentInsets() {
    self.configuration?.contentInsets = self.configuration?
      .image == nil ? buttonContentInsets : buttonWithImageContentInsets
  }

  private func updateColors(with styleConfig: KSRButtonStyleConfiguration) {
    switch self.state {
    case .disabled:
      self.configuration?.background.backgroundColor = styleConfig.disabledBackgroundColor
      self.tintColor = styleConfig.disabledTitleColor
      self.configuration?.background.strokeColor = styleConfig.disabledBorderColor
      self.configuration?.background.strokeWidth = styleConfig.borderWidth
    case .highlighted:
      self.configuration?.background.backgroundColor = styleConfig.highlightedBackgroundColor
      self.tintColor = styleConfig.highlightedTitleColor
      self.configuration?.background.strokeColor = styleConfig.highlightedBorderColor
      self.configuration?.background.strokeWidth = styleConfig.borderWidth
    default:
      self.configuration?.background.backgroundColor = styleConfig.backgroundColor
      self.tintColor = styleConfig.titleColor
      self.configuration?.background.strokeColor = styleConfig.borderColor
      self.configuration?.background.strokeWidth = styleConfig.borderWidth
    }
  }
}
