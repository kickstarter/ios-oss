import Foundation
import KsApi
import Library
import Prelude

final class PledgeContinueViewController: UIViewController {
  // MARK: - Properties

  private let continueButton = UIButton(type: .custom)
  private let viewModel: PledgeContinueViewModelType = PledgeContinueViewModel()

  // MARK: - Lifecycle

  func configureWith(value: (project: Project, reward: Reward)) {
    self.viewModel.inputs.configure(with: value)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configureSubviews()
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.continueButton
      |> continueButtonStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToLoginSignup
      .observeForControllerAction()
      .observeValues { [weak self] intent, project, reward in
        self?.goToLoginSignup(with: intent, project: project, reward: reward)
      }
  }

  private func configureSubviews() {
    _ = (self.continueButton, self.view)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToMarginsInParent()

    self.continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: Styles.grid(8)).isActive = true

    self.continueButton.addTarget(
      self,
      action: #selector(PledgeContinueViewController.continueButtonTapped),
      for: .touchUpInside
    )
  }

  // MARK: - Actions

  @objc private func continueButtonTapped() {
    self.viewModel.inputs.continueButtonTapped()
  }

  // MARK: - Functions

  private func goToLoginSignup(with intent: LoginIntent, project: Project, reward: Reward) {
    let loginSignupViewController = LoginToutViewController.configuredWith(
      loginIntent: intent,
      project: project,
      reward: reward
    )

    let navigationController = UINavigationController(rootViewController: loginSignupViewController)
    let navigationBarHeight = navigationController.navigationBar.bounds.height

    if #available(iOS 13.0, *) {
      self.present(navigationController, animated: true)
    } else {
      self.presentViewControllerWithSheetOverlay(navigationController, offset: navigationBarHeight)
    }
  }
}

// MARK: - Styles

private let continueButtonStyle: ButtonStyle = { button in
  button
    |> greenButtonStyle
    |> UIButton.lens.title(for: .normal) %~ { _ in Strings.Continue() }
}
