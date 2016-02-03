import UIKit
import Models
import AVKit
import ReactiveCocoa
import Result

internal final class PlaylistViewController: MVVMViewController {
  @IBOutlet private weak var categoryLabel: UILabel!
  @IBOutlet private weak var playlistLabel: UILabel!
  @IBOutlet private weak var projectLabel: UILabel!
  @IBOutlet private weak var backgroundImageView: UIImageView!

  private let viewModel: PlaylistViewModelType
  private let project: Project

  internal init (initialPlaylist: Playlist, currentProject: Project) {
    self.viewModel = PlaylistViewModel(initialPlaylist: initialPlaylist, currentProject: currentProject)
    self.project = currentProject
    super.init(nibName: PlaylistViewController.defaultNib, bundle: nil)
  }

  internal required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "pan:"))
  }
  
  internal override func bindViewModel() {

    self.viewModel.outputs.categoryName
      .observeForUI()
      .startWithNext { [weak self] name in
        self?.categoryLabel.text = name
    }

    self.viewModel.outputs.projectName
      .observeForUI()
      .startWithNext { [weak self] name in
        self?.projectLabel.text = name
    }

    self.viewModel.outputs.backgroundImage
      .observeForUI()
      .startWithNext { [weak self] image in
        self?.crossFadeBackgroundImage(image)
    }
  }

  private func crossFadeBackgroundImage(image: UIImage?) {
    UIView.transitionWithView(self.backgroundImageView, duration: 0.3, options: [.TransitionCrossDissolve], animations: {
      self.backgroundImageView.image = image
    }, completion: nil)
  }

  private func imageFromVideoUrl(url: NSURL) -> SignalProducer<UIImage?, NoError> {

    let asset = AVURLAsset(URL: url)
    let generator = AVAssetImageGenerator(asset: asset)
    let requestedTime = CMTimeMakeWithSeconds(30.0, 1)
    let requestedTimeValue = NSValue(CMTime: requestedTime)

    return SignalProducer { observer, disposable in
      generator.generateCGImagesAsynchronouslyForTimes([requestedTimeValue]) { (time, image, actualTime, result, error) -> Void in
        if let image = image {
          observer.sendNext(UIImage(CGImage: image))
        } else {
          observer.sendNext(nil)
        }
        observer.sendCompleted()
      }
    }
  }

  internal override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    super.pressesBegan(presses, withEvent: event)

    if let press = presses.first where press.type == .Select {
      let controller = ProjectViewController(viewModel: ProjectViewModel(project: project))
      self.presentViewController(controller, animated: true, completion: nil)
    }
  }

  internal func pan(recognizer: UIPanGestureRecognizer) {
    if recognizer.state == .Ended {
      let translation = recognizer.translationInView(self.view)
      self.viewModel.inputs.swipeEnded(translation: translation)
    }
  }
}
