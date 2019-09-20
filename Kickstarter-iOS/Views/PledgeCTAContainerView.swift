import KsApi
import Library
import Prelude
import UIKit

protocol PledgeCTAContainerViewDelegate: AnyObject {
  func pledgeCTAButtonTapped(with state: PledgeStateCTAType)
}

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
    let indicator = UIActivityIndicatorView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
    indicator.startAnimating()
    return indicator
  }()

  private lazy var activityIndicatorContainerView: UIView = {
    UIView(frame: .zero)
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

  weak var delegate: PledgeCTAContainerViewDelegate?

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

    _ = self.titleAndSubtitleStackView
      |> titleAndSubtitleStackViewStyle

    _ = self.rootStackView
      |> adaptableStackViewStyle(isAccessibilityCategory)

    _ = self.titleLabel
      |> titleLabelStyle

    _ = self.subtitleLabel
      |> subtitleLabelStyle

    _ = self.activityIndicator
      |> activityIndicatorStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.notifyDelegateCTATapped
      .observeForUI()
      .observeValues { [weak self] state in
        self?.delegate?.pledgeCTAButtonTapped(with: state)
      }

    self.viewModel.outputs.buttonStyleType
      .observeForUI()
      .observeValues { [weak self] buttonStyleType in
        _ = self?.pledgeCTAButton
          ?|> buttonStyleType.style
      }

    self.viewModel.outputs.pledgeCTAButtonIsHidden
      .observeForUI()
      .observeValues { [weak self] isHidden in
        self?.animateView(self?.pledgeCTAButton, isHidden: isHidden)
      }

    self.activityIndicatorContainerView.rac.hidden = self.viewModel.outputs.activityIndicatorIsHidden
    self.pledgeCTAButton.rac.hidden = self.viewModel.outputs.pledgeCTAButtonIsHidden
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

    _ = (self.activityIndicator, self.activityIndicatorContainerView)
      |> ksr_addSubviewToParent()

    _ = ([self.titleLabel, self.subtitleLabel], self.titleAndSubtitleStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = (
      [
        self.titleAndSubtitleStackView,
        self.spacer,
        self.pledgeCTAButton,
        self.pledgeRetryButton,
        self.activityIndicatorContainerView
      ],
      self.rootStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    self.pledgeCTAButton.addTarget(
      self, action: #selector(self.pledgeCTAButtonTapped), for: .touchUpInside
    )
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.activityIndicator.centerXAnchor.constraint(equalTo: self.layoutMarginsGuide.centerXAnchor),
      self.activityIndicator.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor),
      self.activityIndicatorContainerView.heightAnchor.constraint(equalToConstant: Layout.Button.minHeight),
      self.pledgeCTAButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight),
      self.pledgeCTAButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minWidth),
      self.pledgeRetryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight)
    ])
  }

  fileprivate func animateView(_ view: UIView?, isHidden: Bool) {
    let duration = isHidden ? 0.0 : 0.18
    let alpha: CGFloat = isHidden ? 0.0 : 1.0
    UIView.animate(withDuration: duration, animations: {
      _ = view
        ?|> \.alpha .~ alpha
    })
  }

  @objc func pledgeCTAButtonTapped() {
    self.viewModel.inputs.pledgeCTAButtonTapped()
  }
}

// MARK: - Styles

private let activityIndicatorStyle: ActivityIndicatorStyle = { activityIndicator in
  activityIndicator
    |> \.color .~ UIColor.ksr_dark_grey_500
    |> \.hidesWhenStopped .~ true
}

private func adaptableStackViewStyle(_ isAccessibilityCategory: Bool) -> (StackViewStyle) {
  return { (stackView: UIStackView) in
    let spacing: CGFloat = (isAccessibilityCategory ? Styles.grid(1) : 0)

    return stackView
      |> \.alignment .~ .center
      |> \.axis .~ NSLayoutConstraint.Axis.horizontal
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.layoutMargins .~ UIEdgeInsets.init(topBottom: Styles.grid(3), leftRight: Styles.grid(3))
      |> \.spacing .~ spacing
  }
}

private let subtitleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_caption1().bolded
    |> \.textColor .~ UIColor.ksr_dark_grey_500
    |> \.numberOfLines .~ 0
}

private let titleAndSubtitleStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.spacing .~ Styles.gridHalf(1)
}

private let titleLabelStyle: LabelStyle = { label in
  label
    |> \.font .~ UIFont.ksr_callout().bolded
    |> \.numberOfLines .~ 0
}

private let pledgeRetryButtonStyle: ButtonStyle = { button in
  button
    |> baseButtonStyle
    |> UIButton.lens.titleColor(for: .normal) .~ .ksr_text_black
    |> UIButton.lens.titleLabel.font .~ .ksr_caption1()
    |> UIButton.lens.backgroundColor(for: .normal) .~ .clear
    |> UIButton.lens.titleEdgeInsets .~ .init(top: 0, left: Styles.grid(3), bottom: 0, right: 0)
    |> UIButton.lens.titleColor(for: .highlighted) .~ UIColor.ksr_text_black.mixLighter(0.36)
    |> UIButton.lens.contentEdgeInsets .~ UIEdgeInsets(topBottom: Styles.gridHalf(1))
    |> UIButton.lens.image(for: .normal) %~ { _ in image(named: "icon--refresh-small") }
    |> UIButton.lens.image(for: .highlighted) %~ { _ in image(named: "icon--refresh-small", alpha: 0.66) }
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Content_isnt_loading_right_now() }
}
