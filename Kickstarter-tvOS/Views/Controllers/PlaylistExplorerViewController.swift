import UIKit
import Models
import class Library.MVVMViewController
import class Library.SimpleDataSource
import class Library.SimpleViewModel

protocol PlaylistExplorerDelegate: class {
  func playlistExplorerWantsToClose(controller: PlaylistExplorerViewController)
}

class PlaylistExplorerViewController: MVVMViewController {
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

    self.projectsCollectionView.contentInset = UIEdgeInsetsMake(0.0, 80.0, 0.0, 80.0)

    let tap = UITapGestureRecognizer(target: self, action: #selector(PlaylistExplorerViewController.tap(_:)))
    tap.allowedPressTypes = [UIPressType.Menu.rawValue]
    self.view.addGestureRecognizer(tap)
  }

  override func bindViewModel() {

    self.viewModel.outputs.playlists
      .uncollect()
      .map(HomePlaylistViewModel.init)
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

    if opened && self.projectsDataSource.numberOfItems > 0 {
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
      if let playlistViewModel = self.playlistsDataSource[nextFocusedIndexPath] as? HomePlaylistViewModel {
        self.viewModel.inputs.focusPlaylist(playlistViewModel.playlist)
      }
    }

    if collectionView === self.projectsCollectionView {
      if let projectViewModel = self.projectsDataSource[nextFocusedIndexPath] as? SimpleViewModel<Project> {
        self.viewModel.inputs.focusProject(projectViewModel.model)
      }
    }
  }
}
