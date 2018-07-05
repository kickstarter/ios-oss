import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardEmptyStateCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var iconImageView: UIImageView!
  @IBOutlet private weak var animatedIconImageVIew: UIImageView!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!

  internal var thisImage = UIImageView()

  internal func configureWith(value: ProfileProjectsType) {
    switch value {
    case .backed:
      self.messageLabel.text = Strings.Pledge_to_your_favorites_then_view_all_the_projects()
      self.titleLabel.text = Strings.Explore_creative_projects()
      _ = self.iconImageView
        |> UIImageView.lens.image
        .~ UIImage(named: "icon--eye",
                   in: .framework,
                   compatibleWith: nil)
    case .saved:
      self.messageLabel.text = Strings.Tap_the_heart_on_a_project_to_get_notified()
      self.titleLabel.text = Strings.No_saved_projects()
      animateToFilledHeart()
    }
  }

  internal func animateToFilledHeart() {
    UIView.animate(
      withDuration: 0.4,
      delay: 1.0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 0.0,
      options: .curveEaseInOut,
      animations: {
        self.animatedIconImageVIew.alpha = 0.0
        self.iconImageView.alpha = 0.0
        self.iconImageView.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.animatedIconImageVIew.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.animatedIconImageVIew.alpha = 1.0
        },
      completion: { _ in self.animateToHeartOutline() })
  }

  internal func animateToHeartOutline() {
    UIView.animate(
      withDuration: 0.4,
      delay: 0.6,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 0.0,
      options: .curveEaseInOut,
      animations: {
        self.iconImageView.alpha = 0.0
        self.animatedIconImageVIew.alpha = 0.0
        self.animatedIconImageVIew.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.iconImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.iconImageView.alpha = 1.0
    },
      completion: nil)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(4), leftRight: Styles.grid(20))
          : .init(topBottom: Styles.grid(10), leftRight: Styles.grid(3))
    }
    _ = self.messageLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_400
      |> UILabel.lens.font .~ UIFont.ksr_body(size: 15.0)

    _ = self.titleLabel
      |> UILabel.lens.textColor .~ .ksr_text_dark_grey_900
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 21.0)

    _ = self.iconImageView
    |> UIImageView.lens.tintColor .~ .ksr_text_dark_grey_900
  }
}
