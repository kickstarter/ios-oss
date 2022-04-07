import KsApi
import Prelude
import ReactiveSwift
import UIKit

public struct ShareActivityCompletionData {
  internal let activityType: UIActivity.ActivityType?
  internal let completed: Bool
  internal let returnedItems: [Any]?
  internal let activityError: Error?

  public init(
    activityType: UIActivity.ActivityType?,
    completed: Bool,
    returnedItems: [Any]?,
    activityError: Error?
  ) {
    self.activityType = activityType
    self.completed = completed
    self.returnedItems = returnedItems
    self.activityError = activityError
  }
}

public protocol ShareViewModelInputs {
  /// Call with the context that this sharing is taking place in.
  func configureWith(shareContext: ShareContext, shareContextView: UIView?)

  /// Call when the general share button is pressed.
  func shareButtonTapped()
}

public protocol ShareViewModelOutputs {
  /// Emits when the share sheet should be presented.
  var showShareSheet: Signal<(UIActivityViewController, UIView?), Never> { get }
}

public protocol ShareViewModelType {
  var inputs: ShareViewModelInputs { get }
  var outputs: ShareViewModelOutputs { get }
}

public final class ShareViewModel: ShareViewModelType, ShareViewModelInputs, ShareViewModelOutputs {
  public init() {
    let shareContextAndView = self.shareContextProperty.signal.skipNil()

    self.showShareSheet = shareContextAndView
      .takeWhen(self.shareButtonTappedProperty.signal)
      .map { (context, view) -> (UIActivityViewController, UIView?)? in
        guard let controller = activityController(forShareContext: context) else { return nil }
        return (controller, view)
      }
      .skipNil()
  }

  fileprivate let shareContextProperty = MutableProperty<(ShareContext, UIView?)?>(nil)
  public func configureWith(shareContext: ShareContext, shareContextView: UIView?) {
    self.shareContextProperty.value = (shareContext, shareContextView)
  }

  fileprivate let shareButtonTappedProperty = MutableProperty(())
  public func shareButtonTapped() {
    self.shareButtonTappedProperty.value = ()
  }

  public let showShareSheet: Signal<(UIActivityViewController, UIView?), Never>

  public var inputs: ShareViewModelInputs { return self }
  public var outputs: ShareViewModelOutputs { return self }
}

private func activityItemProvider(forShareContext shareContext: ShareContext) -> UIActivityItemProvider {
  switch shareContext {
  case let .creatorDashboard(project):
    return ProjectActivityItemProvider(project: project)
  case let .discovery(project):
    return ProjectActivityItemProvider(project: project)
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
  case let .discovery(project):
    return URL(string: project.urls.web.project)
  case let .project(project):
    return URL(string: project.urls.web.project)
  case let .thanks(project):
    return URL(string: project.urls.web.project)
  case let .update(_, update):
    return URL(string: update.urls.web.update)
  }
}

private func excludedActivityTypes(forShareContext shareContext: ShareContext) -> [UIActivity.ActivityType] {
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
  let safariUrl = SafariURL(url: url)

  let controller = UIActivityViewController(
    activityItems: [provider, safariUrl],
    applicationActivities: [SafariActivity(url: safariUrl)]
  )

  controller.excludedActivityTypes = excludedActivityTypes(forShareContext: shareContext)

  return controller
}
