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

  @IBOutlet private weak var respondNowButton: UIButton!
  @IBOutlet private weak var surveyLabel: UILabel!

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
    self |> activitySurveyTableViewCellStyle
    self.respondNowButton |> activityRespondNowButtonStyle
  }

  internal override func bindViewModel() {
    self.viewModel.outputs.notifyDelegateToRespondToSurvey
      .observeForUI()
      .observeNext { [weak self] in
        self?.delegate?.activityTappedRespondNow(forSurveyResponse: $0)
    }

    self.viewModel.outputs.setSurveyLabelHtmlText
      .observeForUI()
      .observeNext { [weak self] in
        guard let surveyLabel = self?.surveyLabel else { return }

        surveyLabel |> activitySurveyLabelStyle
        surveyLabel.setHTML($0)
    }
  }

  @objc private func respondNowTapped() {
    self.viewModel.inputs.respondNowButtonTapped()
  }
}
