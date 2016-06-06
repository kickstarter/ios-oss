import UIKit
import Library
import ReactiveCocoa
import KsApi
import ReactiveExtensions

internal final class ProjectMainCell: UITableViewCell, ValueCell {
  private let viewModel: ProjectMainCellViewModelType = ProjectMainCellViewModel()

  @IBOutlet internal weak var projectImageView: UIImageView!
  @IBOutlet internal weak var projectNameLabel: UILabel!
  @IBOutlet internal weak var creatorLabel: UILabel!
  @IBOutlet internal weak var blurbLabel: UILabel!
  @IBOutlet internal weak var categoryLabel: UILabel!
  @IBOutlet internal weak var locationLabel: UILabel!
  @IBOutlet internal weak var stateBannerView: UIView!
  @IBOutlet internal weak var stateBannerTitleLabel: UILabel!
  @IBOutlet internal weak var stateBannerMessageLabel: UILabel!
  @IBOutlet internal weak var backersCountLabel: UILabel!
  @IBOutlet internal weak var pledgedLabel: UILabel!
  @IBOutlet internal weak var goalLabel: UILabel!
  @IBOutlet internal weak var daysLabel: UILabel!
  @IBOutlet internal weak var progressBarView: UIView!
  @IBOutlet internal weak var progressHolderView: UIView!

  // swiftlint:disable function_body_length
  override internal func bindViewModel() {

    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName
    self.creatorLabel.rac.text = self.viewModel.outputs.creatorName
    self.blurbLabel.rac.text = self.viewModel.outputs.blurb
    self.categoryLabel.rac.text = self.viewModel.outputs.categoryName
    self.locationLabel.rac.text = self.viewModel.outputs.locationName
    self.stateBannerView.rac.hidden = self.viewModel.outputs.stateHidden
    self.stateBannerView.rac.backgroundColor = self.viewModel.outputs.stateColor
    self.stateBannerTitleLabel.rac.text = self.viewModel.outputs.stateTitle
    self.stateBannerMessageLabel.rac.text = self.viewModel.outputs.stateMessage
    self.backersCountLabel.rac.text = self.viewModel.outputs.backersCount
    self.pledgedLabel.rac.text = self.viewModel.outputs.pledged
    self.goalLabel.rac.text = self.viewModel.outputs.goal
    self.progressHolderView.rac.hidden = self.viewModel.outputs.progressHidden

    self.viewModel.outputs.progress
      .observeForUI()
      .observeNext { [weak element = progressBarView] progress in
        element?.layer.anchorPoint = CGPoint(x: CGFloat(0.5 / progress), y: 0.5)
        element?.transform = CGAffineTransformMakeScale(CGFloat(progress), 1.0)
    }

    self.viewModel.outputs.projectImageURL
      .observeForUI()
      .on(next: { [weak imageView = self.projectImageView] _ in
        imageView?.af_cancelImageRequest()
        imageView?.image = nil
      })
      .ignoreNil()
      .observeNext { [weak imageView = self.projectImageView] in imageView?.af_setImageWithURL($0) }
  }
  // swiftlint:enable function_body_length

  internal func configureWith(value value: Project) {
    self.viewModel.inputs.project(value)
  }
}
