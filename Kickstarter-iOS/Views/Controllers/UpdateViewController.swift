import KsApi
import Library
import Prelude
import SafariServices
import UIKit

internal final class UpdateViewController: WebViewController {
  fileprivate let viewModel: UpdateViewModelType = UpdateViewModel()
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()

  fileprivate let closeButton = UIBarButtonItem()

  @IBOutlet fileprivate weak var shareButton: UIBarButtonItem!

  internal static func configuredWith(project: Project, update: Update) -> UpdateViewController {
    let vc: UpdateViewController = Storyboard.Update.instantiate()
    vc.viewModel.inputs.configureWith(project: project, update: update)
    vc.shareViewModel.inputs.configureWith(shareContext: .update(project, update))
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
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(dismissSelf))

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
      .observeValues { [weak self] in self?.showShareSheet($0) }

    self.viewModel.outputs.goToSafariBrowser
      .observeForControllerAction()
      .observeValues { [weak self] url in self?.goToSafariBrowser(url: url) }
  }

  internal func webView(_ webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                        decisionHandler: (WKNavigationActionPolicy) -> Void) {

    decisionHandler(
      self.viewModel.inputs.decidePolicyFor(navigationAction: .init(navigationAction: navigationAction))
    )
  }

  fileprivate func goToComments(forUpdate update: Update) {
    let vc = CommentsViewController.configuredWith(update: update)

    if self.traitCollection.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = UIModalPresentationStyle.formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  fileprivate func goTo(project: Project, refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    self.present(vc, animated: true, completion: nil)
  }

  fileprivate func goToSafariBrowser(url: URL) {
    let controller = SFSafariViewController(url: url)
    controller.modalPresentationStyle = .overFullScreen
    self.present(controller, animated: true, completion: nil)
  }

  fileprivate func showShareSheet(_ controller: UIActivityViewController) {

    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in

      self?.shareViewModel.inputs.shareActivityCompletion(
        with: .init(activityType: activityType,
                    completed: completed,
                    returnedItems: returnedItems,
                    activityError: error)
      )
    }

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
