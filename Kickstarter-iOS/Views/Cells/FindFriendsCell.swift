import Foundation
import KsApi
import Library
import Prelude

final class FindFriendsCell: UITableViewCell, ValueCell, NibLoading {
  @IBOutlet fileprivate weak var arrowImageView: UIImageView!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  private let viewModel: FindFriendsCellViewModelType = FindFriendsCellViewModel()

  func configureWith(value: SettingsCellValue) {
    _ = self
      |> \.accessibilityTraits .~ value.cellType.accessibilityTraits

    self.viewModel.inputs.configure(with: value.user)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.viewModel.outputs.isDisabled
      .observeForUI()
      .observeValues { [weak self] (isDisabled) in
        self?.updateStyles(isDisabled: isDisabled)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    _ = titleLabel
      |> settingsTitleLabelStyle
      |> \.text .~ SettingsCellType.findFriends.title

    _ = arrowImageView
      |> settingsArrowViewStyle
  }

  private func updateStyles(isDisabled: Bool) {
    let titleLabelColor: UIColor = isDisabled ? .ksr_text_dark_grey_400 : .ksr_soft_black
    let accessibilityTraits = isDisabled ? UIAccessibilityTraits.notEnabled : UIAccessibilityTraits.button
    let accessibilityHint = isDisabled ? Strings.Following_Disabled_Info() : nil

    _ = self.arrowImageView
      |> \.isHidden .~ isDisabled

    _ = self
      |> \.accessibilityTraits .~ accessibilityTraits
      |> \.accessibilityHint .~ accessibilityHint

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ titleLabelColor
  }
}
