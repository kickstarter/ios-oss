import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Button {
    static let minHeight: CGFloat = 48.0
    static let minWidth: CGFloat = 98.0
  }

  enum ActivityIndicator {
    static let height: CGFloat = 30
  }
}

final class PledgeCTAContainerView: UIView {
  // MARK: - Properties

  private lazy var activityIndicator: UIActivityIndicatorView = {
    UIActivityIndicatorView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private(set) lazy var pledgeCTAButton: UIButton = {
    UIButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private(set) lazy var pledgeRetryButton: UIButton = {
    UIButton(type: .custom)
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

  private lazy var subtitleLabel: UILabel = { UILabel(frame: .zero) }()

  private lazy var titleAndSubtitleStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  
  private let viewModel: PledgeCTAContainerViewViewModelType = PledgeCTAContainerViewViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    let isAccessibilityCategory = self.traitCollection.preferredContentSizeCategory.isAccessibilityCategory

    _ = self.pledgeRetryButton
      |> pledgeRetryButtonStyle
      |> \.isHidden .~ true

    _ = self.titleAndSubtitleStackView
      |> \.axis .~ NSLayoutConstraint.Axis.vertical
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.spacing .~ Styles.gridHalf(1)

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

    _ = self.activityIndicator
      |> \.color .~ UIColor.ksr_dark_grey_500
      |> \.hidesWhenStopped .~ true
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.buttonTitleTextColor
      .observeForUI()
      .observeValues { [weak self] textColor in
        self?.pledgeCTAButton.setTitleColor(textColor, for: .normal)
      }

    self.viewModel.outputs.rootStackViewAnimateIsHidden
      .observeValues { [weak self] isHidden in
        let duration = isHidden ? 0.0 : 0.18
        let alpha: CGFloat = isHidden ? 0.0 : 1.0
        UIView.animate(withDuration: duration, animations: {
          _ = self?.rootStackView
            ?|> \.alpha .~ alpha
        })
      }

    self.activityIndicator.rac.animating = self.viewModel.outputs.activityIndicatorIsAnimating
    self.pledgeCTAButton.rac.hidden = self.viewModel.outputs.pledgeCTAButtonIsHidden
    self.pledgeCTAButton.rac.backgroundColor = self.viewModel.outputs.buttonBackgroundColor
    self.pledgeCTAButton.rac.title = self.viewModel.outputs.buttonTitleText
    self.pledgeRetryButton.rac.hidden = self.viewModel.outputs.pledgeRetryButtonIsHidden
    self.spacer.rac.hidden = self.viewModel.outputs.spacerIsHidden
    self.subtitleLabel.rac.text = self.viewModel.outputs.subtitleText
    self.titleAndSubtitleStackView.rac.hidden = self.viewModel.outputs.stackViewIsHidden
    self.titleLabel.rac.text = self.viewModel.outputs.titleText
  }

  // MARK: - Configuration

  func configureWith(value: (projectOrError: Either<Project, ErrorEnvelope>, isLoading: Bool)) {
    self.viewModel.inputs.configureWith(value: value)
  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.activityIndicator, self)
      |> ksr_addSubviewToParent()

    _ = ([self.titleLabel, self.subtitleLabel], self.titleAndSubtitleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.titleAndSubtitleStackView, self.spacer, self.pledgeCTAButton, self.pledgeRetryButton],
         self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.activityIndicator.heightAnchor.constraint(equalToConstant: Layout.ActivityIndicator.height),
      self.activityIndicator.widthAnchor.constraint(equalTo: self.activityIndicator.heightAnchor),
      self.activityIndicator.centerXAnchor.constraint(equalTo: self.layoutMarginsGuide.centerXAnchor),
      self.activityIndicator.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor),
      self.pledgeCTAButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight),
      self.pledgeCTAButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minWidth),
      self.pledgeRetryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight),
      self.pledgeRetryButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minWidth),
      self.rootStackView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor)
    ])
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

private let pledgeRetryButtonStyle: ButtonStyle = { button in
  button
    |> baseButtonStyle
    |> UIButton.lens.titleColor(for: .normal) .~ .ksr_soft_black
    |> UIButton.lens.titleLabel.font .~ .ksr_caption1()
    |> UIButton.lens.backgroundColor(for: .normal) .~ .clear
    |> UIButton.lens.titleColor(for: .highlighted) .~ .init(white: 1.0, alpha: 0.5)
    |> UIButton.lens.backgroundColor(for: .highlighted) .~ .init(white: 1.0, alpha: 0.5)
    |> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: 18.0)
    |> UIButton.lens.contentEdgeInsets %~~ { _, button in
      button.traitCollection.verticalSizeClass == .compact
        ? .init(topBottom: 10.0, leftRight: 12.0)
        : .init(topBottom: 12.0, leftRight: 16.0)
    }
    |> UIButton.lens.image(for: .normal) %~ { _ in image(named: "icon--refresh-small") }
    |> UIButton.lens.title(for: .normal) %~ { _ in
      return localizedString(
        key: "Content_isnt_loading_right_now",
        defaultValue: """
          Content isn't loading right now.
        """,
        count: nil,
        substitutions: [:]
      )
  }
}
