import Models
import ReactiveCocoa
import Result
import Library

internal protocol ProjectSubpagesViewModelInputs {
  func project(project: Project)
}

internal protocol ProjectSubpagesViewModelOutputs {
  var creatorName: Signal<String, NoError> { get }
  var creatorImageURL: Signal<NSURL?, NoError> { get }
  var disclaimer: Signal<String, NoError> { get }
  var disclaimerHidden: Signal<Bool, NoError> { get }
}

internal protocol ProjectSubpagesViewModelType {
  var inputs: ProjectSubpagesViewModelInputs { get }
  var outputs: ProjectSubpagesViewModelOutputs { get }
}

internal final class ProjectSubpagesViewModel: ProjectSubpagesViewModelType,
ProjectSubpagesViewModelInputs, ProjectSubpagesViewModelOutputs {

  private let projectProperty = MutableProperty<Project?>(nil)
  internal func project(project: Project) {
    self.projectProperty.value = project
  }

  internal let creatorName: Signal<String, NoError>
  internal let creatorImageURL: Signal<NSURL?, NoError>
  internal let disclaimer: Signal<String, NoError>
  internal let disclaimerHidden: Signal<Bool, NoError>

  internal var inputs: ProjectSubpagesViewModelInputs { return self }
  internal var outputs: ProjectSubpagesViewModelOutputs { return self }

  internal init() {
    let project = self.projectProperty.signal.ignoreNil()

    self.creatorName = project.map { $0.creator.name }
      .skipRepeats()

    self.creatorImageURL = project
      .map { $0.creator.avatar.large ?? $0.creator.avatar.medium }
      .skipRepeats()
      .map(NSURL.init(string:))

    self.disclaimer = project.map(disclaimer(project:))
      .map { $0 ?? "" }
      .skipRepeats(==)

    self.disclaimerHidden = self.disclaimer.map { $0.characters.isEmpty }
  }
}

private func disclaimer(project project: Project) -> String? {
  guard project.state == .live else { return nil }

  if project.stats.pledged < project.stats.goal {
    return localizedString(
      key: "project.disclaimer.goal_not_reached",
      defaultValue: "This project will only be funded if at least %{goal_currency} is pledged " +
                    "by %{deadline}.",
      substitutions: [
        "goal_currency": Format.currency(project.stats.goal, country: project.country),
        "deadline": Format.date(secondsInUTC: project.dates.deadline)
      ]
    )
  }

  return localizedString(
    key: "project.disclaimer.goal_reached",
    defaultValue: "This project will be funded on %{deadline}.",
    substitutions: [
      "deadline": Format.date(secondsInUTC: project.dates.deadline)
    ]
  )
}
