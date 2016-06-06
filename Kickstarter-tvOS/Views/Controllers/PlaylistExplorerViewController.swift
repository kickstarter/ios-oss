import UIKit
import KsApi
import Library

protocol PlaylistExplorerDelegate: class {
  func playlistExplorerWantsToClose(controller: PlaylistExplorerViewController)
}

class PlaylistExplorerViewController: UIViewController {
  weak var delegate: PlaylistExplorerDelegate?
  @IBOutlet weak var projectsCollectionView: UICollectionView!
  @IBOutlet weak var playlistsCollectionView: UICollectionView!

  let viewModel: PlaylistExplorerViewModelType
  let projectsDataSource = SimpleDataSource<ProjectCell, Project>()
  let playlistsDataSource = HomePlaylistsDataSource()

  var playlistOpened = true

  init(playlist: Playlist) {
    self.viewModel = PlaylistExplorerViewModel(playlist: playlist)
    super.init(nibName: PlaylistExplorerViewController.defaultNib, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.projectsDataSource.registerClasses(collectionView: self.projectsCollectionView)
    self.playlistsDataSource.registerClasses(collectionView: self.playlistsCollectionView)

    self.projectsCollectionView.dataSource = self.projectsDataSource
    self.playlistsCollectionView.dataSource = self.playlistsDataSource

    self.playlistsCollectionView.remembersLastFocusedIndexPath = true

    self.projectsCollectionView.contentInset = UIEdgeInsets(top: 0.0, left: 80.0, bottom: 0.0, right: 80.0)

    let tap = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
    tap.allowedPressTypes = [UIPressType.Menu.rawValue]
    self.view.addGestureRecognizer(tap)
  }

  override func bindViewModel() {

    self.viewModel.outputs.playlists
      .uncollect()
      .collect()
      .observeForUI()
      .startWithNext { [weak self] viewModels in
        self?.playlistsDataSource.load(viewModels)
        self?.playlistsCollectionView.reloadData()
    }

    self.viewModel.outputs.projects
      .observeForUI()
      .observeNext { [weak self] projects in
        self?.projectsDataSource.reload(projects)
        self?.projectsCollectionView.reloadData()
    }

    self.viewModel.outputs.playlistsOpened
      .observeForUI()
      .observeNext { [weak self] opened in
        self?.setPlaylistsOpened(opened, animated: true)
    }

    self.viewModel.outputs.dismiss
      .observeForUI()
      .observeNext { [weak self] in
        guard let controller = self else { return }
        controller.delegate?.playlistExplorerWantsToClose(controller)
    }
  }

  @objc internal func tap(recognizer: UITapGestureRecognizer) {
    self.viewModel.inputs.menuButtonPressed()
  }

  override var preferredFocusedView: UIView? {
    return self.playlistOpened ? self.playlistsCollectionView : UIScreen.mainScreen().focusedView
  }

  private func setPlaylistsOpened(opened: Bool, animated: Bool = false) {
    let leftView = self.playlistsCollectionView
    let rightView = self.projectsCollectionView

    self.playlistOpened = opened
    self.setNeedsFocusUpdate()

    if opened && self.projectsDataSource.numberOfItems() > 0 {
      self.projectsCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0),
                                                          atScrollPosition: .Left,
                                                          animated: true)
    }

    UIView.animateWithDuration(animated ? 0.3 : 0.0) {
      let delta = rightView.center.x - rightView.bounds.width/2.0
      let transform = CGAffineTransformMakeTranslation(opened ? 0.0 : -delta, 0.0)
      rightView.transform = transform
      leftView.transform = transform
    }
  }
}

extension PlaylistExplorerViewController: UICollectionViewDelegate {
  func collectionView(
    collectionView: UICollectionView,
    didUpdateFocusInContext context: UICollectionViewFocusUpdateContext,
                            withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

    guard let nextFocusedIndexPath = context.nextFocusedIndexPath else { return }

    if collectionView === self.playlistsCollectionView {
      if let playlist = self.playlistsDataSource[nextFocusedIndexPath] as? Playlist {
        self.viewModel.inputs.focusPlaylist(playlist)
      }
    }

    if collectionView === self.projectsCollectionView {
      if let project = self.projectsDataSource[nextFocusedIndexPath] as? Project {
        self.viewModel.inputs.focusProject(project)
      }
    }
  }
}
