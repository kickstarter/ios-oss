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
    // TODO: Update to all languages once translations are in [mbl-3158](https://kickstarter.atlassian.net/browse/MBL-3158)
    orthogonalCombos(
      [Language.en],
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
            slug: "video_feed",
            title: "Ringo Move - The Ultimate Workout Bottle",
            creator: "Creator Name",
            creatorImageURL: nil,
            statsText: "$50,134 pledged · Join 431 backers",
            categoryPillText: "Project We Love",
            secondaryPillText: "3 days left",
            videoURL: nil,
            videoPreviewImageURL: nil,
            projectId: "1",
            isSaved: false
          ),
          isSaved: .constant(false),
          onSaveTapped: {}
        )

        assertSnapshot(
          of: cell,
          as: .image(perceptualPrecision: 0.99)
        )
      }
    }
  }

  func testView_VideoFeedCell_LongTitle() {
    // TODO: Update to all languages once translations are in [mbl-3158](https://kickstarter.atlassian.net/browse/MBL-3158)
    orthogonalCombos(
      [Language.en],
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
            slug: "video_feed",
            title: "Ringo Move - The Ultimate Workout Bottle for People Who Like Long Product Names That Wrap Across Several Lines For People Who Like Long Product Names That Wrap Across Several Lines",
            creator: "Creator Name",
            creatorImageURL: nil,
            statsText: "$50,134 pledged · Join 431 backers",
            categoryPillText: "Project We Love",
            secondaryPillText: "3 days left",
            videoURL: nil,
            videoPreviewImageURL: nil,
            projectId: "1",
            isSaved: true
          ),
          isSaved: .constant(true),
          onSaveTapped: {}
        )

        assertSnapshot(
          of: cell,
          as: .image(perceptualPrecision: 0.99)
        )
      }
    }
  }

  func testView_VideoFeedCell_VideoFailed() {
    // TODO: Update to all languages once translations are in [mbl-3158](https://kickstarter.atlassian.net/browse/MBL-3158)
    orthogonalCombos(
      [Language.en],
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
            slug: "video_feed",
            title: "Ringo Move - The Ultimate Workout Bottle",
            creator: "Creator Name",
            creatorImageURL: nil,
            statsText: "$50,134 pledged · Join 431 backers",
            categoryPillText: "Project We Love",
            secondaryPillText: "3 days left",
            videoURL: nil,
            videoPreviewImageURL: nil,
            projectId: "1",
            isSaved: false
          ),
          isSaved: .constant(false),
          onSaveTapped: {}
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

  /// Fires `onVideoFailed` directly, exercising the same code path as the real player.
  func simulateFailure() {
    self.onVideoFailed?()
  }
}
