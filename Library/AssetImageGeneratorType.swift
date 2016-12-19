import class Foundation.NSValue
import AVFoundation

public protocol AssetImageGeneratorType {

  init(asset: AVAsset)

  func generateCGImagesAsynchronouslyForTimes(
    _ requestedTimes: [NSValue],
    completionHandler handler: AVAssetImageGeneratorCompletionHandler)
}

extension AVAssetImageGenerator: AssetImageGeneratorType {
}
