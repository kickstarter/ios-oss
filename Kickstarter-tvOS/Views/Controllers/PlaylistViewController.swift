import AVFoundation
import struct Models.Project
import UIKit
import class Library.MVVMViewController

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

    self.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(PlaylistViewController.pan(_:))))
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

  internal override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
    super.pressesBegan(presses, withEvent: event)

    if let press = presses.first where press.type == .Select {
      let controller = ProjectViewController(viewModel: ProjectViewModel(project: project))
      self.presentViewController(controller, animated: true, completion: nil)
    }
  }

  @objc internal func pan(recognizer: UIPanGestureRecognizer) {
    if recognizer.state == .Ended {
      let translation = recognizer.translationInView(self.view)
      self.viewModel.inputs.swipeEnded(translation: translation)
    }
  }
}
