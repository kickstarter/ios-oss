import KsApi
import Library
import Prelude
import UIKit

final class ManagePledgeViewController: UIViewController {

  private lazy var closeButton: UIBarButtonItem = {
    return UIBarButtonItem(
      image: UIImage(named: "icon--cross"),
      style: .plain,
      target: self,
      action: #selector(RewardsCollectionViewController.closeButtonTapped)
    )
  }()

  private lazy var editButton: UIBarButtonItem = {
    return UIBarButtonItem(
      barButtonSystemItem: .edit,
      target: self,
      action: #selector(ManagePledgeViewController.editButtonTapped)
    )
  }()

  private lazy var navigationBarShadowImage: UIImage? = {
    UIImage(in: CGRect(x: 0, y: 0, width: 1, height: 0.5), with: .ksr_dark_grey_400)
  }()

  private let viewModel: ManagePledgeViewModelType = ManagePledgeViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Manage_your_pledge() }
      |> \.extendedLayoutIncludesOpaqueBars .~ true

    _ = self.navigationController?.navigationBar
      ?|> \.shadowImage .~ UIImage()
      ?|> \.isTranslucent .~ true
      ?|> \.barTintColor .~ .ksr_grey_400

    self.navigationItem.setRightBarButton(self.editButton, animated: false)
    self.navigationItem.setLeftBarButton(self.closeButton, animated: false)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle

    _ = self.closeButton
      |> \.accessibilityLabel %~ { _ in Strings.Dismiss() }
  }

  func configureWith(project: Project, reward: Reward) {
    self.viewModel.inputs.configureWith(project, reward: reward)
  }

  // MARK: Actions

  @objc func editButtonTapped() {
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    actionSheet.addAction(
      UIAlertAction(title: Strings.Contact_creator(), style: .default)
    )
    actionSheet.addAction(
      UIAlertAction(title: Strings.Cancel(), style: .cancel)
    )
    self.present(actionSheet, animated: true, completion: nil)
  }

  @objc func closeButtonTapped() {
    self.navigationController?.dismiss(animated: true)
  }
}
