import KsApi
import Library
import Prelude
import UIKit

public protocol ProjectNavBarViewControllerDelegate: AnyObject {
  func projectNavBarControllerDidTapTitle(_ controller: ProjectNavBarViewController)
}

public final class ProjectNavBarViewController: UIViewController {
  internal weak var delegate: ProjectNavBarViewControllerDelegate?
  fileprivate let viewModel: ProjectNavBarViewModelType = ProjectNavBarViewModel()
  private var sessionEndedObserver: Any?
  private var sessionStartedObserver: Any?
  fileprivate let shareViewModel: ShareViewModelType = ShareViewModel()
  private let watchProjectViewModel: WatchProjectViewModelType = WatchProjectViewModel()

  @IBOutlet fileprivate var backgroundView: UIView!
  @IBOutlet fileprivate var closeButton: UIButton!
  @IBOutlet fileprivate var navContainerView: UIView!
  @IBOutlet fileprivate var projectNameLabel: UILabel!
  @IBOutlet fileprivate var shareButton: UIButton!
  @IBOutlet fileprivate var saveButton: UIButton!

  internal func configureWith(project: Project, refTag: RefTag?) {
    self.viewModel.inputs.configureWith(project: project, refTag: refTag)
    self.shareViewModel.inputs.configureWith(shareContext: .project(project), shareContextView: nil)
    self.watchProjectViewModel.inputs.configure(with: (project, Koala.LocationContext.projectPage, nil))
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

    self.closeButton.addTarget(self, action: #selector(self.closeButtonTapped), for: .touchUpInside)
    self.shareButton.addTarget(self, action: #selector(self.shareButtonTapped), for: .touchUpInside)
    self.saveButton.addTarget(self, action: #selector(self.saveButtonTapped(_:)), for: .touchUpInside)
    self.saveButton.addTarget(self, action: #selector(self.saveButtonPressed), for: .touchDown)
    self.projectNameLabel.addGestureRecognizer(
      UITapGestureRecognizer(target: self, action: #selector(self.projectNameTapped))
    )

    self.sessionStartedObserver = NotificationCenter
      .default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.watchProjectViewModel.inputs.userSessionStarted()
      }

    self.sessionEndedObserver = NotificationCenter
      .default
      .addObserver(forName: .ksr_sessionEnded, object: nil, queue: nil) { [weak self] _ in
        self?.watchProjectViewModel.inputs.userSessionEnded()
      }

    self.viewModel.inputs.viewDidLoad()
    self.watchProjectViewModel.inputs.viewDidLoad()
  }

  deinit {
    self.sessionEndedObserver.doIfSome(NotificationCenter.default.removeObserver)
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self.backgroundView
      |> UIView.lens.layer.shadowOpacity .~ 0
      |> UIView.lens.layer.shadowRadius .~ 2.0
      |> UIView.lens.layer.shadowOffset .~ CGSize(width: 0, height: 2)
      |> UIView.lens.layer.shadowColor .~ UIColor.ksr_grey_500.cgColor

    _ = self.closeButton
      |> UIButton.lens.title(for: .normal) .~ nil
      |> UIButton.lens.image(for: .normal) .~ image(named: "icon--cross")
      |> UIButton.lens.tintColor .~ .ksr_soft_black
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
      |> UILabel.lens.isUserInteractionEnabled .~ true

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
    self.saveButton.rac.accessibilityValue = self.watchProjectViewModel.outputs.saveButtonAccessibilityValue
    self.saveButton.rac.selected = self.watchProjectViewModel.outputs.saveButtonSelected

    self.watchProjectViewModel.outputs.generateImpactFeedback
      .observeForUI()
      .observeValues { generateImpactFeedback() }

    self.watchProjectViewModel.outputs.generateNotificationSuccessFeedback
      .observeForUI()
      .observeValues { generateNotificationSuccessFeedback() }

    self.watchProjectViewModel.outputs.generateSelectionFeedback
      .observeForUI()
      .observeValues { generateSelectionFeedback() }

    self.watchProjectViewModel.outputs.showProjectSavedAlert
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.showProjectStarredPrompt()
      }

    self.watchProjectViewModel.outputs.goToLoginTout
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

    self.watchProjectViewModel.outputs.postNotificationWithProject
      .observeForUI()
      .observeValues { project in
        NotificationCenter.default.post(
          name: Notification.Name.ksr_projectSaved,
          object: nil,
          userInfo: ["project": project]
        )
      }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in self?.showShareSheet(controller) }
  }

  fileprivate func showProjectStarredPrompt() {
    let alert = UIAlertController(
      title: Strings.Project_saved(),
      message: Strings.Well_remind_you_forty_eight_hours_before_this_project_ends(),
      preferredStyle: .alert
    )
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
    let isIpad = AppEnvironment.current.device.userInterfaceIdiom == .pad
    let nav = UINavigationController(rootViewController: vc)
      |> \.modalPresentationStyle .~ (isIpad ? .formSheet : .fullScreen)

    self.present(nav, animated: true, completion: nil)
  }

  fileprivate func showShareSheet(_ controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in

      self?.shareViewModel.inputs.shareActivityCompletion(
        with: .init(
          activityType: activityType,
          completed: completed,
          returnedItems: returnedItems,
          activityError: error
        )
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

  @objc fileprivate func saveButtonTapped(_ button: UIButton) {
    self.watchProjectViewModel.inputs.saveButtonTapped(selected: button.isSelected)
  }

  @objc fileprivate func saveButtonPressed() {
    self.watchProjectViewModel.inputs.saveButtonTouched()
  }

  @objc fileprivate func projectNameTapped() {
    self.delegate?.projectNavBarControllerDidTapTitle(self)
  }
}
