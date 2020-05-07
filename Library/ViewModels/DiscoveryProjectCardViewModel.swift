import Foundation
import ReactiveSwift
import Prelude

public protocol DiscoveryProjectCardViewModelInputs {
  func configure(with value: DiscoveryProjectCellRowValue)
}

public protocol DiscoveryProjectCardViewModelOutputs {
  var goalMetIconHidden: Signal<Bool, Never> { get }
  var projectNameLabelText: Signal<String, Never> { get }
  var projectBlurbLabelText: Signal<String, Never> { get }
  var backerCountLabelText: Signal<String, Never> { get }
  var backerLabelText: Signal<String, Never> { get }
  var percentFundedLabelText: Signal<String, Never> { get }
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
    self.backerCountLabelText = Signal.empty
    self.backerLabelText = project.map { project in
      return Strings.general_backer_count_backers(backer_count: project.stats.backersCount)
    }

    self.percentFundedLabelText = project.map { project in
      if project.stats.goalMet {
        return "Goal met"
      }

      return Strings.percentage_funded(percentage: String(project.stats.percentFunded))
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
  public let backerCountLabelText: Signal<String, Never>
  public let backerLabelText: Signal<String, Never>
  public let percentFundedLabelText: Signal<String, Never>
  public let projectImageURL: Signal<URL, Never>

  public var inputs: DiscoveryProjectCardViewModelInputs { return self }
  public var outputs: DiscoveryProjectCardViewModelOutputs { return self }
}
