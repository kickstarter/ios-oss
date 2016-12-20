#if os(iOS)
import KsApi
import Prelude
import ReactiveSwift
import Result
import Social

/// These share types provide us access to knowing when the user successfully shares through that method,
/// or when the user cancels.
private let firstPartyShareTypes = [UIActivityType.postToFacebook, UIActivityType.postToTwitter,
                                    UIActivityType.postToWeibo, UIActivityType.message, UIActivityType.mail,
                                    UIActivityType.copyToPasteboard, UIActivityType.addToReadingList,
                                    UIActivityType.postToTencentWeibo, UIActivityType.airDrop,
                                    SafariActivityType] as [Any]

public protocol ShareViewModelInputs {
  /// Call with the context that this sharing is taking place in.
  func configureWith(shareContext: ShareContext)

  /// Call when the direct-share facebook button is pressed.
  func facebookButtonTapped()

  /// Call when the general share button is pressed.
  func shareButtonTapped()

  /// Call from the UIActivityViewController's completion handler.
  func shareActivityCompletion(activityType: String?,
                                            completed: Bool,
                                            returnedItems: [AnyObject]?,
                                            activityError: NSError?)

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

    let directShareService = Signal.merge(
      self.facebookButtonTappedProperty.signal.mapConst(SLServiceTypeFacebook),
      self.twitterButtonTappedProperty.signal.mapConst(SLServiceTypeTwitter)
      )

    self.showShareCompose = Signal.combineLatest(shareContext, directShareService)
      .map(shareComposeController(forShareContext:serviceType:))

    let directShareCompletion = Signal.merge(
      self.facebookButtonTappedProperty.signal.mapConst(UIActivityType.postToFacebook),
      self.twitterButtonTappedProperty.signal.mapConst(UIActivityType.postToTwitter)
      )
      .takePairWhen(self.shareComposeCompletionProperty.signal.skipNil())
      .map { service, result in
        (
          activityType: service.rawValue,
          completed: result == .done,
          returnedItems: [AnyObject]?.none,
          activityError: NSError?.none
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
        completion.completed && firstPartyShareTypes.contains(completion.activityType ?? "")
      }
      .flatMap {
        SignalProducer(value: $0)
          .delay(1.0, onScheduler: AppEnvironment.current.scheduler)
      }
      .observeValues { shareContext, completion in
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
  fileprivate let shareActivityCompletionProperty = MutableProperty
    <(activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?)?>(nil)
  public func shareActivityCompletion(activityType: String?,
                                                   completed: Bool,
                                                   returnedItems: [AnyObject]?,
                                                   activityError: NSError?) {
    self.shareActivityCompletionProperty.value = (activityType, completed, returnedItems, activityError)
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
  case let .project(project):
    return ProjectActivityItemProvider(project: project)
  case let .thanks(project):
    return ProjectActivityItemProvider(project: project)
  case let .update(_, update):
    return UpdateActivityItemProvider(update: update)
  }
}

private func shareUrl(forShareContext shareContext: ShareContext) -> URL {

  switch shareContext {
  case let .creatorDashboard(project):
    return URL(string: project.urls.web.project) ?? URL()
  case let .project(project):
    return URL(string: project.urls.web.project) ?? URL()
  case let .thanks(project):
    return URL(string: project.urls.web.project) ?? URL()
  case let .update(_, update):
    return URL(string: update.urls.web.update) ?? URL()
  }
}

private func excludedActivityTypes(forShareContext shareContext: ShareContext) -> [String] {

  switch shareContext {
  case let .update(_, update) where !update.isPublic:
    return [
      UIActivityType.mail.rawValue,
      UIActivityType.message.rawValue,
      UIActivityType.postToFacebook.rawValue,
      UIActivityType.postToTwitter.rawValue,
      UIActivityType.postToWeibo.rawValue
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

    controller?.add(shareUrl(forShareContext: shareContext))

    if serviceType == SLServiceTypeTwitter {
      controller?.setInitialText(twitterInitialText(forShareContext: shareContext))
    }

    return controller!
}
#endif
