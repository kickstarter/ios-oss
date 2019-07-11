import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Button {
    static let height: CGFloat = 48.0
    static let width: CGFloat = 98.0
  }
}

final class PledgeCTAContainerView: UIView {
  // MARK: - Properties

  private let vm: PledgeCTAContainerViewViewModelType = PledgeCTAContainerViewViewModel()

  private lazy var titleAndSubtitleStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var subtitleLabel: UILabel = { UILabel(frame: .zero) }()
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

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.subtitleLabel], self.titleAndSubtitleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleAndSubtitleStackView, self.spacer, self.pledgeCTAButton], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    NSLayoutConstraint.activate([
      self.pledgeCTAButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.height),
      self.pledgeCTAButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.width),
      self.rootStackView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor)
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

    _ = self.titleAndSubtitleStackView
      |> \.axis .~ NSLayoutConstraint.Axis.vertical
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.spacing .~ 0

    _ = self.pledgeCTAButton
      |> pledgeCTAButtonStyle(
        isAccessibilityCategory,
        amountAndRewardTitleStackViewIsHidden: self.titleAndSubtitleStackView.isHidden
      )

    _ = self.rootStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(3), leftRight: Styles.grid(3))
      |> \.alignment .~ .center

    _ = self.titleLabel
      |> \.font .~ UIFont.ksr_callout().bolded
      |> \.numberOfLines .~ 0

    _ = self.subtitleLabel
      |> \.font .~ UIFont.ksr_caption1().bolded
      |> \.textColor .~ UIColor.ksr_dark_grey_500
      |> \.numberOfLines .~ 0
  }

  // MARK: - Binding

  override func bindViewModel() {
    super.bindViewModel()

    self.vm.outputs.buttonTitleTextColor
      .observeForUI()
      .observeValues { [weak self] textColor in
        self?.pledgeCTAButton.setTitleColor(textColor, for: .normal)
      }

    self.titleAndSubtitleStackView.rac.hidden = self.vm.outputs.stackViewIsHidden
    self.titleLabel.rac.text = self.vm.outputs.titleText
    self.subtitleLabel.rac.text = self.vm.outputs.subtitleText
    self.pledgeCTAButton.rac.backgroundColor = self.vm.outputs.buttonBackgroundColor
    self.pledgeCTAButton.rac.title = self.vm.outputs.buttonTitleText
    self.spacer.rac.hidden = self.vm.outputs.spacerIsHidden
  }

  // MARK: - Configuration

  func configureWith(project: Project) {
    self.vm.inputs.configureWith(project: project)
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
      |> UIButton.lens.titleLabel.font .~ UIFont.ksr_headline(size: 15)
      |> UIButton.lens.layer.borderWidth .~ 0
      |> (UIButton.lens.titleLabel .. UILabel.lens.textAlignment) .~ NSTextAlignment.center
      |> (UIButton.lens.titleLabel .. UILabel.lens.lineBreakMode) .~ lineBreakMode
  }
}
