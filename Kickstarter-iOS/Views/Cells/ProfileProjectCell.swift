import Foundation
import UIKit
import Library
import KsApi

internal final class ProfileProjectCell: UICollectionViewCell, ValueCell {
  private let viewModel: ProfileProjectCellViewModelType = ProfileProjectCellViewModel()

  @IBOutlet private weak var projectNameLabel: UILabel!
  @IBOutlet private weak var projectImageView: UIImageView!
  @IBOutlet private weak var progressView: UIView!
  @IBOutlet private weak var progressBarView: UIView!
  @IBOutlet private weak var stateBannerView: UIView!
  @IBOutlet private weak var stateLabel: UILabel!

  internal func configureWith(value value: Project) {
    self.viewModel.inputs.project(value)
  }

  internal override func bindViewModel() {
    self.projectNameLabel.rac.text = self.viewModel.outputs.projectName

    self.viewModel.outputs.photoURL
      .observeForUI()
      .on(next: { [weak self] _ in
        self?.projectImageView.af_cancelImageRequest()
        self?.projectImageView.image = nil
        })
      .ignoreNil()
      .observeNext { [weak self] url in
        self?.projectImageView.af_setImageWithURL(url)
    }

    self.progressView.rac.hidden = self.viewModel.outputs.progressHidden
    self.viewModel.outputs.progress
      .observeForUI()
      .observeNext { [weak element = progressBarView] progress in
        element?.layer.anchorPoint = CGPoint(x: CGFloat(0.5 / progress), y: 0.5)
        element?.transform = CGAffineTransformMakeScale(CGFloat(progress), 1.0)
    }

    self.stateBannerView.rac.hidden = self.viewModel.outputs.stateHidden
    self.stateBannerView.rac.backgroundColor = self.viewModel.outputs.stateBackgroundColor
    self.stateLabel.rac.text = self.viewModel.outputs.state
  }
}
