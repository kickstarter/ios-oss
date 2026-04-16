import KDS
import KsApi
import Library
import UIKit

protocol ProjectPageNavigationDelegate: AnyObject {
  func dismissPage(animated: Bool, completion: (() -> Void)?)
  func goToLogin()
  func displayProjectStarredPrompt()
  func showShareSheet(_ controller: UIActivityViewController, sourceView: UIView?)
}

/// The project page used to have a custom navigation bar; this class was originally `ProjectPageNavigationBarView`.
/// When I cleaned up the custom navigation bar, I decided it made sense to keep the class -
/// there's plenty of complex behavior in here, so it's nice to keep it wrapped up in one place.
final class ProjectPageNavigation {
  // MARK: - Public properties

  var closeButton: UIBarButtonItem {
    guard let icon = Library.image(named: "icon--cross") else {
      return UIBarButtonItem()
    }

    return UIBarButtonItem(
      image: icon.withRenderingMode(.alwaysOriginal), // We want it to be black, not tinted
      style: .plain,
      target: self,
      action: #selector(ProjectPageNavigation.closeButtonTapped)
    )
  }

  var rightBarButtonItems: [UIBarButtonItem] {
    let share = UIBarButtonItem(customView: self.navigationShareButton)
    let save = UIBarButtonItem(customView: self.navigationSaveButton)

    let spacer = UIBarButtonItem.fixedSpace(Spacing.unit_06)

    if #available(iOS 26.0, *) {
      share.hidesSharedBackground = true
      save.hidesSharedBackground = true
    }

    return [save, spacer, share]
  }

  weak var delegate: ProjectPageNavigationDelegate?

  // MARK: - Private properties

  private let shareViewModel: ShareViewModelType = ShareViewModel()
  private let watchProjectViewModel: WatchProjectViewModelType = WatchProjectViewModel()

  private lazy var navigationShareButton: UIButton = { UIButton(type: .custom) }()
  private lazy var navigationSaveButton: UIButton = { UIButton(type: .custom) }()

  // MARK: - Lifecycle

  init() {
    self.configureButtons()
    self.styleButtons()
    self.setupNotifications()
    self.bindViewModel()
  }

  // MARK: - Styles

  func styleButtons() {
    styleShareButton(self.navigationShareButton)
    self.navigationShareButton.accessibilityLabel = Strings.dashboard_accessibility_label_share_project()

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

  private func configureButtons() {
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

  // MARK: Inputs

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

private enum Layout {
  enum Button {
    static let height: CGFloat = 15
  }
}

extension UINavigationBarAppearance {
  static var projectPageNavigationBarAppearance: UINavigationBarAppearance {
    let appearance = UINavigationBarAppearance()
    // On iOS 18, if we don't set the color explicitly, it's slight off from the white we want.
    appearance.backgroundColor = Colors.Background.Surface.primary.uiColor()
    // Hide the nav bar shadow, so it blends in with the project page tabs below.
    appearance.shadowColor = Colors.Background.Surface.primary.uiColor()
    return appearance
  }
}
