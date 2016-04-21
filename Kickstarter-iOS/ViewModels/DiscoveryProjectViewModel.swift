import Models
import Library
import ReactiveCocoa
import Result
import Foundation

internal protocol DiscoveryProjectViewModelInputs {
  func project(project: Project)
}

internal protocol DiscoveryProjectViewModelOutputs {
  var projectImageURL: Signal<NSURL?, NoError> { get }
  var projectName: Signal<String, NoError> { get }
  var category: Signal<String, NoError> { get }
  var blurb: Signal<String, NoError> { get }
  var funding: Signal<String, NoError> { get }
  var backers: Signal<String, NoError> { get }
}

internal protocol DiscoveryProjectViewModelType {

  var inputs: DiscoveryProjectViewModelInputs { get }
  var outputs: DiscoveryProjectViewModelOutputs { get }
}

internal final class DiscoveryProjectViewModel: DiscoveryProjectViewModelType,
DiscoveryProjectViewModelInputs, DiscoveryProjectViewModelOutputs {

  private let projectProperty = MutableProperty<Project?>(nil)
  internal func project(project: Project) {
    self.projectProperty.value = project
  }

  internal var projectImageURL: Signal<NSURL?, NoError>
  internal var projectName: Signal<String, NoError>
  internal var category: Signal<String, NoError>
  internal var blurb: Signal<String, NoError>
  internal var funding: Signal<String, NoError>
  internal var backers: Signal<String, NoError>

  internal var inputs: DiscoveryProjectViewModelInputs { return self }
  internal var outputs: DiscoveryProjectViewModelOutputs { return self }

  internal init() {
    let project = self.projectProperty.signal.ignoreNil()

    self.projectImageURL = project.map { $0.photo.full }.map(NSURL.init(string:))
    self.projectName = project.map { $0.name }
    self.category = project.map { $0.category.name }
    self.blurb = project.map { $0.blurb }
    self.funding = project.map { _ in "89% funded" }
    self.backers = project.map { _ in "154 backers" }
  }
}
