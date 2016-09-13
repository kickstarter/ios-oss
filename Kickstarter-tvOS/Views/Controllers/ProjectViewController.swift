import AVFoundation
import struct KsApi.Project
import Prelude
import UIKit
import Library
import class Library.AVPlayerView

final class ProjectViewController: UIViewController {
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var gradientsView: UIView!
  @IBOutlet private weak var videoPlayerView: AVPlayerView!

  let dataSource = ProjectViewDataSource()
  let viewModel: ProjectViewModelType
  let animator = PlaylistExplorerTransitionAnimator()

  let player: AVPlayer

  required init(viewModel: ProjectViewModel) {
    self.viewModel = viewModel
    self.player = AVPlayer()
    self.player.muted = true

    super.init(nibName: ProjectViewController.defaultNib, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.player.play()
    self.videoPlayerView.playerLayer?.player = self.player
    self.videoPlayerView.playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill

    self.dataSource.registerClasses(collectionView: collectionView)
    self.collectionView?.dataSource = dataSource

    self.collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 80.0, right: 0.0)
    if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
      // NB: There is unfortunately some magic behind choosing this height. Too small and the
      // first layout pass of the cell will be too small, but it will correct itself on a second
      // layout pass. Too big and the collection view will crash! Abandon all hope, ye who
      // change this value.
      layout.estimatedItemSize = CGSize(width: 1920.0, height: 300.0)
    }

    self.view.addGestureRecognizer(
      UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
    )
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.inputs.isActive(true)
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    self.viewModel.inputs.isActive(false)
  }

  override func bindViewModel() {

    self.viewModel.outputs.videoURL
      .observeForUI()
      .startWithNext { [weak self] url in
        self?.player.replaceCurrentItemWithPlayerItem(AVPlayerItem(URL: url))
    }

    self.viewModel.outputs.project
      .observeForUI()
      .startWithNext { [weak self] project in
        self?.dataSource.loadProject(project)
        self?.collectionView?.reloadData()
    }

    self.viewModel.outputs.recommendations
      .observeForUI()
      .startWithNext { [weak self] recommendations in
        self?.dataSource.loadRecommendations(recommendations)
        self?.collectionView?.reloadData()
    }

    self.viewModel.outputs.openPlaylistsExplorer
      .observeForUI()
      .observeNext { [weak self] playlist in
        self?.presentPlaylistExplorer(playlist)
    }

    self.viewModel.outputs.interfaceImportance
      .skipRepeats()
      .observeForUI()
      .observeNext { [weak self] important in
        UIView.animateWithDuration(important ? 0.2 : 0.4) {
          self?.collectionView.alpha = important ? 1.0 : 0.0
          self?.gradientsView.alpha = important ? 1.0 : 0.0
        }
    }

    self.viewModel.outputs.videoIsPlaying
      .observeForUI()
      .observeNext { [weak self] isPlaying in
        if isPlaying {
          self?.player.play()
        } else {
          self?.player.pause()
        }
    }

    self.viewModel.outputs.videoTimelineProgress
      .observeForUI()
      .observeNext { [weak self] progress in
        self?.transformVideoPlayer(progress)
    }
  }

  @objc internal func pan(recognizer: UIPanGestureRecognizer) {
    self.viewModel.inputs.remoteInteraction()
  }

  override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    super.pressesEnded(presses, withEvent: event)

    if let press = presses.first where press.type == .PlayPause {
      self.viewModel.inputs.playPauseClicked(isPlay: player.rate == 0.0)
    }

    self.viewModel.inputs.remoteInteraction()
  }

  private func transformVideoPlayer(progress: CGFloat) {
    let beginFrame = self.view.bounds
    let endSize = CGSize(width: 960.0, height: 540.0)
    let endFrame = CGRect(
      x: self.view.bounds.width - endSize.width - 80.0,
      y: 80.0,
      width: endSize.width,
      height: endSize.height
    )

    let first = progress * 2.0
    let second = first |> clamp(0.0, 1.0)
    let third = second |> lerp(beginFrame, endFrame)
    self.videoPlayerView.frame = third
  }

  private func showRemindMeAlert() {
    let alertController = UIAlertController(
      title: NSLocalizedString("Project saved", comment: ""),
      message: NSLocalizedString("We'll remind you 48 hrs before this project ends", comment: ""),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("OK", comment: ""),
        style: .Cancel, handler: nil
      )
    )
    self.presentViewController(alertController, animated: true, completion: nil)
  }

  private func showLoginAlert() {
    let alertController = UIAlertController(
      title: nil,
      message: NSLocalizedString("You must be logged in to save projects.", comment: ""),
      preferredStyle: .Alert
    )
    alertController.addAction(
      UIAlertAction(
        title: NSLocalizedString("OK", comment: ""),
        style: .Cancel,
        handler: nil
      )
    )
    self.presentViewController(alertController, animated: true, completion: nil)
  }

  private func presentPlaylistExplorer(playlist: Playlist) {
    self.viewModel.inputs.isActive(false)

    let controller = PlaylistExplorerViewController(playlist: playlist)
    controller.transitioningDelegate = self
    controller.modalPresentationStyle = .Custom
    controller.delegate = self
    self.presentViewController(controller, animated: true, completion: nil)
  }
}

// MARK: UICollectionViewDelegate

extension ProjectViewController: UICollectionViewDelegate {
  func collectionView(collectionView: UICollectionView,
                      willDisplayCell cell: UICollectionViewCell,
                                      forItemAtIndexPath indexPath: NSIndexPath) {

    if let cell = cell as? ProjectShelfCell {
      cell.delegate = self
    } else if let cell = cell as? ProjectRecommendationsCell {
      cell.delegate = self
    }
  }

  func collectionView(collectionView: UICollectionView,
                      canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
  }

  func scrollViewDidScroll(scrollView: UIScrollView) {
    self.viewModel.inputs.scrollChanged(
      offset: scrollView.contentOffset,
      size: scrollView.contentSize,
      window: scrollView.bounds.size
    )
  }

  func scrollViewWillEndDragging(scrollView: UIScrollView,
                                 withVelocity velocity: CGPoint,
                                              targetContentOffset: UnsafeMutablePointer<CGPoint>) {

    // when at the top and scrolling down, lock the top to the fold
    if scrollView.contentOffset.y == 0.0 && targetContentOffset.memory.y > 0.0 && velocity.y > 0.0 {
      targetContentOffset.memory.y = 1080.0
    }

    // when below the fold and scrolling up to somewhere in the vicinity of the "more" section,
    // lock the top to the fold
    if targetContentOffset.memory.y >= 1080.0 &&
      targetContentOffset.memory.y <= 1080.0+700.0 &&
      velocity.y < 0.0 {

      targetContentOffset.memory.y = 1080.0
    }

    // when below the fold and scrolling up to somewhere above half the fold, go all the way
    // to the top
    if targetContentOffset.memory.y < 1080.0/2.0 && velocity.y < 0.0 {
      targetContentOffset.memory.y = 0.0
    }
  }
}

// MARK: ProjectShelfCellDelegate

extension ProjectViewController: ProjectShelfCellDelegate {
  func projectShelfTappedSave(cell: ProjectShelfCell) {
  }

  func projectShelfClickedMore(cell: ProjectShelfCell) {
    viewModel.inputs.morePlaylistsClick()
  }
}

// MARK: ProjectRecommendationsCellDelegate

extension ProjectViewController: ProjectRecommendationsCellDelegate {
  func projectRecommendations(cell: ProjectRecommendationsCell, didSelect project: Project) {
    let viewModel = ProjectViewModel(project: project)
    self.presentViewController(ProjectViewController(viewModel: viewModel), animated: true, completion: nil)
  }
}

// MARK: UIViewControllerTransitioningDelegate
extension ProjectViewController: UIViewControllerTransitioningDelegate {
  func animationControllerForPresentedController(
    presented: UIViewController,
    presentingController presenting: UIViewController,
                         sourceController source: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {

    self.animator.isPresenting = true
    return self.animator
  }

  func animationControllerForDismissedController(dismissed: UIViewController)
    -> UIViewControllerAnimatedTransitioning? {

    self.animator.isPresenting = false
    return self.animator
  }
}

// MARK: PlaylistTrayDelegate

extension ProjectViewController: PlaylistTrayDelegate, PlaylistExplorerDelegate {
  func playlistTrayWantsToClose(controller: PlaylistTrayViewController) {
    self.player.play()
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  func playlistTray(controller: PlaylistTrayViewController, didSelectProject: Project, inPlaylist: Playlist) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }

  func playlistExplorerWantsToClose(controller: PlaylistExplorerViewController) {
    self.viewModel.inputs.isActive(true)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}
