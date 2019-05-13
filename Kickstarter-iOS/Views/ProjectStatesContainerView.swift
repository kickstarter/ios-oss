import Library
import Prelude
import UIKit

class ProjectStatesContainerView: UIView {
  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var label: UILabel = { UILabel(frame: .zero) }()
  private lazy var button: UIButton = {
     return MultiLineButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  // MARK: - Lifecycle
  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

//    let margins = self.layoutMarginsGuide
//    let minHeight = Styles.minTouchSize.height
//
//    let buttonConstraints = [
//      self.button.leftAnchor.constraint(equalTo: margins.leftAnchor),
//      self.button.rightAnchor.constraint(equalTo: margins.rightAnchor),
//      self.button.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
//      self.button.topAnchor.constraint(equalTo: margins.topAnchor),
//      self.button.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
//    ]

    _ = ([self.label, self.button], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

//     NSLayoutConstraint.activate(buttonConstraints)
  }

  func configure(value: ProjectStateCTAType) {

    _ = self.button
      |> projectStateButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        return value.buttonTitle }
      |> UIButton.lens.backgroundColor(for: .normal) %~ { _ in
            value.buttonBackgroundColor }

    _ = self.label
      |> \.text %~ { _ in "This shows up" }
      |> \.isHidden .~ value.labelIsHidden

    _ = self.rootStackView
      |> rootStackViewStyle
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override  func bindStyles() {
    super.bindStyles()


  }
}

private let projectStateButtonStyle: ButtonStyle = { (button: UIButton) in button
      |> roundedStyle(cornerRadius: 12)
      |> UIButton.lens.titleColor(for: .normal) .~ .white
      |> UIButton.lens.layer.borderWidth .~ 0
      |> UIButton.lens.titleEdgeInsets .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.top
    |> \.axis .~ NSLayoutConstraint.Axis.horizontal
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(5), leftRight: Styles.grid(4))
    |> \.spacing .~ Styles.grid(3)
}
