import KsApi
import Library
import Prelude
import UIKit

final class PledgeCTAContainerView: UIView {
  // MARK: - Properties

  private let vm: PledgeCTAContainerViewViewModelType = PledgeCTAContainerViewViewModel()

  private lazy var amountAndRewardTitleStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var amountOrRewardLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var pledgeCTAbutton: UIButton = {
    MultiLineButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var youreABackerLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.youreABackerLabel, self.amountOrRewardLabel], self.amountAndRewardTitleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.amountAndRewardTitleStackView, self.pledgeCTAbutton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    NSLayoutConstraint.activate(
      [
        self.pledgeCTAbutton.heightAnchor.constraint(
          greaterThanOrEqualToConstant: Styles.minTouchSize.height
        ),
        self.pledgeCTAbutton.trailingAnchor.constraint(equalTo: self.rootStackView.trailingAnchor)
      ]
    )

    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.pledgeCTAbutton
      |> projectStateButtonStyle

    _ = self.youreABackerLabel
      |> \.font .~ .ksr_headline(size: 14)
      |> \.text %~ { _ in Strings.Youre_a_backer() }

    _ = self.amountOrRewardLabel
      |> \.font .~ .ksr_caption1(size: 14)
      |> \.textColor .~ .ksr_dark_grey_500

    _ = self.rootStackView
      |> checkoutAdaptableStackViewStyle(
        self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
      )
      |> \.distribution .~ UIStackView.Distribution.equalCentering
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(3), leftRight: Styles.grid(3))

    _ = self.amountAndRewardTitleStackView
      |> \.axis .~ NSLayoutConstraint.Axis.vertical
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
      |> \.isLayoutMarginsRelativeArrangement .~ true
  }

  // MARK: - Binding

  override func bindViewModel() {
    super.bindViewModel()

    self.pledgeCTAbutton.rac.title = self.vm.outputs.buttonTitleText
    self.pledgeCTAbutton.rac.backgroundColor = self.vm.outputs.buttonBackgroundColor
    self.amountAndRewardTitleStackView.rac.hidden = self.vm.outputs.stackViewIsHidden
    self.amountOrRewardLabel.rac.text = self.vm.outputs.rewardTitle
  }

  // MARK: - Configuration

  func configureWith(project: Project, user: User) {
    self.vm.inputs.configureWith(project: project, user: user)
  }
}

// MARK: - Styles

private let projectStateButtonStyle: ButtonStyle = { (button: UIButton) in
  button
    |> roundedStyle(cornerRadius: 12)
    |> UIButton.lens.titleColor(for: .normal) .~ .white
    |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 15)
    |> UIButton.lens.layer.borderWidth .~ 0
    |> UIButton.lens.titleEdgeInsets .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
    |> (UIButton.lens.titleLabel .. UILabel.lens.lineBreakMode) .~ .byWordWrapping
}
