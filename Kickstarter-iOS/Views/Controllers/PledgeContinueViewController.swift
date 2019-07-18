import Foundation
import Library
import Prelude

final class PledgeContinueViewController: UIViewController {
  // MARK: - Properties

  private let continueButton = MultiLineButton(type: .custom)
  private let viewModel = PledgeContinueViewModel()

  // MARK: - Lifecycle

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
      |> checkoutGreenButtonStyle
      |> UIButton.lens.title(for: .normal) %~ { _ in
        Strings.Continue()
      }

    _ = self.continueButton.titleLabel
      ?|> checkoutGreenButtonTitleLabelStyle
  }

  // MARK: - View model

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.goToLoginSignup
      .observeForControllerAction()
      .observeValues { [weak self] intent in
        self?.goToLoginSignup(with: intent)
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

  private func goToLoginSignup(with intent: LoginIntent) {
    let loginSignupViewController = LoginToutViewController.configuredWith(loginIntent: intent)
    let navigationController = UINavigationController(rootViewController: loginSignupViewController)
    let sheetOverlayViewController = SheetOverlayViewController(
      child: navigationController,
      offset: Layout.Sheet.offset
    )

    self.present(sheetOverlayViewController, animated: true)
  }
}
