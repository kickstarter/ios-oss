import Foundation
import KsApi
import ReactiveSwift

public struct TrackingActivitiesCellData {
  public let trackingData: RewardTrackingDetailsViewData
  public let project: Project

  public init(trackingData: RewardTrackingDetailsViewData, project: Project) {
    self.trackingData = trackingData
    self.project = project
  }
}

public protocol TrackingActivitiesCellViewModelInputs {
  func configure(with data: Project)
}

public protocol TrackingActivitiesCellViewModelOutputs {
  var projectName: Signal<String, Never> { get }
  var projectImageURL: Signal<URL, Never> { get }
}

public protocol TrackingActivitiesCellViewModelType {
  var inputs: TrackingActivitiesCellViewModelInputs { get }
  var outputs: TrackingActivitiesCellViewModelOutputs { get }
}

public final class TrackingActivitiesCellViewModel: TrackingActivitiesCellViewModelType,
  TrackingActivitiesCellViewModelInputs,
  TrackingActivitiesCellViewModelOutputs {
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

  public var inputs: TrackingActivitiesCellViewModelInputs { return self }
  public var outputs: TrackingActivitiesCellViewModelOutputs { return self }
}
