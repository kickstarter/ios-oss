import Foundation
import KsApi
import Library
import Prelude

final class FindFriendsCell: UITableViewCell, ValueCell, NibLoading {
  @IBOutlet fileprivate weak var arrowImageView: UIImageView!
  @IBOutlet fileprivate weak var descriptionLabelContainer: UIView!
  @IBOutlet fileprivate weak var disabledDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var separatorView: UIView!
  @IBOutlet fileprivate weak var titleLabel: UILabel!

  private let viewModel: FindFriendsCellViewModelType = FindFriendsCellViewModel()

  func configureWith(value: SettingsCellValue) {
    let user = value.user
    self.viewModel.inputs.configure(with: user)
  }

  override func bindViewModel() {
    super.bindViewModel()

    self.descriptionLabelContainer.rac.hidden = self.viewModel.outputs.disabledDescriptionLabelShouldHide

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
      |> UILabel.lens.text .~ SettingsCellType.findFriends.title

    _ = arrowImageView
      |> settingsArrowViewStyle

    _ = disabledDescriptionLabel
      |> settingsDescriptionLabelStyle
      |> UILabel.lens.text
      .~ "Following must be on to find Facebook friends. Following can be changed in Account > Privacy."

    _ = descriptionLabelContainer
      |> UIView.lens.backgroundColor .~ .ksr_grey_200

    _ = separatorView
      |> settingsSeparatorStyle
  }

  private func updateStyles(isDisabled: Bool) {
    let disabledArrowStyle = UIImageView.lens.tintColor
      .~ .ksr_text_dark_grey_400
    let arrowStyle = isDisabled ? disabledArrowStyle : settingsArrowViewStyle
    let backgroundColor: UIColor = isDisabled ? .ksr_grey_200 : .white
    let titleLabelColor: UIColor = isDisabled ? .ksr_text_dark_grey_400 : .ksr_text_dark_grey_500
    let lineLayerColor: UIColor = isDisabled ? .ksr_grey_400 : .ksr_grey_500

    _ = self.arrowImageView |> arrowStyle
    _ = self
      |> UIView.lens.backgroundColor .~ backgroundColor
    _ = self.titleLabel
      |> UILabel.lens.textColor .~ titleLabelColor
    _ = self.separatorView
      |> UIView.lens.backgroundColor .~ lineLayerColor
  }
}
