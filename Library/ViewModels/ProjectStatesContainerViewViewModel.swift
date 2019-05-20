import KsApi
import Prelude
import Result
import ReactiveSwift
import ReactiveExtensions

public protocol ProjectStatesContainerViewViewModelInputs {
  func configureWith(project: Project, user: User)
}

public protocol ProjectStatesContainerViewViewModelOutputs {
  var buttonBackgroundColor: Signal<UIColor, NoError> { get }
  var buttonTitleText: Signal<String, NoError> { get }
  var rewardTitle: Signal<String, NoError> { get }
  var stackViewIsHidden: Signal<Bool, NoError> { get }
}

public protocol ProjectStatesContainerViewViewModelType {
  var inputs: ProjectStatesContainerViewViewModelInputs { get }
  var outputs: ProjectStatesContainerViewViewModelOutputs { get }
}

public final class ProjectStatesContainerViewViewModel: ProjectStatesContainerViewViewModelType,
  ProjectStatesContainerViewViewModelInputs, ProjectStatesContainerViewViewModelOutputs {

  public init() {
    let projectAndUser = self.projectAndBackingProperty.signal.skipNil()

    let projectState = projectAndUser
      .map { project, user in projectStateButton(backer: user, project: project) }

    self.buttonTitleText = projectState.map { $0.buttonTitle }
    self.buttonBackgroundColor = projectState.map { $0.buttonBackgroundColor }
    self.stackViewIsHidden = projectState.map { $0.stackViewIsHidden }
    self.rewardTitle = projectAndUser.map { project, _ in project.personalization.backing?.reward?.title ?? "Title for unavailable reward" }
  }

  fileprivate let projectAndBackingProperty = MutableProperty<(Project, User)?>(nil)
  public func configureWith(project: Project, user: User) {
    self.projectAndBackingProperty.value = (project, user)
  }

  public var inputs: ProjectStatesContainerViewViewModelInputs { return self }
  public var outputs: ProjectStatesContainerViewViewModelOutputs { return self }

  public let buttonTitleText: Signal<String, NoError>
  public let buttonBackgroundColor: Signal<UIColor, NoError>
  public let stackViewIsHidden: Signal<Bool, NoError>
  public let rewardTitle: Signal<String, NoError>
}

private func projectStateButton(backer: User, project: Project) -> ProjectStateCTAType {
  guard let projectIsBacked = project.personalization.isBacking
    else { return ProjectStateCTAType.viewRewards }

  switch project.state {
  case .live:
    return projectIsBacked ? ProjectStateCTAType.manage : ProjectStateCTAType.pledge
  case .canceled, .failed, .suspended, .successful:
    return projectIsBacked ? ProjectStateCTAType.viewBacking : ProjectStateCTAType.viewRewards
  default:
    return ProjectStateCTAType.viewRewards
  }
}
