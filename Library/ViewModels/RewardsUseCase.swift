import Foundation
import KsApi
import ReactiveSwift

public protocol RewardsUseCaseInputs {
  func goToRewardsTapped()
}

public protocol RewardsUseCaseOutputs {
  var goToLoginWithIntent: Signal<LoginIntent, Never> { get }
  var goToRewards: Signal<Void, Never> { get }
}

public protocol RewardsUseCaseType {
  var inputs: RewardsUseCaseInputs { get }
  var outputs: RewardsUseCaseOutputs { get }
}

public final class RewardsUseCase: RewardsUseCaseType, RewardsUseCaseInputs, RewardsUseCaseOutputs {
  public init(secretRewardToken: Signal<String?, Never>, userSessionStarted: Signal<Void, Never>) {
    // Emits when the "View rewards", "View your rewards" or "Back this project" button is tapped.
    let goToRewardsTappedSignal = self.goToRewardsTappedProperty.signal

    let initialIsLoggedIn = goToRewardsTappedSignal
      .compactMap {
        AppEnvironment.current.currentUser != nil
      }

    let isLoggedIn = Signal.merge(
      initialIsLoggedIn,
      userSessionStarted.mapConst(true)
    )

    let isSecretReward = secretRewardToken
      .map { secretRewardToken -> Bool in
        guard let secretRewardToken = secretRewardToken else {
          return false
        }

        return !secretRewardToken.isEmpty
      }

    // Determines if login is required.
    // This is necessary when a secret reward token is present,
    // since calling `addUserToSecretRewardGroup` requires the user to be logged in.
    let requiresLoginForSecretRewards = isSecretReward
      .combineLatest(with: isLoggedIn)
      .compactMap { isSecretReward, isLoggedIn -> Bool in
        isSecretReward && !isLoggedIn
      }

    self.goToRewards = requiresLoginForSecretRewards
      .takeWhen(goToRewardsTappedSignal)
      .filter { $0 == false }
      .ignoreValues()

    // This signal emits to prompt login when accessing a secret reward token
    // while the user is currently logged out.
    self.goToLoginWithIntent = requiresLoginForSecretRewards
      .takeWhen(goToRewardsTappedSignal)
      .filter { $0 == true }
      .map { _ -> LoginIntent in
        LoginIntent.backProject
      }
  }

  // MARK: - Inputs

  private let goToRewardsTappedProperty = MutableProperty(())
  public func goToRewardsTapped() {
    self.goToRewardsTappedProperty.value = ()
  }

  // MARK: Properties

  public var goToLoginWithIntent: ReactiveSwift.Signal<LoginIntent, Never>
  public var goToRewards: Signal<Void, Never>

  // MARK: Type

  public var inputs: any RewardsUseCaseInputs { return self }
  public var outputs: any RewardsUseCaseOutputs { return self }
}
