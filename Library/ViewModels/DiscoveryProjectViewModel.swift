import KsApi
import ReactiveCocoa
import Result

public protocol DiscoveryProjectViewModelInputs {
  func project(project: Project)
}

public protocol DiscoveryProjectViewModelOutputs {
  var backers: Signal<String, NoError> { get }
  var blurb: Signal<String, NoError> { get }
  var category: Signal<String, NoError> { get }
  var cellAccessibilityLabel: Signal<String, NoError> { get }
  var cellAccessibilityValue: Signal<String, NoError> { get }
  var funding: Signal<String, NoError> { get }
  var projectImageURL: Signal<NSURL?, NoError> { get }
  var projectName: Signal<String, NoError> { get }
}

public protocol DiscoveryProjectViewModelType {
  var inputs: DiscoveryProjectViewModelInputs { get }
  var outputs: DiscoveryProjectViewModelOutputs { get }
}

public final class DiscoveryProjectViewModel: DiscoveryProjectViewModelType,
DiscoveryProjectViewModelInputs, DiscoveryProjectViewModelOutputs {

  public init() {
    let project = self.projectProperty.signal.ignoreNil()

    self.projectImageURL = project.map { $0.photo.full }.map(NSURL.init(string:))
    self.projectName = project.map { $0.name }
    self.category = project.map { $0.category.name }
    self.blurb = project.map { $0.blurb }
    self.funding = project.map {
      localizedString(
        key: "card.funded",
        defaultValue: "%{percent_funded} funded",
        substitutions: ["percent_funded": Format.percentage($0.stats.percentFunded)]
      )
    }
    self.backers = project.map {
      localizedString(
        key: "card.backers",
        defaultValue: "%{backers_count} backers",
        count: $0.stats.backersCount,
        substitutions: ["backers_count": Format.wholeNumber($0.stats.backersCount)]
      )
    }

    self.cellAccessibilityValue = project.map(Project.lens.blurb.view)
    self.cellAccessibilityLabel = project.map(Project.lens.name.view)
  }

  private let projectProperty = MutableProperty<Project?>(nil)
  public func project(project: Project) {
    self.projectProperty.value = project
  }

  public let projectImageURL: Signal<NSURL?, NoError>
  public let projectName: Signal<String, NoError>
  public let category: Signal<String, NoError>
  public let blurb: Signal<String, NoError>
  public let funding: Signal<String, NoError>
  public let backers: Signal<String, NoError>
  public let cellAccessibilityLabel: Signal<String, NoError>
  public let cellAccessibilityValue: Signal<String, NoError>

  public var inputs: DiscoveryProjectViewModelInputs { return self }
  public var outputs: DiscoveryProjectViewModelOutputs { return self }
}
