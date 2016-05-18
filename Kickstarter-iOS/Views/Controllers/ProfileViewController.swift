import UIKit
import Library
import Models

internal final class ProfileViewController: UICollectionViewController {
  private let dataSource = ProfileDataSource()
  private let viewModel: ProfileViewModelType = ProfileViewModel()
  private let refreshControl = UIRefreshControl()

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView?.dataSource = self.dataSource
    self.collectionView?.backgroundColor = Color.OffWhite.toUIColor()

    if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.itemSize = CGSize(width: 160, height: 220)
    }

    self.refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
    self.collectionView?.addSubview(refreshControl)
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.viewWillAppear()
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.backedProjects
      .observeForUI()
      .observeNext { [weak self] ps in
        self?.dataSource.load(projects: ps)
        self?.collectionView?.reloadData()
      }

    self.viewModel.outputs.user
      .observeForUI()
      .observeNext { [weak self] u in
        self?.dataSource.load(user: u)
        self?.collectionView?.reloadData()
    }

    self.viewModel.outputs.endRefreshing
      .observeForUI()
      .observeNext { [weak self] in
        self?.refreshControl.endRefreshing()
    }

    self.viewModel.outputs.goToProject
      .observeForUI()
      .observeNext { [weak self] project, refTag in
        self?.present(project: project, refTag: refTag)
    }

    self.viewModel.outputs.showEmptyState
      .observeForUI()
      .observeNext { [weak self] visible in
        self?.dataSource.emptyState(visible: visible)
        self?.collectionView?.reloadData()
    }
  }

  @IBAction internal func logoutPressed() {
    AppEnvironment.logout()
    NSNotificationCenter.defaultCenter().postNotification(
      NSNotification(name: CurrentUserNotifications.sessionEnded, object: nil)
    )
  }

  @IBAction private func messagesButtonPressed() {
    guard let vc = UIStoryboard(name: "Messages", bundle: nil).instantiateInitialViewController(),
      messages = vc as? MessageThreadsViewController else {
        fatalError("Cold not instantiate ProjectViewController")
    }

    messages.configureWith(project: nil)
    self.navigationController?.pushViewController(messages, animated: true)
  }

  internal override func collectionView(collectionView: UICollectionView,
                                        didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let project = self.dataSource[indexPath] as? Project {
      self.viewModel.inputs.projectPressed(project)
    }
  }

  private func present(project project: Project, refTag: RefTag) {
    guard let vc = UIStoryboard(name: "Project", bundle: nil).instantiateInitialViewController()
      as? ProjectViewController else {
        fatalError("Cold not instantiate ProjectViewController")
    }

    vc.configureWith(project: project, refTag: refTag)
    self.presentViewController(UINavigationController(rootViewController: vc),
                               animated: true,
                               completion: nil)
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
