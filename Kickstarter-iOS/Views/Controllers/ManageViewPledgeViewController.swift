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

  private lazy var rewardReceivedViewController: ManageViewPledgeRewardReceivedViewController = {
    ManageViewPledgeRewardReceivedViewController.instantiate()
  }()

  private lazy var rootScrollView: UIScrollView = {
    UIScrollView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
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

    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.configureChildViewControllers()
    self.setupConstraints()

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

    _ = self.menuButton
      |> \.accessibilityLabel %~ { _ in Strings.Menu() }

    _ = self.rootScrollView
      |> rootScrollViewStyle

    _ = self.rootStackView
      |> checkoutRootStackViewStyle
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

    self.viewModel.outputs.goToRewards
      .observeForControllerAction()
      .observeValues { [weak self] project in
        self?.goToRewards(project)
    }

    self.viewModel.outputs.goToUpdatePledge
      .observeForControllerAction()
      .observeValues { [weak self] project in
        self?.goToUpdatePledge(project)
    }

    self.viewModel.outputs.goToChangePaymentMethod
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToChangePaymentMethod()
    }

    self.viewModel.outputs.goToContactCreator
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToContactCreator()
    }

    self.viewModel.outputs.goToCancelPledge
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToCancelPledge()
    }
  }

  // MARK: - Configuration

  private func configureChildViewControllers() {
    let childViewControllers = [
      self.rewardReceivedViewController
    ]

    childViewControllers.forEach { viewController in
      self.addChild(viewController)

      _ = ([viewController.view], self.rootStackView)
        |> ksr_addArrangedSubviewsToStackView()

      viewController.didMove(toParent: self)
    }
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalTo: self.rootScrollView.widthAnchor)
    ])
  }

  func configureWith(project: Project, reward: Reward) {
    self.viewModel.inputs.configureWith(project, reward: reward)
  }

  // MARK: Actions

  @objc private func menuButtonTapped() {
    self.viewModel.inputs.menuButtonTapped()
  }

  private func showActionSheetMenuWithOptions(_ options: [ManagePledgeAlertAction]) {
    let actionSheet = UIAlertController.alert(
      title: Strings.Select_an_option(),
      preferredStyle: .actionSheet,
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
        UIAlertAction(title: title, style: style, handler: { _ in
          self.viewModel.inputs.menuOptionSelected(with: option)
        })
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

  // MARK: - Functions

  private func goToRewards(_ project: Project) {
    let rewardsVC = RewardsCollectionViewController.instantiate(with: project, refTag: nil)

    self.navigationController?.pushViewController(rewardsVC, animated: true)
  }

  private func goToUpdatePledge(_ project: Project) {
    // TODO
  }

  private func goToCancelPledge() {
    // TODO
  }

  private func goToChangePaymentMethod() {
    // TODO
  }

  private func goToContactCreator() {
    // TODO
  }
}

// MARK: Styles

private let rootScrollViewStyle = { (scrollView: UIScrollView) in
  scrollView
    |> \.alwaysBounceVertical .~ true
}

private let viewStyle: ViewStyle = { (view: UIView) in
  view
    |> \.backgroundColor .~ UIColor.ksr_grey_400
}
