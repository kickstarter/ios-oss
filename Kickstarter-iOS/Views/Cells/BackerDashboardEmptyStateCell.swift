import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardEmptyStateCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var filledHeartIconImageView: UIImageView!
  @IBOutlet private weak var messageLabel: UILabel!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var iconImageView: UIImageView!

  private var isAnimating: Bool = false
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

    guard self.isAnimating == false else { return }

    UIView.animate(
      withDuration: self.duration,
      delay: 1.0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 0.0,
      options: .curveEaseInOut,
      animations: { [weak self] in

        guard let _self = self else { return }

        _self.isAnimating = true

        _self.filledHeartIconImageView.alpha = _self.hiddenHeartAlpha
        _self.iconImageView.alpha = _self.hiddenHeartAlpha
        _self.iconImageView.transform = _self.shrunkHeartTransform
        _self.filledHeartIconImageView.transform = _self.expandedHearTransform
        _self.filledHeartIconImageView.alpha = _self.visibleHeartAlpha
        },
      completion: { [weak self] _ in
        guard let _self = self else { return }
        _self.animateToOutlineHeart()
      }
    )
  }

  internal func animateToOutlineHeart() {
    UIView.animate(
      withDuration: self.duration,
      delay: 0.6,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 0.0,
      options: .curveEaseInOut,
      animations: { [weak self] in

        guard let _self = self else { return }

        _self.filledHeartIconImageView.alpha = _self.hiddenHeartAlpha
        _self.iconImageView.alpha = _self.hiddenHeartAlpha
        _self.filledHeartIconImageView.transform = _self.shrunkHeartTransform
        _self.iconImageView.transform = _self.expandedHearTransform
        _self.iconImageView.alpha = _self.visibleHeartAlpha
      },
      completion: { [weak self] _ in

        guard let _self = self else { return }
        _self.isAnimating = false
      }
    )
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
      |> UILabel.lens.textColor .~ .ksr_soft_black
      |> UILabel.lens.font .~ UIFont.ksr_headline(size: 21.0)

    _ = self.iconImageView
    |> UIImageView.lens.tintColor .~ .ksr_soft_black
  }
}
