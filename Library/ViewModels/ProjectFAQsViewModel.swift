import KsApi
import Prelude
import ReactiveSwift

public protocol ProjectFAQsViewModelInputs {
  /// Call with the `[ProjectFAQ]` given to the view.
  func configureWith(projectFAQs: [ProjectFAQ])

  /// Call with the `Int` (index) of the cell selected and the existing values (`[Bool]`) in the data source
  func didSelectRowAt(row: Int, values: [Bool])

  /// Call when the view loads.
  func viewDidLoad()
}

public protocol ProjectFAQsViewModelOutputs {
  /// Emits a tuple of `[ProjectFAQ], [Bool]` so the data source can use the faqs and isExpanded states to render cells
  var loadFAQs: Signal<([ProjectFAQ], [Bool]), Never> { get }

  /// Emits a tuple of `[ProjectFAQ], [Bool]` after a cell is selected and the data source needs to be updated
  var updateDataSource: Signal<([ProjectFAQ], [Bool]), Never> { get }
}

public protocol ProjectFAQsViewModelType {
  var inputs: ProjectFAQsViewModelInputs { get }
  var outputs: ProjectFAQsViewModelOutputs { get }
}

public final class ProjectFAQsViewModel: ProjectFAQsViewModelType,
  ProjectFAQsViewModelInputs, ProjectFAQsViewModelOutputs {
  public init() {
    let projectFAQs = self.configureDataProperty.signal
      .skipNil()
      .combineLatest(with: self.viewDidLoadProperty.signal)
      .map(first)

    let initialIsExpandedArray = projectFAQs
      .map { faqs in Array(repeating: false, count: faqs.count) }

    self.loadFAQs = Signal.combineLatest(projectFAQs, initialIsExpandedArray)

    self.updateDataSource = projectFAQs
      .combineLatest(with: self.didSelectRowAtProperty.signal.skipNil())
      .map { projectFAQs, indexAndDataSourceValues in
        let (index, isExpandedValues) = indexAndDataSourceValues
        var updatedValues = isExpandedValues
        updatedValues[index] = !updatedValues[index]

        return (projectFAQs, updatedValues)
      }
  }

  fileprivate let configureDataProperty = MutableProperty<[ProjectFAQ]?>(nil)
  public func configureWith(projectFAQs: [ProjectFAQ]) {
    self.configureDataProperty.value = projectFAQs
  }

  fileprivate let didSelectRowAtProperty = MutableProperty<(Int, [Bool])?>(nil)
  public func didSelectRowAt(row: Int, values: [Bool]) {
    self.didSelectRowAtProperty.value = (row, values)
  }

  fileprivate let viewDidLoadProperty = MutableProperty(())
  public func viewDidLoad() {
    self.viewDidLoadProperty.value = ()
  }

  public let loadFAQs: Signal<([ProjectFAQ], [Bool]), Never>
  public let updateDataSource: Signal<([ProjectFAQ], [Bool]), Never>

  public var inputs: ProjectFAQsViewModelInputs { return self }
  public var outputs: ProjectFAQsViewModelOutputs { return self }
}
