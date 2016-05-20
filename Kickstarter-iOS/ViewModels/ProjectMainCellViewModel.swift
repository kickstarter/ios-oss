import Models
import ReactiveCocoa
import Result
import Library
import Prelude

internal protocol ProjectMainCellViewModelInputs {
  func project(project: Project)
}

internal protocol ProjectMainCellViewModelOutputs {
  var projectName: Signal<String, NoError> { get }
  var creatorName: Signal<String, NoError> { get }
  var blurb: Signal<String, NoError> { get }
  var categoryName: Signal<String, NoError> { get }
  var locationName: Signal<String, NoError> { get }
  var backersCount: Signal<String, NoError> { get }
  var pledged: Signal<String, NoError> { get }
  var goal: Signal<String, NoError> { get }
  var stateHidden: Signal<Bool, NoError> { get }
  var stateTitle: Signal<String, NoError> { get }
  var stateMessage: Signal<String, NoError> { get }
  var stateColor: Signal<UIColor, NoError> { get }
  var projectImageURL: Signal<NSURL?, NoError> { get }
  var progress: Signal<Float, NoError> { get }
  var progressHidden: Signal<Bool, NoError> { get }
}

internal protocol ProjectMainCellViewModelType {
  var inputs: ProjectMainCellViewModelInputs { get }
  var outputs: ProjectMainCellViewModelOutputs { get }
}

internal final class ProjectMainCellViewModel: ProjectMainCellViewModelType, ProjectMainCellViewModelInputs,
ProjectMainCellViewModelOutputs {

  private let projectProperty = MutableProperty<Project?>(nil)
  internal func project(project: Project) {
    self.projectProperty.value = project
  }

  internal let projectName: Signal<String, NoError>
  internal let creatorName: Signal<String, NoError>
  internal let blurb: Signal<String, NoError>
  internal let categoryName: Signal<String, NoError>
  internal let locationName: Signal<String, NoError>
  internal let backersCount: Signal<String, NoError>
  internal let pledged: Signal<String, NoError>
  internal let goal: Signal<String, NoError>
  internal let stateHidden: Signal<Bool, NoError>
  internal let stateTitle: Signal<String, NoError>
  internal let stateMessage: Signal<String, NoError>
  internal let stateColor: Signal<UIColor, NoError>
  internal let projectImageURL: Signal<NSURL?, NoError>
  internal let progress: Signal<Float, NoError>
  internal let progressHidden: Signal<Bool, NoError>

  internal var inputs: ProjectMainCellViewModelInputs { return self }
  internal var outputs: ProjectMainCellViewModelOutputs { return self }

  init() {
    let project = self.projectProperty.signal.ignoreNil()
    let state = project.map { $0.state }.skipRepeats()

    self.projectName = project.map { $0.name }.skipRepeats()

    self.creatorName = project.map { $0.creator.name }.skipRepeats()

    self.blurb = project.map { $0.blurb }.skipRepeats()

    self.categoryName = project.map { $0.category.name }.skipRepeats()

    self.locationName = project.map { $0.location.displayableName }.skipRepeats()

    self.backersCount = project.map { Format.wholeNumber($0.stats.backersCount) }.skipRepeats()

    self.pledged = project.map { Format.currency($0.stats.pledged, country: $0.country) }.skipRepeats()

    self.goal = project.map {
      localizedString(
        key: "discovery.baseball_card.stats.pledged_of_goal",
        defaultValue: "pledged of %{goal}",
        substitutions: ["goal": Format.currency($0.stats.goal, country: $0.country)]
      )
    }.skipRepeats()

    self.stateTitle = state.map(bannerTitleFor(state:))
      .map { $0 ?? "" }
      .skipRepeats()

    self.stateMessage = project.map(bannerMessageFor(project:))
      .map { $0 ?? "" }
      .skipRepeats()

    self.stateHidden = combineLatest(self.stateTitle, self.stateMessage)
      .map { title, message in title.characters.isEmpty || message.characters.isEmpty }
      .skipRepeats()

    self.stateColor = state.map(bannerColorFor(state:)).skipRepeats(==)

    self.projectImageURL = project.map { $0.photo.full }
      .skipRepeats(==)
      .map(NSURL.init(string:))

    self.progress = project.map { $0.stats.fundingProgress }
      .map(clamp(0.0, 1.0))
      .skipRepeats()

    self.progressHidden = project.map { $0.state != .live }
  }
}

private func bannerTitleFor(state state: Project.State) -> String? {
  switch state {
  case .canceled:
    return localizedString(key: "project.status.funding_canceled", defaultValue: "Funding canceled")
  case .failed:
    return localizedString(key: "project.status.funding_unsuccessful", defaultValue: "Funding unsuccessful")
  case .successful:
    return localizedString(key: "project.status.funded", defaultValue: "Funded!")
  case .suspended:
    return localizedString(key: "project.status.funding_suspended", defaultValue: "Suspended")
  case .live, .started, .submitted, .purged:
    return nil
  }
}

private func bannerMessageFor(project project: Project) -> String? {
  let deadline = { Format.date(secondsInUTC: project.dates.deadline, timeStyle: .NoStyle) }

  switch project.state {
  case .canceled:
    return localizedString(
      key: "project.status.funding_project_canceled_by_creator",
      defaultValue: "This project was canceled by the creator."
    )
  case .failed:
    return localizedString(
      key: "project.status.project_funding_goal_not_reached",
      defaultValue: "This project was unsuccessfully funded on %{deadline}.",
      substitutions: ["deadline": deadline()]
    )
  case .successful:
    return localizedString(
      key: "project.status.project_was_successfully_funded_on_deadline",
      defaultValue: "This project was successfully funded on %{deadline}.",
      substitutions: ["deadline": deadline()]
    )
  case .suspended:
    return localizedString(
      key: "project.status.funding_project_suspended",
      defaultValue: "Funding for this project was suspended."
    )
  case .live, .started, .submitted, .purged:
    return nil
  }
}

private func bannerColorFor(state state: Project.State) -> UIColor {
  switch state {
  case .successful:                           return Color.GreenLight.toUIColor()
  case .canceled, .failed, .suspended:        return Color.GrayMedium.toUIColor()
  case .live, .started, .submitted, .purged:  return .clearColor()
  }
}
