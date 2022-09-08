import Library
import Prelude
import UIKit

final class PledgeShippingSummaryView: UIView {
  // MARK: - Properties

  private let amountLabel = UILabel(frame: .zero)
  private let bottomStackView = UIStackView(frame: .zero)
  private let locationLabel = UILabel(frame: .zero)
  private let rootStackView = UIStackView(frame: .zero)
  private let titleLabel = UILabel(frame: .zero)

  private let viewModel: PledgeShippingSummaryViewModelType = PledgeShippingSummaryViewModel()

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

  public func configure(with data: PledgeShippingSummaryViewData) {
    self.viewModel.inputs.configure(with: data)
  }

  // MARK: - Views

  private func configureSubviews() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.bottomStackView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()

    _ = ([self.locationLabel, UIView(), self.amountLabel], self.bottomStackView)
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
      |> \.text %~ { _ in Strings.Your_shipping_location() }

    _ = self.titleLabel
      |> checkoutBackgroundStyle

    _ = self.locationLabel
      |> \.font .~ .ksr_subhead()
      |> \.textColor .~ .ksr_support_700
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.locationLabel.rac.text = self.viewModel.outputs.locationLabelText
    self.amountLabel.rac.attributedText = self.viewModel.outputs.amountLabelAttributedText
  }
}
