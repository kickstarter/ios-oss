import struct Models.Activity
import protocol Library.ViewModelType
import struct ReactiveCocoa.SignalProducer
import class ReactiveCocoa.Signal
import enum Result.NoError
import struct Library.Environment
import struct Library.AppEnvironment
import ReactiveExtensions

internal protocol ActitiviesViewModelInputs {
  func viewWillAppear()
}

internal protocol ActivitiesViewModelOutputs {
  var activities: SignalProducer<[Activity], NoError> { get }
}

internal protocol ActivitiesViewModelType {
  var inputs: ActitiviesViewModelInputs { get }
  var outputs: ActivitiesViewModelOutputs { get }
}

internal final class ActivitiesViewModel: ViewModelType, ActivitiesViewModelType, ActitiviesViewModelInputs, ActivitiesViewModelOutputs {
  typealias Model = Activity

  // MARK: Inputs
  private var (viewAppearing, viewAppearingObserver) = Signal<(), NoError>.pipe()
  func viewWillAppear() {
    viewAppearingObserver.sendNext(())
  }
  internal var inputs: ActitiviesViewModelInputs { return self }

  // MARK: Outputs
  internal let activities: SignalProducer<[Activity], NoError>
  internal var outputs: ActivitiesViewModelOutputs { return self }

  init(env: Environment = AppEnvironment.current) {
    let service = env.apiService
    let user = env.currentUser

    let (refresh, refreshObserver) = Signal<(), NoError>.pipe()

    self.activities = service.fetchActivities()
      .demoteErrors()
      .map { env in env.activities }
      .replayLazily(1)

    user.producer
      .takeWhen(viewAppearing)
      .startWithNext { u in
        refreshObserver.sendNext()
    }
  }
}
