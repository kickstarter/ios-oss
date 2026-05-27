@testable import Kickstarter_Framework
@testable import Library
@testable import LibraryTestHelpers
import SnapshotTesting
import SwiftUI
import UIKit

final class VideoFeedViewControllerTests: TestCase {
  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
  }

  override func tearDown() {
    UIView.setAnimationsEnabled(true)
    super.tearDown()
  }

  func testView_VideoFeedCell() {
    orthogonalCombos(
      Language.allLanguages,
      Device.allCases
    ).forEach {
      language, device in

      let appBundle = Bundle(identifier: KickstarterBundleIdentifier.debug.rawValue) ?? Bundle.main

      withEnvironment(
        language: language,
        mainBundle: MockBundle(bundleIdentifier: appBundle.bundleIdentifier)
      ) {
        let cell = VideoFeedCell(
          frame: CGRect(
            x: 0,
            y: 0,
            width: device.deviceSize.width,
            height: device.deviceSize.height
          ),
          videoPlayer: MockVideoFeedVideoPlayer()
        )

        cell.configureWith(
          value: VideoFeedItem(
            id: "0",
            pid: 3,
            slug: "video_feed",
            projectURL: "https://test.com",
            title: "Ringo Move - The Ultimate Workout Bottle",
            creator: "Creator Name",
            creatorImageURL: nil,
            statsText: VideoFeedItem.statsText(pledgedAmount: 50_134, backersCount: 431),
            categoryPillText: "Project We Love",
            secondaryPillText: "3 days left",
            videoURL: nil,
            videoPreviewImageURL: nil,
            projectId: "1",
            isSaved: false,
            sharesCount: 2_000,
            watchesCount: 50
          ),
          isSaved: .constant(false)
        )

        assertSnapshot(
          of: cell,
          as: .image(perceptualPrecision: 0.99)
        )
      }
    }
  }

  func testView_VideoFeedCell_LongTitle() {
    orthogonalCombos(
      Language.allLanguages,
      Device.allCases
    ).forEach {
      language, device in

      let appBundle = Bundle(identifier: KickstarterBundleIdentifier.debug.rawValue) ?? Bundle.main

      withEnvironment(
        language: language,
        mainBundle: MockBundle(bundleIdentifier: appBundle.bundleIdentifier)
      ) {
        let cell = VideoFeedCell(
          frame: CGRect(
            x: 0,
            y: 0,
            width: device.deviceSize.width,
            height: device.deviceSize.height
          ),
          videoPlayer: MockVideoFeedVideoPlayer()
        )

        cell.configureWith(
          value: VideoFeedItem(
            id: "0",
            pid: 3,
            slug: "video_feed",
            projectURL: "https://test.com",
            title: "Ringo Move - The Ultimate Workout Bottle for People Who Like Long Product Names That Wrap Across Several Lines For People Who Like Long Product Names That Wrap Across Several Lines",
            creator: "Creator Name",
            creatorImageURL: nil,
            statsText: VideoFeedItem.statsText(pledgedAmount: 50_134, backersCount: 431),
            categoryPillText: "Project We Love",
            secondaryPillText: "3 days left",
            videoURL: nil,
            videoPreviewImageURL: nil,
            projectId: "1",
            isSaved: true,
            sharesCount: 2_000,
            watchesCount: 5_000
          ),
          isSaved: .constant(true)
        )

        assertSnapshot(
          of: cell,
          as: .image(perceptualPrecision: 0.99)
        )
      }
    }
  }

  func testView_VideoFeedCell_VideoFailed() {
    orthogonalCombos(
      Language.allLanguages,
      Device.allCases
    ).forEach {
      language, device in

      let appBundle = Bundle(identifier: KickstarterBundleIdentifier.debug.rawValue) ?? Bundle.main

      withEnvironment(
        language: language,
        mainBundle: MockBundle(bundleIdentifier: appBundle.bundleIdentifier)
      ) {
        let player = MockVideoFeedVideoPlayer()

        let cell = VideoFeedCell(
          frame: CGRect(
            x: 0,
            y: 0,
            width: device.deviceSize.width,
            height: device.deviceSize.height
          ),
          videoPlayer: player
        )

        cell.configureWith(
          value: VideoFeedItem(
            id: "0",
            pid: 3,
            slug: "video_feed",
            projectURL: "https://test.com",
            title: "Ringo Move - The Ultimate Workout Bottle",
            creator: "Creator Name",
            creatorImageURL: nil,
            statsText: VideoFeedItem.statsText(pledgedAmount: 50_134, backersCount: 431),
            categoryPillText: "Project We Love",
            secondaryPillText: "",
            videoURL: nil,
            videoPreviewImageURL: nil,
            projectId: "1",
            isSaved: false,
            sharesCount: 2_000,
            watchesCount: 50
          ),
          isSaved: .constant(false)
        )

        player.simulateFailure()

        assertSnapshot(
          of: cell,
          as: .image(perceptualPrecision: 0.99)
        )
      }
    }
  }
}

final class MockVideoFeedVideoPlayer: VideoFeedVideoPlayer {
  override var progress: Double { 0.4 }
  override var isPlaying: Bool { false }
  override func load(url _: URL) {}
  override func play() {}
  override func pause() {}
  override func stop() {}

  func simulateFailure() {
    self.onVideoFailed?()
  }
}
