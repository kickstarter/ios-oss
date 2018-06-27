import KsApi
import Library
import Prelude
import UIKit

internal final class BackerDashboardEmptyStateCell: UITableViewCell, ValueCell {

  @IBOutlet private weak var iconImageView: UIImageView!
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
      _ = self.iconImageView
        |> UIImageView.lens.image
        .~ UIImage(named: "icon--heart-outline",
                   in: .framework,
                   compatibleWith: nil)

      let image = UIImage(named: "icon--heart-outline",
                                         in: .framework,
                                         compatibleWith: nil)

      let thisImage = UIImage(named: "icon--heart",
                                 in: .framework,
                                 compatibleWith: nil)

      let images = [image!, thisImage!]

            UIView.animate(
                          withDuration: 0.5,
                          delay: 0.0,
                          usingSpringWithDamping: 0.0,
                          initialSpringVelocity: 0.1,
                          options: [.repeat, .autoreverse, .curveEaseOut],
                          animations: {
                            self.iconImageView.alpha = 1.0
                            self.iconImageView.image = UIImage.animatedImage(with: images, duration: 2.0)
                          },
                          completion: nil)}
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

  internal func animateHeart() {
//    self.iconImageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)

    let imageTwo = UIImage(named: "icon--heart",
                             in: .framework,
                             compatibleWith: nil)

    let this = UIImageView()
    this.image = imageTwo



//    let images: [UIImage] = [image!, imageTwo!]
//
//    let thisToo = UIImageView()
//    this.image = image
//

    //self.iconImageView.image = UIImage.animatedImage(with: images, duration: 2.0)

//    UIView.animate(
//      withDuration: 0.8,
//      delay: 0.0,
//      usingSpringWithDamping: 0.6,
//      initialSpringVelocity: 0.8,
//      options:  .repeat,
//      animations: {
//        self.iconImageView.alpha = 1.0
//        self.iconImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
//        self.iconImageView.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
//        self.iconImageView.image = UIImage.animatedImage(with: images, duration: 1)
//    },
//      completion: nil
//    )
  }
}
