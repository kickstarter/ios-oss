import protocol Library.ViewModelType
import struct Library.AppEnvironment
import struct Library.Environment
import struct KsApi.DiscoveryParams
import struct ReactiveCocoa.SignalProducer
import struct Models.Project
import enum Result.NoError

internal protocol DiscoveryViewModelOutputs {
  var projects: SignalProducer<[Project], NoError> { get }
}

internal protocol DiscoveryViewModelType {
  var outputs: DiscoveryViewModelOutputs { get }
}

internal final class DiscoveryViewModel: ViewModelType, DiscoveryViewModelType, DiscoveryViewModelOutputs {
  typealias Model = ()

  internal let projects: SignalProducer<[Project], NoError>

  internal var outputs: DiscoveryViewModelOutputs { return self }

  internal init(env: Environment = AppEnvironment.current) {
    let service = env.apiService

    self.projects = service.fetchProjects(DiscoveryParams(includePOTD: true))
      .demoteErrors()
      .replayLazily(1)
  }
}
