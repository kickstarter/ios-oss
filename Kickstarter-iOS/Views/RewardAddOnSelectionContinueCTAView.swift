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

  private(set) lazy var continueButton: UIButton = {
    UIButton(type: .custom)
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
      |> \.backgroundColor .~ UIColor.white.cgColor
      |> \.shadowColor .~ UIColor.black.cgColor
      |> \.shadowOpacity .~ 0.12
      |> \.shadowOffset .~ CGSize(width: 0, height: -1.0)
      |> \.shadowRadius .~ CGFloat(1.0)
      |> \.maskedCorners .~ [
        CACornerMask.layerMaxXMinYCorner,
        CACornerMask.layerMinXMinYCorner
      ]
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

    self.continueButton.rac.title = self.viewModel.outputs.buttonTitle

    self.viewModel.outputs.buttonStyle
      .observeForUI()
      .observeValues { [weak self] buttonStyleType in
        _ = self?.continueButton
          ?|> buttonStyleType.style

        guard let buttonFont = self?.continueButton.titleLabel?.font else { return }

        _ = self?.continueButton
          ?|> UIButton.lens.titleLabel.font .~ buttonFont.monospaced
      }
  }

  // MARK: - Configuration

  func configure(with data: RewardAddOnSelectionContinueCTAViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  // MARK: Functions

  private func configureSubviews() {
    _ = (self.continueButton, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.Button.minHeight)
    ])
  }
}
