import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardEmptyStateCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var filledHeartIconImageView: UIImageView!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var iconImageView: UIImageView!

  private let duration = 0.4
  private let hiddenHeartAlpha = CGFloat(0.0)
  private let visibleHeartAlpha = CGFloat(1.0)
  private let shrunkHeartTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
  private let expandedHearTransform = CGAffineTransform(scaleX: 1.0, y: 1.0)

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
      _ = self.filledHeartIconImageView
        |> UIImageView.lens.isHidden .~ true
    case .saved:
      self.messageLabel.text = Strings.Tap_the_heart_on_a_project_to_get_notified()
      self.titleLabel.text = Strings.No_saved_projects()

      NotificationCenter.default.addObserver(
        self,
        selector: #selector(animateToFilledHeart),
        name: .ksr_savedProjectEmptyStateTapped,
        object: nil
      )
      animateToFilledHeart()
    }
  }

  @objc internal func animateToFilledHeart() {
    UIView.animate(
      withDuration: self.duration,
      delay: 1.0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 0.0,
      options: .curveEaseInOut,
      animations: { [unowned self] in
        self.filledHeartIconImageView.alpha = self.hiddenHeartAlpha
        self.iconImageView.alpha = self.hiddenHeartAlpha
        self.iconImageView.transform = self.shrunkHeartTransform
        self.filledHeartIconImageView.transform = self.expandedHearTransform
        self.filledHeartIconImageView.alpha = self.visibleHeartAlpha
        },
      completion: { [unowned self] _ in self.animateToOutlineHeart() }
    )
  }

  internal func animateToOutlineHeart() {
    UIView.animate(
      withDuration: self.duration,
      delay: 0.6,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 0.0,
      options: .curveEaseInOut,
      animations: { [unowned self] in
        self.filledHeartIconImageView.alpha = self.hiddenHeartAlpha
        self.iconImageView.alpha = self.hiddenHeartAlpha
        self.filledHeartIconImageView.transform = self.shrunkHeartTransform
        self.iconImageView.transform = self.expandedHearTransform
        self.iconImageView.alpha = self.visibleHeartAlpha
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
