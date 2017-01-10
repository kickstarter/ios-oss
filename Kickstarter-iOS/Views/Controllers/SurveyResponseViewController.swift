import KsApi
import Library
import Prelude
import Social
import UIKit

internal protocol SurveyResponseViewControllerDelegate: class {
  /// Called when the delegate should notify the parent that self was dismissed.
  func surveyResponseViewControllerDismissed()
}

internal final class SurveyResponseViewController: DeprecatedWebViewController {
  internal weak var delegate: SurveyResponseViewControllerDelegate?
  fileprivate let viewModel: SurveyResponseViewModelType = SurveyResponseViewModel()

  internal static func configuredWith(surveyResponse: SurveyResponse)
    -> SurveyResponseViewController {
      let vc = SurveyResponseViewController()
      vc.viewModel.inputs.configureWith(surveyResponse: surveyResponse)
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.leftBarButtonItem =
      UIBarButtonItem(title: Strings.general_navigation_buttons_close(),
                      style: .plain,
                      target: self,
                      action: #selector(closeButtonTapped))

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.navigationController?.dismiss(animated: true, completion: nil)
        self?.delegate?.surveyResponseViewControllerDismissed()
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] param, refTag in
        self?.goToProject(param: param, refTag: refTag)
    }

    self.viewModel.outputs.showAlert
      .observeForControllerAction()
      .observeValues { [weak self] message in
        self?.showAlert(message: message)
    }

    self.navigationItem.rac.title = self.viewModel.outputs.title

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeValues { [weak self] request in
        self?.webView.loadRequest(request)
    }
  }

  @objc fileprivate func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  fileprivate func goToProject(param: Param, refTag: RefTag?) {
    let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .right(param), refTag: refTag)
    let nav = UINavigationController(rootViewController: vc)
    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func showAlert(message: String) {
    self.present(
      UIAlertController.alert(
        message: message,
        handler: { [weak self] _ in
          self?.viewModel.inputs.alertButtonTapped()
        }
      ),
      animated: true,
      completion: nil
    )
  }

  internal func webView(_ webView: UIWebView, shouldStartLoadWithRequest request: URLRequest,
               navigationType: UIWebViewNavigationType) -> Bool {
    let result = self.viewModel.inputs.shouldStartLoad(withRequest: request, navigationType: navigationType)
    return result
  }
}
