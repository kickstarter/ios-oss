import KsApi
import ReactiveCocoa
import Result

public protocol ActivitySurveyResponseCellViewModelInputs {
  func configureWith(surveyResponse surveyResponse: SurveyResponse)
  func respondNowButtonTapped()
}

public protocol ActivitySurveyResponseCellViewModelOutputs {
  var notifyDelegateToRespondToSurvey: Signal<SurveyResponse, NoError> { get }
  var setSurveyLabelHtmlText: Signal<String, NoError> { get }
}

public protocol ActivitySurveyResponseCellViewModelType {
  var inputs: ActivitySurveyResponseCellViewModelInputs { get }
  var outputs: ActivitySurveyResponseCellViewModelOutputs { get }
}

public final class ActivitySurveyResponseCellViewModel: ActivitySurveyResponseCellViewModelType,
ActivitySurveyResponseCellViewModelInputs, ActivitySurveyResponseCellViewModelOutputs {

  public init() {
    let surveyResponse = self.surveyResponseProperty.signal.ignoreNil()

    self.setSurveyLabelHtmlText = surveyResponse.map { surveyResponse in
      let bolded = Strings.discovery_survey_reward_survey()
      let message = Strings.discovery_survey_creator_needs_some_info_to_deliver_reward_for_project(
        creator_name: surveyResponse.project?.creator.name ?? "",
        project_name: surveyResponse.project?.name ?? ""
      )
      return " <b>\(bolded)</b> \(message)"
    }

    self.notifyDelegateToRespondToSurvey = surveyResponse
      .takeWhen(self.respondNowButtonTappedProperty.signal)
  }

  private let surveyResponseProperty = MutableProperty<SurveyResponse?>(nil)
  public func configureWith(surveyResponse surveyResponse: SurveyResponse) {
    self.surveyResponseProperty.value = surveyResponse
  }
  private let respondNowButtonTappedProperty = MutableProperty()
  public func respondNowButtonTapped() {
    self.respondNowButtonTappedProperty.value = ()
  }

  public let notifyDelegateToRespondToSurvey: Signal<SurveyResponse, NoError>
  public let setSurveyLabelHtmlText: Signal<String, NoError>

  public var inputs: ActivitySurveyResponseCellViewModelInputs { return self }
  public var outputs: ActivitySurveyResponseCellViewModelOutputs { return self }
}
