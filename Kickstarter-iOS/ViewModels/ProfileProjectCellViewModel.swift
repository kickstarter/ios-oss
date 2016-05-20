import Foundation
import Library
import Models
import ReactiveCocoa
import Result

internal protocol ProfileProjectCellViewModelInputs {
  /// Call with a backed project.
  func project(project: Project)
}

internal protocol ProfileProjectCellViewModelOutputs {
  /// Emits the project name to be displayed.
  var projectName: Signal<String, NoError> { get }

  /// Emits the project's photo URL to be displayed.
  var photoURL: Signal<NSURL?, NoError> { get }

  /// Emits the project's funding progress amount to be displayed.
  var progress: Signal<Float, NoError> { get }

  /// Emits a boolean that determines if the progress bar should be hidden.
  var progressHidden: Signal<Bool, NoError> { get }

  /// Emits the state of the project to be displayed.
  var state: Signal<String, NoError> { get }

  /// Emits the background color to be displayed for the project's state banner.
  var stateBackgroundColor: Signal<UIColor, NoError> { get }

  /// Emits a boolean that determines if the project's state banner should be hidden.
  var stateHidden: Signal<Bool, NoError> { get }
}

internal protocol ProfileProjectCellViewModelType {
  var inputs: ProfileProjectCellViewModelInputs { get }
  var outputs: ProfileProjectCellViewModelOutputs { get }
}

internal final class ProfileProjectCellViewModel: ProfileProjectCellViewModelType,
  ProfileProjectCellViewModelInputs, ProfileProjectCellViewModelOutputs {
  init() {
    let project = projectProperty.signal.ignoreNil()

    self.projectName = project.map { $0.name }
    self.photoURL = project.map { NSURL(string: $0.photo.full) }
    self.progress = project.map { $0.stats.fundingProgress }
    self.progressHidden = project.map { $0.state != .live }
    self.state = project.map { $0.state.rawValue }
    self.stateBackgroundColor = project.map {
      $0.state == .successful ? Color.Green.toUIColor() : Color.GrayDark.toUIColor()
    }
    self.stateHidden = project.map { $0.state == .live }
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  internal func project(project: Project) {
    self.projectProperty.value = project
  }

  internal let projectName: Signal<String, NoError>
  internal let photoURL: Signal<NSURL?, NoError>
  internal let progress: Signal<Float, NoError>
  internal let progressHidden: Signal<Bool, NoError>
  internal let state: Signal<String, NoError>
  internal let stateBackgroundColor: Signal<UIColor, NoError>
  internal let stateHidden: Signal<Bool, NoError>

  internal var inputs: ProfileProjectCellViewModelInputs { return self }
  internal var outputs: ProfileProjectCellViewModelOutputs { return self }
}
