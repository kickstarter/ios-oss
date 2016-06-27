import KsApi
import Library
import Prelude
import UIKit

internal final class UpdateViewController: WebViewController {
  private let viewModel: UpdateViewModelType = UpdateViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()

  internal func configureWith(project project: Project, update: Update) {
    self.viewModel.inputs.configureWith(project: project, update: update)
    self.shareViewModel.inputs.configureWith(shareContext: .update(project, update))
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    self |> baseControllerStyle()
  }

  internal override func bindViewModel() {
    self.navigationItem.rac.title = self.viewModel.outputs.title

    self.viewModel.outputs.webViewLoadRequest
      .observeForUI()
      .observeNext { [weak self] in self?.webView.loadRequest($0) }

    self.viewModel.outputs.goToComments
      .observeForUI()
      .observeNext { [weak self] in self?.goToComments(forUpdate: $0) }

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] in self?.goTo(project: $0, refTag: $1) }

    self.shareViewModel.outputs.showShareSheet
      .observeForUI()
      .observeNext { [weak self] in self?.showShareSheet($0) }
  }

  internal func webView(webView: WKWebView,
                        decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                        decisionHandler: (WKNavigationActionPolicy) -> Void) {

    decisionHandler(self.viewModel.inputs.decidePolicyFor(navigationAction: navigationAction))
  }

  private func goToComments(forUpdate update: Update) {
    guard let vc = UIStoryboard(name: "Comments", bundle: nil)
      .instantiateInitialViewController() as? CommentsViewController else {
        fatalError("Could not instantiate CommentsViewController.")
    }

    vc.configureWith(project: nil, update: update)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  private func goTo(project project: Project, refTag: RefTag?) {
    guard let vc = UIStoryboard(name: "Project", bundle: nil)
      .instantiateInitialViewController() as? ProjectViewController else {
        fatalError("Could not instantiate ProjectViewController")
    }

    vc.configureWith(project: project, refTag: refTag)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
  }

  private func showShareSheet(activityController: UIActivityViewController) {

    activityController.completionWithItemsHandler = { [weak self] in
      self?.shareViewModel.inputs.shareActivityCompletion(activityType: $0,
                                                          completed: $1,
                                                          returnedItems: $2,
                                                          activityError: $3)
    }

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      activityController.modalPresentationStyle = .Popover
      let popover = activityController.popoverPresentationController
      popover?.permittedArrowDirections = .Any
      popover?.barButtonItem = self.navigationItem.rightBarButtonItem
    }

    self.presentViewController(activityController, animated: true, completion: nil)
  }

  @IBAction private func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }
}
