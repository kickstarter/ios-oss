import Foundation
import KsApi
import Library
import Prelude
import UIKit

final class SystemDesignViewController: UIViewController, NibLoading {
  @IBOutlet var scrollView: UIScrollView!

  // MARK: - Alerts

  @IBOutlet var errorSnackbar: UIView!
  @IBOutlet var confirmationSnackbar: UIView!

  // MARK: - Buttons

  @IBOutlet var buttonsStackView: UIStackView!
  private let rootStackView: UIStackView = { UIStackView(frame: .zero) }()
  private let primaryGreenButton = UIButton(type: .custom)
  private let primaryBlueButton = UIButton(type: .custom)
  private let primaryBlackButton = UIButton(type: .custom)

  // MARK: - Properties

  static func instantiate() -> SystemDesignViewController {
    return Storyboard.SystemDesign.instantiate(SystemDesignViewController.self)
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title .~ "System Design"

    self.configureViews()
  }

  // MARK: - Configuration

  private func configureViews() {
    _ = (
      [
        self.primaryGreenButton,
        self.primaryBlueButton,
        self.primaryBlackButton
      ], self.buttonsStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

//    _ = (self.rootStackView, self.scrollView)
//      |> ksr_addSubviewToParent()
//      |> ksr_constrainViewToMarginsInParent()

    NSLayoutConstraint
      .activate([
        self.primaryGreenButton.heightAnchor
          .constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
          |> \.priority .~ .defaultHigh,
        self.primaryBlueButton.heightAnchor
          .constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
          |> \.priority .~ .defaultHigh,
        self.primaryBlackButton.heightAnchor
          .constraint(greaterThanOrEqualToConstant: Styles.minTouchSize.height)
          |> \.priority .~ .defaultHigh
      ])
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self.primaryGreenButton
      |> greenButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Primary Green Button"

    _ = self.primaryBlueButton
      |> blueButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Primary Blue Button"

    _ = self.primaryBlackButton
      |> blackButtonStyle
      |> UIButton.lens.title(for: .normal) .~ "Primary Black Button"
  }
}
