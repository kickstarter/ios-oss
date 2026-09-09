import FirebaseCrashlytics
import KsApi
import Library
import Prelude
import ReactiveSwift
import UIKit

/// Resolves a stream of `Navigation` values (deep links) into concrete UI actions. Both
/// `AppDelegateViewModel` (fed by push-notification and Braze deep links) and `SceneDelegateViewModel`
/// (fed by URL/continue-user-activity/shortcut-item deep links) run their own `deepLink` signal
/// through this, so the navigation-resolution logic isn't duplicated between them.
internal struct DeepLinkNavigationOutputs {
  internal let goToActivity: Signal<(), Never>
  internal let goToDiscovery: Signal<DiscoveryParams?, Never>
  internal let goToLoginWithIntent: Signal<LoginIntent, Never>
  internal let goToMessageThread: Signal<MessageThread, Never>
  internal let goToProfile: Signal<(), Never>
  internal let goToSearch: Signal<(), Never>
  internal let presentViewController: Signal<UIViewController, Never>
  internal let updateCurrentUserInEnvironment: Signal<User, Never>

  internal init(deepLink: Signal<Navigation, Never>) {
    let fixErroredPledgeLinkAndNeedsToLogin = deepLink
      .filter { link in
        guard case let .project(_, subpage, _, _) = link else { return false }
        guard case .pledge(.manage) = subpage else { return false }

        return AppEnvironment.current.currentUser == nil
      }

    let goToActivity = deepLink
      .filter { $0 == .tab(.activity) }
      .ignoreValues()

    let goToSearch = deepLink
      .filter { $0 == .tab(.search) }
      .ignoreValues()

    let goToLogin = deepLink
      .filter { $0 == .tab(.login) }
      .ignoreValues()

    let goToLoginWithIntent: Signal<LoginIntent, Never> = Signal.merge(
      fixErroredPledgeLinkAndNeedsToLogin.mapConst(.erroredPledge),
      goToLogin.mapConst(.generic)
    )

    let goToProfile = deepLink
      .filter { $0 == .tab(.me) }
      .ignoreValues()

    let goToDiscovery = deepLink
      .map { link -> [String: String]?? in
        guard case let .tab(.discovery(rawParams)) = link else { return nil }
        return .some(rawParams)
      }
      .skipNil()
      .switchMap { rawParams -> SignalProducer<DiscoveryParams?, Never> in

        guard
          let rawParams = rawParams,
          let params = DiscoveryParams.decodeJSONDictionary(rawParams)
        else {
          return .init(value: nil)
        }

        let categories = deepLinkCategories(rawParams: rawParams)

        guard let categoryParam = categories.0 else {
          return .init(value: params)
        }

        return AppEnvironment.current.apiService.fetchGraphCategories()
          .map { envelope in
            findCategoryFromRootCategories(
              envelope: envelope,
              categoryParam: categoryParam,
              subcategoryParam: categories.1
            )
          }
          .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
          .demoteErrors()
          .map { params |> DiscoveryParams.lens.category .~ $0 }
      }

    let goToMessageThread = deepLink
      .map { navigation -> Int? in
        guard case let .messages(messageThreadId) = navigation else { return nil }
        return .some(messageThreadId)
      }
      .skipNil()
      .switchMap {
        AppEnvironment.current.apiService.fetchMessageThread(messageThreadId: $0)
          .demoteErrors()
          .map { $0.messageThread }
      }

    let updatedUserNotificationSettings = deepLink.filter { nav in
      guard case .settings(.notifications) = nav else { return false }
      return true
    }
    .flatMap(updateUserNotificationSetting)

    let surveyUrlFromUserLink = deepLink
      .map { link -> Int? in
        if case let .user(_, .survey(surveyResponseId)) = link { return surveyResponseId }
        return nil
      }
      .skipNil()
      .switchMap { surveyResponseId in
        AppEnvironment.current.apiService.fetchSurveyResponse(surveyResponseId: surveyResponseId)
          .demoteErrors()
          .map { surveyResponse -> String in
            surveyResponse.urls.web.survey
          }
      }

    let surveyUrlFromProjectLink = deepLink
      .map { link -> String? in
        if case let .project(_, .pledgeManagerWebview(surveyUrl), _, _) = link {
          return surveyUrl
        }
        return nil
      }
      .skipNil()

    let pledgeManagerLink = Signal.merge(surveyUrlFromProjectLink, surveyUrlFromUserLink)
      .observeForUI()
      .map { url -> UINavigationController in
        let pm = PledgeManagerWebViewController.configuredWith(url: url)
        let nav = UINavigationController(rootViewController: pm)
        // See PR #2650 for additional context. This used to be added in the view controller.
        nav.modalPresentationStyle = .pageSheet
        return nav
      }

    let projectLinks = ProjectDeepLink.projectViewControllers(fromDeepLink: deepLink)

    let presentViewController = Signal.merge(
      projectLinks,
      pledgeManagerLink
    ).map { $0 as UIViewController }

    self.goToActivity = goToActivity
    self.goToDiscovery = goToDiscovery
    self.goToLoginWithIntent = goToLoginWithIntent
    self.goToMessageThread = goToMessageThread
    self.goToProfile = goToProfile
    self.goToSearch = goToSearch
    self.presentViewController = presentViewController
    self.updateCurrentUserInEnvironment = updatedUserNotificationSettings
  }
}

/// If a URL doesn't match a deep link, whether it should be opened in the browser instead.
internal func shouldOpenUrlInBrowser(_ url: URL) -> Bool {
  // If url has a deeplink match, never attempt to open the url in the browser.
  if Navigation.deepLinkMatch(url) != nil {
    return false
  }
  // Never attempt to open `ksr` urls in the browser; they'll redirect straight back to our app.
  if let scheme = url.scheme, scheme == "ksr" {
    print(
      "Error: Unable to open 'ksr' deeplink. Please doublecheck that the url "
        + "is included in the list of deeplinks and that you're not trying to "
        + "use a staging url in prod (or vice versa)."
    )
    let error = NSError(domain: "Kickstarter.Deeplink", code: 0, userInfo: [
      NSLocalizedDescriptionKey: "Unable to open unsupported ksr deeplink."
    ])
    Crashlytics.crashlytics().record(error: error)
    return false
  }
  // Otherwise, open url in browser.
  return true
}

/// Handles the deeplink route with both an id and text based name for a deeplink to categories.
private func deepLinkCategories(rawParams: [String: String]) -> (Param?, Param?) {
  let parentCategoryParams = rawParams["parent_category_id"]
  let subCategoryParams = rawParams["category_id"]
  var categoryParam: Param?
  var subcategoryParam: Param?

  let rawId: (String?) -> Int? = { rawParam in
    guard let rawParamValue = rawParam else {
      return .none
    }

    return Int(rawParamValue)
  }

  let rawName: (String?) -> String? = { rawParam in
    guard let rawParamValue = rawParam else {
      return .none
    }

    return String(rawParamValue)
  }

  if let categoryId = rawId(parentCategoryParams) {
    categoryParam = Param.id(categoryId)
  } else if let categoryName = rawName(parentCategoryParams) {
    categoryParam = Param.slug(categoryName)
  }

  if let subcategoryId = rawId(subCategoryParams) {
    subcategoryParam = Param.id(subcategoryId)
  } else if let subcategoryName = rawName(subCategoryParams) {
    subcategoryParam = Param.slug(subcategoryName)
  }

  let subCategoryWithNoParentCategory = categoryParam == nil && subcategoryParam != nil

  categoryParam = subCategoryWithNoParentCategory ? subcategoryParam : categoryParam
  subcategoryParam = subCategoryWithNoParentCategory ? nil : subcategoryParam

  return (categoryParam, subcategoryParam)
}

/// Will check id and name of category and subcategory against all available categories and subcategories inside envelope
private func findCategoryFromRootCategories(
  envelope: RootCategoriesEnvelope,
  categoryParam: Param,
  subcategoryParam: Param?
) -> KsApi.Category? {
  let allRootCategoryIdsAndNames = envelope.rootCategories.compactMap { $0 }

  let allSubcategoryIdsAndNames = envelope.rootCategories.compactMap { $0.subcategories?.nodes }
    .flatMap { $0 }

  let allCategoryIdsAndNames = allRootCategoryIdsAndNames + allSubcategoryIdsAndNames

  let routableCategory = allCategoryIdsAndNames.first(where: { category in
    category.intID == categoryParam.id || category.name.lowercased() == categoryParam.slug?.lowercased()
  })

  let routableSubcategory = routableCategory != nil ? allCategoryIdsAndNames.first(where: { category in
    category.intID == subcategoryParam?.id || category.name.lowercased() == subcategoryParam?.slug?
      .lowercased()
  }) : nil

  return routableSubcategory ?? routableCategory
}

private func updateUserNotificationSetting(navigation: Navigation) -> SignalProducer<User, Never> {
  guard
    case let .settings(.notifications(notification, enabled)) = navigation,
    let currentUser = AppEnvironment.current.currentUser
  else { return .empty }

  let currentNotifications = AppEnvironment.current.currentUser?.notifications.encode()
  let updatedNotifications = currentNotifications?.withAllValuesFrom([notification: enabled])

  guard
    let data = try? JSONSerialization.data(withJSONObject: updatedNotifications as Any, options: []),
    let userNotifications = try? JSONDecoder().decode(User.Notifications.self, from: data)
  else { return .empty }

  let updatedUser = currentUser |> User.lens.notifications .~ userNotifications

  return AppEnvironment.current.apiService.updateUserSelf(updatedUser)
    .ksr_delay(AppEnvironment.current.apiDelayInterval, on: AppEnvironment.current.scheduler)
    .demoteErrors()
}

/// A utility for handling all of the `.project` deep links.
/// These deep links can make stacks of view controllers - like Project > Comment > Thread.
/// I pulled these out of `AppDelegateViewModel.init` to them easier to reason about.
internal struct ProjectDeepLink {
  /// TODO: This could be cleaned up to be more imperative. It's basically mapping a project deep link and its subpages
  /// into an array of `UIViewController`s.
  static func projectViewControllers(fromDeepLink deepLink: Signal<Navigation, Never>)
    -> Signal<UINavigationController, Never> {
    let projectLinkValues = deepLink
      // swiftlint:disable:next large_tuple
      .map { link -> (Param, Navigation.Project, RefInfo?, secretRewardToken: String?)? in
        guard case let .project(param, subpage, refInfo, secretRewardToken) = link else { return nil }
        return (param, subpage, refInfo, secretRewardToken)
      }
      .skipNil()
      .switchMap { param, subpage, refInfo, secretRewardToken in
        AppEnvironment.current.apiService.fetchProject(param: param)
          .demoteErrors()
          .observeForUI()
          // swiftlint:disable:next large_tuple
          .map { project -> (Project, Navigation.Project, [UIViewController], RefInfo?) in
            let projectParam = Either<Project, any ProjectPageParam>(left: project)
            let vc = ProjectPageViewController.configuredWith(
              projectOrParam: projectParam,
              refInfo: refInfo,
              secretRewardToken: secretRewardToken
            )

            return (
              project, subpage,
              [vc],
              refInfo
            )
          }
      }

    let projectLink = projectLinkValues
      .filter { project, _, _, _ in project.displayPrelaunch != true }

    let projectPreviewLink = projectLinkValues
      .filter { project, _, _, _ in project.displayPrelaunch == true }

    let fixErroredPledgeLinkAndIsLoggedIn = projectLink
      .filter { _, subpage, _, _ in subpage == .pledge(.manage) }
      .map { project, _, vcs, _ in
        (project, vcs, AppEnvironment.current.currentUser != nil)
      }

    let fixErroredPledgeLink = fixErroredPledgeLinkAndIsLoggedIn
      .filter(third >>> isTrue)
      .map { project, vcs, _ -> [UIViewController]? in
        guard let backingId = project.personalization.backing?.id else { return nil }
        let vc = ManagePledgeViewController.instantiate()
        let params: ManagePledgeViewParamConfigData = (.id(project.id), .id(backingId))
        vc.configureWith(params: params)
        return vcs + [vc]
      }
      .skipNil()
      .map { vcs -> RewardPledgeNavigationController in
        let nav = RewardPledgeNavigationController(nibName: nil, bundle: nil)
        nav.viewControllers = vcs
        // See PR #2650 for additional context. This used to be added in the view controller.
        nav.modalPresentationStyle = .pageSheet
        return nav
      }

    let projectRootLink = Signal.merge(projectLink, projectPreviewLink)
      .filter { _, subpage, _, _ in subpage == .root }
      .map { _, _, vcs, _ in vcs }

    let projectCommentsLink = projectLink
      .filter { _, subpage, _, _ in subpage == .comments }
      .map { project, _, vcs, _ in
        vcs + [commentsViewController(for: project, update: nil)]
      }

    let projectCommentThreadLink = projectLink
      .observeForUI()
      .switchMap { project, subpage, vcs, _ -> SignalProducer<[UIViewController], Never> in
        guard case let .commentThread(commentId, replyId) = subpage,
              let commentId = commentId else {
          return .empty
        }

        return AppEnvironment.current.apiService
          .fetchCommentReplies(
            id: commentId,
            cursor: nil,
            limit: CommentRepliesEnvelope.paginationLimit
          )
          .demoteErrors()
          .observeForUI()
          .map { envelope in
            vcs + [
              commentsViewController(for: project, update: nil),
              CommentRepliesViewController.configuredWith(
                comment: envelope.comment,
                project: project,
                update: nil,
                inputAreaBecomeFirstResponder: false,
                replyId: replyId
              )
            ]
          }
      }

    let updatesLink = projectLink
      .filter { _, subpage, _, _ in subpage == .updates }
      .map { project, _, vcs, _ in vcs + [ProjectUpdatesViewController.configuredWith(project: project)] }

    let updateLink = projectLink
      // swiftlint:disable:next large_tuple
      .map { project, subpage, vcs, _ -> (Project, Int, Navigation.Project.Update, [UIViewController])? in
        guard case let .update(id, updateSubpage) = subpage else { return nil }
        return (project, id, updateSubpage, vcs)
      }
      .skipNil()
      .switchMap { project, id, updateSubpage, vcs in
        AppEnvironment.current.apiService.fetchUpdate(updateId: id, projectParam: .id(project.id))
          .demoteErrors()
          .observeForUI()
          // swiftlint:disable:next large_tuple
          .map { update -> (Project, Update, Navigation.Project.Update, [UIViewController]) in
            (
              project,
              update,
              updateSubpage,
              vcs + [
                UpdateViewController.configuredWith(
                  project: project,
                  update: update,
                  context: .deepLink
                )
              ]
            )
          }
      }

    let updateRootLink = updateLink
      .filter { _, _, subpage, _ in subpage == .root }
      .map { _, _, _, vcs in vcs }

    let updateCommentsLink = updateLink
      .observeForUI()
      .map { _, update, subpage, vcs -> [UIViewController]? in
        guard case .comments = subpage else { return nil }
        return vcs + [commentsViewController(update: update)]
      }
      .skipNil()

    let updateCommentThreadLink = updateLink
      .observeForUI()
      .switchMap { project, update, subpage, vcs -> SignalProducer<[UIViewController], Never> in
        guard case let .commentThread(commentId, replyId) = subpage,
              let commentId = commentId else {
          return .empty
        }
        return AppEnvironment.current.apiService
          .fetchCommentReplies(
            id: commentId,
            cursor: nil,
            limit: CommentRepliesEnvelope.paginationLimit
          )
          .demoteErrors()
          .observeForUI()
          .map { envelope in
            vcs + [
              commentsViewController(for: nil, update: update),
              CommentRepliesViewController.configuredWith(
                comment: envelope.comment,
                project: project,
                update: update,
                inputAreaBecomeFirstResponder: false,
                replyId: replyId
              )
            ]
          }
      }

    return Signal
      .merge(
        projectRootLink,
        projectCommentsLink,
        projectCommentThreadLink,
        updatesLink,
        updateRootLink,
        updateCommentsLink,
        updateCommentThreadLink
      )
      .map { ProjectPageViewController.navigationController(withViewControllers: $0) }
      // This one is already in its own nav controller, `RewardPledgeNavigationController`
      .merge(with: fixErroredPledgeLink.map { $0 as UINavigationController })
  }
}
