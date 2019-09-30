import KsApi
import Library
import Prelude
import UIKit

final class ManagePledgeViewController: UIViewController {
  // MARK: - Properties

  private lazy var closeButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: UIImage(named: "icon--cross"),
      style: .plain,
      target: self,
      action: #selector(ManagePledgeViewController.closeButtonTapped)
    )
  }()

  private lazy var menuButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: UIImage(named: "icon--more-menu"),
      style: .plain,
      target: self,
      action: #selector(ManagePledgeViewController.menuButtonTapped)
    )
  }()

  private lazy var pledgeSummaryView: ManagePledgeSummaryView = { ManagePledgeSummaryView(frame: .zero) }()

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

  private let viewModel = ManagePledgeViewModel()

  static func instantiate(with project: Project, reward: Reward) -> ManagePledgeViewController {
    let manageViewPledgeVC = ManagePledgeViewController.instantiate()
    manageViewPledgeVC.viewModel.inputs.configureWith(project, reward: reward)

    return manageViewPledgeVC
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self.navigationItem
      ?|> \.leftBarButtonItem .~ self.closeButton
      ?|> \.rightBarButtonItem .~ self.menuButton

    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    self.configureViews()
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
      .observeValues { [weak self] project in
        self?.pledgeSummaryView.configureWith(project)
      }

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
      .observeValues { [weak self] project, backing in
        self?.goToCancelPledge(project: project, backing: backing)
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

  func configureWith(project: Project, reward: Reward) {
    self.viewModel.inputs.configureWith(project, reward: reward)
  }

  private func setupConstraints() {
    NSLayoutConstraint.activate([
      self.rootStackView.widthAnchor.constraint(equalTo: self.rootScrollView.widthAnchor)
    ])
  }

  // MARK: Functions

  private func configureViews() {
    _ = (self.rootScrollView, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (self.rootStackView, self.rootScrollView)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = ([self.pledgeSummaryView], self.rootStackView)
      |> ksr_addArrangedSubviewsToStackView()
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

  private func goToUpdatePledge(_: Project) {
    // TODO:
  }

  private func goToCancelPledge(project: Project, backing: Backing) {
    let cancelPledgeViewController = CancelPledgeViewController.instantiate()
    cancelPledgeViewController.configure(with: project, backing: backing)

    self.navigationController?.pushViewController(cancelPledgeViewController, animated: true)
  }

  private func goToChangePaymentMethod() {
    // TODO:
  }

  private func goToContactCreator() {
    // TODO:
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

private let rootStackViewStyle: StackViewStyle = { stackView in
  stackView
    |> \.layoutMargins .~ .init(
      top: Styles.grid(3),
      left: Styles.grid(4),
      bottom: Styles.grid(3),
      right: Styles.grid(4)
    )
    |> \.isLayoutMarginsRelativeArrangement .~ true
    |> \.axis .~ NSLayoutConstraint.Axis.vertical
    |> \.distribution .~ UIStackView.Distribution.fill
    |> \.alignment .~ UIStackView.Alignment.fill
    |> \.spacing .~ Styles.grid(4)
}
