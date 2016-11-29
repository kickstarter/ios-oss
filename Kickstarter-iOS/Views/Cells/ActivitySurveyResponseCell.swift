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
  @IBOutlet private weak var surveyLabel: UILabel!
  @IBOutlet private weak var topLineView: UIView!

  internal override func awakeFromNib() {
    super.awakeFromNib()
    self.respondNowButton.addTarget(self,
                                    action: #selector(respondNowTapped),
                                    forControlEvents: .TouchUpInside)
  }

  internal func configureWith(value surveyResponse: SurveyResponse) {
    self.viewModel.inputs.configureWith(surveyResponse: surveyResponse)
  }

  internal override func bindStyles() {
    self
      |> baseTableViewCellStyle()
      |> UITableViewCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(topBottom: Styles.grid(10), leftRight: Styles.grid(20))
          : .init(all: Styles.grid(2))
    }

    self.cardView
      |> dropShadowStyle()

    self.containerView
      |> UIView.lens.layoutMargins .~ .init(all: Styles.grid(2))

    self.creatorNameLabel
      |> UILabel.lens.font .~ .ksr_headline(size: 13)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700

    self.respondNowButton
      |> textOnlyButtonStyle
      |> UIButton.lens.title(forState: .Normal) %~ { _ in Strings.discovery_survey_button_respond_now() }
    // add the icon

    self.topLineView
      |> UIView.lens.backgroundColor .~ .ksr_green_500
  }

  internal override func bindViewModel() {
    self.creatorNameLabel.rac.text = self.viewModel.outputs.creatorNameText
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
