import KsApi
import Library
import Prelude
import UIKit

private enum Layout {
  enum Button {
    static let minHeight: CGFloat = 48.0
  }
}

final class RewardAddOnSelectionContinueCTAView: UIView {
  // MARK: - Properties

  private(set) lazy var continueButton: LoadingButton = {
    LoadingButton(type: .custom)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var pledgeAmount: UILabel = { UILabel(frame: .zero) }()

  private lazy var pledgeHeading: UILabel = { UILabel(frame: .zero) }()

  private lazy var pledgeAmountStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private let viewModel: RewardAddOnSelectionContinueCTAViewModelType
    = RewardAddOnSelectionContinueCTAViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
    self.bindViewModel()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self
      |> \.layoutMargins .~ .init(all: Styles.grid(3))

    _ = self.layer
      |> checkoutLayerCardRoundedStyle
      |> \.backgroundColor .~ LegacyColors.ksr_white.uiColor().cgColor
      |> \.shadowColor .~ LegacyColors.ksr_black.uiColor().cgColor
      |> \.shadowOpacity .~ 0.12
      |> \.shadowOffset .~ CGSize(width: 0, height: -1.0)
      |> \.shadowRadius .~ CGFloat(1.0)
      |> \.maskedCorners .~ [
        CACornerMask.layerMaxXMinYCorner,
        CACornerMask.layerMinXMinYCorner
      ]

    PledgeViewStyles.rootPledgeCTAStackViewStyle(self.rootStackView)
    self.rootStackView.layoutMargins = UIEdgeInsets.zero
    PledgeViewStyles.pledgeAmountStackViewStyle(self.pledgeAmountStackView)
    PledgeViewStyles.pledgeAmountValueStyle(self.pledgeAmount)
    PledgeViewStyles.pledgeAmountHeadingStyle(self.pledgeHeading)
    self.pledgeHeading.text = Strings.Pledge_amount()

    _ = self.continueButton
      |> greenButtonStyle

    guard let buttonFont = self.continueButton.titleLabel?.font else { return }

    _ = self.continueButton
      |> UIButton.lens.titleLabel.font .~ buttonFont.monospaced
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.continueButton.rac.enabled = self.viewModel.outputs.buttonEnabled
    self.pledgeAmountStackView.rac.hidden = self.viewModel.outputs.pledgeAmountHidden

    self.viewModel.outputs.buttonTitle
      .observeForUI()
      .observeValues { [weak self] text in
        guard let self = self else { return }

        /// Required to work around a quirk with titles in `LoadingButton`.
        [UIControl.State.normal, .highlighted, .disabled, .selected]
          .map { state in (text, state) }
          .forEach(self.continueButton.setTitle)
      }

    self.viewModel.outputs.isLoading
      .observeForUI()
      .observeValues { [weak self] isLoading in
        self?.continueButton.isLoading = isLoading
      }

    self.viewModel.outputs.pledgeAmountText
      .observeForUI()
      .observeValues { [weak self] text in
        self?.pledgeAmount.attributedText = text
      }
  }

  // MARK: - Configuration

  func configure(with data: RewardAddOnSelectionContinueCTAViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    self.rootStackView.addArrangedSubview(self.pledgeAmountStackView)
    self.rootStackView.addArrangedSubview(self.continueButton)

    self.pledgeAmountStackView.addArrangedSubview(self.pledgeHeading)
    self.pledgeAmountStackView.addArrangedSubview(self.pledgeAmount)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight)
    ])
  }
}
