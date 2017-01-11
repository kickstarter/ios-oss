#if os(iOS)
import KsApi
import LiveStream
import Prelude
import ReactiveSwift
import Result
import Social

public struct ShareActivityCompletionData {
  internal let activityType: UIActivityType?
  internal let completed: Bool
  internal let returnedItems: [Any]?
  internal let activityError: Error?

  public init(activityType: UIActivityType?,
              completed: Bool,
              returnedItems: [Any]?,
              activityError: Error?) {
    self.activityType = activityType
    self.completed = completed
    self.returnedItems = returnedItems
    self.activityError = activityError
  }
}

/// These share types provide us access to knowing when the user successfully shares through that method,
/// or when the user cancels.
private let firstPartyShareTypes: [UIActivityType] = [.postToFacebook, .postToTwitter, .postToWeibo,
                                                      .message, .mail, .copyToPasteboard, .addToReadingList,
                                                      .postToTencentWeibo, .airDrop, SafariActivityType]

public protocol ShareViewModelInputs {
  /// Call with the context that this sharing is taking place in.
  func configureWith(shareContext: ShareContext)

  /// Call when the direct-share facebook button is pressed.
  func facebookButtonTapped()

  /// Call when the general share button is pressed.
  func shareButtonTapped()

  /// Call from the UIActivityViewController's completion handler.
  func shareActivityCompletion(with data: ShareActivityCompletionData)

  /// Call from the SLComposeViewController's completion handler
  func shareComposeCompletion(result: SLComposeViewControllerResult)

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
    let shareContext = self.shareContextProperty.signal.skipNil()

    self.showShareSheet = shareContext
      .takeWhen(self.shareButtonTappedProperty.signal)
      .map(activityController(forShareContext:))
      .skipNil()

    let directShareService = Signal.merge(
      self.facebookButtonTappedProperty.signal.mapConst(SLServiceTypeFacebook),
      self.twitterButtonTappedProperty.signal.mapConst(SLServiceTypeTwitter)
      )

    self.showShareCompose = Signal.combineLatest(shareContext, directShareService)
      .map(shareComposeController(forShareContext:serviceType:))
      .skipNil()

    let directShareCompletion = Signal.merge(
      self.facebookButtonTappedProperty.signal.mapConst(UIActivityType.postToFacebook),
      self.twitterButtonTappedProperty.signal.mapConst(UIActivityType.postToTwitter)
      )
      .takePairWhen(self.shareComposeCompletionProperty.signal.skipNil())
      .map { service, result in
        ShareActivityCompletionData(
          activityType: service,
          completed: result == .done,
          returnedItems: nil,
          activityError: nil
        )
    }

    let shareCompletion = Signal.merge(
      directShareCompletion,
      self.shareActivityCompletionProperty.signal.skipNil()
      )

    let shareActivityCompletion = shareContext
      .takePairWhen(shareCompletion)

    let canceledShare = shareActivityCompletion
      .filter { _, completion in !completion.completed }

    shareContext
      .takeWhen(self.shareButtonTappedProperty.signal)
      .observeValues { AppEnvironment.current.koala.trackShowedShareSheet(shareContext: $0) }

    canceledShare
      .filter { _, completion in completion.activityType == nil }
      .map(first)
      .observeValues { AppEnvironment.current.koala.trackCanceledShareSheet(shareContext: $0) }

    shareActivityCompletion
      .filter { _, completion in completion.activityType != nil }
      .observeValues { shareContext, completion in
        AppEnvironment.current.koala.trackShowedShare(
          shareContext: shareContext, shareActivityType: completion.activityType
        )
    }

    shareActivityCompletion
      .filter { _, completion in
        completion.completed && completion.activityType.map(firstPartyShareTypes.contains) == .some(true)
      }
      .flatMap {
        SignalProducer(value: $0)
          .ksr_delay(.seconds(1), on: AppEnvironment.current.scheduler)
      }
      .observeValues { shareContext, completion in
        AppEnvironment.current.koala.trackShared(
          shareContext: shareContext, shareActivityType: completion.activityType
        )
    }

    canceledShare
      .filter { _, completion in completion.activityType.map(firstPartyShareTypes.contains) == .some(true) }
      .flatMap {
        SignalProducer(value: $0)
          .ksr_delay(.seconds(1), on: AppEnvironment.current.scheduler)
      }
      .observeValues { shareContext, completion in
        AppEnvironment.current.koala.trackCanceledShare(
          shareContext: shareContext, shareActivityType: completion.activityType
        )
    }
  }
  // swiftlint:enable function_body_length

  fileprivate let shareContextProperty = MutableProperty<ShareContext?>(nil)
  public func configureWith(shareContext: ShareContext) {
    self.shareContextProperty.value = shareContext
  }
  fileprivate let facebookButtonTappedProperty = MutableProperty()
  public func facebookButtonTapped() {
    self.facebookButtonTappedProperty.value = ()
  }
  fileprivate let shareButtonTappedProperty = MutableProperty()
  public func shareButtonTapped() {
    self.shareButtonTappedProperty.value = ()
  }
  fileprivate let shareActivityCompletionProperty = MutableProperty<ShareActivityCompletionData?>(nil)
  public func shareActivityCompletion(with data: ShareActivityCompletionData) {
    self.shareActivityCompletionProperty.value = data
  }
  fileprivate let shareComposeCompletionProperty = MutableProperty<SLComposeViewControllerResult?>(nil)
  public func shareComposeCompletion(result: SLComposeViewControllerResult) {
    self.shareComposeCompletionProperty.value = result
  }
  fileprivate let twitterButtonTappedProperty = MutableProperty()
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

private func shareUrl(forShareContext shareContext: ShareContext) -> URL? {

  switch shareContext {
  case let .creatorDashboard(project):
    return URL(string: project.urls.web.project)
  case let .project(project):
    return URL(string: project.urls.web.project)
  case let .thanks(project):
    return URL(string: project.urls.web.project)
  case let .update(_, update):
    return URL(string: update.urls.web.update)
  case let .liveStream(_, liveStreamEvent):
    return URL(string: liveStreamEvent.stream.webUrl)
  }
}

private func excludedActivityTypes(forShareContext shareContext: ShareContext) -> [UIActivityType] {

  switch shareContext {
  case let .update(_, update) where !update.isPublic:
    return [.mail, .message, .postToFacebook, .postToTwitter, .postToWeibo]
  default:
    return []
  }
}

private func activityController(forShareContext shareContext: ShareContext) -> UIActivityViewController? {
  guard let url = shareUrl(forShareContext: shareContext) else { return nil }

  let provider = activityItemProvider(forShareContext: shareContext)

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
    return twitterInitialText(forLiveStreamEvent: liveStreamEvent)
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
  -> SLComposeViewController? {

    let controller = SLComposeViewController(forServiceType: serviceType)

    shareUrl(forShareContext: shareContext).doIfSome { controller?.add($0) }

    if serviceType == SLServiceTypeTwitter {
      controller?.setInitialText(twitterInitialText(forShareContext: shareContext))
    }

    return controller
}

private func twitterInitialText(forLiveStreamEvent liveStreamEvent: LiveStreamEvent) -> String {
  if liveStreamEvent.stream.liveNow {
    return Strings.Creator_name_is_streaming_live_on_Kickstarter(creator_name: liveStreamEvent.creator.name)
  }

  if liveStreamEvent.stream.startDate < Date() {
    return Strings.Creator_name_was_streaming_live_on_Kickstarter(creator_name: liveStreamEvent.creator.name)
  }

  return Strings.Creator_name_will_be_streaming_live_on_Kickstarter_in_duration(
    creator_name: liveStreamEvent.creator.name,
    in_duration: Format.relative(secondsInUTC: liveStreamEvent.stream.startDate.timeIntervalSince1970))
}
#endif
