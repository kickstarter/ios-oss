import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit
import KsLive

internal final class LiveStreamContainerViewController: UIViewController {

  @IBOutlet private weak var detailsContainerStackView: UIStackView!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var loaderContainerStackView: UIStackView!
  @IBOutlet private weak var loaderView: UIView!
  @IBOutlet private weak var loaderStackView: UIStackView!
  @IBOutlet private weak var loaderLabel: UILabel!
  @IBOutlet private weak var loaderActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var loaderButton: UIButton!

  private let viewModel: LiveStreamContainerViewModelType = LiveStreamContainerViewModel()
  private var liveStreamViewController: LiveStreamViewController?

  internal static func configuredWith(project project: Project, event: LiveStreamEvent)
    -> LiveStreamContainerViewController {

      let vc = Storyboard.LiveStream.instantiate(LiveStreamContainerViewController)
      vc.viewModel.inputs.configureWith(project: project, event: event)
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    let closeBarButtonItem = UIBarButtonItem()
      |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .whiteColor()
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(LiveStreamContainerViewController.close(_:)))

    let shareBarButtonItem = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .whiteColor()
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(LiveStreamContainerViewController.share(_:)))
      |> UIBarButtonItem.lens.enabled .~ true

    self.navigationItem.leftBarButtonItem = closeBarButtonItem
    self.navigationItem.rightBarButtonItem = shareBarButtonItem

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.projectImageView
      |> UIImageView.lens.contentMode .~ .ScaleAspectFill

    self.loaderContainerStackView
      |> UIStackView.lens.axis .~ .Horizontal
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.distribution .~ .Fill

    self.loaderStackView
      |> UIStackView.lens.axis .~ .Vertical
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.distribution .~ .FillEqually

    self.loaderView
      |> UIView.lens.backgroundColor .~ UIColor.hex(0x353535)

    self.loaderActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .White
      |> UIActivityIndicatorView.lens.animating .~ true

    self.loaderLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .whiteColor()

    self.loaderButton
      |> UIButton.lens.hidden .~ true
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.createAndConfigureLiveStreamViewController
      .observeForUI()
      .observeNext { [weak self] in
        guard let _self = self else { return }
        let (_, event) = $0

        let liveStreamViewController = LiveStreamViewController(event: event, delegate: _self)
        _self.viewModel.inputs.setLiveStreamViewController(controller: liveStreamViewController)
    }

    self.viewModel.outputs.liveStreamViewController
      .observeForUI()
      .observeNext { [weak self]  in
        self?.addChildLiveStreamViewController($0)
    }

    self.viewModel.outputs.layoutLiveStreamView
      .observeForUI()
      .observeNext { [weak self] in
        self?.layoutLiveStreamView($0)
    }

    combineLatest(
      self.viewModel.outputs.liveStreamViewController,
      self.viewModel.outputs.showVideoView
    )
    .observeForUI()
      .observeNext {
        $0.0.view.hidden = !$0.1
    }

    self.viewModel.outputs.layoutLiveStreamViewWithCoordinator
      .observeForUI()
      .observeNext { [weak self] in
        let view = $0
        $1.animateAlongsideTransition({ (context) in
          self?.layoutLiveStreamView(view)
          }, completion: { [weak self] _ in
            guard let _self = self else { return }
            _self.navigationController?.setNavigationBarHidden(_self.isLandscape(), animated: true)
        })
    }

    self.viewModel.outputs.projectImageUrl
      .observeForUI()
      .on(next: { [weak self] image in self?.projectImageView.image = nil })
      .observeNext { [weak self] in self?.projectImageView.af_setImageWithURL($0) }

    self.loaderLabel.rac.text = self.viewModel.outputs.loaderText

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  internal override func prefersStatusBarHidden() -> Bool {
    return true
  }

  internal override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.loaderView.layer
      |> CALayer.lens.masksToBounds .~ false
      |> CALayer.lens.shadowColor .~ UIColor.blackColor().CGColor
      |> CALayer.lens.shadowOffset .~ CGSize(width: 0, height: 5)
      |> CALayer.lens.shadowOpacity .~ Float(0.5)

    self.loaderView.layer.shadowPath = UIBezierPath(rect: self.loaderView.bounds).CGPath
  }

  internal override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator
    coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)

    self.viewModel.inputs.viewWillTransitionToSizeWithCoordinator(coordinator: coordinator)
  }

  private func addChildLiveStreamViewController(controller: UIViewController) {
    self.addChildViewController(controller)
    controller.didMoveToParentViewController(self)
    self.view.addSubview(controller.view)
  }

  private func layoutLiveStreamView(view: UIView) {
    view.frame = self.videoFrame(self.isLandscape())
  }

  private func isLandscape() -> Bool {
    return UIApplication.sharedApplication().statusBarOrientation != .Portrait
  }

  private func videoFrame(landscape: Bool) -> CGRect {
    return CGRect(x: 0, y: 0,
                  width: self.view.bounds.size.width,
                  height: self.view.bounds.size.height * (landscape ? 1 : 0.4))
  }

  // MARK: Actions

  internal func close(sender: UIBarButtonItem) {
    self.viewModel.inputs.closeButtonTapped()
  }

  internal func share(sender: UIBarButtonItem) {

  }

  @IBAction internal func subscribe(sender: UIButton) {
    
  }
}

extension LiveStreamContainerViewController: LiveStreamViewControllerDelegate {
  internal func didRequestUserAuth(liveStreamViewController: LiveStreamViewController) {

  }

  internal func didPerformAction(liveStreamViewController: LiveStreamViewController,
                                 item: LiveStreamAssociatedItem) {

  }

  internal func playbackStateChanged(controller: LiveVideoViewController, state: LiveVideoViewControllerState) {
    self.viewModel.inputs.liveVideoViewControllerStateChanged(state: state)
  }
}