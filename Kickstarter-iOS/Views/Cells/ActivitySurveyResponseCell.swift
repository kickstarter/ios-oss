import KsApi
import Library
import Prelude
import UIKit

internal protocol ActivitySurveyResponseCellDelegate: class {
  /// Called when the delegate should respond to the survey.
  func activityTappedRespondNow(forSurveyResponse surveyResponse: SurveyResponse)
}

internal final class ActivitySurveyResponseCell: UITableViewCell, ValueCell {
  private let viewModel: ActivitySurveyResponseCellViewModelType = ActivitySurveyResponseCellViewModel()
  internal weak var delegate: ActivitySurveyResponseCellDelegate?

  @IBOutlet private weak var cardView: UIView!
  @IBOutlet private weak var containerView: UIView!
  @IBOutlet private weak var creatorImageView: CircleAvatarImageView!
  @IBOutlet private weak var creatorNameLabel: UILabel!
  @IBOutlet private weak var respondNowButton: UIButton!
  @IBOutlet private weak var rewardSurveysCountLabel: UILabel!
  @IBOutlet private weak var surveyLabel: UILabel!
  @IBOutlet private weak var topLineView: UIView!

  internal override func awakeFromNib() {
    super.awakeFromNib()
    self.respondNowButton.addTarget(self,
                                    action: #selector(respondNowTapped),
                                    forControlEvents: .TouchUpInside)
  }

  internal func configureWith(value value: (surveyResponse: SurveyResponse, count: Int, position: Int)) {
    self.viewModel.inputs.configureWith(surveyResponse: value.surveyResponse, count: value.count,
                                        position: value.position)
  }

  internal override func bindStyles() {
    self
      |> feedTableViewCellStyle

    self.cardView
      |> dropShadowStyle()

    self.containerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    self.creatorNameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.respondNowButton
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.backgroundColor(forState: .Normal) .~ .clearColor()
      |> UIButton.lens.titleColor(forState: .Normal) .~ .ksr_green_700
      |> UIButton.lens.titleColor(forState: .Highlighted) .~ .ksr_navy_700
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.discovery_survey_button_respond_now() }
      |> UIButton.lens.tintColor .~ .ksr_green_700
      |> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: Styles.grid(4))
      |> UIButton.lens.image(forState: .Normal) %~ { _ in Library.image(named: "respond-icon") }
      |> UIButton.lens.contentEdgeInsets .~ .init(top: Styles.grid(3), left: 0, bottom: Styles.grid(1),
                                                  right: 0)

    self.rewardSurveysCountLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_green_700

    self.topLineView
      |> UIView.lens.backgroundColor .~ .ksr_green_500
  }

  internal override func bindViewModel() {
    self.creatorNameLabel.rac.text = self.viewModel.outputs.creatorNameText
    self.rewardSurveysCountLabel.rac.text = self.viewModel.outputs.rewardSurveysCountText
    self.rewardSurveysCountLabel.rac.hidden = self.viewModel.outputs.rewardSurveysCountIsHidden
    self.surveyLabel.rac.attributedText = self.viewModel.outputs.surveyLabelText

    self.viewModel.outputs.creatorImageURL
      .observeForUI()
      .on(next: { [weak creatorImageView] _ in
        creatorImageView?.af_cancelImageRequest()
        creatorImageView?.image = nil
        })
      .ignoreNil()
      .observeNext { [weak creatorImageView] url in
        creatorImageView?.af_setImageWithURL(url, imageTransition: .CrossDissolve(0.2))
    }

    self.viewModel.outputs.notifyDelegateToRespondToSurvey
      .observeForUI()
      .observeNext { [weak self] in
        self?.delegate?.activityTappedRespondNow(forSurveyResponse: $0)
    }
  }

  @objc private func respondNowTapped() {
    self.viewModel.inputs.respondNowButtonTapped()
  }
}
