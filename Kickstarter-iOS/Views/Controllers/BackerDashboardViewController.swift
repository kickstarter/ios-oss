import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardViewController: UIViewController {

  @IBOutlet private weak var avatarImageView: CircleAvatarImageView!
  @IBOutlet private weak var backedMenuButton: UIButton!
  @IBOutlet private weak var backerNameLabel: UILabel!
  @IBOutlet private weak var dividerView: UIView!
  @IBOutlet private weak var embeddedViewTopLayoutConstraint: NSLayoutConstraint!
  @IBOutlet private weak var headerTopContainerView: UIView!
  @IBOutlet private weak var headerStackView: UIStackView!
  @IBOutlet private weak var headerView: UIView!
  @IBOutlet private weak var headerViewTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var menuButtonsStackView: UIStackView!
  @IBOutlet private weak var messagesButtonItem: UIBarButtonItem!
  @IBOutlet private weak var savedMenuButton: UIButton!
  @IBOutlet private weak var selectedButtonIndicatorLeadingConstraint: NSLayoutConstraint!
  @IBOutlet private weak var selectedButtonIndicatorView: UIView!
  @IBOutlet private weak var selectedButtonIndicatorWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var settingsButtonItem: UIBarButtonItem!
  @IBOutlet private weak var sortBar: ProfileSortBarView!
  @IBOutlet private weak var topBackgroundView: UIView!

  fileprivate weak var pageViewController: UIPageViewController!

  fileprivate let viewModel: BackerDashboardViewModelType = BackerDashboardViewModel()
  fileprivate var pagesDataSource: BackerDashboardPagesDataSource!

  private var panGesture = UIPanGestureRecognizer()

  internal static func instantiate() -> BackerDashboardViewController {
    return Storyboard.BackerDashboard.instantiate(BackerDashboardViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.pageViewController = self.childViewControllers
      .compactMap { $0 as? UIPageViewController }.first
    self.pageViewController.setViewControllers(
      [.init()],
      direction: .forward,
      animated: false,
      completion: nil
    )
    self.pageViewController.delegate = self

    _ = self.backedMenuButton
      |> UIButton.lens.targets .~ [(self, action: #selector(backedButtonTapped), .touchUpInside)]

    _ = self.savedMenuButton
      |> UIButton.lens.targets .~ [(self, action: #selector(savedButtonTapped), .touchUpInside)]

    _ = self.messagesButtonItem
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(messagesButtonTapped))

    _ = self.settingsButtonItem
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(settingsButtonTapped))

    panGesture.addTarget(self, action: #selector(handlePan))
    panGesture.delegate = self
    self.view.addGestureRecognizer(panGesture)

    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureNotifier))
    self.pageViewController.view.addGestureRecognizer(tapRecognizer)

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.avatarImageView.rac.imageUrl = self.viewModel.outputs.avatarURL
    self.backerNameLabel.rac.text = self.viewModel.outputs.backerNameText
    self.embeddedViewTopLayoutConstraint.rac.constant =
      self.viewModel.outputs.embeddedViewTopConstraintConstant
    self.sortBar.rac.hidden = self.viewModel.outputs.sortBarIsHidden

    self.viewModel.outputs.backedButtonTitleText
      .observeForUI()
      .observeValues { [weak self] string in
        guard let _self = self else { return }
        _self.setAttributedTitles(for: _self.backedMenuButton, with: string)
    }

    self.viewModel.outputs.configurePagesDataSource
      .observeForControllerAction()
      .observeValues { [weak self] tab, sort in
        self?.configurePagesDataSource(tab: tab, sort: sort)
    }

    self.viewModel.outputs.savedButtonTitleText
      .observeForUI()
      .observeValues { [weak self] string in
        guard let _self = self else { return }
        _self.setAttributedTitles(for: _self.savedMenuButton, with: string)
    }

    self.viewModel.outputs.goToMessages
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        guard let _self = self else { return }
        let vc = MessageThreadsViewController.configuredWith(project: nil, refTag: .profile)
        _self.navigationController?.pushViewController(vc, animated: true)
    }

    self.viewModel.outputs.goToSettings
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        self?.goToSettings()
    }

    self.viewModel.outputs.navigateToTab
      .observeForControllerAction()
      .observeValues { [weak self] tab in
        guard let _self = self, let controller = self?.pagesDataSource.controllerFor(tab: tab) else {
          fatalError("Controller not found for tab \(tab)")
        }
        _self.pageViewController.setViewControllers(
          [controller],
          direction: .forward,
          animated: false,
          completion: nil
        )
    }

    self.viewModel.outputs.pinSelectedIndicatorToTab
      .observeForUI()
      .observeValues { [weak self] tab, animated in
        self?.pinSelectedIndicator(to: tab, animated: animated)
    }

    self.viewModel.outputs.postNotification
      .observeForUI()
      .observeValues(NotificationCenter.default.post)

    self.viewModel.outputs.setSelectedButton
      .observeForUI()
      .observeValues { [weak self] in
        self?.selectButton(atTab: $0)
    }

    self.viewModel.outputs.updateCurrentUserInEnvironment
      .observeForUI()
      .observeValues { [weak self] user in
        AppEnvironment.updateCurrentUser(user)
        self?.viewModel.inputs.currentUserUpdatedInEnvironment()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self |> baseControllerStyle()

    _ = self.navigationItem
      |> UINavigationItem.lens.title %~ { _ in Strings.tabbar_profile() }

        _ = self.messagesButtonItem
      |> UIBarButtonItem.lens.image .~ image(named: "inbox-icon")
      |> UIBarButtonItem.lens.accessibilityLabel %~ { _ in Strings.profile_buttons_messages() }

    _ = self.settingsButtonItem
      |> UIBarButtonItem.lens.image .~ image(named: "settings-icon")
      |> UIBarButtonItem.lens.accessibilityLabel %~ { _ in Strings.profile_settings_navbar_title() }

    _ = self.dividerView
      |> UIView.lens.backgroundColor .~ .ksr_grey_500

    _ = self.headerStackView
      |> UIView.lens.layoutMargins %~~ { _, view in
        view.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(2), leftRight: Styles.grid(20))
          : .init(top: Styles.grid(5), left: Styles.grid(2), bottom: 0.0, right: Styles.grid(2))
    }

    _ = self.backerNameLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ .ksr_headline(size: 18)
  }

  private func configurePagesDataSource(tab: BackerDashboardTab, sort: DiscoveryParams.Sort) {
    self.pagesDataSource = BackerDashboardPagesDataSource(delegate: self, sort: sort)

    self.pageViewController.dataSource = self.pagesDataSource
    self.pageViewController.setViewControllers(
      [self.pagesDataSource.controllerFor(tab: tab)].compact(),
      direction: .forward,
      animated: false,
      completion: nil
    )
  }

  private func setAttributedTitles(for button: UIButton, with string: String) {
    let normalTitleString = NSAttributedString(string: string, attributes: [
      NSAttributedStringKey.font: self.traitCollection.isRegularRegular
        ? UIFont.ksr_headline(size: 16.0)
        : UIFont.ksr_headline(size: 13.0),
      NSAttributedStringKey.foregroundColor: UIColor.ksr_text_dark_grey_500
      ])

    let selectedTitleString = NSAttributedString(string: string, attributes: [
      NSAttributedStringKey.font: self.traitCollection.isRegularRegular
        ? UIFont.ksr_headline(size: 16.0)
        : UIFont.ksr_headline(size: 13.0),
      NSAttributedStringKey.foregroundColor: UIColor.ksr_dark_grey_900
      ])

    _ = button
      |> UIButton.lens.attributedTitle(for: .normal) %~ { _ in normalTitleString }
      |> UIButton.lens.attributedTitle(for: .selected) %~ { _ in selectedTitleString }
      |> (UIButton.lens.titleLabel..UILabel.lens.lineBreakMode) .~ .byWordWrapping
  }

  private func selectButton(atTab tab: BackerDashboardTab) {
    guard let index = self.pagesDataSource.indexFor(tab: tab) else { return }

    for (idx, button) in self.menuButtonsStackView.arrangedSubviews.enumerated() {
      _ = (button as? UIButton)
        ?|> UIButton.lens.isSelected .~ (idx == index)
    }
  }

  private func pinSelectedIndicator(to tab: BackerDashboardTab, animated: Bool) {
    guard let index = self.pagesDataSource.indexFor(tab: tab) else { return }
    guard let button = self.menuButtonsStackView.arrangedSubviews[index] as? UIButton else { return }

    let leadingConstant = button.frame.origin.x + Styles.grid(1)
    let widthConstant = button.titleLabel?.frame.size.width ?? button.frame.size.width

    UIView.animate(
      withDuration: animated ? 0.2 : 0.0,
      delay: 0.0,
      options: .curveEaseOut,
      animations: {
        self.headerView.setNeedsLayout()
        self.selectedButtonIndicatorLeadingConstraint.constant = leadingConstant
        self.selectedButtonIndicatorWidthConstraint.constant = widthConstant
        self.headerView.layoutIfNeeded()
      },
      completion: nil)
  }

  private func goToSettings() {
    let vc = SettingsViewController.instantiate()

    if UIDevice.current.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .formSheet
      self.present(nav, animated: true, completion: nil)
    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  @objc private func tapGestureNotifier() {
    NotificationCenter.default.post(name: Notification.Name.ksr_savedProjectEmptyStateTapped, object: nil)
  }

  @objc private func messagesButtonTapped() {
    self.viewModel.inputs.messagesButtonTapped()
  }

  @objc private func settingsButtonTapped() {
    fatalError("Test crash")
//    self.viewModel.inputs.settingsButtonTapped()
  }

  @objc private func backedButtonTapped() {
    self.viewModel.inputs.backedProjectsButtonTapped()
  }

  @objc private func savedButtonTapped() {
    self.viewModel.inputs.savedProjectsButtonTapped()
  }

  @objc private func handlePan(gesture: UIPanGestureRecognizer) {
    let selectedTab = self.viewModel.outputs.currentSelectedTab
    guard let controller = self.pagesDataSource.controllerFor(tab: selectedTab) as?
      BackerDashboardProjectsViewController else { return }

    let minHeaderHeight = self.topBackgroundView.frame.size.height
      - self.menuButtonsStackView.frame.size.height - Styles.grid(3)

    switch gesture.state {
    case .began:
      self.viewModel.inputs.beganPanGestureWith(headerTopConstant: self.headerViewTopConstraint.constant,
                                                scrollViewYOffset: controller.tableView.contentOffset.y)
    case.changed:
      let translation = gesture.translation(in: self.view)
      let newConstant = min(0.0, self.viewModel.outputs.initialTopConstant + translation.y)

      if newConstant >= -minHeaderHeight {
        self.headerViewTopConstraint.constant = newConstant
      }

    case .ended:
      let shouldCollapse = self.headerViewTopConstraint.constant < (-minHeaderHeight / 2.0)

      if shouldCollapse {
        UIView.animate(
          withDuration: 0.3,
          delay: 0.0,
          options: .curveEaseOut,
          animations: {
            self.headerViewTopConstraint.constant = -minHeaderHeight
            self.view.layoutIfNeeded()
        },
          completion: nil)
      } else {
        UIView.animate(
          withDuration: 0.3,
          delay: 0.0,
          options: .curveEaseOut,
          animations: {
            self.headerViewTopConstraint.constant = 0.0
            self.view.layoutIfNeeded()
        },
          completion: nil)
      }
    default: ()
    }
  }
}

extension BackerDashboardViewController: UIPageViewControllerDelegate {
  internal func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {

    self.viewModel.inputs.pageTransition(completed: completed)
  }

  internal func pageViewController(
    _ pageViewController: UIPageViewController,
    willTransitionTo pendingViewControllers: [UIViewController]) {

    guard let idx = pendingViewControllers.first.flatMap(self.pagesDataSource.indexFor(controller:)) else {
      return
    }

    self.viewModel.inputs.willTransition(toPage: idx)
  }
}

extension BackerDashboardViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return false }

    let translation = gestureRecognizer.translation(in: self.view)
    if translation.x != 0 { // only respond to horizontal movement.
      return false
    }

    return true
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool {
      return true
  }
}
