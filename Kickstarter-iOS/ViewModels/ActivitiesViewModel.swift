import struct Models.Activity
import protocol Library.ViewModelType
import struct ReactiveCocoa.SignalProducer
import enum Result.NoError
import struct Library.Environment
import struct Library.AppEnvironment
import ReactiveExtensions

internal protocol ActivitiesViewModelOutputs {
  var activities: SignalProducer<[Activity], NoError> { get }
}

internal protocol ActivitiesViewModelType {
  var outputs: ActivitiesViewModelOutputs { get }
}

internal final class ActivitiesViewModel: ViewModelType, ActivitiesViewModelType, ActivitiesViewModelOutputs {
  typealias Model = Activity

  internal let activities: SignalProducer<[Activity], NoError>

  internal var outputs: ActivitiesViewModelOutputs { return self }

  init(env: Environment = AppEnvironment.current) {
    let service = env.apiService

    self.activities = service.fetchActivities()
      .demoteErrors()
      .map { env in env.activities }
      .replayLazily(1)
  }
}
