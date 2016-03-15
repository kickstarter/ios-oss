import struct Models.Activity
import protocol Library.ViewModelType
import struct ReactiveCocoa.SignalProducer
import class ReactiveCocoa.Signal
import enum Result.NoError
import struct Library.Environment
import struct Library.AppEnvironment
import ReactiveExtensions

internal protocol ActitiviesViewModelInputs {
  func viewDidAppear()
}

internal protocol ActivitiesViewModelOutputs {
  var activities: Signal<[Activity], NoError> { get }
}

internal protocol ActivitiesViewModelType {
  var inputs: ActitiviesViewModelInputs { get }
  var outputs: ActivitiesViewModelOutputs { get }
}

internal final class ActivitiesViewModel: ViewModelType, ActivitiesViewModelType, ActitiviesViewModelInputs, ActivitiesViewModelOutputs {
  typealias Model = Activity

  // MARK: Inputs
  private var (viewDidAppearSignal, viewDidAppearObserver) = Signal<(), NoError>.pipe()
  func viewDidAppear() {
    viewDidAppearObserver.sendNext(())
  }
  internal var inputs: ActitiviesViewModelInputs { return self }

  // MARK: Outputs
  internal let activities: Signal<[Activity], NoError>
  internal var outputs: ActivitiesViewModelOutputs { return self }

  init(env: Environment = AppEnvironment.current) {
    let service = env.apiService
    let user = env.currentUser

    let (refresh, refreshObserver) = Signal<(), NoError>.pipe()

    self.activities = refresh.flatMap { _ in service.fetchActivities().demoteErrors() }
      .map { env in env.activities }

    // update display when the user has changed, otherwise we could do a pull-to-refresh
    user.producer
      .skipRepeats(==)
      .takeWhen(viewDidAppearSignal)
      .startWithNext { u in
        refreshObserver.sendNext()
    }
  }
}
