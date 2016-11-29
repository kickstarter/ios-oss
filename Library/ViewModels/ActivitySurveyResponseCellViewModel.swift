import KsApi
import ReactiveCocoa
import Result

public protocol ActivitySurveyResponseCellViewModelInputs {
  /// Call to configure with survey response.
  func configureWith(surveyResponse surveyResponse: SurveyResponse)

  /// Call when respond now button is tapped.
  func respondNowButtonTapped()
}

public protocol ActivitySurveyResponseCellViewModelOutputs {
  /// Emits image url to creator's avatar.
  var creatorImageURL: Signal<NSURL?, NoError> { get }

  /// Emits text for the creator name label.
  var creatorNameText: Signal<String, NoError> { get }

  /// Emits the survey response for the delegate to respond to the survey.
  var notifyDelegateToRespondToSurvey: Signal<SurveyResponse, NoError> { get }

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
    let surveyResponse = self.surveyResponseProperty.signal.ignoreNil()
    let project = surveyResponse.map { $0.project }.ignoreNil()

    self.creatorImageURL = project.map { NSURL.init(string: $0.creator.avatar.small) }

    self.creatorNameText = project.map { $0.name }

    self.surveyLabelText = project.map {
      let text = Strings.Information_requested_to_deliver_your_reward_for_project_by_creator(project_name: $0.name, creator_name: $0.creator.name)

      return text.simpleHtmlAttributedString(
        base: [
          NSFontAttributeName: UIFont.ksr_subhead(size: 14),
          NSForegroundColorAttributeName: UIColor.ksr_text_navy_700
        ],
        bold: [
          NSFontAttributeName: UIFont.ksr_headline(size: 14),
          NSForegroundColorAttributeName: UIColor.ksr_text_navy_700
        ])
        ?? NSAttributedString(string: "")
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

  public let creatorImageURL: Signal<NSURL?, NoError>
  public let creatorNameText: Signal<String, NoError>
  public let notifyDelegateToRespondToSurvey: Signal<SurveyResponse, NoError>
  public let surveyLabelText: Signal<NSAttributedString, NoError>

  public var inputs: ActivitySurveyResponseCellViewModelInputs { return self }
  public var outputs: ActivitySurveyResponseCellViewModelOutputs { return self }
}
