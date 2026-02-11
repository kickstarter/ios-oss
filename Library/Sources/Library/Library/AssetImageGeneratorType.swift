import AVFoundation
import class Foundation.NSValue

public protocol AssetImageGeneratorType {
  init(asset: AVAsset)

  func generateCGImagesAsynchronously(
    forTimes requestedTimes: [NSValue],
    completionHandler handler: @escaping AVFoundation.AVAssetImageGeneratorCompletionHandler
  )
}

extension AVAssetImageGenerator: AssetImageGeneratorType {}
