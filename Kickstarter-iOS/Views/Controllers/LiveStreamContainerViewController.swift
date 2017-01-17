//swiftlint:disable file_length
import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UIKit

//swiftlint:disable:next type_body_length
public final class LiveStreamContainerViewController: UIViewController {

  @IBOutlet private weak var availableForLabel: UILabel!
  @IBOutlet private weak var creatorAvatarImageView: UIImageView!
  @IBOutlet private weak var creatorAvatarLabel: SimpleHTMLLabel!
  @IBOutlet private weak var creatorAvatarLiveDotImageView: UIImageView!
  @IBOutlet private weak var creatorAvatarWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var detailsContainerStackView: UIStackView!
  @IBOutlet private weak var detailsLoadingActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var detailsStackView: UIStackView!
  @IBOutlet private weak var gradientView: GradientView!
  @IBOutlet private weak var liveStreamParagraphLabel: UILabel!
  @IBOutlet private weak var liveStreamTitleLabel: UILabel!
  @IBOutlet private weak var loaderActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var loaderLabel: UILabel!
  @IBOutlet private weak var loaderStackView: UIStackView!
  @IBOutlet private weak var loaderView: UIView!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private var separatorViews: [UIView]!
  @IBOutlet private weak var subscribeActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var subscribeButton: UIButton!
  @IBOutlet private weak var subscribeLabel: UILabel!
  @IBOutlet private weak var subscribeStackView: UIStackView!
  @IBOutlet private weak var titleStackView: UIStackView!
  @IBOutlet private var videoContainerAspectRatioConstraint_4_3: NSLayoutConstraint!
  @IBOutlet private var videoContainerAspectRatioConstraint_16_9: NSLayoutConstraint!
  @IBOutlet private weak var watchingBadgeView: UIView!
  @IBOutlet private weak var watchingLabel: UILabel!

  fileprivate let eventDetailsViewModel: LiveStreamEventDetailsViewModelType
    = LiveStreamEventDetailsViewModel()
  private weak var liveStreamViewController: LiveStreamViewController?
  private let shareViewModel: ShareViewModelType = ShareViewModel()
  fileprivate let viewModel: LiveStreamContainerViewModelType = LiveStreamContainerViewModel()

  public static func configuredWith(project: Project,
                                    liveStream: Project.LiveStream,
                                    event: LiveStreamEvent?) -> LiveStreamContainerViewController {

    let vc = Storyboard.LiveStream.instantiate(LiveStreamContainerViewController.self)
    vc.viewModel.inputs.configureWith(project: project, event: event)
    vc.eventDetailsViewModel.inputs.configureWith(project: project, liveStream: liveStream, event: event)

    return vc
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    self.subscribeButton.addTarget(self, action: #selector(subscribe), for: .touchUpInside)

    self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
    self.navigationItem.rightBarButtonItem = self.shareBarButtonItem

    self.navBarTitleStackViewBackgroundView.addSubview(self.navBarTitleStackView)
    self.navBarTitleStackView.addArrangedSubview(self.navBarLiveDotImageView)
    self.navBarTitleStackView.addArrangedSubview(self.navBarTitleLabel)

    NSLayoutConstraint.activate([
      self.navBarTitleStackView.leadingAnchor.constraint(
        equalTo: self.navBarTitleStackViewBackgroundView.leadingAnchor),
      self.navBarTitleStackView.topAnchor.constraint(
        equalTo: self.navBarTitleStackViewBackgroundView.topAnchor),
      self.navBarTitleStackView.trailingAnchor.constraint(
        equalTo: self.navBarTitleStackViewBackgroundView.trailingAnchor),
      self.navBarTitleStackView.bottomAnchor.constraint(
        equalTo: self.navBarTitleStackViewBackgroundView.bottomAnchor),
      ])

    self.navigationItem.titleView = navBarTitleStackViewBackgroundView

    self.liveStreamViewController = self.childViewControllers
      .flatMap { $0 as? LiveStreamViewController }
      .first

    self.viewModel.inputs.viewDidLoad()
    self.eventDetailsViewModel.inputs.viewDidLoad()
  }

  //swiftlint:disable:next function_body_length
  public override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseControllerStyle()
      |> LiveStreamContainerViewController.lens.view.backgroundColor .~ .black

    _  = self.projectImageView
      |> UIImageView.lens.contentMode .~ .scaleAspectFill
      |> UIImageView.lens.clipsToBounds .~ true

    _  = self.loaderStackView
      |> UIStackView.lens.axis .~ .vertical
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.spacing .~ Styles.grid(2)
      |> UIStackView.lens.distribution .~ .fillEqually

    _  = self.loaderView
      |> UIView.lens.backgroundColor .~ .hex(0x353535)

    _  = self.loaderActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.animating .~ true

    _  = self.loaderLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 14)
      |> UILabel.lens.textColor .~ .white

    _ = self.separatorViews
      ||> UIView.lens.backgroundColor .~ .white
      ||> UIView.lens.alpha .~ 0.2

    _  = self.titleStackView
      |> UIStackView.lens.axis .~ .horizontal
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.distribution .~ .fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(4))

    _  = self.availableForLabel
      |> UILabel.lens.font .~ UIFont.ksr_footnote(size: 11).italicized
      |> UILabel.lens.textColor .~ .white

    _  = self.detailsStackView
      |> UIStackView.lens.axis .~ .vertical
      |> UIStackView.lens.distribution .~ .fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(4))
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _  = self.subscribeStackView
      |> UIStackView.lens.axis .~ .horizontal
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.distribution .~ .fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(3)
      |> UIStackView.lens.layoutMargins .~ .init(top: 0,
                                                 left: Styles.grid(4),
                                                 bottom: Styles.grid(4),
                                                 right: Styles.grid(4))

    let creatorLabelFont = self.traitCollection.isRegularRegular
      ? UIFont.ksr_title3(size: 18)
      : UIFont.ksr_title3(size: 14)

    let creatorLabelBaseAttributes = [
      NSFontAttributeName: creatorLabelFont,
      NSForegroundColorAttributeName: UIColor.white
    ]
    let creatorLabelBoldAttributes = [
      NSFontAttributeName: creatorLabelFont.bolded
    ]

    _  = self.creatorAvatarLabel
      |> SimpleHTMLLabel.lens.numberOfLines .~ 0
      |> SimpleHTMLLabel.lens.textColor .~ .white
      |> SimpleHTMLLabel.lens.baseAttributes .~ creatorLabelBaseAttributes
      |> SimpleHTMLLabel.lens.boldAttributes .~ creatorLabelBoldAttributes

    _  = self.creatorAvatarImageView
      |> UIImageView.lens.layer.masksToBounds .~ true

    self.creatorAvatarWidthConstraint.constant = self.traitCollection.isRegularRegular
      ? Styles.grid(10) : Styles.grid(5)

    _  = self.liveStreamTitleLabel
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.font %~~ { _, l in
        l.traitCollection.isRegularRegular ? .ksr_title2() : .ksr_title2(size: 18)
      }
      |> UILabel.lens.textColor .~ .white

    _  = self.liveStreamParagraphLabel
      |> UILabel.lens.numberOfLines .~ 0
      |> UILabel.lens.font %~~ { _, l in
        l.traitCollection.isRegularRegular ? .ksr_body() : .ksr_body(size: 14)
      }
      |> UILabel.lens.textColor .~ .white

    _  = self.subscribeLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 13)
      |> UILabel.lens.numberOfLines .~ 3
      |> UILabel.lens.textColor .~ .white

    _  = self.subscribeActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.animating .~ false

    _  = self.subscribeButton
      |> whiteBorderContainerButtonStyle
      |> UIButton.lens.imageEdgeInsets .~ UIEdgeInsets(right: -Styles.grid(1))
      |> UIButton.lens.tintColor .~ self.subscribeButton.currentTitleColor
      |> UIButton.lens.contentEdgeInsets .~ .init(topBottom: 10.0, leftRight: Styles.grid(2))

    _  = self.subscribeButton.semanticContentAttribute = .forceRightToLeft

    _  = self.detailsLoadingActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true
      |> UIActivityIndicatorView.lens.animating .~ false

    _  = self.navBarTitleStackViewBackgroundView
      |> UIView.lens.layer.cornerRadius .~ 2
      |> UIView.lens.layer.masksToBounds .~ true
      |> UIView.lens.backgroundColor .~ UIColor.black.withAlphaComponent(0.5)

    _  = self.navBarTitleStackView
      |> UIStackView.lens.axis .~ .horizontal
      |> UIStackView.lens.alignment .~ .center
      |> UIStackView.lens.distribution .~ .fill
      |> UIStackView.lens.translatesAutoresizingMaskIntoConstraints .~ false
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.layoutMargins .~ .init(leftRight: Styles.grid(2))

    _  = self.navBarLiveDotImageView
      |> UIImageView.lens.image .~ UIImage(named: "live-dot")
      |> UIImageView.lens.contentMode .~ .scaleAspectFit
      |> UIImageView.lens.contentHuggingPriorityForAxis(.horizontal) .~ UILayoutPriorityDefaultHigh

    _  = self.navBarTitleLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.textAlignment .~ .center

    _ = self.watchingBadgeView
      |> UIView.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.1)
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))
      |> roundedStyle()

    _ = self.watchingLabel
      |> UILabel.lens.textColor .~ .white
      |> UILabel.lens.font .~ .ksr_headline(size: 12)

    _ = [self.titleStackView, self.detailsStackView, self.subscribeStackView]
      ||> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      ||> UIStackView.lens.layoutMargins %~~ { _, s in
        s.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(12))
          : .init(all: Styles.grid(4))
    }

    if self.traitCollection.isVerticallyCompact {
      self.videoContainerAspectRatioConstraint_4_3.isActive = false
      self.videoContainerAspectRatioConstraint_16_9.isActive = true
      self.view.addConstraint(self.videoContainerAspectRatioConstraint_16_9)
      self.view.removeConstraint(self.videoContainerAspectRatioConstraint_4_3)
    } else {
      self.videoContainerAspectRatioConstraint_4_3.isActive = true
      self.videoContainerAspectRatioConstraint_16_9.isActive = false
      self.view.removeConstraint(self.videoContainerAspectRatioConstraint_16_9)
      self.view.addConstraint(self.videoContainerAspectRatioConstraint_4_3)
    }

    self.gradientView.startPoint = .zero
    self.gradientView.endPoint = .init(x: 0, y: 1)
    self.gradientView.setGradient([(UIColor.black.withAlphaComponent(0.5), 0),
                                   (UIColor.black.withAlphaComponent(0), 1.0)])
  }

  //swiftlint:disable:next function_body_length
  public override func bindViewModel() {
    super.bindViewModel()

    NotificationCenter.default
      .addObserver(forName: Notification.Name.ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.eventDetailsViewModel.inputs.userSessionStarted()
    }

    self.eventDetailsViewModel.outputs.openLoginToutViewController
      .observeValues { [weak self] _ in
        self?.openLoginTout()
    }

    self.viewModel.outputs.createAndConfigureLiveStreamViewController
      .observeForUI()
      .observeValues { [weak self] _, userId, event in
        guard let _self = self else { return }
        _self.liveStreamViewController?.configureWith(
          event: event,
          userId: userId,
          delegate: _self,
          liveStreamService: AppEnvironment.current.liveStreamService
        )
    }

    self.eventDetailsViewModel.outputs.retrievedLiveStreamEvent
      .observeValues { [weak self] in self?.viewModel.inputs.retrievedLiveStreamEvent(event: $0) }

    self.viewModel.outputs.videoViewControllerHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.liveStreamViewController?.view.isHidden = $0
    }

    self.projectImageView.rac.imageUrl = self.viewModel.outputs.projectImageUrl

    self.loaderLabel.rac.text = self.viewModel.outputs.loaderText
    self.loaderStackView.rac.hidden = self.viewModel.outputs.loaderStackViewHidden

    self.viewModel.outputs.dismiss
      .observeForControllerAction()
      .observeValues { [weak self] in
        self?.dismiss(animated: true, completion: nil)
    }

    self.creatorAvatarLabel.rac.html = self.viewModel.outputs.creatorIntroText

    self.creatorAvatarImageView.rac.imageUrl = self.eventDetailsViewModel.outputs.creatorAvatarUrl

    self.navBarLiveDotImageView.rac.hidden = self.viewModel.outputs.navBarLiveDotImageViewHidden
    self.creatorAvatarLiveDotImageView.rac.hidden = self.viewModel.outputs.creatorAvatarLiveDotImageViewHidden
    self.watchingBadgeView.rac.hidden = self.viewModel.outputs.numberWatchingButtonHidden
    self.availableForLabel.rac.hidden = self.viewModel.outputs.availableForLabelHidden

    self.viewModel.outputs.titleViewText
      .observeForUI()
      .observeValues { [weak self] in
        self?.navBarTitleLabel.text = $0
        self?.view.setNeedsLayout()
    }

    self.liveStreamTitleLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamTitle
    self.liveStreamParagraphLabel.rac.text = self.eventDetailsViewModel.outputs.liveStreamParagraph
    self.subscribeLabel.rac.text = self.eventDetailsViewModel.outputs.subscribeLabelText
    self.subscribeButton.rac.title = self.eventDetailsViewModel.outputs.subscribeButtonText
    self.watchingLabel.rac.text = self.eventDetailsViewModel.outputs.numberOfPeopleWatchingText
    self.shareBarButtonItem.rac.enabled = self.eventDetailsViewModel.outputs.shareButtonEnabled

    self.eventDetailsViewModel.outputs.subscribeLabelHidden
      .observeForUI()
      .observeValues { [weak self] in
        self?.subscribeLabel.alpha = $0 ? 0 : 1
    }

    self.eventDetailsViewModel.outputs.configureShareViewModel
      .observeForUI()
      .observeValues { [weak self] in
        self?.shareViewModel.inputs.configureWith(shareContext: ShareContext.liveStream($0, $1))
    }

    self.eventDetailsViewModel.outputs.subscribeButtonImage
      .observeForUI()
      .observeValues { [weak self] in
        let imageName = $0.flatMap { $0 }.coalesceWith("")
        self?.subscribeButton.setImage(UIImage(named: imageName), for: .normal)
    }

    self.availableForLabel.rac.text = self.eventDetailsViewModel.outputs.availableForText

    self.detailsLoadingActivityIndicatorView.rac.animating = self.eventDetailsViewModel.outputs
      .animateActivityIndicator

    self.detailsContainerStackView.rac.hidden = self.eventDetailsViewModel.outputs.detailsStackViewHidden

    self.subscribeActivityIndicatorView.rac.animating = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.subscribeButton.rac.hidden = self.eventDetailsViewModel.outputs
      .animateSubscribeButtonActivityIndicator

    Signal.merge(
      self.viewModel.outputs.showErrorAlert,
      self.eventDetailsViewModel.outputs.showErrorAlert
    )
    .observeForUI()
    .observeValues { [weak self] in
      self?.present(UIAlertController.genericError($0), animated: true, completion: nil)
    }

    self.shareViewModel.outputs.showShareSheet
      .observeForControllerAction()
      .observeValues { [weak self] in self?.showShareSheet(controller: $0) }
  }

  private func openLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .liveStreamSubscribe)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  override public var prefersStatusBarHidden: Bool {
    return true
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.subscribeButton.layer.cornerRadius = self.subscribeButton.frame.size.height / 2
    self.watchingBadgeView.layer.cornerRadius = self.watchingBadgeView.frame.size.height / 2

    self.layoutNavBarTitle()
  }

  private func layoutNavBarTitle() {
    let stackViewSize = self.navBarTitleStackView.systemLayoutSizeFitting(
      CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))

    let newOrigin = CGPoint(x: (self.view.frame.size.width / 2) - (stackViewSize.width / 2),
                         y: self.navBarTitleStackViewBackgroundView.frame.origin.y)

    self.navBarTitleStackViewBackgroundView.frame = CGRect(
      origin: newOrigin,
      size: CGSize(width: stackViewSize.width, height: Styles.grid(5))
    )
  }

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

  // MARK: Subviews

  lazy var navBarTitleStackViewBackgroundView = { UIView() }()
  lazy var navBarTitleStackView = { UIStackView() }()
  lazy var navBarLiveDotImageView = { UIImageView() }()
  lazy var navBarTitleLabel = { UILabel() }()

  lazy private var closeBarButtonItem: UIBarButtonItem = {
    let closeBarButtonItem = UIBarButtonItem()
      |> closeBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(close))

    closeBarButtonItem.accessibilityLabel = localizedString(
      key: "Close_live_stream",
      defaultValue: "Close live stream"
    )

    closeBarButtonItem.accessibilityHint = localizedString(
      key: "Closes_the_live_stream",
      defaultValue: "Closes the live stream."
    )

    return closeBarButtonItem
  }()

  lazy private var shareBarButtonItem: UIBarButtonItem = {
    let shareBarButtonItem = UIBarButtonItem()
      |> shareBarButtonItemStyle
      |> UIBarButtonItem.lens.tintColor .~ .white
      |> UIBarButtonItem.lens.targetAction .~ (self, #selector(share))
      |> UIBarButtonItem.lens.enabled .~ false

    shareBarButtonItem.accessibilityLabel = localizedString(
      key: "Share_this_live_stream",
      defaultValue: "Share this live stream."
    )

    return shareBarButtonItem
  }()

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
}

extension LiveStreamContainerViewController: LiveStreamViewControllerDelegate {
  public func liveStreamViewControllerNumberOfPeopleWatchingChanged(controller: LiveStreamViewController?,
                                                                      numberOfPeople: Int) {
    self.eventDetailsViewModel.inputs.setNumberOfPeopleWatching(numberOfPeople: numberOfPeople)
  }

  public func liveStreamViewControllerStateChanged(controller: LiveStreamViewController?,
                                                     state: LiveStreamViewControllerState) {
    self.viewModel.inputs.liveStreamViewControllerStateChanged(state: state)
    self.eventDetailsViewModel.inputs.liveStreamViewControllerStateChanged(state: state)
  }
}
