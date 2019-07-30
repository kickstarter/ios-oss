@testable import KsApi
@testable import Library
import ReactiveExtensions_TestHelpers
import ReactiveExtensions
import ReactiveSwift
import Prelude
import XCTest

class RewardStateTests: TestCase {

  func test_Limited_RewardState() {
    let reward = Reward.template
      |> Reward.lens.remaining .~ 1
      |> Reward.lens.limit .~ 5
      |> Reward.lens.endsAt .~ self.dateType.init().addingTimeInterval(-60 * 60 * 24 * 3).timeIntervalSince1970

    let project = Project.template

    XCTAssertEqual(.limited, RewardCellProjectBackingState.RewardState.state(with: reward, project: project))
  }

  func test_Both_RewardState() {
    let reward = .template
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 20
      |> Reward.lens.endsAt .~ self.dateType.init().addingTimeInterval(60 * 60 * 24 * 3).timeIntervalSince1970

    let project = Project.template

    XCTAssertEqual(.both, RewardCellProjectBackingState.RewardState.state(with: reward, project: project))
  }

  func test_Unknown_RewardState() {
    let reward = .template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.limit .~ 0
      |> Reward.lens.endsAt .~ self.dateType.init().addingTimeInterval(-60 * 60 * 24 * 3).timeIntervalSince1970

    let project = Project.template

    XCTAssertEqual(.unknown, RewardCellProjectBackingState.RewardState.state(with: reward, project: project))
  }

  func test_Inactive_RewardState() {
    let reward = .template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.limit .~ nil
      |> Reward.lens.endsAt .~ self.dateType.init().addingTimeInterval(-60 * 60 * 24 * 3).timeIntervalSince1970

    let project = Project.template

    XCTAssertEqual(.inactive, RewardCellProjectBackingState.RewardState.state(with: reward, project: project))
  }

  func test_Timebased_RewardState() {
    let reward = .template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.limit .~ 0
      |> Reward.lens.endsAt .~  self.dateType.init().addingTimeInterval(60 * 60 * 24 * 3).timeIntervalSince1970

    let project = Project.template

    XCTAssertEqual(.timebased, RewardCellProjectBackingState.RewardState.state(with: reward, project: project))
  }

  func test_Nonbacked_Live_RewardCellProjectBackingState() {
    let reward = .template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.limit .~ 0
      |> Reward.lens.endsAt .~  self.dateType.init().addingTimeInterval(60 * 60 * 24 * 3).timeIntervalSince1970

    let project = .template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live

    XCTAssertEqual(.nonBacked(live: .live, activeState: .timebased),
                   RewardCellProjectBackingState.state(with: project, reward: reward))
  }

  func test_Nonbacked_NonLive_RewardCellProjectBackingState() {
    let reward = .template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.limit .~ 0

    let project = .template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .successful

    XCTAssertEqual(.nonBacked(live: .nonlive, activeState: .inactive),
                  RewardCellProjectBackingState.state(with: project, reward: reward))
  }

  func test_Backed_NonLive_RewardCellProjectBackingState() {
    let reward = .template
      |> Reward.lens.remaining .~ 0
      |> Reward.lens.limit .~ 0

    let backing = Backing.template

    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.state .~ .successful

    XCTAssertEqual(.backed(live: .nonlive, activeState: .inactive),
                   RewardCellProjectBackingState.state(with: project, reward: reward))
  }


  func test_Backed_Live_RewardCellProjectBackingState() {
    let reward = Reward.template
      |> Reward.lens.remaining .~ 1
      |> Reward.lens.limit .~ 5
      |> Reward.lens.endsAt .~ self.dateType.init().addingTimeInterval(-60 * 60 * 24 * 3).timeIntervalSince1970

    let backing = Backing.template

    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.state .~ .live

    XCTAssertEqual(.backed(live: .live, activeState: .limited),
                   RewardCellProjectBackingState.state(with: project, reward: reward))
  }

  func test_Backed_Error_RewardCellProjectBackingState() {
    let reward = .template
      |> Reward.lens.limit .~ 100
      |> Reward.lens.remaining .~ 20
      |> Reward.lens.endsAt .~ self.dateType.init().addingTimeInterval(60 * 60 * 24 * 3).timeIntervalSince1970

    let backing = Backing.template
      |> Backing.lens.status .~ .errored

    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.state .~ .live

    XCTAssertEqual(.backedError(activeState: .both),
                   RewardCellProjectBackingState.state(with: project, reward: reward))
  }
}
