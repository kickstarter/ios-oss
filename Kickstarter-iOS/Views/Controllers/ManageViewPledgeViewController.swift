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

  private lazy var editButton: UIBarButtonItem = {
    UIBarButtonItem(
      image: UIImage(named: "icon--more-menu"),
      style: .plain,
      target: self,
      action: #selector(ManageViewPledgeViewController.editButtonTapped)
    )
  }()

  private lazy var navigationBarShadowImage: UIImage? = {
    UIImage(in: CGRect(x: 0, y: 0, width: 1, height: 0.5), with: .ksr_dark_grey_400)
  }()

  private let viewModel: ManageViewPledgeViewModelType = ManageViewPledgeViewModel()

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Manage_your_pledge() }
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    _ = self.navigationController?.navigationBar
      ?|> \.shadowImage .~ UIImage()
      ?|> \.isTranslucent .~ false
      ?|> \.barTintColor .~ .ksr_grey_400

    _ = self.navigationItem
      ?|> \.leftBarButtonItem .~ self.closeButton
      ?|> \.rightBarButtonItem .~ self.editButton
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

  // MARK: - Configuration

  func configureWith(project: Project, reward: Reward) {
    self.viewModel.inputs.configureWith(project, reward: reward)
  }

  // MARK: Actions

  @objc private func editButtonTapped() {
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    actionSheet.addAction(
      UIAlertAction(title: Strings.Contact_creator(), style: .default)
    )
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
