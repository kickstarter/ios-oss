import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class LiveStreamCountdownViewController: UIViewController {
  @IBOutlet private weak var creatorAvatar: UIImageView!
  @IBOutlet private var countdownColons: [UILabel]?
  @IBOutlet private weak var countdownContainerStackView: UIStackView!
  @IBOutlet private weak var countdownStackView: UIStackView!
  @IBOutlet private var countdownLabels: [UILabel]?
  @IBOutlet private weak var daysLabel: UILabel!
  @IBOutlet private weak var gradientView: GradientView!
  @IBOutlet private weak var hoursLabel: UILabel!
  @IBOutlet private weak var liveStreamTitle: UILabel!
  @IBOutlet private weak var liveStreamParagraph: UILabel!
  @IBOutlet private weak var minutesLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var secondsLabel: UILabel!
  @IBOutlet private weak var separator: UIImageView!
  @IBOutlet private weak var subscribeButton: UIButton!
  @IBOutlet private weak var detailsStackViewTopConstraint: NSLayoutConstraint!

  private let viewModel: LiveStreamCountdownViewModelType = LiveStreamCountdownViewModel()
  private var timerProducer: Disposable?

  internal static func configuredWith(project project: Project)
    -> LiveStreamCountdownViewController {

      let vc = Storyboard.LiveStream.instantiate(LiveStreamCountdownViewController)
      vc.viewModel.inputs.configureWith(project: project, now: NSDate())
      return vc
  }

  internal override func viewDidLoad() {
    super.viewDidLoad()

    self.viewModel.inputs.viewDidLoad()
  }

  internal override func bindStyles() {
    super.bindStyles()

    self.projectImageView
      |> UIImageView.lens.contentMode .~ .ScaleAspectFill

    self.countdownStackView
      |> UIStackView.lens.alignment .~ .Center

    self.countdownContainerStackView
      |> UIStackView.lens.alignment .~ .Center
      |> UIStackView.lens.spacing .~ Styles.grid(6)
      |> UIStackView.lens.distribution .~ .FillProportionally

    self.countdownLabels?.forEach { label in
      label
        |> UILabel.lens.textAlignment .~ .Center
        |> UILabel.lens.numberOfLines .~ 2
        |> UILabel.lens.textColor .~ .whiteColor()
    }

    self.countdownColons?.forEach { label in
      label
        |> UILabel.lens.textAlignment .~ .Center
        |> UILabel.lens.numberOfLines .~ 2
        |> UILabel.lens.textColor .~ .whiteColor()
        |> UILabel.lens.font .~ .ksr_title1(size: 24)
    }
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.daysLabel.rac.attributedText = self.viewModel.outputs.daysString.map { [weak self] in
      self?.attributedCountdownString($0, suffix: $1)
      }.ignoreNil()

    self.hoursLabel.rac.attributedText = self.viewModel.outputs.hoursString.map { [weak self] in
      self?.attributedCountdownString($0, suffix: $1)
      }.ignoreNil()

    self.minutesLabel.rac.attributedText = self.viewModel.outputs.minutesString.map { [weak self] in
      self?.attributedCountdownString($0, suffix: $1)
      }.ignoreNil()

    self.secondsLabel.rac.attributedText = self.viewModel.outputs.secondsString.map { [weak self] in
      self?.attributedCountdownString($0, suffix: $1)
      }.ignoreNil()

    self.timerProducer = timer(1, onScheduler: QueueScheduler(queue: dispatch_get_main_queue()))
      .startWithNext { [weak self] in
        self?.viewModel.inputs.setNow($0)
    }

    self.viewModel.outputs.projectImageUrl
      .observeForUI()
      .observeNext { [weak self] in self?.projectImageView.af_setImageWithURL($0) }

    self.viewModel.outputs.categoryId.observeNext { [weak self] in
      let (startColor, endColor) = discoveryGradientColors(forCategoryId: $0)
      self?.gradientView.setGradient([(startColor, 0.0), (endColor, 1.0)])
    }
  }

  deinit {
    self.timerProducer?.dispose()
  }

  private func attributedCountdownString(prefix: String, suffix: String) -> NSAttributedString {
    let prefixAttributes = [NSFontAttributeName : UIFont.ksr_title1(size: 24)]
    let suffixAttributes = [NSFontAttributeName : UIFont.ksr_headline(size: 14)]

    let prefix = NSMutableAttributedString(string: prefix, attributes: prefixAttributes)
    let suffix = NSAttributedString(string: "\n\(suffix)", attributes: suffixAttributes)
    prefix.appendAttributedString(suffix)

    return NSAttributedString(attributedString: prefix)
  }
}