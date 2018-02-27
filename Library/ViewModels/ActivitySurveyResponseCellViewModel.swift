import KsApi
import Prelude
import ReactiveSwift
import Result

public protocol ActivitySurveyResponseCellViewModelInputs {
  /// Call to configure with survey response, number of surveys, and the cell's position in the survey stack.
  func configureWith(surveyResponse: SurveyResponse, count: Int, position: Int)

  /// Call when respond now button is tapped.
  func respondNowButtonTapped()
}

public protocol ActivitySurveyResponseCellViewModelOutputs {
  /// Emits image url to creator's avatar.
  var creatorImageURL: Signal<URL?, NoError> { get }

  /// Emits text for the creator name label.
  var creatorNameText: Signal<String, NoError> { get }

  /// Emits the survey response for the delegate to respond to the survey.
  var notifyDelegateToRespondToSurvey: Signal<SurveyResponse, NoError> { get }

  /// Emits whether reward surveys count label is hidden.
  var rewardSurveysCountIsHidden: Signal<Bool, NoError> { get }

  /// Emits text for reward surveys count label.
  var rewardSurveysCountText: Signal<String, NoError> { get }

  /// Emits text for the survey label.
  var surveyLabelText: Signal<NSAttributedString, NoError> { get }
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
          NSAttributedStringKey.font: UIFont.ksr_subhead(size: 14),
          NSAttributedStringKey.foregroundColor: UIColor.ksr_text_dark_grey_900
        ],
        bold: [
          NSAttributedStringKey.font: UIFont.ksr_headline(size: 14),
          NSAttributedStringKey.foregroundColor: UIColor.ksr_text_dark_grey_900
        ])
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

  public let creatorImageURL: Signal<URL?, NoError>
  public let creatorNameText: Signal<String, NoError>
  public let notifyDelegateToRespondToSurvey: Signal<SurveyResponse, NoError>
  public let rewardSurveysCountIsHidden: Signal<Bool, NoError>
  public var rewardSurveysCountText: Signal<String, NoError>
  public let surveyLabelText: Signal<NSAttributedString, NoError>

  public var inputs: ActivitySurveyResponseCellViewModelInputs { return self }
  public var outputs: ActivitySurveyResponseCellViewModelOutputs { return self }
}
