import KsApi
import Library
import Prelude
import SafariServices
import UIKit
import WebKit

internal final class UpdateViewController: WebViewController {
  fileprivate let viewModel: UpdateViewModelType = UpdateViewModel()
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()

  fileprivate let closeButton = UIBarButtonItem()

  @IBOutlet fileprivate var shareButton: UIBarButtonItem!

  internal static func configuredWith(project: Project, update: Update, context _: KSRAnalytics.UpdateContext)
    -> UpdateViewController {
    let vc = Storyboard.Update.instantiate(UpdateViewController.self)
    vc.viewModel.inputs.configureWith(project: project, update: update)
    vc.shareViewModel.inputs.configureWith(shareContext: .update(project, update), shareContextView: nil)

    return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.navigationController?.setNavigationBarHidden(false, animated: animated)

    guard
      self.presentingViewController != nil,
      let navigationController = self.navigationController, navigationController.viewControllers == [self]
    else { return }

    self.navigationItem.leftBarButtonItem = self.closeButton
  }

  internal override func bindStyles() {
    _ = self |> baseControllerStyle()

    _ = self.closeButton |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(self.dismissSelf))

    _ = self.shareButton
      |> UIBarButtonItem.lens.accessibilityLabel %~ { _ in Strings.Share_update() }
  }

  internal override func bindViewModel() {
    self.navigationItem.rac.title = self.viewModel.outputs.title

    self.viewModel.outputs.webViewLoadRequest
      .observeForControllerAction()
      .observeValues { [weak self] in _ = self?.webView.load($0) }

    self.viewModel.outputs.goToComments
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goToComments(forUpdate: $0) }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goTo(project: $0, refTag: $1) }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in self?.showShareSheet(controller) }

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goTo(url: $0) }
  }

  internal func webView(
    _: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    decisionHandler(
      self.viewModel.inputs.decidePolicyFor(navigationAction: .init(navigationAction: navigationAction))
    )
  }

  fileprivate func goToComments(forUpdate update: Update) {
    let vc = commentsViewController(update: update)

    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  fileprivate func goTo(project: Project, refTag: RefTag) {
    let projectParam = Either<Project, Param>(left: project)
    let vc = ProjectPageViewController.configuredWith(
      projectOrParam: projectParam,
      refTag: refTag
    )

    let nav = NavigationController(rootViewController: vc)
    nav.modalPresentationStyle = self.traitCollection.userInterfaceIdiom == .pad ? .fullScreen : .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func showShareSheet(_ controller: UIActivityViewController) {
    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      let popover = controller.popoverPresentationController
      popover?.permittedArrowDirections = .any
      popover?.barButtonItem = self.navigationItem.rightBarButtonItem
    }

    self.present(controller, animated: true, completion: nil)
  }

  @IBAction fileprivate func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc fileprivate func dismissSelf() {
    self.presentingViewController?.dismiss(animated: true, completion: nil)
  }
}
