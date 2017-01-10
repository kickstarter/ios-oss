import KsApi
import Library
import Prelude
import UIKit

internal protocol ActivitySurveyResponseCellDelegate: class {
  /// Called when the delegate should respond to the survey.
  func activityTappedRespondNow(forSurveyResponse surveyResponse: SurveyResponse)
}

internal final class ActivitySurveyResponseCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivitySurveyResponseCellViewModelType = ActivitySurveyResponseCellViewModel()
  internal weak var delegate: ActivitySurveyResponseCellDelegate?

  @IBOutlet fileprivate weak var cardView: UIView!
  @IBOutlet fileprivate weak var containerView: UIView!
  @IBOutlet fileprivate weak var creatorImageView: CircleAvatarImageView!
  @IBOutlet fileprivate weak var creatorNameLabel: UILabel!
  @IBOutlet fileprivate weak var respondNowButton: UIButton!
  @IBOutlet fileprivate weak var rewardSurveysCountLabel: UILabel!
  @IBOutlet fileprivate weak var surveyLabel: UILabel!
  @IBOutlet fileprivate weak var topLineView: UIView!

  internal override func awakeFromNib() {
    super.awakeFromNib()
    self.respondNowButton.addTarget(self,
                                    action: #selector(respondNowTapped),
                                    for: .touchUpInside)
  }

  internal func configureWith(value: (surveyResponse: SurveyResponse, count: Int, position: Int)) {
    self.viewModel.inputs.configureWith(surveyResponse: value.surveyResponse, count: value.count,
                                        position: value.position)
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> feedTableViewCellStyle

    _ = self.cardView
      |> dropShadowStyle()

    _ = self.containerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    _ = self.creatorNameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    _ = self.respondNowButton
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.backgroundColor(forState: .normal) .~ .clear
      |> UIButton.lens.titleColor(forState: .normal) .~ .ksr_green_700
      |> UIButton.lens.titleColor(forState: .highlighted) .~ .ksr_navy_700
      |> UIButton.lens.title(forState: .normal) %~ { _ in Strings.discovery_survey_button_respond_now() }
      |> UIButton.lens.tintColor .~ .ksr_green_700
      |> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: Styles.grid(4))
      |> UIButton.lens.image(forState: .normal) %~ { _ in Library.image(named: "respond-icon") }
      |> UIButton.lens.contentEdgeInsets .~ .init(top: Styles.grid(3), left: 0, bottom: Styles.grid(1),
                                                  right: 0)

    _ = self.rewardSurveysCountLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_green_700

    _ = self.topLineView
      |> UIView.lens.backgroundColor .~ .ksr_green_500
  }

  internal override func bindViewModel() {
    super.bindViewModel()

    self.creatorNameLabel.rac.text = self.viewModel.outputs.creatorNameText
    self.rewardSurveysCountLabel.rac.text = self.viewModel.outputs.rewardSurveysCountText
    self.rewardSurveysCountLabel.rac.hidden = self.viewModel.outputs.rewardSurveysCountIsHidden
    self.surveyLabel.rac.attributedText = self.viewModel.outputs.surveyLabelText

    self.viewModel.outputs.creatorImageURL
      .observeForUI()
      .on(event: { [weak creatorImageView] _ in
        creatorImageView?.af_cancelImageRequest()
        creatorImageView?.image = nil
        })
      .skipNil()
      .observeValues { [weak creatorImageView] url in
        creatorImageView?.ksr_setImageWithURL(url)
    }

    self.viewModel.outputs.notifyDelegateToRespondToSurvey
      .observeForUI()
      .observeValues { [weak self] in
        self?.delegate?.activityTappedRespondNow(forSurveyResponse: $0)
    }
  }

  @objc fileprivate func respondNowTapped() {
    self.viewModel.inputs.respondNowButtonTapped()
  }
}
