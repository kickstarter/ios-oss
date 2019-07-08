import KsApi
import Library
import Prelude
import UIKit

final class PledgeCTAContainerView: UIView {
  // MARK: - Properties

  private let vm: PledgeCTAContainerViewViewModelType = PledgeCTAContainerViewViewModel()

  private lazy var amountAndRewardTitleStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var amountOrRewardLabel: UILabel = { UILabel(frame: .zero) }()
  private(set) lazy var pledgeCTAButton: UIButton = {
    MultiLineButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var spacer: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var youreABackerLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.youreABackerLabel, self.amountOrRewardLabel], self.amountAndRewardTitleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.amountAndRewardTitleStackView, self.spacer, self.pledgeCTAButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    NSLayoutConstraint.activate([
      self.pledgeCTAButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
    ])

    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory

    _ = self.amountAndRewardTitleStackView
      |> \.axis .~ NSLayoutConstraint.Axis.vertical
      |> \.isLayoutMarginsRelativeArrangement .~ true

    _ = self.amountOrRewardLabel
      |> \.font .~ UIFont.ksr_caption1(size: 14)
      |> \.textColor .~ UIColor.ksr_dark_grey_500
      |> \.numberOfLines .~ 0

    _ = self.pledgeCTAButton
      |> pledgeCTAButtonStyle(
        isAccessibilityCategory,
        amountAndRewardTitleStackViewIsHidden: self.amountAndRewardTitleStackView.isHidden
      )

    _ = self.rootStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(3), leftRight: Styles.grid(3))

    _ = self.youreABackerLabel
      |> \.font .~ UIFont.ksr_headline(size: 14)
      |> \.text %~ { _ in Strings.Youre_a_backer() }
      |> \.numberOfLines .~ 0
  }

  // MARK: - Binding

  override func bindViewModel() {
    super.bindViewModel()

    self.amountAndRewardTitleStackView.rac.hidden = self.vm.outputs.stackViewIsHidden
    self.amountOrRewardLabel.rac.text = self.vm.outputs.rewardTitle
    self.pledgeCTAButton.rac.backgroundColor = self.vm.outputs.buttonBackgroundColor
    self.pledgeCTAButton.rac.title = self.vm.outputs.buttonTitleText
    self.spacer.rac.hidden = self.vm.outputs.spacerIsHidden
  }

  // MARK: - Configuration

  func configureWith(project: Project, user: User) {
    self.vm.inputs.configureWith(project: project, user: user)
  }
}

// MARK: - Styles

private func adaptableStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  return { (stackView: UIStackView) in
    let axis: NSLayoutConstraint.Axis = (isAccessibilityCategory ? .vertical : .horizontal)
    let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : 0)

    return stackView
      |> \.axis .~ axis
      |> \.spacing .~ spacing
  }
}

private func pledgeCTAButtonStyle(
  _ isAccessibilityCategory: Bool, amountAndRewardTitleStackViewIsHidden: Bool
) -> (ButtonStyle) {
  return { (button: UIButton) in
    let lineBreakMode: NSLineBreakMode = isAccessibilityCategory || amountAndRewardTitleStackViewIsHidden
      ? NSLineBreakMode.byWordWrapping : NSLineBreakMode.byTruncatingTail

    return button
      |> roundedStyle(cornerRadius: 12)
      |> UIButton.lens.titleColor(for: .normal) .~ UIColor.white
      |> UIButton.lens.titleLabel.font .~ UIFont.ksr_headline(size: 15)
      |> UIButton.lens.layer.borderWidth .~ 0
      |> UIButton.lens.titleEdgeInsets .~ .init(topBottom: Styles.grid(1), leftRight: Styles.grid(2))
      |> (UIButton.lens.titleLabel .. UILabel.lens.textAlignment) .~ NSTextAlignment.center
      |> (UIButton.lens.titleLabel .. UILabel.lens.lineBreakMode) .~ lineBreakMode
  }
}
