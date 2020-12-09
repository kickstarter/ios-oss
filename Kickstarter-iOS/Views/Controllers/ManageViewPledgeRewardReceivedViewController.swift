import KsApi
import Library
import Prelude
import UIKit

final class ManageViewPledgeRewardReceivedViewController: UIViewController {
  // MARK: - Properties

  private let viewModel: ManageViewPledgeRewardReceivedViewModelType
    = ManageViewPledgeRewardReceivedViewModel()

  private lazy var rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private lazy var titleLabel: UILabel = { UILabel(frame: .zero) }()
  private lazy var toggleViewController: ToggleViewController = {
    ToggleViewController(nibName: nil, bundle: nil)
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

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Views

  private func configureViews() {
    _ = (self.rootStackView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.titleLabel, self.toggleViewController.view], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
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

    _ = self.view
      |> \.layer.borderColor .~ UIColor.ksr_support_300.cgColor

    _ = self.rootStackView
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.axis .~ .vertical
      |> \.spacing .~ Styles.grid(1)
      |> \.insetsLayoutMarginsFromSafeArea .~ false

    _ = self.toggleViewController.titleLabel
      |> checkoutTitleLabelStyle
      |> \.font .~ UIFont.ksr_subhead()
      |> \.textColor .~ .ksr_support_700
      |> \.text %~ { _ in Strings.Reward_received() }

    _ = self.toggleViewController.toggle
      |> checkoutSwitchControlStyle
      |> \.accessibilityLabel %~ { _ in Strings.Reward_received() }
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.titleLabel.rac.attributedText = self.viewModel.outputs.estimatedDeliveryDateLabelAttributedText
    self.toggleViewController.toggle.rac.on = self.viewModel.outputs.rewardReceived
    self.toggleViewController.view.rac.hidden = self.viewModel.outputs.rewardReceivedHidden

    self.viewModel.outputs.marginWidth
      .observeForUI()
      .observeValues { [weak self] borderWidth in
        self?.view.layer.borderWidth = borderWidth
      }

    self.viewModel.outputs.layoutMargins
      .observeForUI()
      .observeValues { [weak self] layoutMargins in
        self?.rootStackView.layoutMargins = layoutMargins
      }

    self.viewModel.outputs.cornerRadius
      .observeForUI()
      .observeValues { [weak self] radius in
        guard let self = self else { return }
        _ = self.view
          |> roundedStyle(cornerRadius: radius)
      }
  }
}
