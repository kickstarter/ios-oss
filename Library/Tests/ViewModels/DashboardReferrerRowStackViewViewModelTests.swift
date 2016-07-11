import Prelude
import ReactiveCocoa
import Result
import XCTest
@testable import KsApi
@testable import Library
@testable import ReactiveExtensions
@testable import ReactiveExtensions_TestHelpers

// swiftlint:disable type_name
internal final class DashboardReferrersRowStackViewViewModelTests: TestCase {
  // swiftlint:enable type_name
  internal let vm = DashboardReferrerRowStackViewViewModel()
  internal let backersText = TestObserver<String, NoError>()
  internal let percentText = TestObserver<String, NoError>()
  internal let pledgedText = TestObserver<String, NoError>()
  internal let sourceText = TestObserver<String, NoError>()
  internal let textColor = TestObserver<UIColor, NoError>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.backersText.observe(self.backersText.observer)
    self.vm.outputs.percentText.observe(self.percentText.observer)
    self.vm.outputs.pledgedText.observe(self.pledgedText.observer)
    self.vm.outputs.sourceText.observe(self.sourceText.observer)
    self.vm.outputs.textColor.observe(self.textColor.observer)
  }

  func testReferrerRowDataEmits() {
    let referrer = .template
      |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 50
      |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.125
      |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 100
      |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "search"
      |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .`internal`
    let country = Project.Country.US

    self.vm.inputs.configureWith(country: country, referrer: referrer)
    self.backersText.assertValues(["50"])
    self.percentText.assertValues(["12%"])
    self.pledgedText.assertValues(["$100"])
    self.sourceText.assertValues(["search"])
    self.textColor.assertValues([.ksr_green_400])
  }
}
