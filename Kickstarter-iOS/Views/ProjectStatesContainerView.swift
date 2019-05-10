import Library
import Prelude
import UIKit

class ProjectStatesContainerView: UIView {
  // MARK: - Properties

  private lazy var label: UILabel = { UILabel(frame: .zero) }()
  private lazy var button: UIButton = {
     return MultiLineButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle
  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = (self.button, self)
      |> ksr_addSubviewToParent()

    let margins = self.layoutMarginsGuide
    let minHeight = Styles.minTouchSize.height

    let buttonConstraints = [
      self.button.leftAnchor.constraint(equalTo: margins.leftAnchor),
      self.button.rightAnchor.constraint(equalTo: margins.rightAnchor),
      self.button.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
      self.button.topAnchor.constraint(equalTo: margins.topAnchor),
      self.button.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
    ]

     NSLayoutConstraint.activate(buttonConstraints)
  }

  func configure(value: ProjectStateCTAType) {

    _ = self.button
      |> checkoutGreenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        return value.buttonTitle
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override  func bindStyles() {
    super.bindStyles()

    _ = self.button
      |> checkoutGreenButtonStyle

    _ = self.button.titleLabel
      ?|> checkoutGreenButtonTitleLabelStyle
  }
}
