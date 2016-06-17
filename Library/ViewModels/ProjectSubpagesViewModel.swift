import KsApi
import ReactiveCocoa
import Result

public protocol ProjectSubpagesViewModelInputs {
  func project(project: Project)
}

public protocol ProjectSubpagesViewModelOutputs {
  var creatorName: Signal<String, NoError> { get }
  var creatorImageURL: Signal<NSURL?, NoError> { get }
  var disclaimer: Signal<String, NoError> { get }
  var disclaimerHidden: Signal<Bool, NoError> { get }
}

public protocol ProjectSubpagesViewModelType {
  var inputs: ProjectSubpagesViewModelInputs { get }
  var outputs: ProjectSubpagesViewModelOutputs { get }
}

public final class ProjectSubpagesViewModel: ProjectSubpagesViewModelType,
ProjectSubpagesViewModelInputs, ProjectSubpagesViewModelOutputs {

  private let projectProperty = MutableProperty<Project?>(nil)
  public func project(project: Project) {
    self.projectProperty.value = project
  }

  public let creatorName: Signal<String, NoError>
  public let creatorImageURL: Signal<NSURL?, NoError>
  public let disclaimer: Signal<String, NoError>
  public let disclaimerHidden: Signal<Bool, NoError>

  public var inputs: ProjectSubpagesViewModelInputs { return self }
  public var outputs: ProjectSubpagesViewModelOutputs { return self }

  public init() {
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
    return Strings.project_disclaimer_goal_not_reached(
        goal_currency: Format.currency(project.stats.goal, country: project.country),
        deadline: Format.date(secondsInUTC: project.dates.deadline)
    )
  }

  return Strings.project_disclaimer_goal_reached(
    deadline: Format.date(secondsInUTC: project.dates.deadline)
    )
}
