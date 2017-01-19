import Prelude
import ReactiveSwift
import ReactiveExtensions
import Result
import XCTest
@testable import KsApi
@testable import ReactiveExtensions_TestHelpers
@testable import Library
@testable import LiveStream

final class LiveStreamDiscoveryCellViewModelTests: TestCase {
  private let vm: LiveStreamDiscoveryCellViewModelType = LiveStreamDiscoveryCellViewModel()

  private let backgroundImageUrl = TestObserver<String?, NoError>()
  private let countdownStackViewHidden = TestObserver<Bool, NoError>()
  private let creatorImageUrl = TestObserver<String?, NoError>()
  private let creatorLabelText = TestObserver<String, NoError>()
  private let dateLabelText = TestObserver<String, NoError>()
  private let dayCountLabelText = TestObserver<String, NoError>()
  private let hourCountLabelText = TestObserver<String, NoError>()
  private let minuteCountLabelText = TestObserver<String, NoError>()
  private let nameLabelText = TestObserver<String, NoError>()
  private let secondCountLabelText = TestObserver<String, NoError>()
  private let watchButtonHidden = TestObserver<Bool, NoError>()

  override func setUp() {
    super.setUp()

    self.vm.outputs.backgroundImageUrl.map { $0?.absoluteString }.observe(self.backgroundImageUrl.observer)
    self.vm.outputs.countdownStackViewHidden.observe(self.countdownStackViewHidden.observer)
    self.vm.outputs.creatorImageUrl.map { $0?.absoluteString }.observe(self.creatorImageUrl.observer)
    self.vm.outputs.creatorLabelText.observe(self.creatorLabelText.observer)
    self.vm.outputs.dateLabelText.observe(self.dateLabelText.observer)
    self.vm.outputs.dayCountLabelText.observe(self.dayCountLabelText.observer)
    self.vm.outputs.hourCountLabelText.observe(self.hourCountLabelText.observer)
    self.vm.outputs.minuteCountLabelText.observe(self.minuteCountLabelText.observer)
    self.vm.outputs.nameLabelText.observe(self.nameLabelText.observer)
    self.vm.outputs.secondCountLabelText.observe(self.secondCountLabelText.observer)
    self.vm.outputs.watchButtonHidden.observe(self.watchButtonHidden.observer)
  }

  func testBackgroundImageUrl() {
    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.backgroundImage.smallCropped .~ "http://www.image.jpg"
    )

    self.backgroundImageUrl.assertValues(["http://www.image.jpg"])
  }

  func testCoundownStackViewHidden_CurrentlyLive() {
    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.liveNow .~ true
    )

    self.countdownStackViewHidden.assertValues([true])
  }

  func testCoundownStackViewHidden_FutureLiveStream() {
    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.liveNow .~ false
        |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(60 * 60).date
    )

    self.countdownStackViewHidden.assertValues([false])
  }

  func testCoundownStackViewHidden_PastLiveStream() {
    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.liveNow .~ false
        |> LiveStreamEvent.lens.hasReplay .~ true
        |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60 * 60).date
    )

    self.countdownStackViewHidden.assertValues([true])
  }

  func testCreatorImageUrl() {
    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.creator.avatar .~ "http://www.image.jpg"
    )

    self.creatorImageUrl.assertValues(["http://www.image.jpg"])
  }

  func testDateLabelText_EST_en_US() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(abbreviation: "EST")!

    withEnvironment(calendar: calendar, locale: Locale(identifier: "en-US")) {
      self.vm.inputs.configureWith(
        liveStreamEvent: .template
          |> LiveStreamEvent.lens.liveNow .~ false
          |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(60 * 60).date
      )

      self.dateLabelText.assertValues(["Live stream – Oct 1, 7:35 PM EDT"])
    }
  }

  func testDateLabelText_PST_en_GB() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(abbreviation: "PST")!

    withEnvironment(calendar: calendar, locale: Locale(identifier: "en_GB")) {
      self.vm.inputs.configureWith(
        liveStreamEvent: .template
          |> LiveStreamEvent.lens.liveNow .~ false
          |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(60 * 60).date
      )

      self.dateLabelText.assertValues(["Live stream – 1 Oct, 4:35 pm GMT-7"])
    }
  }

  func testCountLabels() {
    let future: TimeInterval = TimeInterval(1*60*60*24) + TimeInterval(16*60*60) + TimeInterval(34*60) + 1

    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.liveNow .~ false
        |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(future).date
    )

    self.dayCountLabelText.assertValues(["01"])
    self.hourCountLabelText.assertValues(["16"])
    self.minuteCountLabelText.assertValues(["34"])
    self.secondCountLabelText.assertValues(["01"])

    self.scheduler.advance(by: .seconds(1))

    self.dayCountLabelText.assertValues(["01"])
    self.hourCountLabelText.assertValues(["16"])
    self.minuteCountLabelText.assertValues(["34"])
    self.secondCountLabelText.assertValues(["01", "00"])

    self.scheduler.advance(by: .seconds(1))

    self.dayCountLabelText.assertValues(["01"])
    self.hourCountLabelText.assertValues(["16"])
    self.minuteCountLabelText.assertValues(["34", "33"])
    self.secondCountLabelText.assertValues(["01", "00", "59"])
  }

  func testCountLabels_StartingOnFractionalSecond() {
    let future: TimeInterval = TimeInterval(1*60*60*24) + TimeInterval(16*60*60) + TimeInterval(34*60) + 1.5

    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.liveNow .~ false
        |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(future).date
    )

    self.dayCountLabelText.assertValues(["01"])
    self.hourCountLabelText.assertValues(["16"])
    self.minuteCountLabelText.assertValues(["34"])
    self.secondCountLabelText.assertValues(["02"])

    self.scheduler.advance(by: .milliseconds(500))

    self.dayCountLabelText.assertValues(["01"])
    self.hourCountLabelText.assertValues(["16"])
    self.minuteCountLabelText.assertValues(["34"])
    self.secondCountLabelText.assertValues(["02"])

    self.scheduler.advance(by: .seconds(1))

    self.dayCountLabelText.assertValues(["01"])
    self.hourCountLabelText.assertValues(["16"])
    self.minuteCountLabelText.assertValues(["34"])
    self.secondCountLabelText.assertValues(["02", "01"])

    self.scheduler.advance(by: .seconds(1))

    self.dayCountLabelText.assertValues(["01"])
    self.hourCountLabelText.assertValues(["16"])
    self.minuteCountLabelText.assertValues(["34"])
    self.secondCountLabelText.assertValues(["02", "01", "00"])
  }

  func testNameLabelText() {
    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.name .~ "Upcoming live stream"
    )

    self.nameLabelText.assertValues(["Upcoming live stream"])
  }

  func testWatchButtonHidden_CurrentlyLive() {
    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.liveNow .~ true
    )

    self.watchButtonHidden.assertValues([false])
  }

  func testWatchButtonHidden_FutureLiveStream() {
    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(60 * 60).date
        |> LiveStreamEvent.lens.liveNow .~ false
        |> LiveStreamEvent.lens.hasReplay .~ false
    )

    self.watchButtonHidden.assertValues([true])
  }

  func testWatchButtonHidden_PastLiveStream() {
    self.vm.inputs.configureWith(
      liveStreamEvent: .template
        |> LiveStreamEvent.lens.startDate .~ MockDate().addingTimeInterval(-60 * 60).date
        |> LiveStreamEvent.lens.liveNow .~ false
        |> LiveStreamEvent.lens.hasReplay .~ true
    )

    self.watchButtonHidden.assertValues([false])
  }
}
