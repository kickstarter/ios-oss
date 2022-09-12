import Library
import Prelude
import UIKit

final class PledgeLocalPickupView: UIView {
  // MARK: - Properties

  private let locationLabel = UILabel(frame: .zero)
  private let rootStackView = UIStackView(frame: .zero)
  private let titleLabel = UILabel(frame: .zero)

  private let viewModel: PledgeLocalPickupViewModelType = PledgeLocalPickupViewModel()

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.bindStyles()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration

  public func configure(with data: PledgeLocalPickupViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  // MARK: - Views

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, UIView(), self.locationLabel], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.gridHalf(1)

    _ = self.titleLabel
      |> checkoutTitleLabelStyle
      |> \.text %~ { _ in Strings.Reward_location() }

    _ = self.titleLabel
      |> checkoutBackgroundStyle

    _ = self.locationLabel
      |> \.font .~ .ksr_subhead()
      |> \.textColor .~ .ksr_support_400
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.locationLabel.rac.text = self.viewModel.outputs.locationLabelText
  }
}
