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
  private let viewModel: SurveyResponseViewModelType = SurveyResponseViewModel()

  internal static func configuredWith(surveyResponse surveyResponse: SurveyResponse)
    -> SurveyResponseViewController {
      let vc = SurveyResponseViewController()
      vc.viewModel.inputs.configureWith(surveyResponse: surveyResponse)
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.leftBarButtonItem =
      UIBarButtonItem(title: Strings.general_navigation_buttons_close(),
                      style: .Plain,
                      target: self,
                      action: #selector(closeButtonTapped))

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.dismissViewController
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.navigationController?.dismissViewControllerAnimated(true, completion: nil)

        // iPad provision
        if self?.traitCollection.userInterfaceIdiom == .Pad {
          self?.delegate?.surveyResponseViewControllerDismissed()
        }
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeNext { [weak self] param, refTag in
        self?.goToProject(param: param, refTag: refTag)
    }

    self.viewModel.outputs.showAlert
      .observeForControllerAction()
      .observeNext { [weak self] message in
        self?.showAlert(message: message)
    }

    self.navigationItem.rac.title = self.viewModel.outputs.title

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeNext { [weak self] request in
        self?.webView.loadRequest(request)
    }
  }

  @objc private func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  private func goToProject(param param: Param, refTag: RefTag?) {
    let vc = ProjectPamphletViewController.configuredWith(projectOrParam: .right(param), refTag: refTag)
    let nav = UINavigationController(rootViewController: vc)
    self.presentViewController(nav, animated: true, completion: nil)
  }

  private func showAlert(message message: String) {
    self.presentViewController(
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

  internal func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest,
               navigationType: UIWebViewNavigationType) -> Bool {
    let result = self.viewModel.inputs.shouldStartLoad(withRequest: request, navigationType: navigationType)
    return result
  }
}
