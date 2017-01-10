import KsApi
import Library
import Prelude
import UIKit

internal final class ProfileViewController: UICollectionViewController {
  @IBOutlet fileprivate weak var messagesButton: UIBarButtonItem!
  @IBOutlet fileprivate weak var settingsButton: UIBarButtonItem!

  fileprivate let dataSource = ProfileDataSource()
  fileprivate let viewModel: ProfileViewModelType = ProfileViewModel()
  fileprivate let refreshControl = UIRefreshControl()

  internal static func instantiate() -> ProfileViewController {
    return Storyboard.Profile.instantiate(ProfileViewController.self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView?.dataSource = self.dataSource
    self.collectionView?.backgroundColor = .ksr_grey_100

    if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.itemSize = CGSize(width: 178, height: 220)
    }

    self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    self.collectionView?.addSubview(refreshControl)
  }

  internal override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear(animated)
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.backedProjects
      .observeForUI()
      .observeValues { [weak self] ps in
        self?.dataSource.load(projects: ps)
        self?.collectionView?.reloadData()
      }

    self.viewModel.outputs.user
      .observeForUI()
      .observeValues { [weak self] u in
        self?.dataSource.load(user: u)
        self?.collectionView?.reloadData()
    }

    self.refreshControl.rac.refreshing = self.viewModel.outputs.isRefreshing

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

    self.viewModel.outputs.showEmptyState
      .observeForUI()
      .observeValues { [weak self] visible in
        self?.dataSource.emptyState(visible: visible)
        self?.collectionView?.reloadData()
    }
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.messagesButton
      |> UIBarButtonItem.lens.title %~ { _ in Strings.profile_buttons_messages() }

    _ = self.navigationController?.navigationBar
      ?|> baseNavigationBarStyle

    _ = self.navigationItem
      |> UINavigationItem.lens.title %~ { _ in Strings.tabbar_profile() }

    _ = self.settingsButton
      |> UIBarButtonItem.lens.title %~ { _ in Strings.profile_settings_navbar_title() }
  }

  @IBAction fileprivate func settingsTapped() {
    self.viewModel.inputs.settingsButtonTapped()
  }

  @IBAction fileprivate func messagesButtonTapped() {
    let vc = MessageThreadsViewController.configuredWith(project: nil)
    self.navigationController?.pushViewController(vc, animated: true)
  }

  internal override func collectionView(_ collectionView: UICollectionView,
                                        didSelectItemAt indexPath: IndexPath) {
    if let project = self.dataSource[indexPath] as? Project {
      self.viewModel.inputs.projectTapped(project)
    }
  }

  fileprivate func goToSettings() {
    let vc = SettingsViewController.instantiate()

    if UIDevice.current.userInterfaceIdiom == .pad {
      let nav = UINavigationController(rootViewController: vc)
      nav.modalPresentationStyle = .formSheet
      self.present(nav, animated: true, completion: nil)

    } else {
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }

  fileprivate func present(project: Project, projects: [Project], refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project,
                                                           refTag: refTag,
                                                           initialPlaylist: projects,
                                                           navigatorDelegate: self)
    self.present(vc, animated: true, completion: nil)
  }

  internal override func collectionView(_ collectionView: UICollectionView,
                                        willDisplay cell: UICollectionViewCell,
                                        forItemAt indexPath: IndexPath) {
    self.viewModel.inputs.willDisplayRow(self.dataSource.itemIndexAt(indexPath),
                                         outOf: self.dataSource.numberOfItems())

  }

  internal override func collectionView(_ collectionView: UICollectionView,
                                        viewForSupplementaryElementOfKind kind: String,
                                        at indexPath: IndexPath) -> UICollectionReusableView {
    return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                 withReuseIdentifier: "Header",
                                                                 for: indexPath)
  }

  @objc fileprivate func refresh() {
    self.viewModel.inputs.refresh()
  }
}

extension ProfileViewController: ProjectNavigatorDelegate {
}
