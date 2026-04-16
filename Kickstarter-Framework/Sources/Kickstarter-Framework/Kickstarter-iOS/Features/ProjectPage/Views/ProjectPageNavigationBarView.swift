import KDS
import KsApi
import Library
import PassKit
import Prelude
import UIKit

protocol ProjectPageNavigationBarViewDelegate: AnyObject {
  func configureSaveWatchPrelaunchProject(with: PledgeCTAPrelaunchState)
  func configureSharing(with context: ShareContext)
  func configureWatchProject(with context: WatchProjectValue)
  func viewDidLoad()
}

private enum Layout {
  enum Button {
    static let height: CGFloat = 15
  }
}

final class ProjectPageNavigation {
  var leftBarButtonItem: UIBarButtonItem {
    guard let icon = Library.image(named: "icon--cross") else {
      return UIBarButtonItem()
    }

    return UIBarButtonItem(
      image: icon.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: self,
      action: #selector(ProjectPageNavigation.closeButtonTapped)
    )
  }

  var rightBarButtonItems: [UIBarButtonItem] {
    let share = UIBarButtonItem(customView: self.navigationShareButton)
    let save = UIBarButtonItem(customView: self.navigationSaveButton)

    if #available(iOS 26.0, *) {
      share.hidesSharedBackground = true
      save.hidesSharedBackground = true
    }

    return [share, save]
  }

  // MARK: - Properties

  private let shareViewModel: ShareViewModelType = ShareViewModel()
  private let watchProjectViewModel: WatchProjectViewModelType = WatchProjectViewModel()

  private lazy var navigationShareButton: UIButton = { UIButton(type: .custom) }()

  private lazy var navigationCloseButton: CloseButtonView = {
    let closeButton = CloseButtonView { [weak self] in
      self?.closeButtonTapped()
    }
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    return closeButton
  }()

  private lazy var navigationSaveButton: UIButton = { UIButton(type: .custom) }()

  weak var delegate: ProjectPageViewControllerDelegate?

  // MARK: - Lifecycle

  init() {
    self.configureSubviews()
    self.bindStyles()
    self.setupNotifications()
    self.bindViewModel()
  }

  // MARK: - Styles

  func bindStyles() {
    _ = self.navigationShareButton
      |> shareButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }

    styleSaveButton(self.navigationSaveButton)
    self.navigationSaveButton.accessibilityLabel = Strings.Toggle_saving_this_project()
  }

  // MARK: - View Model

  func bindViewModel() {
    self.bindSharingViewModel()
    self.bindWatchViewModel()
  }

  private func bindSharingViewModel() {
    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] controller, _ in
        self?.delegate?.showShareSheet(controller, sourceView: self?.navigationShareButton)
      }
  }

  private func bindWatchViewModel() {
    self.navigationSaveButton.rac.accessibilityValue = self.watchProjectViewModel.outputs
      .saveButtonAccessibilityValue
    self.navigationSaveButton.rac.selected = self.watchProjectViewModel.outputs.saveButtonSelected

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
        self?.delegate?.displayProjectStarredPrompt()
      }

    self.watchProjectViewModel.outputs.goToLoginTout
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.delegate?.goToLogin()
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
  }

  // MARK: Helpers

  private func setupNotifications() {
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ProjectPageNavigation.userSessionStarted),
        name: .ksr_sessionStarted,
        object: nil
      )

    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ProjectPageNavigation.userSessionEnded),
        name: .ksr_sessionEnded,
        object: nil
      )
  }

  private func configureSubviews() {
    self.addTargetAction(
      buttonItem: self.navigationShareButton,
      targetAction: #selector(ProjectPageNavigation.shareButtonTapped),
      event: .touchUpInside
    )
    self.addTargetAction(
      buttonItem: self.navigationSaveButton,
      targetAction: #selector(ProjectPageNavigation.saveButtonTapped(_:)),
      event: .touchUpInside
    )
    self.addTargetAction(
      buttonItem: self.navigationSaveButton,
      targetAction: #selector(ProjectPageNavigation.saveButtonPressed),
      event: .touchDown
    )
  }

  private func addTargetAction(
    buttonItem: UIButton,
    targetAction: Selector,
    event: UIControl.Event
  ) {
    buttonItem.addTarget(
      self,
      action: targetAction,
      for: event
    )
  }

  // MARK: Selectors

  @objc private func shareButtonTapped() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc private func userSessionStarted() {
    self.watchProjectViewModel.inputs.userSessionStarted()
  }

  @objc private func userSessionEnded() {
    self.watchProjectViewModel.inputs.userSessionEnded()
  }

  @objc private func closeButtonTapped() {
    self.delegate?.dismissPage(animated: true, completion: nil)
  }

  @objc private func saveButtonTapped(_ button: UIButton) {
    self.watchProjectViewModel.inputs.saveButtonTapped(selected: button.isSelected)
  }

  @objc private func saveButtonPressed() {
    self.watchProjectViewModel.inputs.saveButtonTouched()
  }
}

extension ProjectPageNavigation: ProjectPageNavigationBarViewDelegate {
  func viewDidLoad() {
    self.watchProjectViewModel.inputs.viewDidLoad()
  }

  func configureSharing(with context: ShareContext) {
    self.shareViewModel.inputs.configureWith(shareContext: context, shareContextView: nil)
  }

  func configureWatchProject(with context: WatchProjectValue) {
    self.watchProjectViewModel.inputs
      .configure(with: context)
  }

  func configureSaveWatchPrelaunchProject(with context: PledgeCTAPrelaunchState) {
    self.watchProjectViewModel.inputs.saveButtonTapped(selected: context.saved)
  }
}
