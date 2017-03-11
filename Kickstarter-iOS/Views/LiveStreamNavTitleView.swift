import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import UIKit

internal final class LiveStreamNavTitleView: UIView {

  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var playbackStateLabel: UILabel!
  @IBOutlet private weak var playbackStateLabelContainer: UIView!
  @IBOutlet private weak var eyeImageView: UIImageView!
  @IBOutlet private weak var numberOfPeopleWatchingLabel: UILabel!
  @IBOutlet private weak var numberOfPeopleWatchingLabelContainer: UIView!
  @IBOutlet private weak var numberOfPeopleWatchingStackView: UIStackView!

  let viewModel: LiveStreamNavTitleViewModelType = LiveStreamNavTitleViewModel()

  //swiftlint:disable:next force_cast
  internal class func fromNib() -> LiveStreamNavTitleView {
    return UINib(nibName: Nib.LiveStreamNavTitleView.rawValue, bundle: .framework)
      .instantiate(withOwner: nil, options: nil)
      .first as! LiveStreamNavTitleView
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self.rootStackView
      |> UIStackView.lens.distribution .~ .equalCentering
      |> UIStackView.lens.spacing .~ Styles.grid(1)

    _ = self.numberOfPeopleWatchingStackView
      |> UIStackView.lens.spacing .~ Styles.grid(1)
      |> UIStackView.lens.alignment .~ .center

    _ = self.playbackStateLabelContainer
      |> roundedStyle()
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(1))

    _ = self.playbackStateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .white

    _ = self.numberOfPeopleWatchingLabelContainer
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ UIColor.black.withAlphaComponent(0.4)
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(1))

    _ = self.numberOfPeopleWatchingLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .white

    _ = self.eyeImageView
      |> UIImageView.lens.tintColor .~ .white
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.playbackStateLabel.rac.text =
      self.viewModel.outputs.playbackStateLabelText
        .on(value: { [weak self] _ in
          self?.layoutSubviews()
        })

    self.playbackStateLabelContainer.rac.backgroundColor =
      self.viewModel.outputs.playbackStateContainerBackgroundColor

    self.numberOfPeopleWatchingLabelContainer.rac.hidden =
      self.viewModel.outputs.numberOfPeopleWatchingContainerHidden

    self.numberOfPeopleWatchingLabel.rac.text = self.viewModel.outputs.numberOfPeopleWatchingLabelText
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let stackViewSize = self.systemLayoutSizeFitting(UILayoutFittingCompressedSize)

    guard let superview = self.superview else { return }

    let newOrigin = CGPoint(x: (superview.frame.size.width / 2) - (stackViewSize.width / 2),
                            y: self.frame.origin.y)

    self.frame = CGRect(
      origin: newOrigin,
      size: CGSize(width: stackViewSize.width, height: Styles.grid(5))
    )
  }

  public func configureWith(liveStreamEvent: LiveStreamEvent) {
    self.viewModel.inputs.configureWith(liveStreamEvent: liveStreamEvent)
  }

  public func set(numberOfPeopleWatching: Int) {
    self.viewModel.inputs.setNumberOfPeopleWatching(numberOfPeople: numberOfPeopleWatching)
  }
}
