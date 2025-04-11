import KsApi
import Library
import Prelude
import UIKit

internal final class PledgeManagementViewPledgeViewController: WebViewController {
  private let viewModel: PledgeManagementViewPledgeViewModelType = PledgeManagementViewPledgeViewModel()

  internal static func configuredWith(project: Project) -> PledgeManagementViewPledgeViewController {
    let vc = PledgeManagementViewPledgeViewController()
    vc.viewModel.inputs.configureWith(project: project)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.title = Strings.Backing_details()

    if self.navigationController?.viewControllers.count == .some(1) {
      self.navigationItem.leftBarButtonItem = UIBarButtonItem(
        title: Strings.general_navigation_buttons_close(),
        style: .plain,
        target: self,
        action: #selector(self.closeButtonTapped)
      )
    }

    self.viewModel.inputs.viewDidLoad()
  }

  override func bindStyles() {
    super.bindStyles()
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeValues { [weak self] in _ = self?.webView.load($0) }
  }

  @objc fileprivate func closeButtonTapped() {
    self.dismiss(animated: true, completion: nil)
  }
}
