import Library
import Prelude
import UIKit

class ToggleViewController: UIViewController {
  // MARK: - Properties

  public lazy var titleLabel: UILabel = {
    UILabel(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  public lazy var toggle: UISwitch = {
    UISwitch(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.titleLabel
      |> ksr_setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    _ = (self.titleLabel, self.view)
      |> ksr_addSubviewToParent()

    _ = (self.toggle, self.view)
      |> ksr_addSubviewToParent()

    NSLayoutConstraint.activate([
      self.titleLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.titleLabel.topAnchor.constraint(equalTo: self.view.topAnchor),
      self.titleLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      self.titleLabel.centerYAnchor.constraint(equalTo: self.toggle.centerYAnchor),
      self.titleLabel.rightAnchor.constraint(lessThanOrEqualTo: self.toggle.leftAnchor),
      self.toggle.rightAnchor.constraint(equalTo: self.view.rightAnchor)
    ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.toggle
      |> baseSwitchControlStyle
  }
}

// MARK: - Styles

private let titleLabelStyle: LabelStyle = { (label: UILabel) in
  label
    |> \.adjustsFontForContentSizeCategory .~ true
    |> \.font .~ UIFont.ksr_body()
    |> \.numberOfLines .~ 0
}
