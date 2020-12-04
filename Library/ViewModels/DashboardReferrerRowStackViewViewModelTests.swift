@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

internal final class DashboardReferrersRowStackViewViewModelTests: TestCase {
  internal let vm = DashboardReferrerRowStackViewViewModel()
  internal let backersText = TestObserver<String, Never>()
  internal let pledgedText = TestObserver<String, Never>()
  internal let sourceText = TestObserver<String, Never>()
  internal let textColor = TestObserver<UIColor, Never>()

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.backersText.observe(self.backersText.observer)
    self.vm.outputs.pledgedText.observe(self.pledgedText.observer)
    self.vm.outputs.sourceText.observe(self.sourceText.observer)
    self.vm.outputs.textColor.observe(self.textColor.observer)
  }

  func testReferrerRowDataEmits() {
    let referrer = .template
      |> ProjectStatsEnvelope.ReferrerStats.lens.backersCount .~ 50
      |> ProjectStatsEnvelope.ReferrerStats.lens.percentageOfDollars .~ 0.125
      |> ProjectStatsEnvelope.ReferrerStats.lens.pledged .~ 100.0
      |> ProjectStatsEnvelope.ReferrerStats.lens.referrerName .~ "search"
      |> ProjectStatsEnvelope.ReferrerStats.lens.referrerType .~ .internal
    let country = Project.Country.us

    self.vm.inputs.configureWith(country: country, referrer: referrer)
    self.backersText.assertValues(["50"])
    self.pledgedText.assertValues(["$100 (12%)"])
    self.sourceText.assertValues(["search"])
    self.textColor.assertValues([.ksr_create_700])
  }
}
