import AVKit
@testable import kickstartertv
import ReactiveCocoa

internal struct MockSuccessAssetImageGenerator : AssetImageGeneratorType {
  init(asset: AVAsset) {
  }

  func generateCGImagesAsynchronouslyForTimes(requestedTimes: [NSValue], completionHandler handler: AVAssetImageGeneratorCompletionHandler) {

    UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
    let image = UIGraphicsGetImageFromCurrentImageContext().CGImage
    UIGraphicsEndImageContext()

    handler(CMTimeMakeWithSeconds(0.0, 1), image, CMTimeMakeWithSeconds(0.0, 1), .Succeeded, nil)
  }
}

internal struct MockFailureAssetImageGenerator : AssetImageGeneratorType {
  init(asset: AVAsset) {
  }

  func generateCGImagesAsynchronouslyForTimes(requestedTimes: [NSValue], completionHandler handler: AVAssetImageGeneratorCompletionHandler) {
    handler(CMTimeMakeWithSeconds(0.0, 1), nil, CMTimeMakeWithSeconds(0.0, 1), .Failed, NSError(domain: "", code: 1, userInfo: nil))
  }
}

internal struct MockNeverFinishingAssetImageGenerator : AssetImageGeneratorType {
  init(asset: AVAsset) {
  }

  func generateCGImagesAsynchronouslyForTimes(requestedTimes: [NSValue], completionHandler handler: AVAssetImageGeneratorCompletionHandler) {
  }
}

internal struct MockLongRunningAssetImageGenerator : AssetImageGeneratorType {
  init(asset: AVAsset) {
  }

  func generateCGImagesAsynchronouslyForTimes(requestedTimes: [NSValue], completionHandler handler: AVAssetImageGeneratorCompletionHandler) {

    let scheduler = AppEnvironment.current.debounceScheduler

    scheduler.scheduleAfter(NSDate().dateByAddingTimeInterval(10.0)) {
      UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
      let image = UIGraphicsGetImageFromCurrentImageContext().CGImage
      UIGraphicsEndImageContext()

      handler(CMTimeMakeWithSeconds(0.0, 1), image, CMTimeMakeWithSeconds(0.0, 1), .Succeeded, nil)
    }
  }
}
