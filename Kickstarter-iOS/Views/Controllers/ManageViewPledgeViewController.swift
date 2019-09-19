import KsApi
import Library
import Prelude
import UIKit

final class ManageViewPledgeViewController: UIViewController {
  // MARK: - Properties

  private lazy var closeButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: UIImage(named: "icon--cross"),
      style: .plain,
      target: self,
      action: #selector(ManageViewPledgeViewController.closeButtonTapped)
    )
  }()

  private lazy var menuButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: UIImage(named: "icon--more-menu"),
      style: .plain,
      target: self,
      action: #selector(ManageViewPledgeViewController.menuButtonTapped)
    )
  }()

  private lazy var navigationBarShadowImage: UIImage? = {
    UIImage(in: CGRect(x: 0, y: 0, width: 1, height: 0.5), with: .ksr_dark_grey_400)
  }()

  private let viewModel = ManageViewPledgeViewModel()

  static func instantiate(with project: Project, reward: Reward) -> ManageViewPledgeViewController {
    let manageViewPledgeVC = ManageViewPledgeViewController.instantiate()
    manageViewPledgeVC.viewModel.inputs.configureWith(project, reward: reward)

    return manageViewPledgeVC
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    _ = self.navigationController?.navigationBar
      ?|> \.shadowImage .~ UIImage()
      ?|> \.isTranslucent .~ false
      ?|> \.barTintColor .~ .ksr_grey_400

    _ = self.navigationItem
      ?|> \.leftBarButtonItem .~ self.closeButton
      ?|> \.rightBarButtonItem .~ self.menuButton

    self.viewModel.inputs.viewDidLoad()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> viewStyle

    _ = self.closeButton
      |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }
      |> \.width .~ Styles.minTouchSize.width
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.title
      .observeForUI()
      .observeValues { [weak self] title in
        guard let self = self else { return }
        _ = self
          |> \.title .~ title
      }

    self.viewModel.outputs.configurePaymentMethodView
      .observeForUI()
      .observeValues { _ in }

    self.viewModel.outputs.configurePledgeSummaryView
      .observeForUI()
      .observeValues { _ in }

    self.viewModel.outputs.configureRewardSummaryView
      .observeForUI()
      .observeValues { _ in }

    self.viewModel.outputs.showActionSheetMenuWithOptions
      .observeForControllerAction()
      .observeValues { [weak self] options in
        self?.showActionSheetMenuWithOptions(options)
    }
  }

  // MARK: - Configuration

  func configureWith(project: Project, reward: Reward) {
    self.viewModel.inputs.configureWith(project, reward: reward)
  }

  // MARK: Actions

  @objc private func menuButtonTapped() {
    self.viewModel.inputs.menuButtonTapped()
  }

  private func showActionSheetMenuWithOptions(_ options: [ActionSheetMenuOption]) {
    let preferredStyle: UIAlertController.Style =
      AppEnvironment.current.device.userInterfaceIdiom == .pad ? .alert : .actionSheet

    let actionSheet = UIAlertController.alert(
      title: Strings.Select_an_option(),
      preferredStyle: preferredStyle,
      barButtonItem: self.menuButton
    )

    options.forEach { option in
      let title: String

      switch option {
      case .updatePledge:
        title = Strings.Update_pledge()
      case .changePaymentMethod:
        title = Strings.Change_payment_method()
      case .chooseAnotherReward:
        title = Strings.Choose_another_reward()
      case .contactCreator:
        title = Strings.Contact_creator()
      case .cancelPledge:
        title = Strings.Cancel_pledge()
      }

      let style: UIAlertAction.Style = option == .cancelPledge ? .destructive : .default

      actionSheet.addAction(
        UIAlertAction(title: title, style: style)
      )
    }

    actionSheet.addAction(
      UIAlertAction(title: Strings.Cancel(), style: .cancel)
    )

    self.present(actionSheet, animated: true)
  }

  @objc private func closeButtonTapped() {
    self.dismiss(animated: true)
  }
}

// MARK: Styles

public let viewStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ UIColor.ksr_grey_400
}
