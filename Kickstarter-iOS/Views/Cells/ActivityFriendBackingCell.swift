import KsApi
import Library
import Prelude
import ReactiveCocoa
import UIKit

internal final class ActivityFriendBackingCell: UITableViewCell, ValueCell {
  private let viewModel: ActivityFriendBackingViewModel = ActivityFriendBackingViewModel()

  @IBOutlet private weak var friendImageView: UIImageView!
  @IBOutlet private weak var friendTitleLabel: UILabel!
  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var creatorNameLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!

  override func bindViewModel() {
    self.rac.accessibilityLabel = self.viewModel.outputs.cellAccessibilityLabel
    self.rac.accessibilityValue = self.viewModel.outputs.cellAccessibilityValue
    self.friendTitleLabel.rac.attributedText = self.viewModel.outputs.friendTitle
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.creatorNameLabel.rac.text = self.viewModel.outputs.creatorName

    self.viewModel.outputs.friendImageURL
      .observeForUI()
      .on(next: { [weak friendImageView] _ in
        friendImageView?.af_cancelImageRequest()
        friendImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak friendImageView] url in
        friendImageView?.af_setImageWithURL(url)
    }

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(next: { [weak projectImageView] _ in
        projectImageView?.af_cancelImageRequest()
        projectImageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak projectImageView] url in
        projectImageView?.af_setImageWithURL(url)
    }
  }

  override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.backgroundColor .~ .whiteColor()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(3), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(3), leftRight: Styles.grid(4))
    }

    self.friendTitleLabel
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.projectNameLabel
      |> UILabel.lens.font .~ .ksr_body(size: 18)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.creatorNameLabel
      |> UILabel.lens.font .~ .ksr_caption1()
      |> UILabel.lens.textColor .~ .ksr_text_navy_500
  }

  func configureWith(value value: Activity) {
    self.viewModel.inputs.activity(value)
  }
}
