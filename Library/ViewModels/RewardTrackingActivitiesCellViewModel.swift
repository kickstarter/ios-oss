import Foundation
import KsApi
import ReactiveSwift

public struct RewardTrackingActivitiesCellData {
  public let trackingData: RewardTrackingDetailsViewData
  public let project: Project

  public init(trackingData: RewardTrackingDetailsViewData, project: Project) {
    self.trackingData = trackingData
    self.project = project
  }
}

public protocol RewardTrackingActivitiesCellViewModelInputs {
  func configure(with data: Project)
}

public protocol RewardTrackingActivitiesCellViewModelOutputs {
  var projectName: Signal<String, Never> { get }
  var projectImageURL: Signal<URL, Never> { get }
}

public protocol RewardTrackingActivitiesCellViewModelType {
  var inputs: RewardTrackingActivitiesCellViewModelInputs { get }
  var outputs: RewardTrackingActivitiesCellViewModelOutputs { get }
}

public final class RewardTrackingActivitiesCellViewModel: RewardTrackingActivitiesCellViewModelType,
  RewardTrackingActivitiesCellViewModelInputs,
  RewardTrackingActivitiesCellViewModelOutputs {
  public init() {
    self.projectName = self.configDataSignal.map { $0.name }
    self.projectImageURL = self.configDataSignal.map { URL(string: $0.photo.full) }.skipNil()
  }

  private let (configDataSignal, configDataObserver) = Signal<Project, Never>.pipe()
  public func configure(with data: Project) {
    self.configDataObserver.send(value: data)
  }

  public let projectName: Signal<String, Never>
  public let projectImageURL: Signal<URL, Never>

  public var inputs: RewardTrackingActivitiesCellViewModelInputs { return self }
  public var outputs: RewardTrackingActivitiesCellViewModelOutputs { return self }
}
