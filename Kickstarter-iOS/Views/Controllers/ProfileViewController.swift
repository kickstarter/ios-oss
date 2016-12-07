import KsApi
import Library
import Prelude
import UIKit

internal final class ProfileViewController: UICollectionViewController {
  @IBOutlet private weak var messagesButton: UIBarButtonItem!
  @IBOutlet private weak var settingsButton: UIBarButtonItem!

  private let dataSource = ProfileDataSource()
  private let viewModel: ProfileViewModelType = ProfileViewModel()
  private let refreshControl = UIRefreshControl()

  internal static func instantiate() -> ProfileViewController {
    return Storyboard.Profile.instantiate(ProfileViewController)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView?.dataSource = self.dataSource
    self.collectionView?.backgroundColor = .ksr_grey_100

    if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.itemSize = CGSize(width: 160, height: 220)
    }

    self.refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
    self.collectionView?.addSubview(refreshControl)
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.backedProjects
      .observeForControllerAction()
      .observeNext { [weak self] ps in
        self?.dataSource.load(projects: ps)
        self?.collectionView?.reloadData()
      }

    self.viewModel.outputs.user
      .observeForControllerAction()
      .observeNext { [weak self] u in
        self?.dataSource.load(user: u)
        self?.collectionView?.reloadData()
    }

    self.viewModel.outputs.endRefreshing
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.refreshControl.endRefreshing()
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeNext { [weak self] project, projects, refTag in
        self?.present(project: project, projects: projects, refTag: refTag)
    }

    self.viewModel.outputs.goToSettings
      .observeForControllerAction()
      .observeNext { [weak self] _ in
        self?.goToSettings()
    }

    self.viewModel.outputs.showEmptyState
      .observeForControllerAction()
      .observeNext { [weak self] visible in
        self?.dataSource.emptyState(visible: visible)
        self?.collectionView?.reloadData()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.messagesButton
      |> UIBarButtonItem.lens.title %~ { _ in Strings.profile_buttons_messages() }

    self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle

    self.navigationItem
      |> UINavigationItem.lens.title %~ { _ in Strings.tabbar_profile() }

    self.settingsButton
      |> UIBarButtonItem.lens.title %~ { _ in Strings.profile_settings_navbar_title() }
  }

  @IBAction private func settingsTapped() {
    self.viewModel.inputs.settingsButtonTapped()
  }

  @IBAction private func messagesButtonTapped() {
    let vc = MessageThreadsViewController.configuredWith(project: nil)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal override func collectionView(collectionView: UICollectionView,
                                        didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let project = self.dataSource[indexPath] as? Project {
      self.viewModel.inputs.projectTapped(project)
    }
  }

  private func goToSettings() {
    let vc = SettingsViewController.instantiate()

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .FormSheet
      self.presentViewController(nav, animated: true, completion: nil)

    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  private func present(project project: Project, projects: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: projects,
                                                           navigatorDelegate: self)
    self.presentViewController(vc, animated: true, completion: nil)
  }

  internal override func collectionView(collectionView: UICollectionView,
                                        willDisplayCell cell: UICollectionViewCell,
                                        forItemAtIndexPath indexPath: NSIndexPath) {
    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())

  }

  internal override func collectionView(collectionView: UICollectionView,
                                        viewForSupplementaryElementOfKind kind: String,
                                        atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    return collectionView.dequeueReusableSupplementaryViewOfKind(kind,
                                                                 withReuseIdentifier: "Header",
                                                                 forIndexPath: indexPath)
  }

  @objc private func refresh() {
    self.viewModel.inputs.refresh()
  }
}

extension ProfileViewController: ProjectNavigatorDelegate {
}
