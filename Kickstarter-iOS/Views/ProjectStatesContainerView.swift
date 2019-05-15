import Library
import Prelude
import UIKit

class ProjectStatesContainerView: UIView {
  // MARK: - Properties

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var labelStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var backerLabel: UILabel = { UILabel(frame: .zero) }()
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

    NSLayoutConstraint.activate([self.button.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)])

    _ = ([self.backerLabel, self.label], self.labelStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.labelStackView, self.button], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  func configure(value: ProjectStateCTAType, rewardTitle: String) {

    _ = self.button
      |> projectStateButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        return value.buttonTitle }
      |> UIButton.lens.backgroundColor(for: .normal) %~ { _ in
            value.buttonBackgroundColor }

    _ = self.backerLabel
      |> \.text %~ { _ in "You're a backer"}

    _ = self.label
      |> \.text %~ { _ in rewardTitle }
      |> \.font .~ .ksr_caption1(size: 14)
      |> \.textColor .~ .ksr_dark_grey_500

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.labelStackView
      |> \.axis .~ NSLayoutConstraint.Axis.vertical
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.isHidden .~ value.stackViewIsHidden
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private let projectStateButtonStyle: ButtonStyle = { (button: UIButton) in
  button
      |> roundedStyle(cornerRadius: 12)
      |> UIButton.lens.titleColor(for: .normal) .~ .white
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
      |> UIButton.lens.layer.borderWidth .~ 0
      |> UIButton.lens.titleEdgeInsets .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
}

private let rootStackViewStyle: StackViewStyle = { (stackView: UIStackView) in
  stackView
    |> \.alignment .~ UIStackView.Alignment.center
    |> \.distribution .~ UIStackView.Distribution.equalCentering
    |> \.axis .~ NSLayoutConstraint.Axis.horizontal
    |> \.translatesAutoresizingMaskIntoConstraints .~ false
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(3), leftRight: Styles.grid(3))
//    |> \.spacing .~ Styles.grid(2)
}
