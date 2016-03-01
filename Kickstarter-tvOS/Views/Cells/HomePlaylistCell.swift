import UIKit
import ReactiveCocoa
import protocol Library.ViewModeledCellType

final class HomePlaylistCell: UICollectionViewCell, ViewModeledCellType {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var selectedIndicatorView: UIView!

  static var focusedTitleColor = UIColor.whiteColor()
  static var unfocusedTitleColor = UIColor(white: 1.0, alpha: 0.5)
  static let focusedFont: UIFont = {
    let descriptor = UIFontDescriptor.preferredFontDescriptorWithTextStyle(UIFontTextStyleCallout)
    let mediumDescriptor = descriptor.fontDescriptorWithSymbolicTraits(.TraitBold)
    return UIFont(descriptor: mediumDescriptor, size: 0.0)
  }()

  static let unfocusedFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)

  let viewModel = MutableProperty<HomePlaylistViewModel?>(nil)

  override func awakeFromNib() {
    super.awakeFromNib()
    render(focused: false)
  }

  override func bindViewModel() {
    titleLabel.rac_text <~ viewModel.producer.map { $0?.outputs.title }
  }

  override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
    coordinator.addCoordinatedAnimations({
      self.render(focused: self.focused)
    }, completion: nil)
  }

  func render(focused focused: Bool) {
    self.selectedIndicatorView.hidden = !focused
    self.titleLabel.font = focused ? HomePlaylistCell.focusedFont : HomePlaylistCell.unfocusedFont
    self.titleLabel.textColor = focused ? HomePlaylistCell.focusedTitleColor : HomePlaylistCell.unfocusedTitleColor
  }
}
