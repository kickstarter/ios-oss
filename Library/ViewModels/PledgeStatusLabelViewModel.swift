import Foundation
import KsApi
import Prelude
import ReactiveSwift

public struct PledgeStatusLabelViewData {
  public let currentUserIsCreatorOfProject: Bool
  public let needsConversion: Bool
  public let pledgeAmount: Double
  public let projectCountry: Project.Country
  public let projectDeadline: TimeInterval
  public let projectState: ProjectState
  public let backingState: BackingState
}

public protocol PledgeStatusLabelViewModelInputs {
  func configure(with data: PledgeStatusLabelViewData)
}

public protocol PledgeStatusLabelViewModelOutputs {
  var labelText: Signal<NSAttributedString, Never> { get }
}

public protocol PledgeStatusLabelViewModelType {
  var inputs: PledgeStatusLabelViewModelInputs { get }
  var outputs: PledgeStatusLabelViewModelOutputs { get }
}

public class PledgeStatusLabelViewModel: PledgeStatusLabelViewModelType,
  PledgeStatusLabelViewModelInputs, PledgeStatusLabelViewModelOutputs {
  public init() {
    self.labelText = self.configureWithDataProperty.signal
      .skipNil()
      .map(statusLabelText(with:))
      .skipNil()
  }

  private let configureWithDataProperty = MutableProperty<PledgeStatusLabelViewData?>(nil)
  public func configure(with data: PledgeStatusLabelViewData) {
    self.configureWithDataProperty.value = data
  }

  public let labelText: Signal<NSAttributedString, Never>

  public var inputs: PledgeStatusLabelViewModelInputs { return self }
  public var outputs: PledgeStatusLabelViewModelOutputs { return self }
}

// MARK: - Functions

private func statusLabelText(with data: PledgeStatusLabelViewData) -> NSAttributedString? {
  let currentUserIsCreatorOfProject = data.currentUserIsCreatorOfProject

  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.alignment = .center

  let font = UIFont.ksr_subhead()
  let foregroundColor = UIColor.ksr_text_black

  let attributes = [
    NSAttributedString.Key.paragraphStyle: paragraphStyle,
    NSAttributedString.Key.font: font,
    NSAttributedString.Key.foregroundColor: foregroundColor
  ]

  if let stringFromProject = projectStatusLabelText(
    with: data.projectState,
    isCreator: currentUserIsCreatorOfProject
  ) {
    return NSAttributedString(string: stringFromProject, attributes: attributes)
  }

  let string: String

  switch (data.backingState, currentUserIsCreatorOfProject) {
  // Backer context
  case (.canceled, false):
    string = Strings.You_canceled_your_pledge_for_this_project()
  case (.collected, false):
    string = Strings.We_collected_your_pledge_for_this_project()
  case (.dropped, false):
    string = Strings.Your_pledge_was_dropped_because_of_payment_errors()
  case (.errored, false):
    string = Strings.We_cant_process_your_pledge_Please_update_your_payment_method()
  case (.pledged, _):
    return attributedConfirmationString(with: data)
  case (.preauth, false):
    string = Strings.We_re_processing_your_pledge_pull_to_refresh()
  // Creator context
  case (.canceled, true):
    string = Strings.The_backer_canceled_their_pledge_for_this_project()
  case (.collected, true):
    string = Strings.We_collected_the_backers_pledge_for_this_project()
  case (.dropped, true):
    string = Strings.This_pledge_was_dropped_because_of_payment_errors()
  case (.errored, true):
    string = Strings.We_cant_process_this_pledge_because_of_a_problem_with_the_backers_payment_method()
  case (.preauth, true):
    string = Strings.We_re_processing_this_pledge_pull_to_refresh()
  }

  return NSAttributedString(string: string, attributes: attributes)
}

private func projectStatusLabelText(with projectState: ProjectState, isCreator: Bool) -> String? {
  let string: String

  switch (projectState, isCreator) {
  // Backer context
  case (.canceled, false):
    string = Strings.The_creator_canceled_this_project_so_your_payment_method_was_never_charged()
  case (.failed, false):
    string = Strings.This_project_didnt_reach_its_funding_goal_so_your_payment_method_was_never_charged()
  // Creator context
  case (.canceled, true):
    string = Strings.You_canceled_this_project_so_the_backers_payment_method_was_never_charged()
  case (.failed, true):
    string = Strings
      .Your_project_didnt_reach_its_funding_goal_so_the_backers_payment_method_was_never_charged()
  case (.live, _), (.purged, _), (.started, _), (.submitted, _), (.suspended, _), (.successful, _):
    return nil
  }

  return string
}

private func attributedConfirmationString(with data: PledgeStatusLabelViewData) -> NSAttributedString {
  let date = Format.date(secondsInUTC: data.projectDeadline, template: "MMMM d, yyyy")
  let pledgeTotal = Format.currency(data.pledgeAmount, country: data.projectCountry)
  let isCreator = data.currentUserIsCreatorOfProject

  let font = UIFont.ksr_subhead()
  let foregroundColor = UIColor.ksr_text_black

  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.alignment = .center

  let attributes = [
    NSAttributedString.Key.paragraphStyle: paragraphStyle
  ]

  guard data.needsConversion else {
    if isCreator {
      return Strings.If_your_project_reaches_its_funding_goal_the_backer_will_be_charged_on_project_deadline(
        project_deadline: date
      )
      .attributed(with: font, foregroundColor: foregroundColor, attributes: attributes, bolding: [date])
    }

    return Strings.If_the_project_reaches_its_funding_goal_you_will_be_charged_on_project_deadline(
      project_deadline: date
    )
    .attributed(with: font, foregroundColor: foregroundColor, attributes: attributes, bolding: [date])
  }

  if isCreator {
    return Strings
      .If_your_project_reaches_its_funding_goal_the_backer_will_be_charged_total_on_project_deadline(
        total: pledgeTotal,
        project_deadline: date
      )
      .attributed(
        with: font, foregroundColor: foregroundColor, attributes: attributes, bolding: [pledgeTotal, date]
      )
  }

  return Strings.If_the_project_reaches_its_funding_goal_you_will_be_charged_total_on_project_deadline(
    total: pledgeTotal,
    project_deadline: date
  )
  .attributed(
    with: font, foregroundColor: foregroundColor, attributes: attributes, bolding: [pledgeTotal, date]
  )
}
