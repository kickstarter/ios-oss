import class UIKit.NSCoder
import class AVKit.AVPlayerViewController
import class AVFoundation.AVPlayer
import class Library.MVVMViewController

final class ProjectPlayerViewController: MVVMViewController {

  let viewModel: ProjectPlayerViewModel
  let playerController = AVPlayerViewController()

  required init(viewModel: ProjectPlayerViewModel) {

    self.viewModel = viewModel

    super.init(nibName: nil, bundle: nil)

    let player = AVPlayer(URL: viewModel.videoURL)
    self.playerController.player = player
    self.playerController.showsPlaybackControls = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    addChildViewController(playerController)
    self.view.addSubview(playerController.view)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    playerController.view.frame = self.view.bounds
  }

  // MARK: Video Control
  func play() {
    playerController.player?.play()
  }
}
