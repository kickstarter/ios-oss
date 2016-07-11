import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

internal final class DashboardReferrersCellViewModelTests: TestCase {
  internal let vm = DashboardReferrersCellViewModel()
  internal let averagePledgeText = TestObserver<String, NoError>()
  internal let externalPercentText = TestObserver<String, NoError>()
  internal let externalPledgedText = TestObserver<String, NoError>()
  internal let internalPercentText = TestObserver<String, NoError>()
  internal let internalPledgedText = TestObserver<String, NoError>()
  internal let notifyDelegateAddedReferrerRows = TestObserver<Void, NoError>()
  internal let referrersRowCountry = TestObserver<Project.Country, NoError>()
  internal let referrersRowReferrers = TestObserver<[ProjectStatsEnvelope.ReferrerStats], NoError>()
  internal let showMoreReferrersButtonHidden = TestObserver<Bool, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.averagePledgeText.observe(self.averagePledgeText.observer)
    self.vm.outputs.externalPercentText.observe(self.externalPercentText.observer)
    self.vm.outputs.externalPledgedText.observe(self.externalPledgedText.observer)
    self.vm.outputs.internalPercentText.observe(self.internalPercentText.observer)
    self.vm.outputs.internalPledgedText.observe(self.internalPledgedText.observer)
    self.vm.outputs.notifyDelegateAddedReferrerRows.observe(self.notifyDelegateAddedReferrerRows.observer)
    self.vm.outputs.referrersRowData.map { $0.country }.observe(self.referrersRowCountry.observer)
    self.vm.outputs.referrersRowData.map { $0.referrers }.observe(self.referrersRowReferrers.observer)
    self.vm.outputs.showMoreReferrersButtonHidden.observe(self.showMoreReferrersButtonHidden.observer)
  }

  func testAccumulatedReferrerDataEmits() {
    let country = Project.Country.US
    let cumulative = ProjectStatsEnvelope.Cumulative.template
    let project = .template |> Project.lens.country .~ country
    let referrers = [
      .template
        |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.5
        |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 500
        |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .`internal`,
      .template
        |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.2
        |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 200
        |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .`internal`,
      .template
        |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.3
        |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 300
        |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .external,
      ]

    self.vm.inputs.configureWith(cumulative: cumulative, project: project, referrers: referrers)

    self.externalPercentText.assertValues(["30%"])
    self.externalPledgedText.assertValues(["$300"])
    self.internalPercentText.assertValues(["70%"])
    self.internalPledgedText.assertValues(["$700"])
  }

  func testCumulativeDataEmits() {
    let country = Project.Country.US
    let cumulative = .template
      |> ProjectStatsEnvelope.Cumulative.lens.averagePledge .~ 50
    let project = .template |> Project.lens.country .~ country
    let referrers = [ProjectStatsEnvelope.ReferrerStats.template]

    self.vm.inputs.configureWith(cumulative: cumulative, project: project, referrers: referrers)
    self.averagePledgeText.assertValues(["$50"], "Average pledge amount emits.")
  }

  func testReferrersRowDataEmits() {
    let stats1 = .template |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 1
    let stats2 = .template |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 2
    let stats3 = .template |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 3
    let stats4 = .template |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 4
    let stats5 = .template |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 5
    let stats6 = .template |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 6
    let stats7 = .template |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 7
    let stats8 = .template |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 8
    let stats9 = .template |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 9
    let stats10 = .template |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 10

    let country = Project.Country.US
    let cumulative = ProjectStatsEnvelope.Cumulative.template
    let project = .template |> Project.lens.country .~ country
    let referrers = [stats1, stats2, stats3, stats4, stats5, stats6, stats7, stats8, stats9, stats10]

    self.vm.inputs.configureWith(cumulative: cumulative, project: project, referrers: referrers)
    self.referrersRowCountry.assertValues([country], "Project country emits.")
    self.referrersRowReferrers.assertValues([[stats1, stats2, stats3, stats4]],
                                            "First four referrer stats emit.")
    self.showMoreReferrersButtonHidden.assertValues([false], "Button shown when there are more referrers.")
    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.showMoreReferrersTapped()
    self.referrersRowReferrers.assertValues(
      [
        [stats1, stats2, stats3, stats4],
        [stats1, stats2, stats3, stats4, stats5, stats6, stats7, stats8, stats9, stats10]
      ],
      "Remaining referrer stats emit."
    )
    self.notifyDelegateAddedReferrerRows.assertValueCount(1, "Notified delegate that rows were added.")
    self.showMoreReferrersButtonHidden.assertValues([false, true], "Button hidden when clicked.")
    XCTAssertEqual(["Showed All Referrers"], self.trackingClient.events)
  }

  func testSortByColumn() {
    let country = Project.Country.US
    let cumulative = ProjectStatsEnvelope.Cumulative.template
    let project = .template |> Project.lens.country .~ country

    let stats1 = .template
      |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 6
      |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.3
      |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 300
      |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "B"

    let stats2 = .template
      |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 3
      |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.5
      |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 500
      |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "A"

    let stats3 = .template
      |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 10
      |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.2
      |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 200
      |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "C"

    let stats4 = .template
      |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 2
      |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.05
      |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 50
      |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "E"

    let stats5 = .template
      |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 7
      |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.15
      |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 150
      |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "D"

    let referrers = [stats1, stats2, stats3, stats4, stats5]

    self.vm.inputs.configureWith(cumulative: cumulative, project: project, referrers: referrers)
    self.referrersRowReferrers.assertValues(
      [[stats2, stats1, stats3, stats5, stats4]],
      "Initial stats emit sorted by descending pledge amount."
    )

    self.vm.inputs.backersButtonTapped()
    self.referrersRowReferrers.assertValues(
      [[stats3, stats5, stats1, stats2, stats4]],
      "Stats emit sorted by descending backers count."
    )

    self.vm.inputs.percentButtonTapped()
    self.referrersRowReferrers.assertValues(
      [[stats2, stats1, stats3, stats5, stats4]],
      "Stats emit sorted by descending percent pledged amount."
    )

    self.vm.inputs.pledgedButtonTapped()
    self.referrersRowReferrers.assertValues(
      [[stats2, stats1, stats3, stats5, stats4]],
      "Stats emit sorted by descending pledge amount."
    )

    self.vm.inputs.sourceButtonTapped()
    self.referrersRowReferrers.assertValues(
      [[stats2, stats1, stats3, stats5, stats4]],
      "Stats emit sorted alphabetically."
    )
    self.notifyDelegateAddedReferrerRows.assertDidNotEmitValue("Delegate should not have added any rows.")
  }
}
