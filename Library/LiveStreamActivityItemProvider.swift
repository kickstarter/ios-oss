#if os(iOS)
  import KsApi
  import UIKit
  import KsLive

  public final class LiveStreamActivityItemProvider: UIActivityItemProvider {

    private var liveStreamEvent: LiveStreamEvent?

    public convenience init(liveStreamEvent: LiveStreamEvent) {
      self.init(placeholderItem: liveStreamEvent.stream.name)

      self.liveStreamEvent = liveStreamEvent
    }

    public override func activityViewController(activityViewController: UIActivityViewController,
                                                itemForActivityType activityType: String) -> AnyObject? {
      if let liveStreamEvent = self.liveStreamEvent {
        if activityType == UIActivityTypeMail || activityType == UIActivityTypeMessage {
          return liveStreamEvent.stream.projectName
        } else if activityType == UIActivityTypePostToTwitter {
          return localizedString(
            key: "Creator_name_is_streaming_live_on_Kickstarter",
            defaultValue: "%{creator_name} is streaming live on Kickstarter",
            substitutions: ["creator_name" : liveStreamEvent.creator.name]
          )
        } else if activityType == UIActivityTypeCopyToPasteboard ||
          activityType == UIActivityTypePostToFacebook {
          return liveStreamEvent.stream.webUrl
        }
      }
      return self.activityViewControllerPlaceholderItem(activityViewController)
    }
  }
#endif
