import UIKit
import AVFoundation
import Models
import Library

internal final class HomeViewController: UIViewController {
  @IBOutlet private weak var overlayView: UIView!
  @IBOutlet private weak var videoPlayerView: AVPlayerView!
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var nowPlayingProjectNameLabel: UILabel!
  @IBOutlet private weak var nowPlaylistStackView: UIStackView!
  @IBOutlet private weak var iconsLabel: UILabel!

  private let viewModel: HomeViewModelType = HomeViewModel()
  private var dataSource = HomePlaylistsDataSource()

  private lazy var player: AVPlayer = {
    let player = AVPlayer()
    NSNotificationCenter.defaultCenter().addObserver(
      self,
      selector: #selector(playerFinishedPlaying(_:)),
      name: AVPlayerItemDidPlayToEndTimeNotification,
      object: player
    )
    player.muted = true
    return player
  }()

  internal required init?(coder aDecoder: NSCoder) {
    super.init(nibName: HomeViewController.defaultNib, bundle: nil)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.inputs.viewDidLoad()

    self.iconsLabel.text = "\u{f215} \u{f210}"

    self.videoPlayerView.playerLayer?.player = self.player
    self.videoPlayerView.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill

    if let superview = collectionView.superview {
      superview.layer.mask = { gradientLayer in
        gradientLayer.frame = superview.bounds
        gradientLayer.colors = [
          UIColor.clearColor(),
          UIColor.blackColor(),
          UIColor.blackColor(),
          UIColor.clearColor()
          ].map { $0.CGColor }
        gradientLayer.locations = [ 0.0, 0.05, 0.95, 1.0 ]
        return gradientLayer
      }(CAGradientLayer())
    }

    collectionView.contentInset = UIEdgeInsets(top: 40.0, left: 0.0, bottom: 40.0, right: 0.0)
    collectionView.remembersLastFocusedIndexPath = true

    dataSource.registerClasses(collectionView: collectionView)
    collectionView.dataSource = dataSource

    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      layout.itemSize = CGSize(width: collectionView.frame.width, height: 80.0)
    }
  }

  internal override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    viewModel.inputs.viewWillAppear()
  }

  internal override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.inputs.viewWillDisappear()
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.playlists
      .observeForUI()
      .observeNext { [weak self] data in
        self?.dataSource.load(data)
        self?.collectionView.reloadData()
    }

    self.viewModel.outputs.nowPlayingVideoUrl
      .observeForUI()
      .observeNext(self.playVideo)

    self.viewModel.outputs.nowPlayingProjectName
      .observeForUI()
      .observeNext(self.swapNowPlayingInfo)

    self.viewModel.outputs.selectProject
      .observeForUI()
      .observeNext { [weak self] project in
        self?.presentProject(project)
    }

    self.viewModel.outputs.interfaceImportance
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

  private func playVideo(url: NSURL?) {
    guard let url = url else {
      self.player.replaceCurrentItemWithPlayerItem(nil)
      return
    }

    let item = AVPlayerItem(URL: url)
    self.player.replaceCurrentItemWithPlayerItem(item)
  }

  private func swapNowPlayingInfo(projectName: String?) {

    guard let projectName = projectName else {
      self.nowPlaylistStackView.alpha = 0.0
      return
    }

    UIView.animateWithDuration(0.3, animations: {
      self.nowPlaylistStackView.alpha = 0.0
      }, completion: { _ in
        self.nowPlayingProjectNameLabel.text = projectName
        UIView.animateWithDuration(0.3) {
          self.nowPlaylistStackView.alpha = 1.0
        }
    })
  }

  @objc private func playerFinishedPlaying(notification: NSNotification) {
    viewModel.inputs.videoEnded()
  }

  private func presentProject(project: Project) {
    let controller = PlaylistViewController(initialPlaylist: Playlist.Popular, currentProject: project)
    presentViewController(controller, animated: true, completion: nil)
  }

  internal override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    super.pressesEnded(presses, withEvent: event)

    if let press = presses.first where press.type == .PlayPause && self.view.window != nil {
      if player.rate == 1.0 {
        self.viewModel.inputs.pauseVideoClick()
      } else {
        self.viewModel.inputs.playVideoClick()
      }
    }
  }
}

internal extension HomeViewController {
  internal func collectionView(
    collectionView: UICollectionView,
    didUpdateFocusInContext context: UICollectionViewFocusUpdateContext,
                            withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {

    guard let indexPath = context.nextFocusedIndexPath else { return }

    if let playlist = dataSource[indexPath] as? Playlist {
      self.viewModel.inputs.focusedPlaylist(playlist)
    }
  }

  internal func collectionView(collectionView: UICollectionView,
                               didSelectItemAtIndexPath indexPath: NSIndexPath) {
    if let playlist = dataSource[indexPath] as? Playlist {
      self.viewModel.inputs.clickedPlaylist(playlist)
    }
  }
}
