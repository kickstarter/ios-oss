import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift

public extension Bundle {
  var _buildVersion: String {
    return (self.infoDictionary?["CFBundleVersion"] as? String) ?? "1"
  }
}

/**
 A `ServerType` that requests data from an API webservice.
 */
public struct Service: ServiceType {
  public let appId: String
  public let serverConfig: ServerConfigType
  public let oauthToken: OauthTokenAuthType?
  public let language: String
  public let currency: String
  public let buildVersion: String

  public init(appId: String = Bundle.main.bundleIdentifier ?? "com.kickstarter.kickstarter",
              serverConfig: ServerConfigType = ServerConfig.production,
              oauthToken: OauthTokenAuthType? = nil,
              language: String = "en",
              currency: String = "USD",
              buildVersion: String = Bundle.main._buildVersion) {

    self.appId = appId
    self.serverConfig = serverConfig
    self.oauthToken = oauthToken
    self.language = language
    self.currency = currency
    self.buildVersion = buildVersion
  }

  public func login(_ oauthToken: OauthTokenAuthType) -> Service {
    return Service(appId: self.appId,
                   serverConfig: self.serverConfig,
                   oauthToken: oauthToken,
                   language: self.language,
                   buildVersion: self.buildVersion)
  }

  public func logout() -> Service {
    return Service(appId: self.appId,
                   serverConfig: self.serverConfig,
                   oauthToken: nil,
                   language: self.language,
                   buildVersion: self.buildVersion)
  }

  public func facebookConnect(facebookAccessToken token: String) -> SignalProducer<User, ErrorEnvelope> {
    return request(.facebookConnect(facebookAccessToken: token))
  }

  public func addImage(file fileURL: URL, toDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Image, ErrorEnvelope> {
      return request(Route.addImage(fileUrl: fileURL, toDraft: draft))
  }

  public func addVideo(file fileURL: URL, toDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Video, ErrorEnvelope> {

      return request(Route.addVideo(fileUrl: fileURL, toDraft: draft))
  }

  public func changeEmail(input: ChangeEmailInput) ->
    SignalProducer<GraphMutationEmptyResponseEnvelope, GraphError> {
      return applyMutation(mutation: UpdateUserAccountMutation(input: input))
  }

  public func changePassword(input: ChangePasswordInput) ->
    SignalProducer<GraphMutationEmptyResponseEnvelope, GraphError> {
      return applyMutation(mutation: UpdateUserAccountMutation(input: input))
  }

  public func changePaymentMethod(project: Project)
    -> SignalProducer<ChangePaymentMethodEnvelope, ErrorEnvelope> {

      return request(.changePaymentMethod(project: project))
  }

  public func createPledge(project: Project,
                           amount: Double,
                           reward: Reward?,
                           shippingLocation: Location?,
                           tappedReward: Bool) -> SignalProducer<CreatePledgeEnvelope, ErrorEnvelope> {
    return request(
      .createPledge(
        project: project,
        amount: amount,
        reward: reward,
        shippingLocation: shippingLocation,
        tappedReward: tappedReward
      )
    )
  }

  public func delete(image: UpdateDraft.Image, fromDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Image, ErrorEnvelope> {

      return request(.deleteImage(image, fromDraft: draft))
  }

  public func delete(video: UpdateDraft.Video, fromDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Video, ErrorEnvelope> {

      return request(.deleteVideo(video, fromDraft: draft))
  }

  public func exportData() -> SignalProducer<VoidEnvelope, ErrorEnvelope> {
    return request(.exportData)
  }

  public func exportDataState()
    -> SignalProducer<ExportDataEnvelope, ErrorEnvelope> {
      return request(.exportDataState)
  }

  public func previewUrl(forDraft draft: UpdateDraft) -> URL? {
    return self.serverConfig.apiBaseUrl
      .appendingPathComponent("/v1/projects/\(draft.update.projectId)/updates/draft/preview")
  }

  public func fetchActivities(count: Int?) -> SignalProducer<ActivityEnvelope, ErrorEnvelope> {
    let categories: [Activity.Category] = [
      .backing,
      .cancellation,
      .failure,
      .follow,
      .launch,
      .success,
      .update,
      ]
    return request(.activities(categories: categories, count: count))
  }

  public func fetchActivities(paginationUrl: String)
    -> SignalProducer<ActivityEnvelope, ErrorEnvelope> {
      return requestPagination(paginationUrl)
  }

  public func fetchBacking(forProject project: Project, forUser user: User)
    -> SignalProducer<Backing, ErrorEnvelope> {
      return request(.backing(projectId: project.id, backerId: user.id))
  }

  public func fetchCheckout(checkoutUrl url: String) -> SignalProducer<CheckoutEnvelope, ErrorEnvelope> {
    return request(.checkout(url))
  }

  public func fetchComments(paginationUrl url: String) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
    return requestPagination(url)
  }

  public func fetchComments(project: Project) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
    return request(.projectComments(project))
  }

  public func fetchComments(update: Update) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
    return request(.updateComments(update))
  }

  public func fetchConfig() -> SignalProducer<Config, ErrorEnvelope> {
    return request(.config)
  }

  public func fetchDiscovery(paginationUrl: String)
    -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope> {

      return requestPagination(paginationUrl)
  }

  public func fetchDiscovery(params: DiscoveryParams)
    -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope> {

      return request(.discover(params))
  }

  public func fetchFriends() -> SignalProducer<FindFriendsEnvelope, ErrorEnvelope> {
    return request(.friends)
  }

  public func fetchFriends(paginationUrl: String)
    -> SignalProducer<FindFriendsEnvelope, ErrorEnvelope> {

      return requestPagination(paginationUrl)
  }

  public func fetchFriendStats() -> SignalProducer<FriendStatsEnvelope, ErrorEnvelope> {
    return request(.friendStats)
  }

  public func fetchGraphCategories(query: NonEmptySet<Query>)
    -> SignalProducer<RootCategoriesEnvelope, GraphError> {
      return fetch(query: query)
  }

  public func fetchGraphCategory(query: NonEmptySet<Query>)
    -> SignalProducer<CategoryEnvelope, GraphError> {
      return fetch(query: query)
  }

  public func fetchGraphCurrency(query: NonEmptySet<Query>)
    -> SignalProducer<UserEnvelope<UserCurrency>, GraphError> {
      return fetch(query: query)
  }

  public func fetchGraphUserEmail(query: NonEmptySet<Query>)
    -> SignalProducer<UserEnvelope<GraphUserEmail>, GraphError> {
      return fetch(query: query)
  }

  public func fetchMessageThread(messageThreadId: Int)
    -> SignalProducer<MessageThreadEnvelope, ErrorEnvelope> {

      return request(.messagesForThread(messageThreadId: messageThreadId))
  }

  public func fetchMessageThread(backing: Backing)
    -> SignalProducer<MessageThreadEnvelope?, ErrorEnvelope> {
      return request(.messagesForBacking(backing))
  }

  public func fetchMessageThreads(mailbox: Mailbox, project: Project?)
    -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope> {

      return request(.messageThreads(mailbox: mailbox, project: project))
  }

  public func fetchMessageThreads(paginationUrl: String)
    -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope> {

      return requestPagination(paginationUrl)
  }

  public func fetchProject(param: Param) -> SignalProducer<Project, ErrorEnvelope> {
    return request(.project(param))
  }

  public func fetchProject(_ params: DiscoveryParams) -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope> {
    return request(.discover(params |> DiscoveryParams.lens.perPage .~ 1))
  }

  public func fetchProject(project: Project) -> SignalProducer<Project, ErrorEnvelope> {
    return request(.project(.id(project.id)))
  }

  public func fetchProjectNotifications() -> SignalProducer<[ProjectNotification], ErrorEnvelope> {
    return request(.projectNotifications)
  }

  public func fetchProjectActivities(forProject project: Project) ->
    SignalProducer<ProjectActivityEnvelope, ErrorEnvelope> {
      return request(.projectActivities(project))
  }

  public func fetchProjectActivities(paginationUrl: String)
    -> SignalProducer<ProjectActivityEnvelope, ErrorEnvelope> {
      return requestPagination(paginationUrl)
  }

  public func fetchProjects(member: Bool) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope> {
    return request(.projects(member: member))
  }

  public func fetchProjects(paginationUrl url: String) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope> {
    return requestPagination(url)
  }

  public func fetchProjectStats(projectId: Int) ->
    SignalProducer<ProjectStatsEnvelope, ErrorEnvelope> {
      return request(.projectStats(projectId: projectId))
  }

  public func fetchRewardShippingRules(projectId: Int, rewardId: Int)
    -> SignalProducer<ShippingRulesEnvelope, ErrorEnvelope> {
      return request(.shippingRules(projectId: projectId, rewardId: rewardId))
  }

  public func fetchSurveyResponse(surveyResponseId id: Int) -> SignalProducer<SurveyResponse, ErrorEnvelope> {
    return request(.surveyResponse(surveyResponseId: id))
  }

  public func fetchUserProjectsBacked() -> SignalProducer<ProjectsEnvelope, ErrorEnvelope> {
    return request(.userProjectsBacked)
  }

  public func fetchUserProjectsBacked(paginationUrl url: String)
    -> SignalProducer<ProjectsEnvelope, ErrorEnvelope> {
      return requestPagination(url)
  }

  public func fetchUserSelf() -> SignalProducer<User, ErrorEnvelope> {
    return request(.userSelf)
  }

  public func fetchUser(userId: Int) -> SignalProducer<User, ErrorEnvelope> {
    return request(.user(userId: userId))
  }

  public func fetchUser(_ user: User) -> SignalProducer<User, ErrorEnvelope> {
    return fetchUser(userId: user.id)
  }

  public func fetchUpdate(updateId: Int, projectParam: Param)
    -> SignalProducer<Update, ErrorEnvelope> {

      return request(.update(updateId: updateId, projectParam: projectParam))
  }

  public func fetchUpdateDraft(forProject project: Project) -> SignalProducer<UpdateDraft, ErrorEnvelope> {
    return request(.fetchUpdateDraft(forProject: project))
  }

  public func fetchUnansweredSurveyResponses() -> SignalProducer<[SurveyResponse], ErrorEnvelope> {
    return request(.unansweredSurveyResponses)
  }

  public func backingUpdate(forProject project: Project, forUser user: User, received: Bool) ->
    SignalProducer<Backing, ErrorEnvelope> {
      return request(.backingUpdate(projectId: project.id, backerId: user.id, received: received))
  }

  public func followAllFriends() -> SignalProducer<VoidEnvelope, ErrorEnvelope> {
    return request(.followAllFriends)
  }

  public func followFriend(userId id: Int) -> SignalProducer<User, ErrorEnvelope> {
    return request(.followFriend(userId: id))
  }

  public func incrementVideoCompletion(forProject project: Project) ->
    SignalProducer<VoidEnvelope, ErrorEnvelope> {

      let producer = request(.incrementVideoCompletion(project: project))
        as SignalProducer<VoidEnvelope, ErrorEnvelope>

      return producer
        .flatMapError { env -> SignalProducer<VoidEnvelope, ErrorEnvelope> in
          if env.ksrCode == .ErrorEnvelopeJSONParsingFailed {
            return .init(value: VoidEnvelope())
          }
          return .init(error: env)
      }
  }

  public func incrementVideoStart(forProject project: Project) ->
    SignalProducer<VoidEnvelope, ErrorEnvelope> {

      let producer = request(.incrementVideoStart(project: project))
        as SignalProducer<VoidEnvelope, ErrorEnvelope>

      return producer
        .flatMapError { env -> SignalProducer<VoidEnvelope, ErrorEnvelope> in
          if env.ksrCode == .ErrorEnvelopeJSONParsingFailed {
            return .init(value: VoidEnvelope())
          }
          return .init(error: env)
      }
  }

  public func login(email: String, password: String, code: String?) ->
    SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {

      return request(.login(email: email, password: password, code: code))
  }

  public func login(facebookAccessToken: String, code: String?) ->
    SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {

      return request(.facebookLogin(facebookAccessToken: facebookAccessToken, code: code))
  }

  public func markAsRead(messageThread: MessageThread) -> SignalProducer<MessageThread, ErrorEnvelope> {
    return request(.markAsRead(messageThread))
  }

  public func postComment(_ body: String, toProject project: Project) ->
    SignalProducer<Comment, ErrorEnvelope> {

      return request(.postProjectComment(project, body: body))
  }

  public func postComment(_ body: String, toUpdate update: Update) -> SignalProducer<Comment, ErrorEnvelope> {

    return request(.postUpdateComment(update, body: body))
  }

  public func publish(draft: UpdateDraft) -> SignalProducer<Update, ErrorEnvelope> {
    return request(.publishUpdateDraft(draft))
  }

  public func register(pushToken: String) -> SignalProducer<VoidEnvelope, ErrorEnvelope> {

    return request(.registerPushToken(pushToken))
  }

  public func resetPassword(email: String) -> SignalProducer<User, ErrorEnvelope> {
    return request(.resetPassword(email: email))
  }

  public func searchMessages(query: String, project: Project?)
    -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope> {

      return request(.searchMessages(query: query, project: project))
  }

  public func sendMessage(body: String, toSubject subject: MessageSubject)
    -> SignalProducer<Message, ErrorEnvelope> {

      return request(.sendMessage(body: body, messageSubject: subject))
  }

  public func signup(name: String,
                     email: String,
                     password: String,
                     passwordConfirmation: String,
                     sendNewsletters: Bool) -> SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {
    return request(.signup(name: name,
                           email: email,
                           password: password,
                           passwordConfirmation: passwordConfirmation,
                           sendNewsletters: sendNewsletters))
  }

  public func signup(facebookAccessToken token: String, sendNewsletters: Bool) ->
    SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {

      return request(.facebookSignup(facebookAccessToken: token, sendNewsletters: sendNewsletters))
  }

  public func star(_ project: Project) -> SignalProducer<StarEnvelope, ErrorEnvelope> {
    return request(.star(project))
  }

  public func submitApplePay(
    checkoutUrl: String,
    stripeToken: String,
    paymentInstrumentName: String,
    paymentNetwork: String,
    transactionIdentifier: String) -> SignalProducer<SubmitApplePayEnvelope, ErrorEnvelope> {

    return request(
      .submitApplePay(
        checkoutUrl: checkoutUrl,
        stripeToken: stripeToken,
        paymentInstrumentName: paymentInstrumentName,
        paymentNetwork: paymentNetwork,
        transactionIdentifier: transactionIdentifier
      )
    )
  }

  public func toggleStar(_ project: Project) -> SignalProducer<StarEnvelope, ErrorEnvelope> {
    return request(.toggleStar(project))
  }

  public func unfollowFriend(userId id: Int) -> SignalProducer<VoidEnvelope, ErrorEnvelope> {
    return request(.unfollowFriend(userId: id))
  }

  public func update(draft: UpdateDraft, title: String, body: String, isPublic: Bool)
    -> SignalProducer<UpdateDraft, ErrorEnvelope> {

      return request(.updateUpdateDraft(draft, title: title, body: body, isPublic: isPublic))
  }

  public func updatePledge(project: Project,
                           amount: Double,
                           reward: Reward?,
                           shippingLocation: Location?,
                           tappedReward: Bool) -> SignalProducer<UpdatePledgeEnvelope, ErrorEnvelope> {

    return request(
      .updatePledge(
        project: project,
        amount: amount,
        reward: reward,
        shippingLocation: shippingLocation,
        tappedReward: tappedReward
      )
    )
  }

  public func updateProjectNotification(_ notification: ProjectNotification)
    -> SignalProducer<ProjectNotification, ErrorEnvelope> {

      return request(.updateProjectNotification(notification: notification))
  }

  public func updateUserSelf(_ user: User) -> SignalProducer<User, ErrorEnvelope> {
    return request(.updateUserSelf(user))
  }
}
