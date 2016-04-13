import AVFoundation
@testable import Kickstarter_tvOS
import ReactiveCocoa
import protocol Library.AssetImageGeneratorType
import struct Library.AppEnvironment

/**
 *  An asset generator that immediately completes successfully with a blank image.
 */
internal struct MockSuccessAssetImageGenerator: AssetImageGeneratorType {
  init(asset: AVAsset) {
  }

  func generateCGImagesAsynchronouslyForTimes(
    requestedTimes: [NSValue],
    completionHandler handler: AVAssetImageGeneratorCompletionHandler) {

    UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
    let image = UIGraphicsGetImageFromCurrentImageContext().CGImage
    UIGraphicsEndImageContext()

    handler(
      CMTime(seconds: 0.0, preferredTimescale: 1),
      image,
      CMTime(seconds: 0.0, preferredTimescale: 1),
      .Succeeded,
      nil
    )
  }
}

/**
 *  An asset generator that immediately fails.
 */
internal struct MockFailureAssetImageGenerator: AssetImageGeneratorType {
  init(asset: AVAsset) {
  }

  func generateCGImagesAsynchronouslyForTimes(
    requestedTimes: [NSValue],
    completionHandler handler: AVAssetImageGeneratorCompletionHandler) {

    handler(
      CMTime(seconds: 0.0, preferredTimescale: 1),
      nil,
      CMTime(seconds: 0.0, preferredTimescale: 1),
      .Failed,
      NSError(domain: "", code: 1, userInfo: nil)
    )
  }
}

/**
 *  An asset generator that never completes.
 */
internal struct MockNeverFinishingAssetImageGenerator: AssetImageGeneratorType {
  init(asset: AVAsset) {
  }

  func generateCGImagesAsynchronouslyForTimes(
    requestedTimes: [NSValue],
    completionHandler handler: AVAssetImageGeneratorCompletionHandler) {
  }
}

/**
 *  An asset generate that comlpetes successfully after 10 seconds.
 */
internal struct MockLongRunningAssetImageGenerator: AssetImageGeneratorType {
  init(asset: AVAsset) {
  }

  func generateCGImagesAsynchronouslyForTimes(
    requestedTimes: [NSValue],
    completionHandler handler: AVAssetImageGeneratorCompletionHandler) {

    let scheduler = AppEnvironment.current.scheduler

    scheduler.scheduleAfter(NSDate().dateByAddingTimeInterval(10.0)) {
      UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
      let image = UIGraphicsGetImageFromCurrentImageContext().CGImage
      UIGraphicsEndImageContext()

      handler(CMTimeMakeWithSeconds(0.0, 1), image, CMTimeMakeWithSeconds(0.0, 1), .Succeeded, nil)
    }
  }
}
