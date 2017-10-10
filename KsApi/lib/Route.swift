import Prelude

/**
 A list of possible requests that can be made for Kickstarter data.
 */
internal enum Route {
  case activities(categories: [Activity.Category], count: Int?)
  case addImage(fileUrl: URL, toDraft: UpdateDraft)
  case addVideo(fileUrl: URL, toDraft: UpdateDraft)
  case backing(projectId: Int, backerId: Int)
  case categories
  case category(Param)
  case changePaymentMethod(project: Project)
  case checkout(String)
  case config
  case createPledge(project: Project, amount: Double, reward: Reward?, shippingLocation: Location?,
    tappedReward: Bool)
  case deleteImage(UpdateDraft.Image, fromDraft: UpdateDraft)
  case deleteVideo(UpdateDraft.Video, fromDraft: UpdateDraft)
  case discover(DiscoveryParams)
  case facebookConnect(facebookAccessToken: String)
  case facebookLogin(facebookAccessToken: String, code: String?)
  case facebookSignup(facebookAccessToken: String, sendNewsletters: Bool)
  case fetchUpdateDraft(forProject: Project)
  case friends
  case friendStats
  case followAllFriends
  case followFriend(userId: Int)
  case incrementVideoCompletion(project: Project)
  case incrementVideoStart(project: Project)
  case login(email: String, password: String, code: String?)
  case markAsRead(MessageThread)
  case messagesForThread(messageThreadId: Int)
  case messagesForBacking(Backing)
  case messageThreads(mailbox: Mailbox, project: Project?)
  case postProjectComment(Project, body: String)
  case postUpdateComment(Update, body: String)
  case project(Param)
  case projectActivities(Project)
  case projectComments(Project)
  case projectNotifications
  case projects(member: Bool)
  case projectStats(projectId: Int)
  case publishUpdateDraft(UpdateDraft)
  case registerPushToken(String)
  case resetPassword(email: String)
  case searchMessages(query: String, project: Project?)
  case sendMessage(body: String, messageSubject: MessageSubject)
  case shippingRules(projectId: Int, rewardId: Int)
  case signup(name: String, email: String, password: String, passwordConfirmation: String,
    sendNewsletters: Bool)
  case star(Project)
  case submitApplePay(checkoutUrl: String, stripeToken: String, paymentInstrumentName: String,
    paymentNetwork: String, transactionIdentifier: String)
  case surveyResponse(surveyResponseId: Int)
  case toggleStar(Project)
  case unansweredSurveyResponses
  case unfollowFriend(userId: Int)
  case update(updateId: Int, projectParam: Param)
  case updateComments(Update)
  case updatePledge(project: Project, amount: Double, reward: Reward?, shippingLocation: Location?,
    tappedReward: Bool)
  case updateProjectNotification(notification: ProjectNotification)
  case updateUpdateDraft(UpdateDraft, title: String, body: String, isPublic: Bool)
  case updateUserSelf(User)
  case userProjectsBacked
  case userSelf
  case user(userId: Int)

  enum UploadParam: String {
    case image
    case video
  }

  internal var requestProperties:
    (method: Method, path: String, query: [String: Any], file: (name: UploadParam, url: URL)?) {

    switch self {
    case let .activities(categories, count):
      var params: [String: Any] = ["categories": categories.map { $0.rawValue }]
      params["count"] = count
      return (.GET, "/v1/activities", params, nil)

    case let .addImage(file, draft):
      return (.POST, "/v1/projects/\(draft.update.projectId)/updates/draft/images", [:], (.image, file))

    case let .addVideo(file, draft):
      return (.POST, "/v1/projects/\(draft.update.projectId)/updates/draft/video", [:], (.video, file))

    case let .backing(projectId, backerId):
      return (.GET, "/v1/projects/\(projectId)/backers/\(backerId)", [:], nil)

    case .categories:
      return (.GET, "/v1/categories", [:], nil)

    case let .category(param):
      return (.GET, "/v1/categories/\(param.escapedUrlComponent)", [:], nil)

    case let .changePaymentMethod(project):
      let changeMethodUrl = URL(string: project.urls.web.project)?
        .appendingPathComponent("pledge")
        .appendingPathComponent("change_method")

      return (.PUT, changeMethodUrl?.absoluteString ?? "", ["format": "json"], nil)

    case let .checkout(url):
      return (.GET, url, [:], nil)

    case .config:
      return (.GET, "/v1/app/ios/config", [:], nil)

    case let .createPledge(project, amount, reward, shippingLocation, tappedReward):
      let pledgeUrl = URL(string: project.urls.web.project)?
        .appendingPathComponent("pledge")

      var params: [String: Any] = [:]
      params["clicked_reward"] = tappedReward ? "true" : nil
      params["format"] = "json"
      params["backing"] = [
        "amount": String(amount),
        "backer_reward_id": reward.map { String($0.id) } ?? "",
        "location_id": shippingLocation.map { String($0.id) }
        ].compact()

      return (.POST, pledgeUrl?.absoluteString ?? "", params, nil)

    case let .deleteImage(i, draft):
      return (.DELETE, "/v1/projects/\(draft.update.projectId)/updates/draft/images/\(i.id)", [:], nil)

    case let .deleteVideo(v, draft):
      return (.DELETE, "/v1/projects/\(draft.update.projectId)/updates/draft/video/\(v.id)", [:], nil)

    case let .discover(params):
      return (.GET, "/v1/discover", params.queryParams, nil)

    case let .facebookConnect(token):
      return (.PUT, "v1/facebook/connect", ["access_token": token], nil)

    case let .facebookLogin(facebookAccessToken, code):
      var params = ["access_token": facebookAccessToken, "intent": "login"]
      params["code"] = code
      return (.PUT, "/v1/facebook/access_token", params, nil)

    case let .facebookSignup(facebookAccessToken, sendNewsletters):
      let params: [String: Any] = [
        "access_token": facebookAccessToken,
        "intent": "register",
        "send_newsletters": sendNewsletters,
        "newsletter_opt_in": sendNewsletters
      ]
      return (.PUT, "/v1/facebook/access_token", params, nil)

    case let .fetchUpdateDraft(project):
      return (.GET, "/v1/projects/\(project.id)/updates/draft", [:], nil)

    case .friends:
      return (.GET, "v1/users/self/friends/find", [:], nil)

    case .friendStats:
      return (.GET, "v1/users/self/friends/find", ["count": 0], nil)

    case .followAllFriends:
      return (.PUT, "v1/users/self/friends/follow_all", [:], nil)

    case let .followFriend(userId):
      return (.POST, "v1/users/self/friends", ["followed_id": userId], nil)

    case let .incrementVideoCompletion(project):
      let statsURL = URL(string: project.urls.web.project)?
        .appendingPathComponent("video/plays")
      return (.POST, statsURL?.absoluteString ?? "", ["event_type": "complete", "location": "internal"], nil)

    case let .incrementVideoStart(project):
      let statsURL = URL(string: project.urls.web.project)?
        .appendingPathComponent("video/plays")
      return (.POST, statsURL?.absoluteString ?? "", ["event_type": "start", "location": "internal"], nil)

    case let .login(email, password, code):
      var params = ["email": email, "password": password]
      params["code"] = code
      return (.POST, "/xauth/access_token", params, nil)

    case let .markAsRead(messageThread):
      return (.PUT, "/v1/message_threads/\(messageThread.id)/read", [:], nil)

    case let .messagesForThread(messageThreadId):
      return (.GET, "/v1/message_threads/\(messageThreadId)/messages", [:], nil)

    case let .messagesForBacking(backing):
      return (.GET, "/v1/projects/\(backing.projectId)/backers/\(backing.backerId)/messages", [:], nil)

    case let .messageThreads(mailbox, project):
      if let project = project {
        return (.GET, "/v1/projects/\(project.id)/message_threads/\(mailbox.rawValue)", [:], nil)
      }
      return (.GET, "/v1/message_threads/\(mailbox.rawValue)", [:], nil)

    case let .postProjectComment(p, body):
      return (.POST, "/v1/projects/\(p.id)/comments", ["body": body], nil)

    case let .postUpdateComment(u, body):
      return (.POST, "/v1/projects/\(u.projectId)/updates/\(u.id)/comments", ["body": body], nil)

    case let .project(param):
      return (.GET, "/v1/projects/\(param.escapedUrlComponent)", [:], nil)

    case let .projectActivities(project):
      return (.GET, "/v1/projects/\(project.id)/activities", [:], nil)

    case let .projectComments(p):
      return (.GET, "/v1/projects/\(p.id)/comments", [:], nil)

    case .projectNotifications:
      return (.GET, "/v1/users/self/notifications", [:], nil)

    case let .projects(member):
      return (.GET, "/v1/users/self/projects", ["member": member ? "1" : "0"], nil)

    case let .projectStats(projectId):
      return (.GET, "/v1/projects/\(projectId)/stats", [:], nil)

    case let .publishUpdateDraft(d):
      return (.POST, "/v1/projects/\(d.update.projectId)/updates/draft/publish", [:], nil)

    case let .registerPushToken(token):
      return (.POST, "v1/users/self/ios/push_tokens", ["token": token], nil)

    case let .resetPassword(email):
      return (.POST, "/v1/users/reset", ["email": email], nil)

    case let .searchMessages(query, project):
      if let project = project {
        return (.GET, "/v1/projects/\(project.id)/message_threads/search", ["q": query], nil)
      }
      return (.GET, "/v1/message_threads/search", ["q": query], nil)

    case let .sendMessage(body, messageSubject):
      switch messageSubject {
      case let .backing(backing):
        return (.POST,
                "v1/projects/\(backing.projectId)/backers/\(backing.backerId)/messages",
                ["body": body],
                nil)

      case let .messageThread(messageThread):
        return (.POST, "/v1/message_threads/\(messageThread.id)/messages", ["body": body], nil)

      case let .project(project):
        return (.POST, "v1/projects/\(project.id)/messages", ["body": body], nil)
      }

    case let .shippingRules(projectId, rewardId):
      return (.GET, "/v1/projects/\(projectId)/rewards/\(rewardId)/shipping_rules", [:], nil)

    case let .signup(name, email, password, passwordConfirmation, sendNewsletters):
      let params: [String: Any] = [
        "name": name,
        "email": email,
        "newsletter_opt_in": sendNewsletters,
        "password": password,
        "password_confirmation": passwordConfirmation,
        "send_newsletters": sendNewsletters
      ]
      return (.POST, "/v1/users", params, nil)

    case let .star(p):
      return (.PUT, "/v1/projects/\(p.id)/star", [:], nil)

    case let .submitApplePay(checkoutUrl, stripeToken, paymentInstrumentName, paymentNetwork,
      transactionIdentifier):

      let params = [
        "format": "json",
        "payment_instrument_name": paymentInstrumentName,
        "payment_network": paymentNetwork,
        "payment_type": "apple_pay",
        "token": stripeToken,
        "transaction_identifier": transactionIdentifier,
        ]

      return (.POST, checkoutUrl, params, nil)

    case let.surveyResponse(surveyResponseId):
      return (.GET, "/v1/users/self/surveys/\(surveyResponseId)", [:], nil)

    case let .toggleStar(p):
      return (.POST, "/v1/projects/\(p.id)/star/toggle", [:], nil)

    case .unansweredSurveyResponses:
      return (.GET, "/v1/users/self/surveys/unanswered", [:], nil)

    case let .unfollowFriend(userId):
      return (.DELETE, "v1/users/self/friends/\(userId)", [:], nil)

    case let .update(id, projectParam):
      return (.GET, "v1/projects/\(projectParam.escapedUrlComponent)/updates/\(id)", [:], nil)

    case let .updateComments(u):
      return (.GET, "/v1/projects/\(u.projectId)/updates/\(u.id)/comments", [:], nil)

    case let .updatePledge(project, amount, reward, shippingLocation, tappedReward):
      let pledgeUrl = URL(string: project.urls.web.project)?
        .appendingPathComponent("pledge")

      var params: [String: Any] = [:]
      params["clicked_reward"] = tappedReward ? "true" : nil
      params["format"] = "json"
      params["backing"] = [
        "amount": String(amount),
        "backer_reward_id": reward.map { String($0.id) } ?? "",
        "location_id": shippingLocation.map { String($0.id) }
        ].compact()

      return (.PUT, pledgeUrl?.absoluteString ?? "", params, nil)

    case let .updateUpdateDraft(d, title, body, isPublic):
      let params: [String: Any] = ["title": title, "body": body, "public": isPublic]
      return (.PUT, "/v1/projects/\(d.update.projectId)/updates/draft", params, nil)

    case let .updateProjectNotification(notification):
      let params = ["email": notification.email, "mobile": notification.mobile]
      return (.PUT, "/v1/users/self/notifications/\(notification.id)", params, nil)

    case let .updateUserSelf(user):
      let params = user.notifications.encode().withAllValuesFrom(user.newsletters.encode())
      return (.PUT, "/v1/users/self", params, nil)

    case .userProjectsBacked:
      return (.GET, "/v1/users/self/projects/backed", [:], nil)

    case .userSelf:
      return (.GET, "/v1/users/self", [:], nil)

    case let .user(userId):
      return (.GET, "/v1/users/\(userId)", [:], nil)

    }
  }
}
