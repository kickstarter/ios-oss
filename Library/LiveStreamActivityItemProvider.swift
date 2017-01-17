#if os(iOS)
  import KsApi
  import UIKit
  import LiveStream

  public final class LiveStreamActivityItemProvider: UIActivityItemProvider {

    private var liveStreamEvent: LiveStreamEvent?

    public convenience init(liveStreamEvent: LiveStreamEvent) {
      self.init(placeholderItem: liveStreamEvent.stream.name)

      self.liveStreamEvent = liveStreamEvent
    }

    public override func activityViewController(_ activityViewController: UIActivityViewController,
                                                itemForActivityType activityType: UIActivityType) -> Any? {

      if let liveStreamEvent = self.liveStreamEvent {
        if activityType == .mail || activityType == .message {
          return liveStreamEvent.stream.projectName
        } else if activityType == .postToTwitter {
          return twitterInitialText(forLiveStreamEvent: liveStreamEvent)
        } else if activityType == .copyToPasteboard || activityType == .postToFacebook {
          return liveStreamEvent.stream.webUrl
        }
      }

      return self.activityViewControllerPlaceholderItem(activityViewController)
    }
  }

  private func twitterInitialText(forLiveStreamEvent liveStreamEvent: LiveStreamEvent) -> String {
    if liveStreamEvent.stream.liveNow {
      return Strings.Creator_name_is_streaming_live_on_Kickstarter(creator_name: liveStreamEvent.creator.name)
    }

    if liveStreamEvent.stream.startDate < AppEnvironment.current.dateType.init().date {
      return Strings.Creator_name_was_streaming_live_on_Kickstarter(
        creator_name: liveStreamEvent.creator.name
      )
    }

    return Strings.Creator_name_will_be_streaming_live_on_Kickstarter_in_duration(
      creator_name: liveStreamEvent.creator.name,
      in_duration: Format.relative(secondsInUTC: liveStreamEvent.stream.startDate.timeIntervalSince1970)
    )
  }
#endif
