import KsApi
import Library
import Prelude
import UIKit
import WebKit

internal protocol SurveyResponseViewControllerDelegate: AnyObject {
  /// Called when the delegate should notify the parent that self was dismissed.
  func surveyResponseViewControllerDismissed()
}

internal final class SurveyResponseViewController: WebViewController {
  internal weak var delegate: SurveyResponseViewControllerDelegate?
  fileprivate let viewModel: SurveyResponseViewModelType = SurveyResponseViewModel()

  internal static func configuredWith(surveyUrl: String)
    -> SurveyResponseViewController {
    let vc = SurveyResponseViewController()
    vc.viewModel.inputs.configureWith(surveyUrl: surveyUrl)
    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.leftBarButtonItem =
      UIBarButtonItem(
        title: Strings.general_navigation_buttons_close(),
        style: .plain,
        target: self,
        action: #selector(self.closeButtonTapped)
      )

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

    self.viewModel.outputs.goToUpdate
      .observeForControllerAction()
      .observeValues { [weak self] project, update in
        self?.goToUpdate(project: project, update: update)
      }

    self.viewModel.outputs.goToPledge
      .observeForControllerAction()
      .observeValues { [weak self] param in
        self?.goToPledge(param: param)
      }

    self.navigationItem.rac.title = self.viewModel.outputs.title

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeValues { [weak self] request in
        self?.webView.load(request)
      }
  }

  @objc fileprivate func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  internal func webView(
    _: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    decisionHandler(
      self.viewModel.inputs.decidePolicyFor(
        navigationAction: WKNavigationActionData(navigationAction: navigationAction)
      )
    )
  }

  // MARK: - Deeplinks

  fileprivate func goToProject(param: Param, refTag: RefTag?) {
    let vc = ProjectPageViewController.configuredWith(
      projectOrParam: .right(param),
      refInfo: RefInfo(refTag)
    )
    self.presentViewController(vc)
  }

  fileprivate func goToUpdate(project: Project, update: Update) {
    let vc = UpdateViewController.configuredWith(
      project: project,
      update: update,
      context: .deepLink
    )
    self.presentViewController(vc)
  }

  fileprivate func goToPledge(param: Param) {
    let vc = ManagePledgeViewController.instantiate()
    vc.configureWith(params: (param, nil))
    self.presentViewController(vc)
  }

  fileprivate func presentViewController(_ vc: UIViewController) {
    let nav = NavigationController(rootViewController: vc)
    nav.modalPresentationStyle = self.traitCollection.userInterfaceIdiom == .pad ? .fullScreen : .formSheet

    self.present(nav, animated: true, completion: nil)
  }
}
