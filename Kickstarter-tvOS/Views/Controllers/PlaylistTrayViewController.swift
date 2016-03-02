import UIKit
import Models
import class Library.MVVMViewController

protocol PlaylistTrayDelegate : class {
  func playlistTrayWantsToClose(controller: PlaylistTrayViewController)
  func playlistTray(controller: PlaylistTrayViewController, didSelectProject: Project, inPlaylist: Playlist)
}

class PlaylistTrayViewController: MVVMViewController {
  weak var delegate: PlaylistTrayDelegate?

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var collectionView: UICollectionView!

  let viewModel: PlaylistTrayViewModel
  let dataSource = PlaylistTrayDataSource()

  init(viewModel: PlaylistTrayViewModel) {
    self.viewModel = viewModel
    super.init(nibName: PlaylistTrayViewController.defaultNib, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.superview!.layer.mask = { gradientLayer in
      gradientLayer.frame = collectionView.superview!.bounds
      gradientLayer.colors = [
        UIColor.clearColor(),
        UIColor.blackColor(),
        UIColor.blackColor(),
        UIColor.clearColor()
        ].map { $0.CGColor }
      gradientLayer.locations = [ 0.0, 0.05, 0.9, 1.0 ]
      return gradientLayer
    }(CAGradientLayer())

    dataSource.registerClasses(collectionView: self.collectionView)
    self.collectionView.dataSource = dataSource
  }

  override func bindViewModel() {

    viewModel.outputs.playlists
      .observeForUI()
      .startWithNext { [weak self] playlists in
        self?.dataSource.load(playlists.map(PlaylistsMenuViewModel.init))
    }
  }

  override var preferredFocusedView: UIView? {
    return self.collectionView
  }

  override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    if let press = presses.first where press.type == .Menu {
      self.delegate?.playlistTrayWantsToClose(self)
    }
  }
}

extension PlaylistTrayViewController : UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

    if let cell = cell as? PlaylistTrayCell {
      cell.delegate = self
    }
  }
}

extension PlaylistTrayViewController : PlaylistTrayCellDelegate {
  func playlistTrayCell(cell: PlaylistTrayCell, didSelectedProject project: Project, inPlaylist playlist: Playlist) {

    self.delegate?.playlistTray(self, didSelectProject: project, inPlaylist: playlist)
  }
}
