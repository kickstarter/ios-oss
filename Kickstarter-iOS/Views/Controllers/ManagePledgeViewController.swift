import KsApi
import Library
import Prelude
import UIKit

final class ManagePledgeViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    _ = self
      |> \.title %~ { _ in Strings.Manage_your_pledge() }

    let navigationBarButton = UIBarButtonItem(barButtonSystemItem: .edit,
                                              target: self,
                                              action: #selector(ManagePledgeViewController.editButtonTapped))
    self.navigationItem.setRightBarButton(navigationBarButton, animated: false)
  }

  override func bindStyles() {
    super.bindStyles()

    _ = self.view
      |> checkoutBackgroundStyle
  }

  // MARK: Functions
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
}
