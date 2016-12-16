#if os(iOS)
import KsApi
import Prelude
import ReactiveCocoa
import Result
import Social

/// These share types provide us access to knowing when the user successfully shares through that method,
/// or when the user cancels.
private let firstPartyShareTypes = [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter,
                                    UIActivityTypePostToWeibo, UIActivityTypeMessage, UIActivityTypeMail,
                                    UIActivityTypeCopyToPasteboard, UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToTencentWeibo, UIActivityTypeAirDrop,
                                    SafariActivityType]

public protocol ShareViewModelInputs {
  /// Call with the context that this sharing is taking place in.
  func configureWith(shareContext shareContext: ShareContext)

  /// Call when the direct-share facebook button is pressed.
  func facebookButtonTapped()

  /// Call when the general share button is pressed.
  func shareButtonTapped()

  /// Call from the UIActivityViewController's completion handler.
  func shareActivityCompletion(activityType activityType: String?,
                                            completed: Bool,
                                            returnedItems: [AnyObject]?,
                                            activityError: NSError?)

  /// Call from the SLComposeViewController's completion handler
  func shareComposeCompletion(result result: SLComposeViewControllerResult)

  /// Call when the direct-share twitter button is pressed.
  func twitterButtonTapped()
}

public protocol ShareViewModelOutputs {
  /// Emits when the share compose controller show be presented.
  var showShareCompose: Signal<SLComposeViewController, NoError> { get }

  /// Emits when the share sheet should be presented.
  var showShareSheet: Signal<UIActivityViewController, NoError> { get }
}

public protocol ShareViewModelType {
  var inputs: ShareViewModelInputs { get }
  var outputs: ShareViewModelOutputs { get }
}

public final class ShareViewModel: ShareViewModelType, ShareViewModelInputs, ShareViewModelOutputs {

  // swiftlint:disable function_body_length
  public init() {
    let shareContext = self.shareContextProperty.signal.ignoreNil()

    self.showShareSheet = shareContext
      .takeWhen(self.shareButtonTappedProperty.signal)
      .map(activityController(forShareContext:))

    let directShareService = Signal.merge(
      self.facebookButtonTappedProperty.signal.mapConst(SLServiceTypeFacebook),
      self.twitterButtonTappedProperty.signal.mapConst(SLServiceTypeTwitter)
      )

    self.showShareCompose = combineLatest(shareContext, directShareService)
      .map(shareComposeController(forShareContext:serviceType:))

    let directShareCompletion = Signal.merge(
      self.facebookButtonTappedProperty.signal.mapConst(UIActivityTypePostToFacebook),
      self.twitterButtonTappedProperty.signal.mapConst(UIActivityTypePostToTwitter)
      )
      .takePairWhen(self.shareComposeCompletionProperty.signal.ignoreNil())
      .map { service, result in
        (
          activityType: String?(service),
          completed: result == .Done,
          returnedItems: [AnyObject]?.None,
          activityError: NSError?.None
        )
    }

    let shareCompletion = Signal.merge(
      directShareCompletion,
      self.shareActivityCompletionProperty.signal.ignoreNil()
      )

    let shareActivityCompletion = shareContext
      .takePairWhen(shareCompletion)

    let canceledShare = shareActivityCompletion
      .filter { _, completion in !completion.completed }

    shareContext
      .takeWhen(self.shareButtonTappedProperty.signal)
      .observeNext { AppEnvironment.current.koala.trackShowedShareSheet(shareContext: $0) }

    canceledShare
      .filter { _, completion in completion.activityType == nil }
      .map(first)
      .observeNext { AppEnvironment.current.koala.trackCanceledShareSheet(shareContext: $0) }

    shareActivityCompletion
      .filter { _, completion in completion.activityType != nil }
      .observeNext { shareContext, completion in
        AppEnvironment.current.koala.trackShowedShare(
          shareContext: shareContext, shareActivityType: completion.activityType
        )
    }

    shareActivityCompletion
      .filter { _, completion in
        completion.completed && firstPartyShareTypes.contains(completion.activityType ?? "")
      }
      .flatMap {
        SignalProducer(value: $0)
          .delay(1.0, onScheduler: AppEnvironment.current.scheduler)
      }
      .observeNext { shareContext, completion in
        AppEnvironment.current.koala.trackShared(
          shareContext: shareContext, shareActivityType: completion.activityType
        )
    }

    canceledShare
      .filter { _, completion in firstPartyShareTypes.contains(completion.activityType ?? "") }
      .flatMap {
        SignalProducer(value: $0)
          .delay(1.0, onScheduler: AppEnvironment.current.scheduler)
      }
      .observeNext { shareContext, completion in
        AppEnvironment.current.koala.trackCanceledShare(
          shareContext: shareContext, shareActivityType: completion.activityType
        )
    }
  }
  // swiftlint:enable function_body_length

  private let shareContextProperty = MutableProperty<ShareContext?>(nil)
  public func configureWith(shareContext shareContext: ShareContext) {
    self.shareContextProperty.value = shareContext
  }
  private let facebookButtonTappedProperty = MutableProperty()
  public func facebookButtonTapped() {
    self.facebookButtonTappedProperty.value = ()
  }
  private let shareButtonTappedProperty = MutableProperty()
  public func shareButtonTapped() {
    self.shareButtonTappedProperty.value = ()
  }
  private let shareActivityCompletionProperty = MutableProperty
    <(activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?)?>(nil)
  public func shareActivityCompletion(activityType activityType: String?,
                                                   completed: Bool,
                                                   returnedItems: [AnyObject]?,
                                                   activityError: NSError?) {
    self.shareActivityCompletionProperty.value = (activityType, completed, returnedItems, activityError)
  }
  private let shareComposeCompletionProperty = MutableProperty<SLComposeViewControllerResult?>(nil)
  public func shareComposeCompletion(result result: SLComposeViewControllerResult) {
    self.shareComposeCompletionProperty.value = result
  }
  private let twitterButtonTappedProperty = MutableProperty()
  public func twitterButtonTapped() {
    self.twitterButtonTappedProperty.value = ()
  }

  public let showShareCompose: Signal<SLComposeViewController, NoError>
  public let showShareSheet: Signal<UIActivityViewController, NoError>

  public var inputs: ShareViewModelInputs { return self }
  public var outputs: ShareViewModelOutputs { return self }
}

private func activityItemProvider(forShareContext shareContext: ShareContext) -> UIActivityItemProvider {

  switch shareContext {
  case let .creatorDashboard(project):
    return ProjectActivityItemProvider(project: project)
  case let .liveStream(_, liveStreamEvent):
    return LiveStreamActivityItemProvider(liveStreamEvent: liveStreamEvent)
  case let .project(project):
    return ProjectActivityItemProvider(project: project)
  case let .thanks(project):
    return ProjectActivityItemProvider(project: project)
  case let .update(_, update):
    return UpdateActivityItemProvider(update: update)
  }
}

private func shareUrl(forShareContext shareContext: ShareContext) -> NSURL {

  switch shareContext {
  case let .creatorDashboard(project):
    return NSURL(string: project.urls.web.project) ?? NSURL()
  case let .project(project):
    return NSURL(string: project.urls.web.project) ?? NSURL()
  case let .thanks(project):
    return NSURL(string: project.urls.web.project) ?? NSURL()
  case let .update(_, update):
    return NSURL(string: update.urls.web.update) ?? NSURL()
  case let .liveStream(_, liveStreamEvent):
    return NSURL(string: liveStreamEvent.stream.webUrl) ?? NSURL()
  }
}

private func excludedActivityTypes(forShareContext shareContext: ShareContext) -> [String] {

  switch shareContext {
  case let .update(_, update) where !update.isPublic:
    return [
      UIActivityTypeMail,
      UIActivityTypeMessage,
      UIActivityTypePostToFacebook,
      UIActivityTypePostToTwitter,
      UIActivityTypePostToWeibo
    ]
  default:
    return []
  }
}

private func activityController(forShareContext shareContext: ShareContext) -> UIActivityViewController {
  let provider = activityItemProvider(forShareContext: shareContext)
  let url = shareUrl(forShareContext: shareContext)

  let controller = UIActivityViewController(activityItems: [provider, url],
                                            applicationActivities: [SafariActivity(url: url)])

  controller.excludedActivityTypes = excludedActivityTypes(forShareContext: shareContext)

  return controller
}

private func twitterInitialText(forShareContext shareContext: ShareContext) -> String {

  switch shareContext {
  case let .creatorDashboard(project):
    return Strings.project_checkout_share_twitter_via_kickstarter(project_or_update_title: project.name)
  case let .liveStream(_, liveStreamEvent):
    return localizedString(
      key: "Creator_name_is_streaming_live_on_Kickstarter",
      defaultValue: "%{creator_name} is streaming live on Kickstarter",
      substitutions: ["creator_name" : liveStreamEvent.creator.name]
    )
  case let .project(project):
    return Strings.project_checkout_share_twitter_via_kickstarter(project_or_update_title: project.name)
  case let .thanks(project):
    return Strings.project_checkout_share_twitter_I_just_backed_project_on_kickstarter(
      project_name: project.name
    )
  case let .update(_, update):
    return Strings.social_update_number(update_number: String(update.sequence)) + ": " + update.title
  }
}

private func shareComposeController(forShareContext shareContext: ShareContext, serviceType: String)
  -> SLComposeViewController {

    let controller = SLComposeViewController(forServiceType: serviceType)

    controller.addURL(shareUrl(forShareContext: shareContext))

    if serviceType == SLServiceTypeTwitter {
      controller.setInitialText(twitterInitialText(forShareContext: shareContext))
    }

    return controller
}
#endif
