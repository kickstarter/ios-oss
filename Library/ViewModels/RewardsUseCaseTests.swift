@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardsUseCaseTests: TestCase {
  private var vm: RewardsUseCase!

  private let goToLoginWithIntent = TestObserver<LoginIntent, Never>()
  private let goToRewards = TestObserver<Void, Never>()
  private let secretRewardToken = TestObserver<String?, Never>()
  private let userSessionStarted = TestObserver<Void, Never>()

  private let (secretRewardTokenSignal, secretRewardTokenObserver) = Signal<String?, Never>.pipe()
  private let (userSessionStartedSignal, userSessionStartedObserver) = Signal<Void, Never>.pipe()
  private let (goToRewardsTappedSignal, goToRewardsTappedObserver) = Signal<Void, Never>.pipe()

  override func setUp() {
    super.setUp()

    self.secretRewardTokenSignal.observe(self.secretRewardToken.observer)
    self.userSessionStartedSignal.observe(self.userSessionStarted.observer)

    self.vm = .init(
      secretRewardToken: self.secretRewardTokenSignal,
      userSessionStarted: self.userSessionStartedSignal,
      goToRewardsTapped: self.goToRewardsTappedSignal
    )

    self.vm.goToLoginWithIntent.observe(self.goToLoginWithIntent.observer)
    self.vm.goToRewards.observe(self.goToRewards.observer)
  }

  func test_goToRewards_whenUserIsLoggedOut_andNoSecretRewardToken() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.secretRewards.rawValue: true
    ]

    withEnvironment(currentUser: nil, remoteConfigClient: mockConfigClient) {
      self.secretRewardTokenObserver.send(value: nil)

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidNotEmitValue()

      self.goToRewardsTappedObserver.send(value: ())

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidEmitValue()
    }
  }

  func test_goToRewards_whenUserIsLoggedIn_andNoSecretRewardToken() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.secretRewards.rawValue: true
    ]

    withEnvironment(currentUser: .template, remoteConfigClient: mockConfigClient) {
      self.secretRewardTokenObserver.send(value: nil)

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidNotEmitValue()

      self.goToRewardsTappedObserver.send(value: ())

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidEmitValue()
    }
  }

  func test_goToRewards_whenUserIsLoggedIn_andHasSecretRewardToken() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.secretRewards.rawValue: true
    ]

    withEnvironment(currentUser: .template, remoteConfigClient: mockConfigClient) {
      self.secretRewardTokenObserver.send(value: "secret-reward-token")

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidNotEmitValue()

      self.goToRewardsTappedObserver.send(value: ())

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidEmitValue()
    }
  }

  func test_goToLogin_whenUserIsLoggedOut_andHasSecretRewardToken() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.secretRewards.rawValue: true
    ]

    withEnvironment(currentUser: nil, remoteConfigClient: mockConfigClient) {
      self.secretRewardTokenObserver.send(value: "secret-reward-token")

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidNotEmitValue()

      self.goToRewardsTappedObserver.send(value: ())

      self.goToLoginWithIntent.assertValues([.backProject])
      self.goToRewards.assertDidNotEmitValue()
    }
  }

  // MARK: - Feature flag Off

  func test_goToRewards_whenUserIsLoggedIn_andHasSecretRewardToken_FeatureflagOff() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.secretRewards.rawValue: false
    ]

    withEnvironment(currentUser: .template, remoteConfigClient: mockConfigClient) {
      self.secretRewardTokenObserver.send(value: "secret-reward-token")

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidNotEmitValue()

      self.goToRewardsTappedObserver.send(value: ())

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidEmitValue()
    }
  }

  func test_goToRewards_whenUserIsLoggedOut_andHasSecretRewardToken_FeatureflagOff() {
    let mockConfigClient = MockRemoteConfigClient()
    mockConfigClient.features = [
      RemoteConfigFeature.secretRewards.rawValue: false
    ]

    withEnvironment(currentUser: nil, remoteConfigClient: mockConfigClient) {
      self.secretRewardTokenObserver.send(value: "secret-reward-token")

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidNotEmitValue()

      self.goToRewardsTappedObserver.send(value: ())

      self.goToLoginWithIntent.assertDidNotEmitValue()
      self.goToRewards.assertDidEmitValue()
    }
  }
}
