import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardViewController: UIViewController {

  @IBOutlet private weak var avatarImageView: CircleAvatarImageView!
  @IBOutlet private weak var backedMenuButton: UIButton!
  @IBOutlet private weak var backerNameLabel: UILabel!
  @IBOutlet private weak var backerLocationLabel: UILabel!
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

  internal static func instantiate() -> BackerDashboardViewController {
    return Storyboard.BackerDashboard.instantiate(BackerDashboardViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.pageViewController = self.childViewControllers
      .flatMap { $0 as? UIPageViewController }.first
    self.pageViewController.delegate = self

    _ = self.backedMenuButton
      |> UIButton.lens.targets .~ [(self, action: #selector(backedButtonTapped), .touchUpInside)]

    _ = self.savedMenuButton
      |> UIButton.lens.targets .~ [(self, action: #selector(savedButtonTapped), .touchUpInside)]

    _ = self.messagesButtonItem
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(messagesButtonTapped))

    _ = self.settingsButtonItem
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(settingsButtonTapped))

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    self.viewModel.inputs.viewWillAppear(animated)
  }

  // swiftlint:disable:next function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.avatarImageView.rac.imageUrl = self.viewModel.outputs.avatarURL
    self.backerNameLabel.rac.text = self.viewModel.outputs.backerNameText
    self.backerLocationLabel.rac.text = self.viewModel.outputs.backerLocationText
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
        let vc = MessageThreadsViewController.configuredWith(project: nil)
        _self.navigationController?.pushViewController(vc, animated: true)
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] project, projects, refTag in
        self?.present(project: project, projects: projects, refTag: refTag)
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

    self.viewModel.outputs.setSelectedButton
      .observeForUI()
      .observeValues { [weak self] in
        self?.selectButton(atTab: $0)
    }

    self.viewModel.outputs.updateProjectPlaylist
      .observeForUI()
      .observeValues { [weak self] in
        self?.updateProjectPlaylist($0)
    }

    self.viewModel.outputs.notifyPageToScrollToProject
      .observeForUI()
      .observeValues { [weak self] row in
        guard let controller = self?.pageViewController.childViewControllers.first
          else { return }

        self?.pagesDataSource.scrollToProject(at: row, in: controller)
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
      |> UILabel.lens.textColor .~ .black
      |> UILabel.lens.font .~ .ksr_headline(size: 18)

    _ = self.backerLocationLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_600
      |> UILabel.lens.font .~ .ksr_subhead(size: 14)
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

  private func present(project: Project, projects: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: projects,
                                                           navigatorDelegate: self)
    self.present(vc, animated: true, completion: nil)
  }

  private func updateProjectPlaylist(_ playlist: [Project]) {
    guard let navigator = self.presentedViewController as? ProjectNavigatorViewController else { return }
    navigator.updatePlaylist(playlist)
  }

  private func setAttributedTitles(for button: UIButton, with string: String) {
    let normalTitleString = NSAttributedString(string: string, attributes: [
      NSFontAttributeName: self.traitCollection.isRegularRegular
        ? UIFont.ksr_headline(size: 16.0)
        : UIFont.ksr_headline(size: 13.0),
      NSForegroundColorAttributeName: UIColor.ksr_text_navy_500
    ])

    let selectedTitleString = NSAttributedString(string: string, attributes: [
      NSFontAttributeName: self.traitCollection.isRegularRegular
        ? UIFont.ksr_headline(size: 16.0)
        : UIFont.ksr_headline(size: 13.0),
      NSForegroundColorAttributeName: UIColor.black
    ])

    _ = button
      |> UIButton.lens.attributedTitle(forState: .normal) %~ { _ in normalTitleString }
      |> UIButton.lens.attributedTitle(forState: .selected) %~ { _ in selectedTitleString }
      |> (UIButton.lens.titleLabel • UILabel.lens.lineBreakMode) .~ .byWordWrapping
  }

  private func selectButton(atTab tab: BackerDashboardTab) {
    for (idx, button) in self.menuButtonsStackView.arrangedSubviews.enumerated() {
      _ = (button as? UIButton)
        ?|> UIButton.lens.selected .~ (idx == tab.rawValue)
    }
  }

  private func pinSelectedIndicator(to tab: BackerDashboardTab, animated: Bool) {
    guard let button = self.menuButtonsStackView.arrangedSubviews[tab.rawValue] as? UIButton else { return }

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

  @objc private func messagesButtonTapped() {
    self.viewModel.inputs.messagesButtonTapped()
  }

  @objc private func settingsButtonTapped() {
    self.viewModel.inputs.settingsButtonTapped()
  }

  @objc private func backedButtonTapped() {
    self.viewModel.inputs.backedProjectsButtonTapped()
  }

  @objc private func savedButtonTapped() {
    self.viewModel.inputs.savedProjectsButtonTapped()
  }
}

extension BackerDashboardViewController: UIPageViewControllerDelegate {}

extension BackerDashboardViewController: BackerDashboardProjectsViewControllerDelegate {
  func profileProjectsGoToProject(_ project: Project, projects: [Project], reftag: RefTag) {
    self.viewModel.inputs.profileProjectsGoToProject(project, projects: projects, reftag: reftag)
  }

  func profileProjectsUpdatePlaylist(_ projects: [Project]) {
    self.viewModel.inputs.profileProjectsUpdatePlaylist(projects)
  }
}

extension BackerDashboardViewController: ProjectNavigatorDelegate {
  func transitionedToProject(at index: Int) {
    self.viewModel.inputs.transitionedToProject(at: index)
  }
}
