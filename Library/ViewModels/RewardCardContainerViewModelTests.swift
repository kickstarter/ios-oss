@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class RewardCardContainerViewModelTests: TestCase {
  fileprivate let vm: RewardCardContainerViewModelType = RewardCardContainerViewModel()

  private let gradientViewHidden = TestObserver<Bool, Never>()
  private let pledgeButtonStyleType = TestObserver<ButtonStyleType, Never>()
  private let pledgeButtonEnabled = TestObserver<Bool, Never>()
  private let pledgeButtonHidden = TestObserver<Bool, Never>()
  private let pledgeButtonTitleText = TestObserver<String?, Never>()
  private let rewardSelected = TestObserver<Int, Never>()

  let availableLimitedReward = Reward.postcards
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 25
  let availableTimebasedReward = Reward.postcards
    |> Reward.lens.limit .~ nil
    |> Reward.lens.remaining .~ nil
    |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)
  let availableLimitedTimebasedReward = Reward.postcards
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 25
    |> Reward.lens.endsAt .~ (MockDate().timeIntervalSince1970 + 60.0 * 60.0 * 24.0)
  let availableNonLimitedReward = Reward.postcards
    |> Reward.lens.limit .~ nil
    |> Reward.lens.remaining .~ nil
    |> Reward.lens.endsAt .~ nil

  let unavailableLimitedReward = Reward.postcards
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 0
  let unavailableTimebasedReward = Reward.postcards
    |> Reward.lens.limit .~ nil
    |> Reward.lens.remaining .~ nil
    |> Reward.lens.endsAt .~ (MockDate().date.timeIntervalSince1970 - 1)
  let unavailableLimitedTimebasedReward = Reward.postcards
    |> Reward.lens.limit .~ 100
    |> Reward.lens.remaining .~ 0
    |> Reward.lens.endsAt .~ (MockDate().date.timeIntervalSince1970 - 1)

  private var allRewards: [Reward] {
    return [
      availableLimitedReward,
      availableTimebasedReward,
      availableLimitedTimebasedReward,
      availableNonLimitedReward,
      unavailableLimitedReward,
      unavailableTimebasedReward,
      unavailableLimitedTimebasedReward,
      Reward.noReward
    ]
  }

  override func setUp() {
    super.setUp()

    self.vm.outputs.gradientViewHidden.observe(self.gradientViewHidden.observer)
    self.vm.outputs.pledgeButtonStyleType.observe(self.pledgeButtonStyleType.observer)
    self.vm.outputs.pledgeButtonEnabled.observe(self.pledgeButtonEnabled.observer)
    self.vm.outputs.pledgeButtonHidden.observe(self.pledgeButtonHidden.observer)
    self.vm.outputs.pledgeButtonTitleText.observe(self.pledgeButtonTitleText.observer)
    self.vm.outputs.rewardSelected.observe(self.rewardSelected.observer)
  }

  func testLive_BackedProject_BackedReward() {
    self.gradientViewHidden.assertValueCount(0)
    self.pledgeButtonStyleType.assertValueCount(0)
    self.pledgeButtonEnabled.assertValueCount(0)
    self.pledgeButtonHidden.assertValueCount(0)
    self.pledgeButtonTitleText.assertValueCount(0)

    for (index, reward) in self.allRewards.enumerated() {
      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700
        )

      self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

      let emissionCount = index + 1

      self.gradientViewHidden.assertValueCount(emissionCount)
      self.pledgeButtonStyleType.assertValueCount(emissionCount)
      self.pledgeButtonEnabled.assertValueCount(emissionCount)
      self.pledgeButtonHidden.assertValueCount(emissionCount)
      self.pledgeButtonTitleText.assertValueCount(emissionCount)
    }

    self.gradientViewHidden.assertValueCount(self.allRewards.count)
    self.pledgeButtonStyleType.assertValueCount(self.allRewards.count)
    self.pledgeButtonEnabled.assertValueCount(self.allRewards.count)
    self.pledgeButtonHidden.assertValueCount(self.allRewards.count)
    self.pledgeButtonTitleText.assertValueCount(self.allRewards.count)

    self.gradientViewHidden.assertValues([false, false, false, false, false, false, false, false])
    self.pledgeButtonStyleType.assertValues([.black, .black, .black, .black, .black, .black, .black, .black])
    self.pledgeButtonEnabled.assertValues([false, false, false, false, false, false, false, false])
    self.pledgeButtonHidden.assertValues([false, false, false, false, false, false, false, false])
    self.pledgeButtonTitleText.assertValues([
      "Selected",
      "Selected",
      "Selected",
      "Selected",
      "Selected",
      "Selected",
      "Selected",
      "Selected"
    ])
  }

  func testLive_BackedProject_NonBackedReward() {
    self.gradientViewHidden.assertValueCount(0)
    self.pledgeButtonStyleType.assertValueCount(0)
    self.pledgeButtonEnabled.assertValueCount(0)
    self.pledgeButtonHidden.assertValueCount(0)
    self.pledgeButtonTitleText.assertValueCount(0)

    for (index, reward) in self.allRewards.enumerated() {
      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.reward .~ Reward.otherReward
            |> Backing.lens.rewardId .~ Reward.otherReward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700
        )

      self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

      let emissionCount = index + 1

      self.gradientViewHidden.assertValueCount(emissionCount)
      self.pledgeButtonStyleType.assertValueCount(emissionCount)
      self.pledgeButtonEnabled.assertValueCount(emissionCount)
      self.pledgeButtonHidden.assertValueCount(emissionCount)
      self.pledgeButtonTitleText.assertValueCount(emissionCount)
    }

    self.gradientViewHidden.assertValueCount(self.allRewards.count)
    self.pledgeButtonStyleType.assertValueCount(self.allRewards.count)
    self.pledgeButtonEnabled.assertValueCount(self.allRewards.count)
    self.pledgeButtonHidden.assertValueCount(self.allRewards.count)
    self.pledgeButtonTitleText.assertValueCount(self.allRewards.count)

    self.gradientViewHidden.assertValues([false, false, false, false, false, false, false, false])
    self.pledgeButtonStyleType.assertValues([.green, .green, .green, .green, .green, .green, .green, .green])
    self.pledgeButtonEnabled.assertValues([true, true, true, true, false, false, false, true])
    self.pledgeButtonHidden.assertValues([false, false, false, false, false, false, false, false])
    self.pledgeButtonTitleText.assertValues([
      "Select",
      "Select",
      "Select",
      "Select",
      "No longer available",
      "No longer available",
      "No longer available",
      "Select"
    ])
  }

  func testLive_NonBackedProject_LoggedIn() {
    withEnvironment(currentUser: .template) {
      self.gradientViewHidden.assertValueCount(0)
      self.pledgeButtonStyleType.assertValueCount(0)
      self.pledgeButtonEnabled.assertValueCount(0)
      self.pledgeButtonHidden.assertValueCount(0)
      self.pledgeButtonTitleText.assertValueCount(0)

      for (index, reward) in self.allRewards.enumerated() {
        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ false

        self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

        let emissionCount = index + 1

        self.gradientViewHidden.assertValueCount(emissionCount)
        self.pledgeButtonStyleType.assertValueCount(emissionCount)
        self.pledgeButtonEnabled.assertValueCount(emissionCount)
        self.pledgeButtonHidden.assertValueCount(emissionCount)
        self.pledgeButtonTitleText.assertValueCount(emissionCount)
      }

      self.gradientViewHidden.assertValueCount(self.allRewards.count)
      self.pledgeButtonStyleType.assertValueCount(self.allRewards.count)
      self.pledgeButtonEnabled.assertValueCount(self.allRewards.count)
      self.pledgeButtonHidden.assertValueCount(self.allRewards.count)
      self.pledgeButtonTitleText.assertValueCount(self.allRewards.count)

      self.gradientViewHidden.assertValues([false, false, false, false, false, false, false, false])
      self.pledgeButtonStyleType.assertValues(
        [.green, .green, .green, .green, .green, .green, .green, .green]
      )
      self.pledgeButtonEnabled.assertValues([true, true, true, true, false, false, false, true])
      self.pledgeButtonHidden.assertValues([false, false, false, false, false, false, false, false])
      self.pledgeButtonTitleText.assertValues([
        "Select",
        "Select",
        "Select",
        "Select",
        "No longer available",
        "No longer available",
        "No longer available",
        "Select"
      ])
    }
  }

  func testLive_NonBackedProject_LoggedOut() {
    withEnvironment(currentUser: nil) {
      self.gradientViewHidden.assertValueCount(0)
      self.pledgeButtonStyleType.assertValueCount(0)
      self.pledgeButtonEnabled.assertValueCount(0)
      self.pledgeButtonHidden.assertValueCount(0)
      self.pledgeButtonTitleText.assertValueCount(0)

      for (index, reward) in self.allRewards.enumerated() {
        let project = Project.cosmicSurgery
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ nil
          |> Project.lens.personalization.backing .~ nil

        self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

        let emissionCount = index + 1

        self.gradientViewHidden.assertValueCount(emissionCount)
        self.pledgeButtonStyleType.assertValueCount(emissionCount)
        self.pledgeButtonEnabled.assertValueCount(emissionCount)
        self.pledgeButtonHidden.assertValueCount(emissionCount)
        self.pledgeButtonTitleText.assertValueCount(emissionCount)
      }

      self.gradientViewHidden.assertValueCount(self.allRewards.count)
      self.pledgeButtonStyleType.assertValueCount(self.allRewards.count)
      self.pledgeButtonEnabled.assertValueCount(self.allRewards.count)
      self.pledgeButtonHidden.assertValueCount(self.allRewards.count)
      self.pledgeButtonTitleText.assertValueCount(self.allRewards.count)

      self.gradientViewHidden.assertValues([false, false, false, false, false, false, false, false])
      self.pledgeButtonStyleType.assertValues(
        [.green, .green, .green, .green, .green, .green, .green, .green]
      )
      self.pledgeButtonEnabled.assertValues([true, true, true, true, false, false, false, true])
      self.pledgeButtonHidden.assertValues([false, false, false, false, false, false, false, false])
      self.pledgeButtonTitleText.assertValues([
        "Select",
        "Select",
        "Select",
        "Select",
        "No longer available",
        "No longer available",
        "No longer available",
        "Select"
      ])
    }
  }

  func testNonLive_BackedProject_BackedReward() {
    self.gradientViewHidden.assertValueCount(0)
    self.pledgeButtonStyleType.assertValueCount(0)
    self.pledgeButtonEnabled.assertValueCount(0)
    self.pledgeButtonHidden.assertValueCount(0)
    self.pledgeButtonTitleText.assertValueCount(0)

    for (index, reward) in self.allRewards.enumerated() {
      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700
        )

      self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

      let emissionCount = index + 1

      self.gradientViewHidden.assertValueCount(emissionCount)
      self.pledgeButtonStyleType.assertValueCount(emissionCount)
      self.pledgeButtonEnabled.assertValueCount(emissionCount)
      self.pledgeButtonHidden.assertValueCount(emissionCount)
      self.pledgeButtonTitleText.assertValueCount(emissionCount)
    }

    self.gradientViewHidden.assertValueCount(self.allRewards.count)
    self.pledgeButtonStyleType.assertValueCount(self.allRewards.count)
    self.pledgeButtonEnabled.assertValueCount(self.allRewards.count)
    self.pledgeButtonHidden.assertValueCount(self.allRewards.count)
    self.pledgeButtonTitleText.assertValueCount(self.allRewards.count)

    self.gradientViewHidden.assertValues([false, false, false, false, false, false, false, false])
    self.pledgeButtonStyleType.assertValues([.black, .black, .black, .black, .black, .black, .black, .black])
    self.pledgeButtonEnabled.assertValues([true, true, true, true, true, true, true, true])
    self.pledgeButtonHidden.assertValues([false, false, false, false, false, false, false, false])
    self.pledgeButtonTitleText.assertValues([
      "View your pledge",
      "View your pledge",
      "View your pledge",
      "View your pledge",
      "View your pledge",
      "View your pledge",
      "View your pledge",
      "View your pledge"
    ])
  }

  func testNonLive_BackedProject_NonBackedReward() {
    self.gradientViewHidden.assertValueCount(0)
    self.pledgeButtonStyleType.assertValueCount(0)
    self.pledgeButtonEnabled.assertValueCount(0)
    self.pledgeButtonHidden.assertValueCount(0)
    self.pledgeButtonTitleText.assertValueCount(0)

    for (index, reward) in self.allRewards.enumerated() {
      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.reward .~ Reward.otherReward
            |> Backing.lens.rewardId .~ Reward.otherReward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700
        )

      self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

      let emissionCount = index + 1

      self.gradientViewHidden.assertValueCount(emissionCount)
      self.pledgeButtonStyleType.assertValueCount(emissionCount)
      self.pledgeButtonEnabled.assertValueCount(emissionCount)
      self.pledgeButtonHidden.assertValueCount(emissionCount)
      self.pledgeButtonTitleText.assertValueCount(emissionCount)
    }

    self.gradientViewHidden.assertValueCount(self.allRewards.count)
    self.pledgeButtonStyleType.assertValueCount(self.allRewards.count)
    self.pledgeButtonEnabled.assertValueCount(self.allRewards.count)
    self.pledgeButtonHidden.assertValueCount(self.allRewards.count)
    self.pledgeButtonTitleText.assertValueCount(self.allRewards.count)

    self.gradientViewHidden.assertValues([true, true, true, true, true, true, true, true])
    self.pledgeButtonStyleType.assertValues([.none, .none, .none, .none, .none, .none, .none, .none])
    self.pledgeButtonEnabled.assertValues([false, false, false, false, false, false, false, false])
    self.pledgeButtonHidden.assertValues([true, true, true, true, true, true, true, true])
    self.pledgeButtonTitleText.assertValues([nil, nil, nil, nil, nil, nil, nil, nil])
  }

  func testNonLive_NonBackedProject() {
    self.gradientViewHidden.assertValueCount(0)
    self.pledgeButtonStyleType.assertValueCount(0)
    self.pledgeButtonEnabled.assertValueCount(0)
    self.pledgeButtonHidden.assertValueCount(0)
    self.pledgeButtonTitleText.assertValueCount(0)

    for (index, reward) in self.allRewards.enumerated() {
      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ false

      self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

      let emissionCount = index + 1

      self.gradientViewHidden.assertValueCount(emissionCount)
      self.pledgeButtonStyleType.assertValueCount(emissionCount)
      self.pledgeButtonEnabled.assertValueCount(emissionCount)
      self.pledgeButtonHidden.assertValueCount(emissionCount)
      self.pledgeButtonTitleText.assertValueCount(emissionCount)
    }

    self.gradientViewHidden.assertValueCount(self.allRewards.count)
    self.pledgeButtonStyleType.assertValueCount(self.allRewards.count)
    self.pledgeButtonEnabled.assertValueCount(self.allRewards.count)
    self.pledgeButtonHidden.assertValueCount(self.allRewards.count)
    self.pledgeButtonTitleText.assertValueCount(self.allRewards.count)

    self.gradientViewHidden.assertValues([true, true, true, true, true, true, true, true])
    self.pledgeButtonStyleType.assertValues([.none, .none, .none, .none, .none, .none, .none, .none])
    self.pledgeButtonEnabled.assertValues([false, false, false, false, false, false, false, false])
    self.pledgeButtonHidden.assertValues([true, true, true, true, true, true, true, true])
    self.pledgeButtonTitleText.assertValues([nil, nil, nil, nil, nil, nil, nil, nil])
  }

  func testLive_BackedProject_BackedReward_Errored() {
    // only test reward states that we can get to
    let rewards = [
      availableLimitedReward,
      availableTimebasedReward,
      availableLimitedTimebasedReward,
      availableNonLimitedReward,
      Reward.noReward
    ]

    self.gradientViewHidden.assertValueCount(0)
    self.pledgeButtonStyleType.assertValueCount(0)
    self.pledgeButtonEnabled.assertValueCount(0)
    self.pledgeButtonHidden.assertValueCount(0)
    self.pledgeButtonTitleText.assertValueCount(0)

    for (index, reward) in rewards.enumerated() {
      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .live
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700
            |> Backing.lens.status .~ .errored
        )

      self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

      let emissionCount = index + 1

      self.gradientViewHidden.assertValueCount(emissionCount)
      self.pledgeButtonStyleType.assertValueCount(emissionCount)
      self.pledgeButtonEnabled.assertValueCount(emissionCount)
      self.pledgeButtonHidden.assertValueCount(emissionCount)
      self.pledgeButtonTitleText.assertValueCount(emissionCount)
    }

    self.gradientViewHidden.assertValueCount(rewards.count)
    self.pledgeButtonStyleType.assertValueCount(rewards.count)
    self.pledgeButtonEnabled.assertValueCount(rewards.count)
    self.pledgeButtonHidden.assertValueCount(rewards.count)
    self.pledgeButtonTitleText.assertValueCount(rewards.count)

    self.gradientViewHidden.assertValues([false, false, false, false, false])
    self.pledgeButtonStyleType.assertValues([.black, .black, .black, .black, .black])
    self.pledgeButtonEnabled.assertValues([false, false, false, false, false])
    self.pledgeButtonHidden.assertValues([false, false, false, false, false])
    self.pledgeButtonTitleText.assertValues([
      "Selected",
      "Selected",
      "Selected",
      "Selected",
      "Selected"
    ])
  }

  func testNonLive_BackedProject_BackedReward_Errored() {
    // only test reward states that we can get to
    let rewards = [
      availableLimitedReward,
      availableTimebasedReward,
      availableLimitedTimebasedReward,
      availableNonLimitedReward,
      Reward.noReward
    ]

    self.gradientViewHidden.assertValueCount(0)
    self.pledgeButtonStyleType.assertValueCount(0)
    self.pledgeButtonEnabled.assertValueCount(0)
    self.pledgeButtonHidden.assertValueCount(0)
    self.pledgeButtonTitleText.assertValueCount(0)

    for (index, reward) in rewards.enumerated() {
      let project = Project.cosmicSurgery
        |> Project.lens.state .~ .successful
        |> Project.lens.personalization.isBacking .~ true
        |> Project.lens.personalization.backing .~ (
          .template
            |> Backing.lens.reward .~ reward
            |> Backing.lens.rewardId .~ reward.id
            |> Backing.lens.shippingAmount .~ 10
            |> Backing.lens.amount .~ 700
            |> Backing.lens.status .~ .errored
        )

      self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

      let emissionCount = index + 1

      self.gradientViewHidden.assertValueCount(emissionCount)
      self.pledgeButtonStyleType.assertValueCount(emissionCount)
      self.pledgeButtonEnabled.assertValueCount(emissionCount)
      self.pledgeButtonHidden.assertValueCount(emissionCount)
      self.pledgeButtonTitleText.assertValueCount(emissionCount)
    }

    self.gradientViewHidden.assertValueCount(rewards.count)
    self.pledgeButtonStyleType.assertValueCount(rewards.count)
    self.pledgeButtonEnabled.assertValueCount(rewards.count)
    self.pledgeButtonHidden.assertValueCount(rewards.count)
    self.pledgeButtonTitleText.assertValueCount(rewards.count)

    self.gradientViewHidden.assertValues([false, false, false, false, false])
    self.pledgeButtonStyleType.assertValues([.black, .black, .black, .black, .black])
    self.pledgeButtonEnabled.assertValues([true, true, true, true, true])
    self.pledgeButtonHidden.assertValues([false, false, false, false, false])
    self.pledgeButtonTitleText.assertValues([
      "View your pledge",
      "View your pledge",
      "View your pledge",
      "View your pledge",
      "View your pledge"
    ])
  }

  func testLive_IsCreator_LoggedIn() {
    let creator = User.template
      |> User.lens.id .~ 5
    withEnvironment(currentUser: creator) {
      self.gradientViewHidden.assertValueCount(0)
      self.pledgeButtonStyleType.assertValueCount(0)
      self.pledgeButtonEnabled.assertValueCount(0)
      self.pledgeButtonHidden.assertValueCount(0)
      self.pledgeButtonTitleText.assertValueCount(0)

      for (index, reward) in self.allRewards.enumerated() {
        let project = Project.cosmicSurgery
          |> Project.lens.creator .~ creator
          |> Project.lens.state .~ .live
          |> Project.lens.personalization.isBacking .~ false

        self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

        let emissionCount = index + 1

        self.gradientViewHidden.assertValueCount(emissionCount)
        self.pledgeButtonStyleType.assertValueCount(emissionCount)
        self.pledgeButtonEnabled.assertValueCount(emissionCount)
        self.pledgeButtonHidden.assertValueCount(emissionCount)
        self.pledgeButtonTitleText.assertValueCount(emissionCount)
      }

      self.gradientViewHidden.assertValueCount(self.allRewards.count)
      self.pledgeButtonStyleType.assertValueCount(self.allRewards.count)
      self.pledgeButtonEnabled.assertValueCount(self.allRewards.count)
      self.pledgeButtonHidden.assertValueCount(self.allRewards.count)
      self.pledgeButtonTitleText.assertValueCount(self.allRewards.count)

      self.gradientViewHidden.assertValues([true, true, true, true, true, true, true, true])
      self.pledgeButtonStyleType.assertValues(
        [.none, .none, .none, .none, .none, .none, .none, .none]
      )
      self.pledgeButtonEnabled.assertValues([false, false, false, false, false, false, false, false])
      self.pledgeButtonHidden.assertValues([true, true, true, true, true, true, true, true])
      self.pledgeButtonTitleText.assertValues([nil, nil, nil, nil, nil, nil, nil, nil])
    }
  }

  func testNonLive_IsCreator_LoggedIn() {
    let creator = User.template
      |> User.lens.id .~ 5

    withEnvironment(currentUser: creator) {
      self.gradientViewHidden.assertValueCount(0)
      self.pledgeButtonStyleType.assertValueCount(0)
      self.pledgeButtonEnabled.assertValueCount(0)
      self.pledgeButtonHidden.assertValueCount(0)
      self.pledgeButtonTitleText.assertValueCount(0)

      for (index, reward) in self.allRewards.enumerated() {
        let project = Project.cosmicSurgery
          |> Project.lens.creator .~ creator
          |> Project.lens.state .~ .successful
          |> Project.lens.personalization.isBacking .~ false

        self.vm.inputs.configureWith(project: project, rewardOrBacking: .init(reward))

        let emissionCount = index + 1

        self.gradientViewHidden.assertValueCount(emissionCount)
        self.pledgeButtonStyleType.assertValueCount(emissionCount)
        self.pledgeButtonEnabled.assertValueCount(emissionCount)
        self.pledgeButtonHidden.assertValueCount(emissionCount)
        self.pledgeButtonTitleText.assertValueCount(emissionCount)
      }

      self.gradientViewHidden.assertValueCount(self.allRewards.count)
      self.pledgeButtonStyleType.assertValueCount(self.allRewards.count)
      self.pledgeButtonEnabled.assertValueCount(self.allRewards.count)
      self.pledgeButtonHidden.assertValueCount(self.allRewards.count)
      self.pledgeButtonTitleText.assertValueCount(self.allRewards.count)

      self.gradientViewHidden.assertValues([true, true, true, true, true, true, true, true])
      self.pledgeButtonStyleType.assertValues(
        [.none, .none, .none, .none, .none, .none, .none, .none]
      )
      self.pledgeButtonEnabled.assertValues([false, false, false, false, false, false, false, false])
      self.pledgeButtonHidden.assertValues([true, true, true, true, true, true, true, true])
      self.pledgeButtonTitleText.assertValues([nil, nil, nil, nil, nil, nil, nil, nil])
    }
  }

  func testPledgeButtonTapped() {
    self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))

    self.vm.inputs.pledgeButtonTapped()

    self.rewardSelected.assertValues([Reward.template.id])
  }

  func testPledgeButtonTapped_eventTracking() {
    let client = MockTrackingClient()

    withEnvironment(apiService: MockService(), koala: Koala(client: client)) {
      XCTAssertEqual([], client.events)

      self.vm.inputs.configureWith(project: .template, rewardOrBacking: .left(.template))

      self.vm.inputs.pledgeButtonTapped()

      XCTAssertEqual(["Select Reward Button Clicked"], client.events)
    }
  }
}
