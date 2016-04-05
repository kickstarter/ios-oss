import protocol Library.ViewModelType
import struct Library.AppEnvironment
import struct Library.Environment
import struct KsApi.DiscoveryParams
import struct ReactiveCocoa.SignalProducer
import struct Models.Project
import enum Result.NoError
import Prelude

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
    let koala = env.koala

    self.projects = service.fetchProjects(DiscoveryParams(includePOTD: true))
      .demoteErrors()
      .map { $0.distincts() }
      .replayLazily(1)

    koala.trackDiscovery()
  }
}
