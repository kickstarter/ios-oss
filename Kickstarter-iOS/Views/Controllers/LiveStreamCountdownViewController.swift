import KsApi
import Library
import LiveStream
import Prelude
import ReactiveCocoa
import UIKit

internal final class LiveStreamCountdownViewController: UIViewController {
  @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var creatorAvatarImageView: UIImageView!
  @IBOutlet private weak var creatorAvatarWidthConstraint: NSLayoutConstraint!
  @IBOutlet private var countdownColons: [UILabel]?
  @IBOutlet private weak var countdownContainerStackView: UIStackView!
  @IBOutlet private weak var countdownStackView: UIStackView!
  @IBOutlet private var countdownLabels: [UILabel]?
  @IBOutlet private weak var daysLabel: UILabel!
  @IBOutlet private weak var detailsContainerStackView: UIStackView!
  @IBOutlet private weak var detailsContainerStackViewTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var detailsStackViewBackgroundView: UIView!
  @IBOutlet private weak var detailsStackView: UIStackView!
  @IBOutlet private weak var gradientView: GradientView!
  @IBOutlet private weak var hoursLabel: UILabel!
  @IBOutlet private weak var introLabel: UILabel!
  @IBOutlet private weak var liveStreamTitleLabel: UILabel!
  @IBOutlet private weak var liveStreamParagraphLabel: UILabel!
  @IBOutlet private weak var minutesLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var secondsLabel: UILabel!
  @IBOutlet private weak var subscribeActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var subscribeButton: UIButton!

  private let eventDetailsViewModel: LiveStreamEventDetailsViewModelType = LiveStreamEventDetailsViewModel()
  private let viewModel: LiveStreamCountdownViewModelType = LiveStreamCountdownViewModel()
  private let shareViewModel: ShareViewModelType = ShareViewModel()

  internal static func configuredWith(project project: Project)
    -> LiveStreamCountdownViewController {

      let vc = Storyboard.LiveStream.instantiate(LiveStreamCountdownViewController)
      vc.viewModel.inputs.configureWith(project: project)
      vc.eventDetailsViewModel.inputs.configureWith(project: project, event: nil)
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    let closeBarButtonItem = UIBarButtonItem()
      |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .whiteColor()
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(close))

    self.navigationItem.leftBarButtonItem = closeBarButtonItem
    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

    self.navigationController?.delegate = self

    self.viewModel.inputs.viewDidLoad()
    self.eventDetailsViewModel.inputs.viewDidLoad()
  }

  //swiftlint:disable function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    self.projectImageView
      |> UIImageView.lens.contentMode .~ .ScaleAspectFill

    self.countdownStackView
      |> UIStackView.lens.alignment .~ .Top
      |> UIStackView.lens.distribution .~ .EqualCentering

    self.countdownContainerStackView
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.spacing .~ Styles.grid(6)
      |> UIStackView.lens.distribution .~ .Fill

    self.countdownLabels?.forEach { label in
      label
        |> UILabel.lens.textAlignment .~ .Center
        |> UILabel.lens.numberOfLines .~ 2
        |> UILabel.lens.textColor .~ .whiteColor()
    }

    self.countdownColons?.forEach { label in
      label
        |> UILabel.lens.text .~ ":"
        |> UILabel.lens.textAlignment .~ .Center
        |> UILabel.lens.numberOfLines .~ 2
        |> UILabel.lens.textColor .~ .whiteColor()
        |> UILabel.lens.font .~ .ksr_title1(size: 24)
    }

    self.detailsContainerStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(
        top: 0, left: Styles.grid(4), bottom: Styles.grid(4), right: Styles.grid(4))

    self.detailsStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(top: Styles.grid(8), left: Styles.grid(4),
                                                        bottom: Styles.grid(7), right: Styles.grid(4))
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    self.detailsStackViewBackgroundView
      |> roundedStyle(cornerRadius: 2)

    self.detailsContainerStackViewTopConstraint.constant = -Styles.grid(4)
    self.creatorAvatarWidthConstraint.constant = Styles.grid(10)

    self.creatorAvatarImageView
      |> UIImageView.lens.layer.masksToBounds .~ true

    self.introLabel
      |> UILabel.lens.numberOfLines .~ 2

    self.liveStreamTitleLabel
      |> UILabel.lens.font .~ UIFont.ksr_title3()
      |> UILabel.lens.textColor .~ .ksr_navy_700

    self.liveStreamParagraphLabel
      |> UILabel.lens.font .~ UIFont.ksr_subhead()
      |> UILabel.lens.textColor .~ .ksr_navy_600

    self.subscribeButton
      |> greenBorderContainerButtonStyle
      |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(right: -Styles.grid(1))
      |> UIButton.lens.tintColor .~ self.subscribeButton.currentTitleColor

    self.subscribeButton.semanticContentAttribute = .ForceRightToLeft

    self.activityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .Gray
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.animating .~ false

    self.subscribeActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .Gray
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.animating .~ false
  }
  //swiftlint:enable function_body_length

  internal override func prefersStatusBarHidden() -> Bool {
    return true
  }

  internal override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return .LightContent
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.subscribeButton.layer.cornerRadius = self.subscribeButton.frame.size.height / 2
    self.creatorAvatarImageView.layer.cornerRadius = self.creatorAvatarImageView.frame.size.height / 2
  }

  //swiftlint:disable function_body_length
  internal override func bindViewModel() {
    super.bindViewModel()

    self.daysLabel.rac.attributedText = self.viewModel.outputs.daysString
    self.hoursLabel.rac.attributedText = self.viewModel.outputs.hoursString
    self.minutesLabel.rac.attributedText = self.viewModel.outputs.minutesString
    self.secondsLabel.rac.attributedText = self.viewModel.outputs.secondsString

    self.eventDetailsViewModel.outputs.configureShareViewModel
      .observeNext { [weak self] in
        self?.shareViewModel.inputs.configureWith(shareContext: ShareContext.liveStream($0, $1))
    }

    // FIXME: move this logic to the VM
    self.shareBarButtonItem.rac.enabled = self.eventDetailsViewModel.outputs.configureShareViewModel.mapConst(true)

    self.introLabel.rac.attributedText = self.viewModel.outputs.upcomingIntroText
    self.liveStreamTitleLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamTitle
    self.liveStreamParagraphLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamParagraph

    self.viewModel.outputs.projectImageUrl
      .observeForUI()
      .on(next: { [weak self] image in self?.projectImageView.image = nil })
      .observeNext { [weak self] in self?.projectImageView.ksr_setImageWithURL($0) }

    self.eventDetailsViewModel.outputs.creatorAvatarUrl
      .observeForUI()
      .on(next: { [weak self] image in self?.creatorAvatarImageView.image = nil })
      .ignoreNil()
      .observeNext { [weak self] in self?.creatorAvatarImageView.ksr_setImageWithURL($0) }

    self.viewModel.outputs.categoryId
      .observeForUI()
      .observeNext { [weak self] in
        let (startColor, endColor) = discoveryGradientColors(forCategoryId: $0)
        self?.gradientView.setGradient([(startColor, 0.0), (endColor, 1.0)])
    }

    self.eventDetailsViewModel.outputs.retrievedLiveStreamEvent
      .observeNext(self.viewModel.inputs.retrievedLiveStreamEvent(event:))

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeNext { [weak self] in
        self?.dismissViewControllerAnimated(true, completion: nil)
    }

    self.navigationItem.rac.title = self.viewModel.outputs.viewControllerTitle
    self.subscribeButton.rac.title = self.eventDetailsViewModel.outputs.subscribeButtonText

    self.eventDetailsViewModel.outputs.subscribeButtonImage
      .observeForUI()
      .observeNext { [weak self] in
        self?.subscribeButton.setImage($0, forState: .Normal)
    }

    self.activityIndicatorView.rac.animating = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.detailsStackView.rac.hidden = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.subscribeActivityIndicatorView.rac.animating = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.subscribeButton.rac.hidden = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.viewModel.outputs.pushLiveStreamViewController
      .observeForControllerAction()
      .observeNext { [weak self] in
        let liveStreamContainerViewController = LiveStreamContainerViewController
          .configuredWith(project: $0, event: $1)

        self?.navigationController?.pushViewController(liveStreamContainerViewController, animated: true)
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeNext { [weak self] in self?.showShareSheet($0) }

    self.eventDetailsViewModel.outputs.showErrorAlert
      .observeForUI()
      .observeNext { [weak self] in
        self?.presentViewController(UIAlertController.genericError($0), animated: true, completion: nil)
    }
  }
  //swiftlint:enable function_body_length

  // FIXME: this can be an IBOutlet
  lazy var shareBarButtonItem: UIBarButtonItem = {
    let shareBarButtonItem = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .whiteColor()
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(share))
      |> UIBarButtonItem.lens.enabled .~ false

    return shareBarButtonItem
  }()

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] in
      self?.shareViewModel.inputs.shareActivityCompletion(activityType: $0,
                                                          completed: $1,
                                                          returnedItems: $2,
                                                          activityError: $3)
    }

    if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
      controller.modalPresentationStyle = .Popover
      controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
      self.presentViewController(controller, animated: true, completion: nil)

    } else {
      self.presentViewController(controller, animated: true, completion: nil)
    }
  }

  // MARK: Actions

  @objc private func close() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc private func share() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @IBAction private func subscribe() {
    self.eventDetailsViewModel.inputs.subscribeButtonTapped()
  }
}

// FIXME: let's chat about this
extension LiveStreamCountdownViewController: UINavigationControllerDelegate {
  func navigationControllerSupportedInterfaceOrientations(
    navigationController: UINavigationController) -> UIInterfaceOrientationMask {
    return .Portrait
  }
}
