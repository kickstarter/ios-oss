import KsApi
import Library
import PassKit
import Prelude
import UIKit

protocol ProjectPageNavigationBarViewDelegate: AnyObject {
  func configureSharing(with context: ShareContext)
  func configureWatchProject(with context: WatchProjectValue)
  func viewDidLoad()
}

private enum Layout {
  enum Button {
    static let height: CGFloat = 15
  }
}

final class ProjectPageNavigationBarView: UIView {
  // MARK: - Properties

  private let shareViewModel: ShareViewModelType = ShareViewModel()
  private let watchProjectViewModel: WatchProjectViewModelType = WatchProjectViewModel()

  private lazy var navigationShareButton: UIButton = { UIButton(type: .custom) }()

  private lazy var navigationCloseButton: UIButton = {
    let buttonView = UIButton(type: .custom)
      |> UIButton.lens.title(for: .normal) .~ nil
      |> UIButton.lens.image(for: .normal) .~ image(named: "icon--cross")
      |> UIButton.lens.tintColor .~ .ksr_support_700
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.accessibility_projects_buttons_close() }
      |> UIButton.lens.accessibilityHint %~ { _ in Strings.Closes_project() }

    return buttonView
  }()

  private lazy var navigationSaveButton: UIButton = { UIButton(type: .custom) }()

  private lazy var rootStackView: UIStackView = {
    UIStackView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  private lazy var spacer: UIView = {
    UIView(frame: .zero)
      |> \.translatesAutoresizingMaskIntoConstraints .~ false
  }()

  weak var delegate: ProjectPageViewControllerDelegate?

  // MARK: - Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.configureSubviews()
    self.setupConstraints()
    self.setupNotifications()
    self.bindViewModel()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Styles

  override func bindStyles() {
    super.bindStyles()

    _ = self |> \.backgroundColor .~ .ksr_white

    _ = self.rootStackView
      |> \.isLayoutMarginsRelativeArrangement .~ true
      |> \.insetsLayoutMarginsFromSafeArea .~ true
      |> \.spacing .~ Styles.grid(0)

    _ = self.navigationShareButton
      |> shareButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.dashboard_accessibility_label_share_project() }

    _ = self.navigationSaveButton
      |> saveButtonStyle
      |> UIButton.lens.accessibilityLabel %~ { _ in Strings.Toggle_saving_this_project() }
  }

  // MARK: - View Model

  override func bindViewModel() {
    super.bindViewModel()

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

  private func setupConstraints() {
    _ = (self.rootStackView, self)
      |> ksr_addSubviewToParent()
      |> ksr_constrainViewToEdgesInParent()

    _ = (
      [
        self.navigationCloseButton,
        self.spacer,
        self.navigationShareButton,
        self.navigationSaveButton
      ],
      self.rootStackView
    )
      |> ksr_addArrangedSubviewsToStackView()

    NSLayoutConstraint
      .activate([
        self.navigationShareButton.widthAnchor
          .constraint(equalTo: self.navigationShareButton.heightAnchor),
        self.navigationSaveButton.widthAnchor
          .constraint(equalTo: self.navigationSaveButton.heightAnchor),
        self.navigationCloseButton.widthAnchor
          .constraint(equalTo: self.navigationCloseButton.heightAnchor)
      ])
  }

  private func setupNotifications() {
    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ProjectPageNavigationBarView.userSessionStarted),
        name: .ksr_sessionStarted,
        object: nil
      )

    NotificationCenter.default
      .addObserver(
        self,
        selector: #selector(ProjectPageNavigationBarView.userSessionEnded),
        name: .ksr_sessionEnded,
        object: nil
      )
  }

  private func configureSubviews() {
    self.addTargetAction(
      buttonItem: self.navigationCloseButton,
      targetAction: #selector(ProjectPageNavigationBarView.closeButtonTapped),
      event: .touchUpInside
    )
    self.addTargetAction(
      buttonItem: self.navigationShareButton,
      targetAction: #selector(ProjectPageNavigationBarView.shareButtonTapped),
      event: .touchUpInside
    )
    self.addTargetAction(
      buttonItem: self.navigationSaveButton,
      targetAction: #selector(ProjectPageNavigationBarView.saveButtonTapped(_:)),
      event: .touchUpInside
    )
    self.addTargetAction(
      buttonItem: self.navigationSaveButton,
      targetAction: #selector(ProjectPageNavigationBarView.saveButtonPressed),
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

extension ProjectPageNavigationBarView: ProjectPageNavigationBarViewDelegate {
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
}
