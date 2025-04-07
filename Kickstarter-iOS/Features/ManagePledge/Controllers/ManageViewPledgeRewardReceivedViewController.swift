import KsApi
import Library
import Prelude
import UIKit

final class ManageViewPledgeRewardReceivedViewController: UIViewController {
  // MARK: - Properties

  private let viewModel: ManageViewPledgeRewardReceivedViewModelType
    = ManageViewPledgeRewardReceivedViewModel()

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var rewardReceivedInfoStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var labelStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var deliveryLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var shippingLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var toggleViewController: ToggleViewController = {
    ToggleViewController(nibName: nil, bundle: nil)
  }()

  private lazy var pledgeDisclaimerView: PledgeDisclaimerView = {
    PledgeDisclaimerView(frame: .zero)
  }()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    self.toggleViewController.toggle.addTarget(
      self,
      action: #selector(ManageViewPledgeRewardReceivedViewController.toggleValueDidChange(_:)),
      for: .valueChanged
    )

    self.configureViews()
    self.configureDisclaimerView()

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Views

  private func configureViews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.deliveryLabel, self.shippingLabel], self.labelStackView)
      |> ksr_addArrangedSubviewsToStackView()

    self.rewardReceivedInfoStackView.addArrangedSubviews(self.labelStackView, self.toggleViewController.view)

    self.rootStackView.addArrangedSubviews(self.rewardReceivedInfoStackView, self.pledgeDisclaimerView)
  }

  // MARK: - Actions

  @objc private func toggleValueDidChange(_ toggle: UISwitch) {
    self.viewModel.inputs.rewardReceivedToggleTapped(isOn: toggle.isOn)
  }

  // MARK: - Configuration

  public func configureWith(data: ManageViewPledgeRewardReceivedViewData) {
    self.viewModel.inputs.configureWith(data)
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.rewardReceivedInfoStackView
      |> \.layer.borderColor .~ UIColor.ksr_support_300.cgColor

    _ = self.rootStackView
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(3)
      |> \.insetsLayoutMarginsFromSafeArea .~ false

    _ = self.rewardReceivedInfoStackView
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(1)
      |> \.insetsLayoutMarginsFromSafeArea .~ false

    self.labelStackView.isLayoutMarginsRelativeArrangement = true
    self.labelStackView.axis = .vertical
    self.labelStackView.spacing = Styles.grid(2)
    self.labelStackView.insetsLayoutMarginsFromSafeArea = false

    _ = self.toggleViewController.titleLabel
      |> checkoutTitleLabelStyle
      |> \.font .~ UIFont.ksr_subhead()
      |> \.textColor .~ .ksr_support_700
      |> \.text %~ { _ in Strings.Reward_received() }

    _ = self.toggleViewController.toggle
      |> checkoutSwitchControlStyle
      |> \.accessibilityLabel %~ { _ in Strings.Reward_received() }

    applyDisclaimerStyle(self.pledgeDisclaimerView)
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.deliveryLabel.rac.attributedText = self.viewModel.outputs.estimatedDeliveryDateLabelAttributedText
    self.shippingLabel.rac.attributedText = self.viewModel.outputs.estimatedShippingAttributedText
    self.shippingLabel.rac.hidden = self.viewModel.outputs.estimatedShippingHidden
    self.toggleViewController.toggle.rac.on = self.viewModel.outputs.rewardReceived
    self.toggleViewController.view.rac.hidden = self.viewModel.outputs.rewardReceivedHidden
    self.pledgeDisclaimerView.rac.hidden = self.viewModel.outputs.pledgeDisclaimerViewHidden

    self.viewModel.outputs.marginWidth
      .observeForUI()
      .observeValues { [weak self] borderWidth in
        self?.rewardReceivedInfoStackView.layer.borderWidth = borderWidth
      }

    self.viewModel.outputs.layoutMargins
      .observeForUI()
      .observeValues { [weak self] layoutMargins in
        self?.rewardReceivedInfoStackView.layoutMargins = layoutMargins
      }

    self.viewModel.outputs.cornerRadius
      .observeForUI()
      .observeValues { [weak self] radius in
        guard let self = self else { return }
        _ = self.rewardReceivedInfoStackView
          |> roundedStyle(cornerRadius: radius)
      }
  }

  // MARK: - Helpers

  private func configureDisclaimerView() {
    let string1 = Strings.Remember_that_delivery_dates_are_not_guaranteed()
    let string2 = Strings.Delays_or_changes_are_possible()

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 2

    let attributedText = string1
      .appending(String.nbsp)
      .appending(string2)
      .attributed(
        with: UIFont.ksr_footnote(),
        foregroundColor: .ksr_support_400,
        attributes: [.paragraphStyle: paragraphStyle],
        bolding: [string1]
      )

    self.pledgeDisclaimerView.configure(with: ("calendar-icon", attributedText))
  }
}

// MARK: - Styles

private func applyDisclaimerStyle(_ view: UIView) {
  view.clipsToBounds = true
  view.layer.masksToBounds = true
  view.layer.cornerRadius = Styles.grid(2)
}
