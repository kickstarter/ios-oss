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
    var buttonConfiguration = styleConfig.buttonConfiguration

    buttonConfiguration.contentInsets = buttonContentInsets

    buttonConfiguration.background.cornerRadius = styleConfig.cornerRadius

    buttonConfiguration.imagePadding = Styles.grid(1)
    buttonConfiguration.imagePlacement = .leading

    buttonConfiguration.titleLineBreakMode = .byTruncatingMiddle
    buttonConfiguration.titleAlignment = .center

    self.tintColor = styleConfig.titleColor

    self.configurationUpdateHandler = { [weak self] _ in
      guard let self = self else { return }

      self.updateColors(with: styleConfig)
      self.updateContentInsets()
    }

    buttonConfiguration.titleTextAttributesTransformer =
      UIConfigurationTextAttributesTransformer { [weak self] config in
        guard let self = self else { return config }

        var newConfig = config
        newConfig.font = styleConfig.font
        newConfig.foregroundColor = self.tintColor
        return newConfig
      }

    buttonConfiguration.imageColorTransformer = UIConfigurationColorTransformer { [weak self] _ in
      self?.tintColor ?? .white
    }

    self.configuration = buttonConfiguration
  }

  private func updateContentInsets() {
    guard var buttonConfiguration = self.configuration else { return }

    buttonConfiguration.contentInsets = buttonConfiguration
      .image == nil ? buttonContentInsets : buttonWithImageContentInsets
  }

  private func updateColors(with styleConfig: KSRButtonStyleConfiguration) {
    guard var buttonConfiguration = self.configuration else { return }

    switch self.state {
    case .disabled:
      buttonConfiguration.background.backgroundColor = styleConfig.disabledBackgroundColor
      self.tintColor = styleConfig.disabledTitleColor
      buttonConfiguration.background.strokeColor = styleConfig.disabledBorderColor
      buttonConfiguration.background.strokeWidth = styleConfig.borderWidth
    case .highlighted:
      buttonConfiguration.background.backgroundColor = styleConfig.highlightedBackgroundColor
      self.tintColor = styleConfig.highlightedTitleColor
      buttonConfiguration.background.strokeColor = styleConfig.highlightedBorderColor
      buttonConfiguration.background.strokeWidth = styleConfig.borderWidth
    default:
      buttonConfiguration.background.backgroundColor = styleConfig.backgroundColor
      self.tintColor = styleConfig.titleColor
      buttonConfiguration.background.strokeColor = styleConfig.borderColor
      buttonConfiguration.background.strokeWidth = styleConfig.borderWidth
    }

    self.configuration = buttonConfiguration
  }
}
