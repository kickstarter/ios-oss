import UIKit
import ReactiveCocoa
import Library

private let focusedTitleColor = UIColor.whiteColor()
private let unfocusedTitleColor = UIColor(white: 1.0, alpha: 0.5)

final class HomePlaylistCell: UICollectionViewCell, ValueCell {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var selectedIndicatorView: UIView!

  static let focusedFont: UIFont = {
    let descriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleCallout)
    let mediumDescriptor = descriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
    return UIFont(descriptor: mediumDescriptor, size: 0.0)
  }()

  static let unfocusedFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

  private var viewModel = HomePlaylistViewModel()

  override func awakeFromNib() {
    super.awakeFromNib()

    titleLabel.rac.text = self.viewModel.outputs.title.ignoreNil()

    render(focused: false)
  }

  func configureWith(value value: Playlist) {
    self.viewModel.inputs.playlist(value)
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext,
                                        withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({
      self.render(focused: self.focused)
    }, completion: nil)
  }

  func render(focused focused: Bool) {
    self.selectedIndicatorView.hidden = !focused
    self.titleLabel.font = focused ? HomePlaylistCell.focusedFont : HomePlaylistCell.unfocusedFont
    self.titleLabel.textColor = focused ? focusedTitleColor : unfocusedTitleColor
  }
}
