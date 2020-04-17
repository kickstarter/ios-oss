import AVFoundation
@testable import KsApi
@testable import Library
import Prelude
import ReactiveExtensions_TestHelpers
import XCTest

internal final class VideoViewModelTests: TestCase {
  internal let vm = VideoViewModel()
  internal let addCompletionObserver = TestObserver<CMTime, Never>()
  internal let configurePlayerWithURL = TestObserver<String, Never>()
  internal let incrementVideoCompletion = TestObserver<VoidEnvelope, Never>()
  internal let incrementVideoStart = TestObserver<VoidEnvelope, Never>()
  internal let opacityForViews = TestObserver<CGFloat, Never>()
  internal let pauseVideo = TestObserver<Void, Never>()
  internal let playVideo = TestObserver<Void, Never>()
  internal let playButtonHidden = TestObserver<Bool, Never>()
  internal let projectImageHidden = TestObserver<Bool, Never>()
  internal let projectImageURL = TestObserver<String?, Never>()
  internal let seekToBeginning = TestObserver<Void, Never>()
  internal let videoViewHidden = TestObserver<Bool, Never>()

  let pauseRate = 0.0
  let playRate = 1.0
  let startTime = CMTimeMake(value: 0, timescale: 1)
  let halfwayTime = CMTimeMake(value: 50, timescale: 1)
  let completedThreshold = CMTimeMake(value: 85, timescale: 1)
  let duration = CMTimeMake(value: 100, timescale: 1)

  internal override func setUp() {
    super.setUp()
    self.vm.outputs.addCompletionObserver.observe(self.addCompletionObserver.observer)
    self.vm.outputs.configurePlayerWithURL.map { $0.absoluteString }
      .observe(self.configurePlayerWithURL.observer)
    self.vm.outputs.incrementVideoCompletion.observe(self.incrementVideoCompletion.observer)
    self.vm.outputs.incrementVideoStart.observe(self.incrementVideoStart.observer)
    self.vm.outputs.pauseVideo.observe(self.pauseVideo.observer)
    self.vm.outputs.playVideo.observe(self.playVideo.observer)
    self.vm.outputs.playButtonHidden.observe(self.playButtonHidden.observer)
    self.vm.outputs.projectImageHidden.observe(self.projectImageHidden.observer)
    self.vm.outputs.projectImageURL.map { $0?.absoluteString }.observe(self.projectImageURL.observer)
    self.vm.outputs.opacityForViews.observe(self.opacityForViews.observer)
    self.vm.outputs.seekToBeginning.observe(self.seekToBeginning.observer)
    self.vm.outputs.videoViewHidden.observe(self.videoViewHidden.observer)
  }

  func testAddCompletionObserver() {
    self.vm.inputs.configureWith(project: Project.template)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.vm.inputs.playButtonTapped()
    self.vm.inputs.durationChanged(toNew: self.duration)

    self.addCompletionObserver.assertValues(
      [self.completedThreshold],
      "Observer added to completion threshold."
    )
  }

  func testConfigureVideoWithURL_setsHighURL_WhenHlsIsNil() {
    let video = .template
      |> Project.Video.lens.hls .~ nil
      |> Project.Video.lens.high .~ "https://sickskatevid.mp4"
    let project = .template |> Project.lens.video .~ video

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()
    self.vm.inputs.playButtonTapped()

    self.configurePlayerWithURL.assertValues([video.high], "Video url emitted.")
  }

  func testConfigureVideoWithURL_setsHlsURL_WhenHlsIsNotNil() {
    let video = .template
      |> Project.Video.lens.hls .~ "https://sickskatevid.m3u8"
      |> Project.Video.lens.high .~ "https://sickskatevid.mp4"
    let project = .template |> Project.lens.video .~ video

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()
    self.vm.inputs.playButtonTapped()

    self.configurePlayerWithURL.assertValues([video.hls!], "Video url emitted.")
  }

  func testIncrementVideoStats() {
    withEnvironment(apiService: MockService()) {
      self.vm.inputs.configureWith(project: Project.template)
      self.vm.inputs.viewDidLoad()
      self.vm.inputs.viewDidAppear()

      self.vm.inputs.playButtonTapped()
      self.vm.inputs.durationChanged(toNew: duration)
      self.vm.inputs.rateChanged(toNew: playRate, atTime: startTime)

      self.incrementVideoStart.assertValueCount(1, "Incremented video start count.")

      self.vm.inputs.rateChanged(toNew: pauseRate, atTime: duration)
      self.incrementVideoCompletion.assertValueCount(1, "Incremented video complete count.")

      self.vm.inputs.rateChanged(toNew: pauseRate, atTime: startTime)
      self.vm.inputs.rateChanged(toNew: playRate, atTime: startTime)
      self.incrementVideoStart.assertValueCount(1, "Video start count not incremented again.")

      self.vm.inputs.rateChanged(toNew: pauseRate, atTime: duration)
      self.incrementVideoCompletion.assertValueCount(1, "Video complete count not incremented again.")
    }
  }

  func testPauseVideoWhenViewDidDisappear() {
    self.vm.inputs.configureWith(project: Project.template)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    // Leave the project magazine without starting video.
    self.vm.inputs.viewWillDisappear()
    self.vm.inputs.viewDidDisappear(animated: true)
    self.pauseVideo.assertDidNotEmitValue("Video not paused by view navigation.")
    XCTAssertEqual([], self.trackingClient.events, "No tracking events occur.")

    // Go back to the project and start playing the video.
    self.vm.inputs.viewDidAppear()
    self.vm.inputs.playButtonTapped()
    self.vm.inputs.durationChanged(toNew: self.duration)
    self.vm.inputs.rateChanged(toNew: self.playRate, atTime: self.startTime)
    self.pauseVideo.assertDidNotEmitValue("Video not paused by view navigation.")

    // Player pauses the video.
    self.vm.inputs.rateChanged(toNew: self.pauseRate, atTime: self.halfwayTime)
    self.pauseVideo.assertDidNotEmitValue("Video not paused by view navigation.")
    XCTAssertEqual([
      "Project Video Start", "Started Project Video", "Project Video Pause",
      "Paused Project Video"
    ], self.trackingClient.events)

    // Leave the project magazine.
    self.vm.inputs.viewWillDisappear()
    self.vm.inputs.viewDidDisappear(animated: true)
    self.pauseVideo.assertValueCount(1, "Video pauses when view disappears.")
    XCTAssertEqual(
      ["Project Video Start", "Started Project Video", "Project Video Pause", "Paused Project Video"],
      self.trackingClient.events, "Pause event not tracked again."
    )
  }

  func testProjectImageAndOverlayVisibility() {
    self.vm.inputs.configureWith(project: Project.template)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.playButtonHidden.assertValues([false])
    self.projectImageHidden.assertValues([false])
    self.videoViewHidden.assertValues([true])

    self.vm.inputs.playButtonTapped()
    self.vm.inputs.durationChanged(toNew: self.duration)
    self.vm.inputs.rateChanged(toNew: self.playRate, atTime: self.startTime)

    self.playVideo.assertValueCount(1)
    self.playButtonHidden.assertValues([false, true])
    self.projectImageHidden.assertValues([false, true], "Overlaid views hidden when video starts.")
    self.videoViewHidden.assertValues([true, false])

    self.vm.inputs.rateChanged(toNew: self.pauseRate, atTime: self.halfwayTime)
    self.playButtonHidden.assertValues([false, true])
    self.projectImageHidden.assertValues([false, true], "Overlaid views still hidden on pause.")

    self.vm.inputs.rateChanged(toNew: self.pauseRate, atTime: self.duration)
    self.playButtonHidden.assertValues([false, true, false])
    self.projectImageHidden.assertValues([false, true, false], "Overlaid views reappear at end.")
    self.videoViewHidden.assertValues([true, false, true])
  }

  func testProjectImageEmits() {
    let project = Project.template

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.projectImageURL.assertValues([project.photo.full])
    self.projectImageHidden.assertValues([false])
    self.videoViewHidden.assertValues([true])
  }

  func testProjectWithNoVideo() {
    let project = .template
      |> Project.lens.video .~ nil

    self.vm.inputs.configureWith(project: project)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.configurePlayerWithURL.assertValueCount(0)
    self.addCompletionObserver.assertValues([])
    self.playButtonHidden.assertValues([true])
    self.projectImageHidden.assertValues([false])
    self.videoViewHidden.assertValues([true])
  }

  func testSeekPlayerToBeginning() {
    self.vm.inputs.configureWith(project: Project.template)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.vm.inputs.playButtonTapped()
    self.vm.inputs.durationChanged(toNew: self.duration)
    self.vm.inputs.rateChanged(toNew: self.playRate, atTime: self.startTime)

    self.vm.inputs.crossedCompletionThreshold()
    self.vm.inputs.rateChanged(toNew: self.pauseRate, atTime: self.duration)

    self.seekToBeginning.assertValueCount(1)
  }

  func testTrackVideoPlayback() {
    self.vm.inputs.configureWith(project: Project.template)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    XCTAssertEqual([], self.trackingClient.events)

    self.vm.inputs.playButtonTapped()
    self.vm.inputs.durationChanged(toNew: self.duration)

    self.vm.inputs.rateChanged(toNew: self.playRate, atTime: self.startTime)
    XCTAssertEqual(["Project Video Start", "Started Project Video"], self.trackingClient.events)

    self.vm.inputs.rateChanged(toNew: self.pauseRate, atTime: self.halfwayTime)
    XCTAssertEqual([
      "Project Video Start", "Started Project Video",
      "Project Video Pause", "Paused Project Video"
    ], self.trackingClient.events)

    self.vm.inputs.rateChanged(toNew: self.playRate, atTime: self.halfwayTime)
    XCTAssertEqual([
      "Project Video Start", "Started Project Video",
      "Project Video Pause", "Paused Project Video",
      "Project Video Resume", "Resumed Project Video"
    ], self.trackingClient.events)

    self.vm.inputs.crossedCompletionThreshold()
    XCTAssertEqual([
      "Project Video Start", "Started Project Video",
      "Project Video Pause", "Paused Project Video",
      "Project Video Resume", "Resumed Project Video",
      "Project Video Complete", "Completed Project Video"
    ], self.trackingClient.events)

    self.vm.inputs.crossedCompletionThreshold()
    XCTAssertEqual(
      [
        "Project Video Start", "Started Project Video", "Project Video Pause", "Paused Project Video",
        "Project Video Resume", "Resumed Project Video", "Project Video Complete", "Completed Project Video"
      ],
      self.trackingClient.events, "Video completion not tracked again."
    )

    self.vm.inputs.rateChanged(toNew: self.pauseRate, atTime: self.duration)
    self.seekToBeginning.assertValueCount(1)

    // Play video again.
    self.vm.inputs.playButtonTapped()
    self.vm.inputs.rateChanged(toNew: self.playRate, atTime: self.startTime)

    self.pauseVideo.assertDidNotEmitValue("Video not paused by view navigation.")

    XCTAssertEqual(
      [
        "Project Video Start", "Started Project Video", "Project Video Pause", "Paused Project Video",
        "Project Video Resume", "Resumed Project Video", "Project Video Complete", "Completed Project Video"
      ],
      self.trackingClient.events, "Video start not tracked again."
    )
  }

  func testTrackVideoCompletionViaScrubbing() {
    self.vm.inputs.configureWith(project: Project.template)
    self.vm.inputs.viewDidLoad()
    self.vm.inputs.viewDidAppear()

    self.vm.inputs.playButtonTapped()
    self.vm.inputs.durationChanged(toNew: self.duration)

    self.vm.inputs.rateChanged(toNew: self.playRate, atTime: self.startTime)
    XCTAssertEqual(["Project Video Start", "Started Project Video"], self.trackingClient.events)

    // Scrub video through to completion.
    self.vm.inputs.rateChanged(toNew: self.pauseRate, atTime: self.halfwayTime)
    self.vm.inputs.rateChanged(toNew: self.playRate, atTime: self.completedThreshold)
    XCTAssertEqual([
      "Project Video Start", "Started Project Video",
      "Project Video Pause", "Paused Project Video",
      "Project Video Complete", "Completed Project Video",
      "Project Video Resume", "Resumed Project Video"
    ], self.trackingClient.events)
  }

  func testViewTransition() {
    self.vm.inputs.configureWith(project: Project.template)

    self.opacityForViews.assertValueCount(0)

    self.vm.inputs.viewDidLoad()

    self.opacityForViews.assertValues([0.0])

    self.vm.inputs.viewDidAppear()

    self.opacityForViews.assertValues([0.0, 1.0], "Fade in controls after view appears.")
  }
}
