import KsApi
import Library
import Prelude
import Social
import UIKit

public protocol ProjectNavBarViewControllerDelegate: class {
  func projectNavBarControllerDidTapTitle(_ controller: ProjectNavBarViewController)
}

public final class ProjectNavBarViewController: UIViewController {
  internal weak var delegate: ProjectNavBarViewControllerDelegate?
  fileprivate let viewModel: ProjectNavBarViewModelType = ProjectNavBarViewModel()
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()

  @IBOutlet fileprivate weak var backgroundView: UIView!
  @IBOutlet fileprivate weak var closeButton: UIButton!
  @IBOutlet fileprivate weak var navContainerView: UIView!
  @IBOutlet fileprivate weak var projectNameLabel: UILabel!
  @IBOutlet fileprivate weak var shareButton: UIButton!
  @IBOutlet fileprivate weak var saveButton: UIButton!

  internal func configureWith(project: Project, refTag: RefTag?) {
    self.viewModel.inputs.configureWith(project: project, refTag: refTag)
    self.shareViewModel.inputs.configureWith(shareContext: .project(project), shareContextView: nil)
  }

  internal func setDidScrollToTop(_ didScrollToTop: Bool) {
    self.viewModel.inputs.projectPageDidScrollToTop(didScrollToTop)
  }

  internal func setProjectImageIsVisible(_ visible: Bool) {
    self.viewModel.inputs.projectImageIsVisible(visible)
  }

  internal func projectVideoDidFinish() {
    self.viewModel.inputs.projectVideoDidFinish()
  }

  internal func projectVideoDidStart() {
    self.viewModel.inputs.projectVideoDidStart()
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    self.shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
    self.saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    self.projectNameLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(projectNameTapped))
    )

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    NotificationCenter
      .default
      .addObserver(forName: Notification.Name.ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionEnded()
    }

    self.viewModel.inputs.viewDidLoad()
  }

    public override func bindStyles() {
    super.bindStyles()

    _ = self.backgroundView
      |> UIView.lens.layer.shadowOpacity .~ 0
      |> UIView.lens.layer.shadowRadius .~ 2
      |> UIView.lens.layer.shadowOffset .~ CGSize(width: 0, height: 2)
      |> UIView.lens.layer.shadowColor .~ UIColor.ksr_grey_500.cgColor

    _ = self.closeButton
      |> UIButton.lens.title(forState: .normal) .~ nil
      |> UIButton.lens.image(forState: .normal) .~ image(named: "icon--cross")
      |> UIButton.lens.tintColor .~ .ksr_dark_grey_900
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_close() }
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Closes_project() }

    _ = self.navContainerView
      |> UIView.lens.layoutMargins .~ .init(topBottom: 0, leftRight: Styles.gridHalf(1))

    _ = self.projectNameLabel
      |> UILabel.lens.font .~ .ksr_body(size: 14)
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_500
      |> UILabel.lens.textAlignment .~ .center
      |> UILabel.lens.numberOfLines .~ 2
      |> UILabel.lens.minimumScaleFactor .~ 0.8
      |> UILabel.lens.adjustsFontSizeToFitWidth .~ true
      |> UILabel.lens.userInteractionEnabled .~ true

    _ = self.shareButton
      |> shareButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }

    _ = self.saveButton
      |> saveButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Toggle_saving_this_project() }
  }

    public override func bindViewModel() {
    super.bindViewModel()

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.saveButton.rac.accessibilityValue = self.viewModel.outputs.saveButtonAccessibilityValue
    self.saveButton.rac.selected = self.viewModel.outputs.saveButtonSelected
    self.saveButton.rac.enabled = self.viewModel.outputs.saveButtonEnabled

    self.viewModel.outputs.showProjectSavedPrompt
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showProjectStarredPrompt()
    }

    self.viewModel.outputs.goToLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.goToLoginTout()
    }

    self.viewModel.outputs.navBarShadowVisible
      .observeForUI()
      .observeValues { [weak self] didScrollToTop in
        UIView.animate(withDuration: 0.0) {
          self?.backgroundView.layer.shadowOpacity = didScrollToTop ? 0 : 1
        }
      }

    self.viewModel.outputs.titleHiddenAndAnimate
      .observeForUI()
      .observeValues { [weak self] hidden, animate in
        UIView.animate(withDuration: animate ? 0.2 : 0) {
          self?.projectNameLabel.alpha = hidden ? 0 : 1
        }
    }

    self.viewModel.outputs.backgroundOpaqueAndAnimate
      .observeForUI()
      .observeValues { [weak self] opaque, animate in
        UIView.animate(withDuration: animate ? 0.2 : 0) {
          self?.navContainerView.backgroundColor = opaque ? .white : .clear
        }
    }

    self.viewModel.outputs.dismissViewController
      .observeForUI()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    self.viewModel.outputs.postNotificationWithProject
      .observeForUI()
      .observeValues { project in
        NotificationCenter.default.post(name: Notification.Name.ksr_projectSaved,
                                        object: nil,
                                        userInfo: ["project": project])
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in self?.showShareSheet(controller) }
  }

  fileprivate func showProjectStarredPrompt() {
    let alert = UIAlertController(
      title: Strings.Project_saved(),
      message: Strings.Well_remind_you_forty_eight_hours_before_this_project_ends(),
      preferredStyle: .alert)
    alert.addAction(
      UIAlertAction(
        title: Strings.Got_it(),
        style: .cancel,
        handler: nil
      )
    )

    self.present(alert, animated: true, completion: nil)
  }

  fileprivate func goToLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .starProject)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
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
      popover?.sourceView = self.shareButton
    }

    self.present(controller, animated: true, completion: nil)
  }

  @objc fileprivate func closeButtonTapped() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc fileprivate func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc fileprivate func saveButtonTapped() {
    self.viewModel.inputs.saveButtonTapped()
  }

  @objc fileprivate func projectNameTapped() {
    self.delegate?.projectNavBarControllerDidTapTitle(self)
  }
}
