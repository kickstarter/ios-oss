import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import Result
import UIKit

internal final class LiveStreamEventDetailsViewController: UIViewController {
  @IBOutlet private weak var availableForLabel: UILabel!
  @IBOutlet private weak var detailsStackView: UIStackView!
  @IBOutlet private weak var goToProjectButton: UIButton!
  @IBOutlet private weak var goToProjectButtonContainerView: UIView!
  @IBOutlet private weak var liveStreamParagraphLabel: UILabel!
  @IBOutlet private weak var liveStreamTitleLabel: UILabel!
  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var separatorView: UIView!
  @IBOutlet private weak var subscribeActivityIndicatorView: UIActivityIndicatorView!
  @IBOutlet private weak var subscribeButton: UIButton!
  @IBOutlet private weak var subscribeLabel: UILabel!
  @IBOutlet private weak var subscribeStackView: UIStackView!

  fileprivate let viewModel: LiveStreamEventDetailsViewModelType
    = LiveStreamEventDetailsViewModel()

  public static func configuredWith(project: Project, liveStreamEvent: LiveStreamEvent,
                                    refTag: RefTag, presentedFromProject: Bool) ->
    LiveStreamEventDetailsViewController {

      let vc = Storyboard.LiveStream.instantiate(LiveStreamEventDetailsViewController.self)
      vc.viewModel.inputs.configureWith(project: project, liveStreamEvent: liveStreamEvent,
                                        refTag: refTag, presentedFromProject: presentedFromProject)

      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.subscribeButton.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
    self.goToProjectButton.addTarget(self, action: #selector(goToProjectButtonTapped), for: [.touchUpInside])

    NotificationCenter.default
      .addObserver(forName: .ksr_sessionStarted, object: nil, queue: nil) { [weak self] _ in
        self?.viewModel.inputs.userSessionStarted()
    }

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    self.subscribeButton.layer.cornerRadius = self.subscribeButton.frame.size.height / 2
  }

  //swiftlint:disable:next function_body_length
  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseLiveStreamControllerStyle()
      |> UIViewController.lens.view.backgroundColor .~ .ksr_dark_grey_500

    _  = self.availableForLabel
      |> UILabel.lens.font .~ UIFont.ksr_footnote(size: 11).italicized
      |> UILabel.lens.textColor .~ .white

    _  = self.detailsStackView
      |> UIStackView.lens.axis .~ .vertical
      |> UIStackView.lens.distribution .~ .fill
      |> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      |> UIStackView.lens.layoutMargins .~ .init(all: Styles.grid(4))
      |> UIStackView.lens.spacing .~ Styles.grid(3)

    _ = self.separatorView
      |> UIView.lens.backgroundColor .~ UIColor.white.withAlphaComponent(0.2)

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
      |> UILabel.lens.textColor .~ .ksr_grey_500

    _  = self.subscribeLabel
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 13)
      |> UILabel.lens.numberOfLines .~ 3
      |> UILabel.lens.textColor .~ .white

    _  = self.subscribeActivityIndicatorView
      |> UIActivityIndicatorView.lens.activityIndicatorViewStyle .~ .white
      |> UIActivityIndicatorView.lens.hidesWhenStopped .~ true

    _  = self.subscribeButton
      |> lightSubscribeButtonStyle

    _ = [self.detailsStackView, self.subscribeStackView]
      ||> UIStackView.lens.layoutMarginsRelativeArrangement .~ true
      ||> UIStackView.lens.layoutMargins %~~ { _, s in
        s.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(12))
          : .init(all: Styles.grid(4))
    }

    _ = self.goToProjectButton
      |> UIButton.lens.titleColor(forState: .normal) .~ .white
      |> liveStreamGoToProjectStyle
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.openLoginToutViewController
      .observeForControllerAction()
      .observeValues { [weak self] _ in
        self?.openLoginTout()
    }

    self.liveStreamTitleLabel.rac.text = self.viewModel.outputs.liveStreamTitle
    self.liveStreamParagraphLabel.rac.text = self.viewModel.outputs.liveStreamParagraph
    self.subscribeLabel.rac.text = self.viewModel.outputs.subscribeLabelText
    self.subscribeButton.rac.title = self.viewModel.outputs.subscribeButtonText
    self.subscribeButton.rac.accessibilityHint
      = self.viewModel.outputs.subscribeButtonAccessibilityHint
    self.subscribeButton.rac.accessibilityLabel
      = self.viewModel.outputs.subscribeButtonAccessibilityLabel

    self.subscribeLabel.rac.alpha = self.viewModel.outputs.subscribeLabelAlpha

    self.viewModel.outputs.subscribeButtonImage
      .observeForUI()
      .observeValues { [weak self] imageName in
        self?.subscribeButton.setImage(imageName.flatMap { image(named: $0) },
                                       for: .normal)
    }

    self.availableForLabel.rac.text = self.viewModel.outputs.availableForText
    self.availableForLabel.rac.hidden = self.viewModel.outputs.availableForLabelHidden

    self.subscribeActivityIndicatorView.rac.animating = self.viewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.subscribeButton.rac.hidden = self.viewModel.outputs
      .animateSubscribeButtonActivityIndicator

    self.goToProjectButtonContainerView.rac.hidden = self.viewModel.outputs.goToProjectButtonContainerHidden

    self.viewModel.outputs.showErrorAlert
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

  private func openLoginTout() {
    let vc = LoginToutViewController.configuredWith(loginIntent: .liveStreamSubscribe)
    let nav = UINavigationController(rootViewController: vc)
    nav.modalPresentationStyle = .formSheet

    self.present(nav, animated: true, completion: nil)
  }

  @objc private func subscribeButtonTapped() {
    self.viewModel.inputs.subscribeButtonTapped()
  }

  @objc private func goToProjectButtonTapped() {
    self.viewModel.inputs.goToProjectButtonTapped()
  }
}
