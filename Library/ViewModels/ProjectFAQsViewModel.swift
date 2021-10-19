import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectFAQsViewModelInputs {
  /// Call with the `Project` given to the view.
  func configureWith(project: Project)

  /// Call with the `Int` (index) of the cell selected and the existing values (`[Bool]`) in the data source
  func didSelectRowAt(row: Int, values: [Bool])

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectFAQsViewModelOutputs {
  /// Emits a tuple of `Project, [Bool]` so the data source can use the faqs and isExpanded states to render cells
  var loadFAQs: Signal<(Project, [Bool]), Never> { get }

  /// Emits a tuple of `Project, [Bool]` after a cell is selected and the data source needs to be updated
  var updateDataSource: Signal<(Project, [Bool]), Never> { get }
}

public protocol ProjectFAQsViewModelType {
  var inputs: ProjectFAQsViewModelInputs { get }
  var outputs: ProjectFAQsViewModelOutputs { get }
}

public final class ProjectFAQsViewModel: ProjectFAQsViewModelType,
  ProjectFAQsViewModelInputs, ProjectFAQsViewModelOutputs {
  public init() {
    let project = self.configureDataProperty.signal
      .skipNil()
      .combineLatest(with: self.viewDidLoadProperty.signal)
      .map(first)

    let initialIsExpandedArray = project
      .map(\.extendedProjectProperties?.faqs.count)
      .skipNil()
      .map { count in Array(repeating: false, count: count) }

    self.loadFAQs = Signal.combineLatest(project, initialIsExpandedArray)

    self.updateDataSource = project
      .combineLatest(with: self.didSelectRowAtProperty.signal.skipNil())
      .map { project, indexAndDataSourceValues -> (Project, [Bool]) in
        let (index, isExpandedValues) = indexAndDataSourceValues
        var updatedValues = isExpandedValues
        updatedValues[index] = !updatedValues[index]

        return (project, updatedValues)
      }
  }

  fileprivate let configureDataProperty = MutableProperty<Project?>(nil)
  public func configureWith(project: Project) {
    self.configureDataProperty.value = project
  }

  fileprivate let didSelectRowAtProperty = MutableProperty<(Int, [Bool])?>(nil)
  public func didSelectRowAt(row: Int, values: [Bool]) {
    self.didSelectRowAtProperty.value = (row, values)
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadFAQs: Signal<(Project, [Bool]), Never>
  public let updateDataSource: Signal<(Project, [Bool]), Never>

  public var inputs: ProjectFAQsViewModelInputs { return self }
  public var outputs: ProjectFAQsViewModelOutputs { return self }
}
