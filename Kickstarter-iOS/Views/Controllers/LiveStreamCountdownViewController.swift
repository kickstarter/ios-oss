import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import UIKit

public final class LiveStreamCountdownViewController: UIViewController {
  @IBOutlet private weak var bgView: UIView!
  @IBOutlet private weak var creatorAvatarBottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var creatorAvatarImageView: UIImageView!
  @IBOutlet private weak var creatorAvatarWidthConstraint: NSLayoutConstraint!
  @IBOutlet private var countdownColons: [UILabel]!
  @IBOutlet private weak var countdownRootStackView: UIStackView!
  @IBOutlet private weak var countdownStackView: UIStackView!
  @IBOutlet private weak var daysSubtitleLabel: UILabel!
  @IBOutlet private weak var daysTitleLabel: UILabel!
  @IBOutlet private weak var dateContainerView: UIView!
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var detailsStackViewBackgroundView: UIView!
  @IBOutlet private weak var detailsStackView: UIStackView!
  @IBOutlet private weak var goToProjectButton: UIButton!
  @IBOutlet private weak var goToProjectButtonContainer: UIView!
  @IBOutlet private weak var hoursSubtitleLabel: UILabel!
  @IBOutlet private weak var hoursTitleLabel: UILabel!
  @IBOutlet private weak var imageOverlayView: UIView!
  @IBOutlet private weak var introLabel: SimpleHTMLLabel!
  @IBOutlet private weak var liveStreamTitleLabel: UILabel!
  @IBOutlet private weak var liveStreamParagraphLabel: UILabel!
  @IBOutlet private weak var minutesSubtitleLabel: UILabel!
  @IBOutlet private weak var minutesTitleLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var secondsSubtitleLabel: UILabel!
  @IBOutlet private weak var secondsTitleLabel: UILabel!
  @IBOutlet private var separatorViews: [UIView]!
  @IBOutlet private weak var subscribeActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var subscribeButton: UIButton!

  private let eventDetailsViewModel: LiveStreamEventDetailsViewModelType = LiveStreamEventDetailsViewModel()
  private let viewModel: LiveStreamCountdownViewModelType = LiveStreamCountdownViewModel()
  private var sessionStartedObserver: Any?
  private let shareViewModel: ShareViewModelType = ShareViewModel()

  public static func configuredWith(project: Project,
                                    liveStreamEvent: LiveStreamEvent,
                                    refTag: RefTag,
                                    presentedFromProject: Bool) -> LiveStreamCountdownViewController {

    let vc = Storyboard.LiveStream.instantiate(LiveStreamCountdownViewController.self)
    vc.viewModel.inputs.configureWith(project: project,
                                      liveStreamEvent: liveStreamEvent,
                                      refTag: refTag,
                                      presentedFromProject: presentedFromProject)
    vc.eventDetailsViewModel.inputs.configureWith(project: project, liveStreamEvent: liveStreamEvent,
                                                  refTag: refTag, presentedFromProject: presentedFromProject)
    vc.shareViewModel.inputs.configureWith(shareContext: .liveStream(project, liveStreamEvent),
                                           shareContextView: nil)

    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.subscribeButton.addTarget(self, action: #selector(subscribe), for: .touchUpInside)

    self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

    self.goToProjectButton.addTarget(self, action: #selector(goToProjectButtonTapped), for: [.touchUpInside])

    self.sessionStartedObserver = NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.eventDetailsViewModel.inputs.userSessionStarted()
    }

    self.viewModel.inputs.viewDidLoad()
    self.eventDetailsViewModel.inputs.viewDidLoad()
  }

  deinit {
    self.sessionStartedObserver.doIfSome(NotificationCenter.default.removeObserver)
  }

  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseLiveStreamControllerStyle()

    _ = self.projectImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill
      |> UIImageView.lens.clipsToBounds .~ true

    _ = self.countdownStackView
      |> UIStackView.lens.isAccessibilityElement .~ true
      |> UIStackView.lens.alignment .~ .firstBaseline
      |> UIStackView.lens.distribution .~ .equalCentering
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins %~~ { _, s in
        s.traitCollection.isRegularRegular
          ? .init(topBottom: 0, leftRight: Styles.grid(28))
          : .init(topBottom: 0, leftRight: Styles.grid(6))
    }

    _ = [self.daysTitleLabel, self.hoursTitleLabel, self.minutesTitleLabel, self.secondsTitleLabel]
      ||> UILabel.lens.textColor .~ .white
      ||> UILabel.lens.font %~~ { _, l in
        (l.traitCollection.isRegularRegular ? UIFont.ksr_title1() : .ksr_title1(size: 24)).countdownMonospaced
      }
      ||> UILabel.lens.textAlignment .~ .center

    _ = [self.daysSubtitleLabel, self.hoursSubtitleLabel, self.minutesSubtitleLabel,
         self.secondsSubtitleLabel]
      ||> UILabel.lens.textColor .~ .white
      ||> UILabel.lens.font %~~ { _, l in
        l.traitCollection.isRegularRegular ? .ksr_headline() : .ksr_subhead(size: 14)
      }
      ||> UILabel.lens.textAlignment .~ .center

    _ = [self.minutesSubtitleLabel, self.secondsSubtitleLabel]
      ||> UILabel.lens.contentCompressionResistancePriorityForAxis(.horizontal) .~ UILayoutPriorityDefaultLow
      ||> UILabel.lens.lineBreakMode .~ .byTruncatingTail

    _ = self.countdownRootStackView
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.dateContainerView
      |> liveStreamDateContainerStyle

    _ = self.dateLabel
      |> UILabel.lens.font .~ .ksr_subhead()
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.textAlignment .~ .center

    _ = self.daysSubtitleLabel
      |> UILabel.lens.text %~ { _ in Strings.days_plural() }

    _ = self.hoursSubtitleLabel
      |> UILabel.lens.text %~ { _ in Strings.hours_plural() }

    _ = self.minutesSubtitleLabel
      |> UILabel.lens.text %~ { _ in Strings.minutes_plural() }

    _ = self.secondsSubtitleLabel
      |> UILabel.lens.text %~ { _ in Strings.seconds() }

    _ = self.countdownColons
      ||> UILabel.lens.text .~ ":"
      ||> UILabel.lens.textColor .~ .white
      ||> UILabel.lens.font .~ .ksr_title1(size: 24)

    _ = self.detailsStackView
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ UIEdgeInsets(top: Styles.grid(4), left: Styles.grid(4),
                                                        bottom: Styles.grid(7), right: Styles.grid(4))
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.detailsStackViewBackgroundView
      |> roundedStyle()
      |> dropShadowStyleMedium()

    self.creatorAvatarBottomConstraint.constant = -Styles.grid(4)
    self.creatorAvatarWidthConstraint.constant = self.traitCollection.isRegularRegular
      ? Styles.grid(20)
      : Styles.grid(10)

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    let introLabelBaseFont = self.traitCollection.isRegularRegular
      ? UIFont.ksr_subhead(size: 18)
      : UIFont.ksr_subhead(size: 14)

    let introLabelBaseAttributes = [
      NSFontAttributeName: introLabelBaseFont,
      NSForegroundColorAttributeName: UIColor.ksr_navy_600,
      NSParagraphStyleAttributeName: paragraphStyle
    ]

    let introLabelBoldAttributes = [
      NSFontAttributeName: introLabelBaseFont.bolded,
      NSForegroundColorAttributeName: UIColor.ksr_dark_grey_500
    ]
    _ = self.introLabel
      |> SimpleHTMLLabel.lens.baseAttributes .~ introLabelBaseAttributes
      |> SimpleHTMLLabel.lens.boldAttributes .~ introLabelBoldAttributes
      |> SimpleHTMLLabel.lens.numberOfLines .~ 2

    _ = self.liveStreamTitleLabel
      |> UILabel.lens.font %~~ { _, v in
        v.traitCollection.isRegularRegular ?  UIFont.ksr_title2() : UIFont.ksr_title3(size: 18)
      }
      |> UILabel.lens.textColor .~ .ksr_dark_grey_900
      |> UILabel.lens.numberOfLines .~ 2

    _ = self.liveStreamParagraphLabel
      |> UILabel.lens.font %~~ { _, v in
        v.traitCollection.isRegularRegular ?  UIFont.ksr_body() : UIFont.ksr_body(size: 14)
      }
      |> UILabel.lens.textColor .~ .ksr_navy_600

    _ = self.subscribeButton
      |> darkSubscribeButtonStyle

    _ = self.subscribeActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .gray
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true

    _ = self.bgView
      |> UIView.lens.backgroundColor .~ .white
      |> UIView.lens.layoutMargins %~~ { _, s in
        s.traitCollection.horizontalSizeClass == .regular
          ? .init(top: 0, left: Styles.grid(12), bottom: Styles.grid(4), right: Styles.grid(12))
          : .init(top: 0, left: Styles.grid(4), bottom: Styles.grid(4), right: Styles.grid(4))
    }

    _ = self.goToProjectButton
      |> liveStreamGoToProjectStyle
      |> UIButton.lens.titleColor(forState: .normal) .~ .ksr_text_dark_grey_900

    _ = self.imageOverlayView
      |> UIView.lens.backgroundColor .~ UIColor.ksr_dark_grey_900.withAlphaComponent(0.8)

    _ = self.separatorViews
      ||> separatorStyle
  }

  override public var prefersStatusBarHidden: Bool {
    return true
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.subscribeButton.layer.cornerRadius = self.subscribeButton.frame.size.height / 2
  }

  public override func bindViewModel() {
    super.bindViewModel()

    self.countdownStackView.rac.accessibilityLabel = self.viewModel.outputs.countdownAccessibilityLabel
    self.daysTitleLabel.rac.text = self.viewModel.outputs.daysString
    self.hoursTitleLabel.rac.text = self.viewModel.outputs.hoursString
    self.minutesTitleLabel.rac.text = self.viewModel.outputs.minutesString
    self.secondsTitleLabel.rac.text = self.viewModel.outputs.secondsString
    self.introLabel.rac.html = self.viewModel.outputs.upcomingIntroText
    self.liveStreamTitleLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamTitle
    self.liveStreamParagraphLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamParagraph
    self.projectImageView.rac.imageUrl = self.viewModel.outputs.projectImageUrl
    self.creatorAvatarImageView.rac.imageUrl = self.eventDetailsViewModel.outputs.creatorAvatarUrl
    self.dateLabel.rac.text = self.viewModel.outputs.countdownDateLabelText
    self.goToProjectButtonContainer.rac.hidden = self.viewModel.outputs.goToProjectButtonContainerHidden

    self.eventDetailsViewModel.outputs.openLoginToutViewController
      .observeValues { [weak self] _ in
        self?.openLoginTout()
    }

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    self.navigationItem.rac.title = self.viewModel.outputs.viewControllerTitle
    self.subscribeButton.rac.title = self.eventDetailsViewModel.outputs.subscribeButtonText
    self.subscribeButton.rac.accessibilityHint
      = self.eventDetailsViewModel.outputs.subscribeButtonAccessibilityHint
    self.subscribeButton.rac.accessibilityLabel
      = self.eventDetailsViewModel.outputs.subscribeButtonAccessibilityLabel

    self.eventDetailsViewModel.outputs.subscribeButtonImage
      .observeForUI()
      .observeValues { [weak self] imageName in
        self?.subscribeButton.setImage(image(named: imageName ?? ""), for: .normal)
    }

    self.subscribeActivityIndicatorView.rac.animating = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.subscribeButton.rac.hidden = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.viewModel.outputs.pushLiveStreamViewController
      .observeForControllerAction()
      .observeValues { [weak self] project, liveStreamEvent, refTag in
        let liveStreamContainerViewController = LiveStreamContainerViewController
          .configuredWith(project: project,
                          liveStreamEvent: liveStreamEvent,
                          refTag: refTag,
                          presentedFromProject: false)

        self?.navigationController?.pushViewController(liveStreamContainerViewController, animated: true)
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self]  controller, _ in self?.showShareSheet(controller: controller) }

    self.eventDetailsViewModel.outputs.showErrorAlert
      .observeForUI()
      .observeValues { [weak self] in
        self?.present(UIAlertController.genericError($0), animated: true, completion: nil)
    }

    self.viewModel.outputs.goToProject
      .observeForControllerAction()
      .observeValues { [weak self] in self?.goTo(project: $0, refTag: $1) }
  }

  private func goTo(project: Project, refTag: RefTag) {
    let vc = ProjectNavigatorViewController.configuredWith(project: project, refTag: refTag)
    self.present(vc, animated: true, completion: nil)
  }

  lazy private var closeBarButtonItem: UIBarButtonItem = {
    let closeBarButtonItem = UIBarButtonItem()
      |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(close))

    closeBarButtonItem.accessibilityLabel = Strings.Close_live_stream()

    closeBarButtonItem.accessibilityHint = Strings.Closes_live_stream()

    return closeBarButtonItem
  }()

  lazy private var shareBarButtonItem: UIBarButtonItem = {
    let shareBarButtonItem = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(share))

    shareBarButtonItem.accessibilityLabel = Strings.Share_this_live_stream()

    return shareBarButtonItem
  }()

  private func showShareSheet(controller: UIActivityViewController) {
    controller.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in

      self?.shareViewModel.inputs.shareActivityCompletion(
        with: .init(activityType: activityType,
                    completed: completed,
                    returnedItems: returnedItems,
                    activityError: error)
      )
    }

    if UIDevice.current.userInterfaceIdiom == .pad {
      controller.modalPresentationStyle = .popover
      controller.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
      self.present(controller, animated: true, completion: nil)

    } else {
      self.present(controller, animated: true, completion: nil)
    }
  }

  private func openLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .liveStreamSubscribe)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  // MARK: Actions

  @objc private func close() {
    self.viewModel.inputs.closeButtonTapped()
  }

  @objc private func share() {
    self.shareViewModel.inputs.shareButtonTapped()
  }

  @objc private func subscribe() {
    self.eventDetailsViewModel.inputs.subscribeButtonTapped()
  }

  @objc private func goToProjectButtonTapped() {
    self.viewModel.inputs.goToProjectButtonTapped()
  }
}
