import Foundation
import Prelude
import ReactiveSwift

public enum Mailbox: String {
  case inbox
  case sent
}

/**
 A type that knows how to perform requests for Kickstarter data.
 */
public protocol ServiceType {
  var appId: String { get }
  var serverConfig: ServerConfigType { get }
  var oauthToken: OauthTokenAuthType? { get }
  var language: String { get }
  var currency: String { get }
  var buildVersion: String { get }

  init(appId: String,
       serverConfig: ServerConfigType,
       oauthToken: OauthTokenAuthType?,
       language: String,
       currency: String,
       buildVersion: String)

  /// Returns a new service with the oauth token replaced.
  func login(_ oauthToken: OauthTokenAuthType) -> Self

  /// Returns a new service with the oauth token set to `nil`.
  func logout() -> Self

  /// Request to connect user to Facebook with access token.
  func facebookConnect(facebookAccessToken token: String) -> SignalProducer<User, ErrorEnvelope>

  /// Uploads and attaches an image to the draft of a project update.
  func addImage(file fileURL: URL, toDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Image, ErrorEnvelope>

  /// Uploads and attaches a video to the draft of a project update.
  func addVideo(file fileURL: URL, toDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Video, ErrorEnvelope>

  func changePaymentMethod(project: Project)
    -> SignalProducer<ChangePaymentMethodEnvelope, ErrorEnvelope>

  /// Performs the first step of checkout by creating a pledge on the server.
  func createPledge(project: Project,
                    amount: Double,
                    reward: Reward?,
                    shippingLocation: Location?,
                    tappedReward: Bool) -> SignalProducer<CreatePledgeEnvelope, ErrorEnvelope>

  /// Removes an image from a project update draft.
  func delete(image: UpdateDraft.Image, fromDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Image, ErrorEnvelope>

  /// Removes a video from a project update draft.
  func delete(video: UpdateDraft.Video, fromDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Video, ErrorEnvelope>

  /// Fetch a page of activities.
  func fetchActivities(count: Int?) -> SignalProducer<ActivityEnvelope, ErrorEnvelope>

  /// Fetch activities from a pagination URL
  func fetchActivities(paginationUrl: String) -> SignalProducer<ActivityEnvelope, ErrorEnvelope>

  /// Fetches the current user's backing for the project, if it exists.
  func fetchBacking(forProject project: Project, forUser user: User)
    -> SignalProducer<Backing, ErrorEnvelope>

  /// Fetch all categories.
  func fetchCategories() -> SignalProducer<CategoriesEnvelope, ErrorEnvelope>

  /// Fetch the newest data for a particular category.
  func fetchCategory(param: Param) -> SignalProducer<Category, ErrorEnvelope>

  /// Fetch a checkout's status.
  func fetchCheckout(checkoutUrl url: String) -> SignalProducer<CheckoutEnvelope, ErrorEnvelope>

  /// Fetch comments from a pagination url.
  func fetchComments(paginationUrl url: String) -> SignalProducer<CommentsEnvelope, ErrorEnvelope>

  /// Fetch comments for a project.
  func fetchComments(project: Project) -> SignalProducer<CommentsEnvelope, ErrorEnvelope>

  /// Fetch comments for an update.
  func fetchComments(update: Update) -> SignalProducer<CommentsEnvelope, ErrorEnvelope>

  /// Fetch the config.
  func fetchConfig() -> SignalProducer<Config, ErrorEnvelope>

  /// Fetch discovery envelope with a pagination url.
  func fetchDiscovery(paginationUrl: String) -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope>

  /// Fetch the full discovery envelope with specified discovery params.
  func fetchDiscovery(params: DiscoveryParams) -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope>

  /// Fetch friends for a user.
  func fetchFriends() -> SignalProducer<FindFriendsEnvelope, ErrorEnvelope>

  /// Fetch friends from a pagination url.
  func fetchFriends(paginationUrl: String) -> SignalProducer<FindFriendsEnvelope, ErrorEnvelope>

  /// Fetch friend stats.
  func fetchFriendStats() -> SignalProducer<FriendStatsEnvelope, ErrorEnvelope>

  /// Fetches all of the messages in a particular message thread.
  func fetchMessageThread(messageThreadId: Int)
    -> SignalProducer<MessageThreadEnvelope, ErrorEnvelope>

  /// Fetches all of the messages related to a particular backing.
  func fetchMessageThread(backing: Backing) -> SignalProducer<MessageThreadEnvelope?, ErrorEnvelope>

  /// Fetches all of the messages in a particular mailbox and specific to a particular project.
  func fetchMessageThreads(mailbox: Mailbox, project: Project?)
    -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope>

  /// Fetches more messages threads from a pagination URL.
  func fetchMessageThreads(paginationUrl: String)
    -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope>

  /// Fetch the newest data for a particular project from its id.
  func fetchProject(param: Param) -> SignalProducer<Project, ErrorEnvelope>

  /// Fetch a single project with the specified discovery params.
  func fetchProject(_ params: DiscoveryParams) -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope>

  /// Fetch the newest data for a particular project from its project value.
  func fetchProject(project: Project) -> SignalProducer<Project, ErrorEnvelope>

  /// Fetch a page of activities for a project.
  func fetchProjectActivities(forProject project: Project) ->
    SignalProducer<ProjectActivityEnvelope, ErrorEnvelope>

  /// Fetch a page of activities for a project from a pagination url.
  func fetchProjectActivities(paginationUrl: String) ->
    SignalProducer<ProjectActivityEnvelope, ErrorEnvelope>

  /// Fetch the user's project notifications.
  func fetchProjectNotifications() -> SignalProducer<[ProjectNotification], ErrorEnvelope>

  /// Fetches the projects that the current user is a member of.
  func fetchProjects(member: Bool) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope>

  /// Fetches more projects from a pagination URL.
  func fetchProjects(paginationUrl: String) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope>

  /// Fetches the stats for a particular project.
  func fetchProjectStats(projectId: Int) -> SignalProducer<ProjectStatsEnvelope, ErrorEnvelope>

  /// Fetches a reward for a project and reward id.
  func fetchRewardShippingRules(projectId: Int, rewardId: Int)
    -> SignalProducer<ShippingRulesEnvelope, ErrorEnvelope>

  /// Fetches a survey response belonging to the current user.
  func fetchSurveyResponse(surveyResponseId: Int)
    -> SignalProducer<SurveyResponse, ErrorEnvelope>

  /// Fetches all of the user's unanswered surveys.
  func fetchUnansweredSurveyResponses() -> SignalProducer<[SurveyResponse], ErrorEnvelope>

  /// Fetches an update from its id and project.
  func fetchUpdate(updateId: Int, projectParam: Param) -> SignalProducer<Update, ErrorEnvelope>

  /// Fetches a project update draft.
  func fetchUpdateDraft(forProject project: Project) -> SignalProducer<UpdateDraft, ErrorEnvelope>

  /// Fetches the current user's backed projects.
  func fetchUserProjectsBacked() -> SignalProducer<ProjectsEnvelope, ErrorEnvelope>

  /// Fetches more user backed projects.
  func fetchUserProjectsBacked(paginationUrl url: String) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope>

  /// Fetch the newest data for a particular user.
  func fetchUser(_ user: User) -> SignalProducer<User, ErrorEnvelope>

  /// Fetch a user.
  func fetchUser(userId: Int) -> SignalProducer<User, ErrorEnvelope>

  /// Fetch the logged-in user's data.
  func fetchUserSelf() -> SignalProducer<User, ErrorEnvelope>

  /// Follow all friends of current user.
  func followAllFriends() -> SignalProducer<VoidEnvelope, ErrorEnvelope>

  /// Follow a user with their id.
  func followFriend(userId id: Int) -> SignalProducer<User, ErrorEnvelope>

  /// Increment the video complete stat for a project.
  func incrementVideoCompletion(forProject project: Project) -> SignalProducer<VoidEnvelope, ErrorEnvelope>

  /// Increment the video start stat for a project.
  func incrementVideoStart(forProject project: Project) -> SignalProducer<VoidEnvelope, ErrorEnvelope>

  /// Attempt a login with an email, password and optional code.
  func login(email: String, password: String, code: String?) ->
    SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  /// Attempt a login with Facebook access token and optional code.
  func login(facebookAccessToken: String, code: String?) ->
    SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  /// Marks all the messages in a particular thread as read.
  func markAsRead(messageThread: MessageThread) -> SignalProducer<MessageThread, ErrorEnvelope>

  /// Posts a comment to a project.
  func postComment(_ body: String, toProject project: Project) -> SignalProducer<Comment, ErrorEnvelope>

  /// Posts a comment to an update.
  func postComment(_ body: String, toUpdate update: Update) -> SignalProducer<Comment, ErrorEnvelope>

  /// Returns a project update preview URL.
  func previewUrl(forDraft draft: UpdateDraft) -> URL?

  /// Publishes a project update draft.
  func publish(draft: UpdateDraft) -> SignalProducer<Update, ErrorEnvelope>

  /// Registers a push token.
  func register(pushToken: String) -> SignalProducer<VoidEnvelope, ErrorEnvelope>

  /// Reset user password with email address.
  func resetPassword(email: String) -> SignalProducer<User, ErrorEnvelope>

  /// Searches all of the messages, (optionally) bucketed to a specific project.
  func searchMessages(query: String, project: Project?)
    -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope>

  /// Sends a message to a subject, i.e. creator project, message thread, backer of backing.
  func sendMessage(body: String, toSubject subject: MessageSubject)
    -> SignalProducer<Message, ErrorEnvelope>

  /// Signup with email.
  func signup(name: String, email: String, password: String, passwordConfirmation: String,
              sendNewsletters: Bool) -> SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  /// Signup with Facebook access token and newsletter bool.
  func signup(facebookAccessToken: String, sendNewsletters: Bool) ->
    SignalProducer<AccessTokenEnvelope, ErrorEnvelope>

  /// Star a project.
  func star(_ project: Project) -> SignalProducer<StarEnvelope, ErrorEnvelope>

  func submitApplePay(checkoutUrl: String,
                      stripeToken: String,
                      paymentInstrumentName: String,
                      paymentNetwork: String,
                      transactionIdentifier: String) -> SignalProducer<SubmitApplePayEnvelope, ErrorEnvelope>

  /// Toggle the starred state on a project.
  func toggleStar(_ project: Project) -> SignalProducer<StarEnvelope, ErrorEnvelope>

  /// Unfollow a user with their id.
  func unfollowFriend(userId id: Int) -> SignalProducer<VoidEnvelope, ErrorEnvelope>

  /// Performs the first step of checkout by creating a pledge on the server.
  func updatePledge(project: Project,
                    amount: Double,
                    reward: Reward?,
                    shippingLocation: Location?,
                    tappedReward: Bool) -> SignalProducer<UpdatePledgeEnvelope, ErrorEnvelope>

  /// Update the project notification setting.
  func updateProjectNotification(_ notification: ProjectNotification)
    -> SignalProducer<ProjectNotification, ErrorEnvelope>

  /// Update the current user with settings attributes.
  func updateUserSelf(_ user: User) -> SignalProducer<User, ErrorEnvelope>

  /// Updates the draft of a project update.
  func update(draft: UpdateDraft, title: String, body: String, isPublic: Bool)
    -> SignalProducer<UpdateDraft, ErrorEnvelope>
}

extension ServiceType {
  /// Returns `true` if an oauth token is present, and `false` otherwise.
  public var isAuthenticated: Bool {
    return self.oauthToken != nil
  }
}

public func == (lhs: ServiceType, rhs: ServiceType) -> Bool {
  return
    type(of: lhs) == type(of: rhs) &&
      lhs.serverConfig == rhs.serverConfig &&
      lhs.oauthToken == rhs.oauthToken &&
      lhs.language == rhs.language &&
      lhs.buildVersion == rhs.buildVersion
}

public func != (lhs: ServiceType, rhs: ServiceType) -> Bool {
  return !(lhs == rhs)
}

extension ServiceType {

  /**
   Prepares a URL request to be sent to the server.

   - parameter originalRequest: The request that should be prepared.
   - parameter query:           Additional query params that should be attached to the request.

   - returns: A new URL request that is properly configured for the server.
   */
  public func preparedRequest(forRequest originalRequest: URLRequest, query: [String:Any] = [:])
    -> URLRequest {

      var request = originalRequest
      guard let URL = request.url else {
        return originalRequest
      }

      var headers = self.defaultHeaders

      let method = request.httpMethod?.uppercased()
      // swiftlint:disable:next force_unwrapping
      var components = URLComponents(url: URL, resolvingAgainstBaseURL: false)!
      var queryItems = components.queryItems ?? []
      queryItems.append(contentsOf: self.defaultQueryParams.map(URLQueryItem.init(name:value:)))

      if method == .some("POST") || method == .some("PUT") {
        if request.httpBody == nil {
          headers["Content-Type"] = "application/json; charset=utf-8"
          request.httpBody = try? JSONSerialization.data(withJSONObject: query, options: [])
        }
      } else {
        queryItems.append(
          contentsOf: query
            .flatMap(queryComponents)
            .map(URLQueryItem.init(name:value:))
        )
      }
      components.queryItems = queryItems.sorted { $0.name < $1.name }
      request.url = components.url

      let currentHeaders = request.allHTTPHeaderFields ?? [:]
      request.allHTTPHeaderFields = currentHeaders.withAllValuesFrom(headers)

      return request
  }

  /**
   Prepares a request to be sent to the server.

   - parameter URL:    The URL to turn into a request and prepare.
   - parameter method: The HTTP verb to use for the request.
   - parameter query:  Additional query params that should be attached to the request.

   - returns: A new URL request that is properly configured for the server.
   */
  public func preparedRequest(forURL url: URL, method: Method = .GET, query: [String:Any] = [:])
    -> URLRequest {

      var request = URLRequest(url: url)
      request.httpMethod = method.rawValue
      return self.preparedRequest(forRequest: request, query: query)
  }

  public func isPrepared(request: URLRequest) -> Bool {
    return request.value(forHTTPHeaderField: "Authorization") == authorizationHeader
      && request.value(forHTTPHeaderField: "Kickstarter-iOS-App") != nil
  }

  fileprivate var defaultHeaders: [String:String] {
    var headers: [String:String] = [:]
    headers["Accept-Language"] = self.language
    headers["Authorization"] = self.authorizationHeader
    headers["Kickstarter-App-Id"] = self.appId
    headers["Kickstarter-iOS-App"] = self.buildVersion

    let executable = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String
    let bundleIdentifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String
    let app: String = executable ?? bundleIdentifier ?? "Kickstarter"
    let bundleVersion: String = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
    let model = UIDevice.current.model
    let systemVersion = UIDevice.current.systemVersion
    let scale = UIScreen.main.scale

    headers["User-Agent"] = "\(app)/\(bundleVersion) (\(model); iOS \(systemVersion) Scale/\(scale))"

    return headers
  }

  fileprivate var authorizationHeader: String? {
    if let token = self.oauthToken?.token {
      return "token \(token)"
    } else {
      return self.serverConfig.basicHTTPAuth?.authorizationHeader
    }
  }

  fileprivate var defaultQueryParams: [String:String] {
    var query: [String:String] = [:]
    query["client_id"] = self.serverConfig.apiClientAuth.clientId
    query["currency"] = self.currency
    query["oauth_token"] = self.oauthToken?.token
    return query
  }

  fileprivate func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
    var components: [(String, String)] = []

    if let dictionary = value as? [String:Any] {
      for (nestedKey, value) in dictionary {
        components += queryComponents("\(key)[\(nestedKey)]", value)
      }
    } else if let array = value as? [Any] {
      for value in array {
        components += queryComponents("\(key)[]", value)
      }
    } else {
      components.append((key, String(describing: value)))
    }

    return components
  }
}
// swiftlint:enable file_length
