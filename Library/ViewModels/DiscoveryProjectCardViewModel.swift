import Foundation
import Prelude
import ReactiveSwift

public typealias BoldedAttributedLabelData = (boldedString: String, inString: String)

public protocol DiscoveryProjectCardViewModelInputs {
  func configure(with value: DiscoveryProjectCellRowValue)
}

public protocol DiscoveryProjectCardViewModelOutputs {
  var backerCountLabelData: Signal<BoldedAttributedLabelData, Never> { get }
  var goalMetIconHidden: Signal<Bool, Never> { get }
  var projectNameLabelText: Signal<String, Never> { get }
  var projectBlurbLabelText: Signal<String, Never> { get }
  var percentFundedLabelData: Signal<BoldedAttributedLabelData, Never> { get }
  var projectImageURL: Signal<URL, Never> { get }
}

public protocol DiscoveryProjectCardViewModelType {
  var inputs: DiscoveryProjectCardViewModelInputs { get }
  var outputs: DiscoveryProjectCardViewModelOutputs { get }
}

public final class DiscoveryProjectCardViewModel: DiscoveryProjectCardViewModelType,
  DiscoveryProjectCardViewModelInputs, DiscoveryProjectCardViewModelOutputs {
  public init() {
    let project = self.configureWithValueProperty.signal.skipNil().map(first)

    self.projectNameLabelText = project.map(\.name)
    self.projectBlurbLabelText = project.map(\.blurb)
    self.backerCountLabelData = project.map(\.stats.backersCount).map { count in
      (String(count), Strings.general_backer_count_backers(backer_count: count))
    }

    self.percentFundedLabelData = project.map { project in
      if project.stats.goalMet {
        return ("Goal met", "Goal met")
      }

      let percentage = "\(project.stats.percentFunded)%"

      return (percentage, Strings.percentage_funded(percentage: percentage))
    }

    self.goalMetIconHidden = project.map { !$0.stats.goalMet }
    self.projectImageURL = project.map(\.photo.full).map(URL.init(string:)).skipNil()
  }

  private let configureWithValueProperty = MutableProperty<DiscoveryProjectCellRowValue?>(nil)
  public func configure(with value: DiscoveryProjectCellRowValue) {
    self.configureWithValueProperty.value = value
  }

  public let goalMetIconHidden: Signal<Bool, Never>
  public let projectNameLabelText: Signal<String, Never>
  public let projectBlurbLabelText: Signal<String, Never>
  public let backerCountLabelData: Signal<BoldedAttributedLabelData, Never>
  public let percentFundedLabelData: Signal<BoldedAttributedLabelData, Never>
  public let projectImageURL: Signal<URL, Never>

  public var inputs: DiscoveryProjectCardViewModelInputs { return self }
  public var outputs: DiscoveryProjectCardViewModelOutputs { return self }
}
