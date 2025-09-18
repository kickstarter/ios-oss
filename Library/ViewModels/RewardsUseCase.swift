import Foundation
import KsApi
import ReactiveSwift

public protocol RewardsUseCaseOutputs {
  var goToLoginWithIntent: Signal<LoginIntent, Never> { get }
  var goToRewards: Signal<Void, Never> { get }
}

public protocol RewardsUseCaseType {
  var outputs: RewardsUseCaseOutputs { get }
}

public final class RewardsUseCase: RewardsUseCaseType, RewardsUseCaseOutputs {
  public init(
    secretRewardToken: Signal<String?, Never>,
    userSessionStarted: Signal<Void, Never>,
    goToRewardsTapped: Signal<Void, Never>
  ) {
    // `goToRewardsTapped` emits when the "View rewards", "View your rewards"
    // or "Back this project" button is tapped.
    let initialIsLoggedIn = goToRewardsTapped
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
      .takeWhen(goToRewardsTapped)
      .filter { $0 == false }
      .ignoreValues()

    // This signal emits to prompt login when accessing a secret reward token
    // while the user is currently logged out.
    self.goToLoginWithIntent = requiresLoginForSecretRewards
      .takeWhen(goToRewardsTapped)
      .filter { $0 == true }
      .map { _ -> LoginIntent in
        LoginIntent.backProject
      }
  }

  // MARK: Utilities

  /// Attempts to add the user to the secret reward group if logged in and a valid token is present.
  /// - Returns: `true` if the GraphQL mutation `addUserToSecretRewardGroup` was triggered successfully.
  ///            `false` if the user is not logged in or the token is missing/empty, thus skipping the mutation.
  static func addUserToSecretRewardGroupIfNeeded(
    project: Project,
    secretRewardToken: String?
  ) -> SignalProducer<Bool, ErrorEnvelope> {
    let isUserLoggedIn = AppEnvironment.current.currentUser != nil

    guard isUserLoggedIn,
          let secretRewardToken = secretRewardToken,
          !secretRewardToken.isEmpty else {
      return SignalProducer(value: false)
    }

    let input = AddUserToSecretRewardGroupInput(
      projectId: project.graphID,
      secretRewardToken: secretRewardToken
    )
    return AppEnvironment.current.apiService
      .addUserToSecretRewardGroup(input: input)
      .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
      .switchMap { _ -> SignalProducer<Bool, ErrorEnvelope> in
        SignalProducer(value: true)
      }
  }

  // MARK: Properties

  public var goToLoginWithIntent: ReactiveSwift.Signal<LoginIntent, Never>
  public var goToRewards: Signal<Void, Never>

  // MARK: Type

  public var outputs: any RewardsUseCaseOutputs { return self }
}
