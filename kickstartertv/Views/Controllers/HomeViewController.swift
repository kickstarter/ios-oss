import UIKit
import AVKit
import Models

final class HomeViewController: MVVMViewController {
  @IBOutlet weak var overlayView: UIView!
  @IBOutlet weak var videoPlayerView: AVPlayerView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var nowPlayingProjectNameLabel: UILabel!
  @IBOutlet weak var nowPlaylistStackView: UIStackView!
  @IBOutlet weak var iconsLabel: UILabel!

  let viewModel: HomeViewModelType = HomeViewModel()
  var dataSource = HomePlaylistsDataSource()

  lazy var player: AVPlayer = {
    let player = AVPlayer()
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: Selector("playerFinishedPlaying:"),
      name: AVPlayerItemDidPlayToEndTimeNotification,
      object: player
    )
    player.muted = true
    return player
  }()

  required init?(coder aDecoder: NSCoder) {
    super.init(nibName: HomeViewController.defaultNib, bundle: nil)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.iconsLabel.text = "\u{f215} \u{f210}"

    self.videoPlayerView.playerLayer?.player = self.player
    self.videoPlayerView.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill

    self.nowPlaylistStackView.alpha = 0.0

    collectionView.superview!.layer.mask = { gradientLayer in
      gradientLayer.frame = collectionView.superview!.bounds
      gradientLayer.colors = [
        UIColor.clearColor(),
        UIColor.blackColor(),
        UIColor.blackColor(),
        UIColor.clearColor()
      ].map { $0.CGColor }
      gradientLayer.locations = [ 0.0, 0.05, 0.95, 1.0 ]
      return gradientLayer
    }(CAGradientLayer())

    collectionView.contentInset = UIEdgeInsets(top: 40.0, left: 0.0, bottom: 40.0, right: 0.0)
    collectionView.remembersLastFocusedIndexPath = true

    dataSource.registerClasses(collectionView: collectionView)
    collectionView.dataSource = dataSource

    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.itemSize = CGSize(width: collectionView.frame.width, height: 80.0)
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.inputs.isActive(true)
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.inputs.isActive(false)
  }

  override func bindViewModel() {
    super.bindViewModel()

    viewModel.outputs.playlists
      .observeForUI()
      .startWithNext { [weak self] data in
        self?.dataSource.load(data)
        self?.collectionView.reloadData()
    }

    viewModel.outputs.nowPlayingInfo
      .map { $0.videoUrl }
      .observeForUI()
      .observeNext { [weak self] url in
        let item = AVPlayerItem(URL: url)
        self?.player.replaceCurrentItemWithPlayerItem(item)
    }

    viewModel.outputs.isActive.filter { $0 }.take(1)
      .observeNext { [weak self] _ in
        self?.nowPlaylistStackView.alpha = 0.0
    }

    viewModel.outputs.nowPlayingInfo
      .map { $0.projectName }
      .observeForUI()
      .observeNext { [weak self] name in
        UIView.animateWithDuration(0.3, animations: {
            self?.nowPlaylistStackView.alpha = 0.0
        }, completion: { _ in
          self?.nowPlayingProjectNameLabel.text = name
          UIView.animateWithDuration(0.3) {
            self?.nowPlaylistStackView.alpha = 1.0
          }
        })
    }

    viewModel.outputs.selectProject
      .observeForUI()
      .observeNext { [weak self] project in
        self?.presentProject(project)
    }

    self.viewModel.outputs.interfaceImportance
      .skipRepeats()
      .observeForUI()
      .observeNext { [weak self] important in
        UIView.animateWithDuration(important ? 0.2 : 0.5) {
          self?.overlayView.alpha = important ? 1.0 : 0.25
        }
    }

    self.viewModel.outputs.videoIsPlaying
      .observeForUI()
      .observeNext { [weak self] play in
        if play {
          self?.player.play()
        } else {
          self?.player.pause()
        }
    }
  }

  override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    super.pressesEnded(presses, withEvent: event)

    if let press = presses.first where press.type == .PlayPause && self.view.window != nil {
      if player.rate == 1.0 {
        self.viewModel.inputs.pauseVideoClick()
      } else {
        self.viewModel.inputs.playVideoClick()
      }
    }
  }

  private func playerFinishedPlaying(notification: NSNotification) {
    viewModel.inputs.videoEnded()
  }

  private func presentProject(project: Project) {
    let controller = PlaylistViewController(initialPlaylist: Playlist.Popular, currentProject: project)
    presentViewController(controller, animated: true, completion: nil)
  }
}

extension HomeViewController {
  func collectionView(collectionView: UICollectionView, didUpdateFocusInContext context: UICollectionViewFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

    guard let indexPath = context.nextFocusedIndexPath else { return }

    if let viewModel = dataSource[indexPath] as? HomePlaylistViewModel {
      self.viewModel.inputs.focusedPlaylist(viewModel.playlist)
    }
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let viewModel = dataSource[indexPath] as? HomePlaylistViewModel {
      self.viewModel.inputs.clickedPlaylist(viewModel.playlist)
    }
  }
}
