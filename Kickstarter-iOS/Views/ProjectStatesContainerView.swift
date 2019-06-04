import Library
import KsApi
import Prelude
import UIKit

class ProjectStatesContainerView: UIView {
  fileprivate let vm: ProjectStatesContainerViewViewModelType = ProjectStatesContainerViewViewModel()
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

    NSLayoutConstraint.activate(
      [self.button.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)]
    )

    _ = ([self.backerLabel, self.label], self.labelStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.labelStackView, self.button], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.button.rac.title = self.vm.outputs.buttonTitleText
    self.button.rac.backgroundColor = self.vm.outputs.buttonBackgroundColor
    self.labelStackView.rac.hidden = self.vm.outputs.stackViewIsHidden
    self.label.rac.text = self.vm.outputs.rewardTitle
  }

  func configureWith(project: Project, user: User) {
    _ = self.button
      |> projectStateButtonStyle

    _ = self.backerLabel
      |> \.font .~ .ksr_headline(size: 14)
      |> \.text %~ { _ in Strings.Youre_a_backer() }

    _ = self.label
      |> \.font .~ .ksr_caption1(size: 14)
      |> \.textColor .~ .ksr_dark_grey_500

    _ = self.rootStackView
      |> rootStackViewStyle

    _ = self.labelStackView
      |> \.axis .~ NSLayoutConstraint.Axis.vertical
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.isLayoutMarginsRelativeArrangement .~ true

    self.vm.inputs.configureWith(project: project, user: user)
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
}
