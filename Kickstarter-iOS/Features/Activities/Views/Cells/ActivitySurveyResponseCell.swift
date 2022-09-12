import KsApi
import Library
import Prelude
import UIKit

internal protocol ActivitySurveyResponseCellDelegate: AnyObject {
  /// Called when the delegate should respond to the survey.
  func activityTappedRespondNow(forSurveyResponse surveyResponse: SurveyResponse)
}

internal final class ActivitySurveyResponseCell: UITableViewCell, ValueCell {
  fileprivate let viewModel: ActivitySurveyResponseCellViewModelType = ActivitySurveyResponseCellViewModel()
  internal weak var delegate: ActivitySurveyResponseCellDelegate?

  @IBOutlet fileprivate var cardView: UIView!
  @IBOutlet fileprivate var containerView: UIView!
  @IBOutlet fileprivate var creatorImageView: CircleAvatarImageView!
  @IBOutlet fileprivate var creatorNameLabel: UILabel!
  @IBOutlet fileprivate var respondNowButton: UIButton!
  @IBOutlet fileprivate var rewardSurveysCountLabel: UILabel!
  @IBOutlet fileprivate var surveyLabel: UILabel!
  @IBOutlet fileprivate var topLineView: UIView!

  internal override func awakeFromNib() {
    super.awakeFromNib()
    self.respondNowButton.addTarget(
      self,
      action: #selector(self.respondNowTapped),
      for: .touchUpInside
    )
  }

  internal func configureWith(value: (surveyResponse: SurveyResponse, count: Int, position: Int)) {
    self.viewModel.inputs.configureWith(
      surveyResponse: value.surveyResponse, count: value.count,
      position: value.position
    )
  }

  internal override func bindStyles() {
    super.bindStyles()

    _ = self
      |> feedTableViewCellStyle

    _ = self.cardView
      |> cardStyle()

    _ = self.containerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    _ = self.creatorImageView
      |> ignoresInvertColorsImageViewStyle

    _ = self.creatorNameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_support_700

    _ = self.respondNowButton
      |> UIButton.lens.titleLabel.font .~ .ksr_headline(size: 12)
      |> UIButton.lens.backgroundColor(for: .normal) .~ .clear
      |> UIButton.lens.titleColor(for: .normal) .~ .ksr_create_700
      |> UIButton.lens.titleColor(for: .highlighted) .~ .ksr_support_400
      |> UIButton.lens.title(for: .normal) %~ { _ in Strings.discovery_survey_button_respond_now() }
      |> UIButton.lens.tintColor .~ .ksr_create_700
      |> UIButton.lens.imageEdgeInsets .~ .init(top: 0, left: 0, bottom: 0, right: Styles.grid(4))
      |> UIButton.lens.image(for: .normal) %~ { _ in Library.image(named: "respond-icon") }
      |> UIButton.lens.contentEdgeInsets .~ .init(
        top: Styles.grid(3), left: 0, bottom: Styles.grid(1),
        right: 0
      )

    _ = self.rewardSurveysCountLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_create_700

    _ = self.topLineView
      |> UIView.lens.backgroundColor .~ .ksr_create_700
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
        creatorImageView?.af.cancelImageRequest()
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
