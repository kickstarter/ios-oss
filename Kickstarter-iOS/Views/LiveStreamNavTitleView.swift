import KsApi
import Library
import LiveStream
import Prelude
import ReactiveSwift
import UIKit

internal protocol LiveStreamNavTitleViewDelegate: class {
  func liveStreamNavTitleView(_ navTitleView: LiveStreamNavTitleView,
                              requiresLayoutWithPreferredSize size: CGSize)
}

internal final class LiveStreamNavTitleView: UIView {

  @IBOutlet private weak var rootStackView: UIStackView!
  @IBOutlet private weak var playbackStateLabel: UILabel!
  @IBOutlet private weak var playbackStateLabelContainer: UIView!
  @IBOutlet private weak var eyeImageView: UIImageView!
  @IBOutlet private weak var numberOfPeopleWatchingLabel: UILabel!
  @IBOutlet private weak var numberOfPeopleWatchingLabelContainer: UIView!
  @IBOutlet private weak var numberOfPeopleWatchingStackView: UIStackView!

  private weak var delegate: LiveStreamNavTitleViewDelegate?
  internal let viewModel: LiveStreamNavTitleViewModelType = LiveStreamNavTitleViewModel()

  internal class func fromNib() -> LiveStreamNavTitleView? {
    guard let view = UINib(nibName: Nib.LiveStreamNavTitleView.rawValue, bundle: .framework)
      .instantiate(withOwner: nil, options: nil)
      .first as? LiveStreamNavTitleView else {
        assertionFailure("Nib not found")
        return nil
    }

    return view
  }

  internal override func layoutSubviews() {
    super.layoutSubviews()

    self.delegate?.liveStreamNavTitleView(
      self,
      requiresLayoutWithPreferredSize: self.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
    )
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
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.gridHalf(1), leftRight: Styles.grid(1))

    _ = self.playbackStateLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .white

    _ = self.numberOfPeopleWatchingLabelContainer
      |> roundedStyle()
      |> UIView.lens.backgroundColor .~ UIColor.ksr_grey_900.withAlphaComponent(0.4)
      |> UIView.lens.layoutMargins .~ .init(topBottom: Styles.gridHalf(1), leftRight: Styles.grid(1))

    _ = self.numberOfPeopleWatchingLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .white

    _ = self.eyeImageView
      |> UIImageView.lens.tintColor .~ .white
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.playbackStateLabel.rac.text = self.viewModel.outputs.playbackStateLabelText

    self.playbackStateLabelContainer.rac.backgroundColor =
      self.viewModel.outputs.playbackStateContainerBackgroundColor

    self.numberOfPeopleWatchingLabelContainer.rac.hidden =
      self.viewModel.outputs.numberOfPeopleWatchingContainerHidden

    self.numberOfPeopleWatchingLabel.rac.text = self.viewModel.outputs.numberOfPeopleWatchingLabelText
  }

  public func configureWith(liveStreamEvent: LiveStreamEvent, delegate: LiveStreamNavTitleViewDelegate?) {
    self.delegate = delegate
    self.viewModel.inputs.configureWith(liveStreamEvent: liveStreamEvent)
  }

  public func set(numberOfPeopleWatching: Int) {
    self.viewModel.inputs.setNumberOfPeopleWatching(numberOfPeople: numberOfPeopleWatching)
  }
}
