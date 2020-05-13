import Foundation
import KsApi
import Prelude
import ReactiveSwift

public typealias BoldedAttributedLabelData = (boldedString: String, inString: String)

public protocol DiscoveryProjectCardViewModelInputs {
  func configure(with value: DiscoveryProjectCellRowValue)
}

public protocol DiscoveryProjectCardViewModelOutputs {
  var backerCountLabelData: Signal<BoldedAttributedLabelData, Never> { get }
  var goalMetIconHidden: Signal<Bool, Never> { get }
  var loadProjectTags: Signal<[DiscoveryProjectTagPillCellValue], Never> { get }
  var percentFundedLabelData: Signal<BoldedAttributedLabelData, Never> { get }
  var projectBlurbLabelText: Signal<String, Never> { get }
  var projectImageURL: Signal<URL, Never> { get }
  var projectNameLabelText: Signal<String, Never> { get }
  var tagsCollectionViewHidden: Signal<Bool, Never> { get }
}

public protocol DiscoveryProjectCardViewModelType {
  var inputs: DiscoveryProjectCardViewModelInputs { get }
  var outputs: DiscoveryProjectCardViewModelOutputs { get }
}

public final class DiscoveryProjectCardViewModel: DiscoveryProjectCardViewModelType,
  DiscoveryProjectCardViewModelInputs, DiscoveryProjectCardViewModelOutputs {
  public init() {
    let project = self.configureWithValueProperty.signal.skipNil().map(first)
    let category = self.configureWithValueProperty.signal.skipNil().map(second)
//    let filterParams = self.configureWithValueProperty.signal.skipNil().map(third)

    self.projectNameLabelText = project.map(\.name)
    self.projectBlurbLabelText = project.map(\.blurb)
    self.backerCountLabelData = project.map(\.stats.backersCount).map { count in
      (String(count), Strings.general_backer_count_backers(backer_count: count))
    }

    self.percentFundedLabelData = project.map { project in
      if project.stats.goalMet {
        return (
          localizedString(key: "Goal_met", defaultValue: "Goal met"),
          localizedString(key: "Goal_met", defaultValue: "Goal met")
        )
      }

      let percentage = "\(project.stats.percentFunded)%"

      return (percentage, Strings.percentage_funded(percentage: percentage))
    }

    self.goalMetIconHidden = project.map { !$0.stats.goalMet }
    self.projectImageURL = project.map(\.photo.full).map(URL.init(string:)).skipNil()

    let projectCategoryTagShouldHide = Signal.zip(project, category)
      .map(projectCategoryTagShouldHide(for:in:))
    let pwlTagShouldHide = project.map(\.staffPick).negate()

    self.tagsCollectionViewHidden = Signal.combineLatest(
      projectCategoryTagShouldHide,
      pwlTagShouldHide
    )
    .map { $0 && $1 }

    self.loadProjectTags = Signal.combineLatest(
      project,
      pwlTagShouldHide.negate(),
      projectCategoryTagShouldHide.negate()
    )
    .map(projectTags(project:shouldShowPWLTag:shouldShowCategoryTag:))
    .filter { !$0.isEmpty }
  }

  private let configureWithValueProperty = MutableProperty<DiscoveryProjectCellRowValue?>(nil)
  public func configure(with value: DiscoveryProjectCellRowValue) {
    self.configureWithValueProperty.value = value
  }

  public let backerCountLabelData: Signal<BoldedAttributedLabelData, Never>
  public let goalMetIconHidden: Signal<Bool, Never>
  public let loadProjectTags: Signal<[DiscoveryProjectTagPillCellValue], Never>
  public let percentFundedLabelData: Signal<BoldedAttributedLabelData, Never>
  public let projectBlurbLabelText: Signal<String, Never>
  public let projectImageURL: Signal<URL, Never>
  public let projectNameLabelText: Signal<String, Never>
  public let tagsCollectionViewHidden: Signal<Bool, Never>

  public var inputs: DiscoveryProjectCardViewModelInputs { return self }
  public var outputs: DiscoveryProjectCardViewModelOutputs { return self }
}

private func projectCategoryTagShouldHide(for project: Project, in category: KsApi.Category?) -> Bool {
  guard let category = category, !category.isRoot else {
    // Always show category when filter category is nil, or we're in a root category
    return false
  }

  return project.category.id == category.intID
}

private func projectTags(project: Project, shouldShowPWLTag: Bool, shouldShowCategoryTag: Bool)
  -> [DiscoveryProjectTagPillCellValue] {
  var tags: [DiscoveryProjectTagPillCellValue] = []

  if shouldShowPWLTag {
    let pwlTag = DiscoveryProjectTagPillCellValue(
      type: .green,
      tagLabelText: Strings.Projects_We_Love(),
      tagIconImageName: "icon--small-k"
    )

    tags.append(pwlTag)
  }

  if shouldShowCategoryTag {
    let categoryTag = DiscoveryProjectTagPillCellValue(
      type: .grey,
      tagLabelText: project.category.name,
      tagIconImageName: "icon--compass"
    )

    tags.append(categoryTag)
  }

  return tags
}
