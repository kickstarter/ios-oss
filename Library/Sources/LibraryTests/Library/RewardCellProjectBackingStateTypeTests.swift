@testable import KsApi
@testable import Library
import Prelude
import XCTest

final class RewardCellProjectBackingStateTypeTests: TestCase {
  func test_Nonbacked_Live() {
    let project = .template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .live

    XCTAssertEqual(
      .nonBacked(live: .live),
      RewardCellProjectBackingStateType.state(with: project)
    )
  }

  func test_Nonbacked_NonLive() {
    let project = .template
      |> Project.lens.personalization.isBacking .~ false
      |> Project.lens.personalization.backing .~ nil
      |> Project.lens.state .~ .successful

    XCTAssertEqual(
      .nonBacked(live: .nonLive),
      RewardCellProjectBackingStateType.state(with: project)
    )
  }

  func test_Backed_NonLive() {
    let backing = Backing.template

    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.state .~ .successful

    XCTAssertEqual(
      .backed(live: .nonLive),
      RewardCellProjectBackingStateType.state(with: project)
    )
  }

  func test_Backed_Live() {
    let backing = Backing.template

    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.state .~ .live

    XCTAssertEqual(
      .backed(live: .live),
      RewardCellProjectBackingStateType.state(with: project)
    )
  }

  func test_Backed_Error_Live() {
    let backing = Backing.template
      |> Backing.lens.status .~ .errored

    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.state .~ .live

    XCTAssertEqual(
      .backed(live: .live),
      RewardCellProjectBackingStateType.state(with: project)
    )
  }

  func test_Backed_Error_NonLive() {
    let backing = Backing.template
      |> Backing.lens.status .~ .errored

    let project = .template
      |> Project.lens.personalization.isBacking .~ true
      |> Project.lens.personalization.backing .~ backing
      |> Project.lens.state .~ .successful

    XCTAssertEqual(
      .backed(live: .nonLive),
      RewardCellProjectBackingStateType.state(with: project)
    )
  }
}
