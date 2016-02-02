import UIKit
import Models
import AVKit
import ReactiveCocoa
import Result

class PlaylistViewController: MVVMViewController {
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var playlistLabel: UILabel!
  @IBOutlet weak var projectLabel: UILabel!
  @IBOutlet weak var backgroundImageView: UIImageView!

  let viewModel: PlaylistViewModelType
  let project: Project

  init (initialPlaylist: Playlist, currentProject: Project) {
    self.viewModel = PlaylistViewModel(initialPlaylist: initialPlaylist, currentProject: currentProject)
    self.project = currentProject
    super.init(nibName: PlaylistViewController.defaultNib, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "pan:"))
  }
  
  override func bindViewModel() {

    self.viewModel.outputs.project
      .observeForUI()
      .startWithNext { [weak self] project in
        self?.categoryLabel.text = project.category.name
        self?.projectLabel.text = project.name
    }

    self.viewModel.outputs.project
      .flatMap { $0.video?.high }
      .flatMap(NSURL.init)
      .switchMap(imageFromVideoUrl)
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

  override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    super.pressesBegan(presses, withEvent: event)

    if let press = presses.first where press.type == .Select {
      let controller = ProjectViewController(viewModel: ProjectViewModel(project: project))
      self.presentViewController(controller, animated: true, completion: nil)
    }
  }

  func pan(recognizer: UIPanGestureRecognizer) {
    if recognizer.state == .Ended {
      self.viewModel.inputs.swipeEnded(recognizer.translationInView(self.view))
    }
  }
}
