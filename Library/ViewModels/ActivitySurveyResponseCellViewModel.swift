import KsApi
import Prelude
import ReactiveSwift
import UIKit

public protocol ActivitySurveyResponseCellViewModelInputs {
  /// Call to configure with survey response, number of surveys, and the cell's position in the survey stack.
  func configureWith(surveyResponse: SurveyResponse, count: Int, position: Int)

  /// Call when respond now button is tapped.
  func respondNowButtonTapped()
}

public protocol ActivitySurveyResponseCellViewModelOutputs {
  /// Emits image url to creator's avatar.
  var creatorImageURL: Signal<URL?, Never> { get }

  /// Emits text for the creator name label.
  var creatorNameText: Signal<String, Never> { get }

  /// Emits the survey response for the delegate to respond to the survey.
  var notifyDelegateToRespondToSurvey: Signal<SurveyResponse, Never> { get }

  /// Emits whether reward surveys count label is hidden.
  var rewardSurveysCountIsHidden: Signal<Bool, Never> { get }

  /// Emits text for reward surveys count label.
  var rewardSurveysCountText: Signal<String, Never> { get }

  /// Emits text for the survey label.
  var surveyLabelText: Signal<NSAttributedString, Never> { get }
}

public protocol ActivitySurveyResponseCellViewModelType {
  var inputs: ActivitySurveyResponseCellViewModelInputs { get }
  var outputs: ActivitySurveyResponseCellViewModelOutputs { get }
}

public final class ActivitySurveyResponseCellViewModel: ActivitySurveyResponseCellViewModelType,
  ActivitySurveyResponseCellViewModelInputs, ActivitySurveyResponseCellViewModelOutputs {
  public init() {
    let surveyResponseAndCountAndPosition = self.surveyResponseCountPositionProperty.signal.skipNil()
    let project = surveyResponseAndCountAndPosition
      .map { surveyResponse, _, _ in surveyResponse.project }
      .skipNil()

    self.creatorImageURL = project.map { URL.init(string: $0.creator.avatar.small) }

    self.creatorNameText = project.map { $0.creator.name }

    self.surveyLabelText = project.map {
      let text = Strings.Creator_name_needs_some_information_to_deliver_your_reward_for_project_name(
        creator_name: $0.creator.name, project_name: $0.name
      )

      return text.simpleHtmlAttributedString(
        base: [
          NSAttributedString.Key.font: UIFont.ksr_subhead(size: 14),
          NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
        ],
        bold: [
          NSAttributedString.Key.font: UIFont.ksr_headline(size: 14),
          NSAttributedString.Key.foregroundColor: UIColor.ksr_support_700
        ]
      )
        ?? NSAttributedString(string: "")
    }

    self.notifyDelegateToRespondToSurvey = surveyResponseAndCountAndPosition
      .map(first)
      .takeWhen(self.respondNowButtonTappedProperty.signal)

    self.rewardSurveysCountIsHidden = surveyResponseAndCountAndPosition.map { _, count, position in
      count > 1 && position != 0
    }

    self.rewardSurveysCountText = surveyResponseAndCountAndPosition
      .map { _, count, _ in Strings.Reward_Surveys(reward_survey_count: count) }
  }

  fileprivate let surveyResponseCountPositionProperty = MutableProperty<(SurveyResponse, Int, Int)?>(nil)
  public func configureWith(surveyResponse: SurveyResponse, count: Int, position: Int) {
    self.surveyResponseCountPositionProperty.value = (surveyResponse, count, position)
  }

  fileprivate let respondNowButtonTappedProperty = MutableProperty(())
  public func respondNowButtonTapped() {
    self.respondNowButtonTappedProperty.value = ()
  }

  public let creatorImageURL: Signal<URL?, Never>
  public let creatorNameText: Signal<String, Never>
  public let notifyDelegateToRespondToSurvey: Signal<SurveyResponse, Never>
  public let rewardSurveysCountIsHidden: Signal<Bool, Never>
  public var rewardSurveysCountText: Signal<String, Never>
  public let surveyLabelText: Signal<NSAttributedString, Never>

  public var inputs: ActivitySurveyResponseCellViewModelInputs { return self }
  public var outputs: ActivitySurveyResponseCellViewModelOutputs { return self }
}
