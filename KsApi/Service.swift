import Apollo
import Combine
import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift
import UIKit

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
  public let deviceIdentifier: String
  public let apolloClient: ApolloClientType?

  public init(
    appId: String = Bundle.main.bundleIdentifier ?? "com.kickstarter.kickstarter",
    serverConfig: ServerConfigType = ServerConfig.production,
    oauthToken: OauthTokenAuthType? = nil,
    language: String = "en",
    currency: String = "USD",
    buildVersion: String = Bundle.main._buildVersion,
    deviceIdentifier: String = UIDevice.current.identifierForVendor.coalesceWith(UUID()).uuidString,
    apolloClient: ApolloClientType? = nil
  ) {
    self.appId = appId
    self.serverConfig = serverConfig
    self.oauthToken = oauthToken
    self.language = language
    self.currency = currency
    self.buildVersion = buildVersion
    self.deviceIdentifier = deviceIdentifier
    /// Dummy client, only required to satisfy `ApolloClientType` protocol, not used.
    self.apolloClient = apolloClient

    // Global override required for injecting custom User-Agent header in ajax requests
    UserDefaults.standard.register(defaults: ["UserAgent": Service.userAgent])

    // Configure GraphQL Client
    GraphQL.shared.configure(
      with: serverConfig.graphQLEndpointUrl,
      headers: self.defaultHeaders,
      additionalHeaders: { [:] }
    )
  }

  public func login(_ oauthToken: OauthTokenAuthType) -> Service {
    return Service(
      appId: self.appId,
      serverConfig: self.serverConfig,
      oauthToken: oauthToken,
      language: self.language,
      buildVersion: self.buildVersion
    )
  }

  public func logout() -> Service {
    return Service(
      appId: self.appId,
      serverConfig: self.serverConfig,
      oauthToken: nil,
      language: self.language,
      buildVersion: self.buildVersion
    )
  }

  public func facebookConnect(facebookAccessToken token: String) -> SignalProducer<User, ErrorEnvelope> {
    return request(.facebookConnect(facebookAccessToken: token))
  }

  public func addImage(file fileURL: URL, toDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Image, ErrorEnvelope> {
    return request(Route.addImage(fileUrl: fileURL, toDraft: draft))
  }

  public func fetch<Q: GraphQLQuery>(query: Q) -> SignalProducer<Q.Data, ErrorEnvelope> {
    GraphQL.shared.client.fetch(query: query)
  }

  public func addNewCreditCard(input: CreatePaymentSourceInput)
    -> SignalProducer<CreatePaymentSourceEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .CreatePaymentSourceMutation(input: GraphAPI.CreatePaymentSourceInput.from(input))
      )
      .flatMap(CreatePaymentSourceEnvelope.producer(from:))
  }

  public func addPaymentSheetPaymentSource(input: CreatePaymentSourceSetupIntentInput)
    -> SignalProducer<CreatePaymentSourceEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .CreatePaymentSourceMutation(input: GraphAPI.CreatePaymentSourceInput.from(input))
      )
      .flatMap(CreatePaymentSourceEnvelope.producer(from:))
  }

  public func triggerThirdPartyEventInput(input: TriggerThirdPartyEventInput)
    -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .TriggerThirdPartyEventMutation(input: GraphAPI.TriggerThirdPartyEventInput.from(input))
      )
      .flatMap { _ in
        SignalProducer(value: EmptyResponseEnvelope())
      }
  }

  public func buildPaymentPlan(
    projectSlug: String,
    pledgeAmount: String
  ) -> SignalProducer<GraphAPI.BuildPaymentPlanQuery.Data, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(query: GraphAPI.BuildPaymentPlanQuery(
        slug: projectSlug,
        amount: pledgeAmount
      ))
  }

  public func cancelBacking(input: CancelBackingInput)
    -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .CancelBackingMutation(input: GraphAPI.CancelBackingInput(id: input.backingId))
      )
      .flatMap { _ in
        SignalProducer(value: EmptyResponseEnvelope())
      }
  }

  public func changeEmail(input: ChangeEmailInput) ->
    SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .UpdateUserAccountMutation(input: GraphAPI.UpdateUserAccountInput.from(input))
      )
      .flatMap { _ in
        SignalProducer(value: EmptyResponseEnvelope())
      }
  }

  public func changePassword(input: ChangePasswordInput) ->
    SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .UpdateUserAccountMutation(input: GraphAPI.UpdateUserAccountInput.from(input))
      )
      .flatMap { _ in
        SignalProducer(value: EmptyResponseEnvelope())
      }
  }

  public func createAttributionEvent(input: GraphAPI.CreateAttributionEventInput) ->
    SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(mutation: GraphAPI.CreateAttributionEventMutation(input: input))
      .flatMap { _ in
        SignalProducer(value: EmptyResponseEnvelope())
      }
  }

  public func createBacking(input: CreateBackingInput) ->
    SignalProducer<CreateBackingEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(mutation: GraphAPI.CreateBackingMutation(input: GraphAPI.CreateBackingInput.from(input)))
      .flatMap(CreateBackingEnvelope.producer(from:))
  }

  public func completeOnSessionCheckout(input: GraphAPI.CompleteOnSessionCheckoutInput) ->
    SignalProducer<GraphAPI.CompleteOnSessionCheckoutMutation.Data, ErrorEnvelope> {
    return GraphQL.shared.client.perform(mutation: GraphAPI.CompleteOnSessionCheckoutMutation(input: input))
  }

  public func createCheckout(input: CreateCheckoutInput) ->
    SignalProducer<CreateCheckoutEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(mutation: GraphAPI.CreateCheckoutMutation(
        input: GraphAPI
          .CreateCheckoutInput(
            projectId: input.projectId,
            amount: input.amount,
            locationId: input.locationId,
            rewardIds: input.rewardIds,
            refParam: input.refParam
          )
      ))
      .flatMap(CreateCheckoutEnvelope.producer(from:))
  }

  public func createFlaggingInput(input: CreateFlaggingInput)
    -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .CreateFlaggingMutation(input: GraphAPI.CreateFlaggingInput.from(input))
      )
      .flatMap { _ in
        SignalProducer(value: EmptyResponseEnvelope())
      }
  }

  public func createFlaggingInputCombine(input: CreateFlaggingInput)
    -> AnyPublisher<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .CreateFlaggingMutation(input: GraphAPI.CreateFlaggingInput.from(input))
      )
      .map { _ in
        EmptyResponseEnvelope()
      }
      .eraseToAnyPublisher()
  }

  public func createPaymentIntentInput(input: CreatePaymentIntentInput) -> ReactiveSwift
    .SignalProducer<PaymentIntentEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .CreatePaymentIntentMutation(input: GraphAPI.CreatePaymentIntentInput(
            projectId: input.projectId,
            amount: input.amountDollars,
            paymentIntentContext: input.paymentIntentContext,
            digitalMarketingAttributed: input.digitalMarketingAttributed,
            checkoutId: input.checkoutId
          ))
      )
      .flatMap(PaymentIntentEnvelope.envelopeProducer(from:))
  }

  public func createPassword(input: CreatePasswordInput)
    -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .UpdateUserAccountMutation(input: GraphAPI.UpdateUserAccountInput.from(input))
      )
      .flatMap { _ in
        SignalProducer(value: EmptyResponseEnvelope())
      }
  }

  public func createStripeSetupIntent(input: CreateSetupIntentInput) ->
    SignalProducer<ClientSecretEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .CreateSetupIntentMutation(input: GraphAPI.CreateSetupIntentInput.from(input))
      )
      .flatMap(ClientSecretEnvelope.envelopeProducer(from:))
  }

  public func clearUserUnseenActivity(input _: EmptyInput)
    -> SignalProducer<ClearUserUnseenActivityEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .ClearUserUnseenActivityMutation(input: GraphAPI.ClearUserUnseenActivityInput())
      )
      .flatMap(ClearUserUnseenActivityEnvelope.producer(from:))
  }

  public func deletePaymentMethod(input: PaymentSourceDeleteInput)
    -> SignalProducer<DeletePaymentMethodEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .DeletePaymentSourceMutation(input: GraphAPI.PaymentSourceDeleteInput.from(input))
      )
      .flatMap(DeletePaymentMethodEnvelope.producer(from:))
  }

  public func changeCurrency(input: ChangeCurrencyInput) ->
    SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .UpdateUserProfileMutation(input: GraphAPI.UpdateUserProfileInput.from(input))
      )
      .flatMap { _ in
        SignalProducer(value: EmptyResponseEnvelope())
      }
  }

  public func delete(image: UpdateDraft.Image, fromDraft draft: UpdateDraft)
    -> SignalProducer<UpdateDraft.Image, ErrorEnvelope> {
    return request(.deleteImage(image, fromDraft: draft))
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
      .update
    ]
    return request(.activities(categories: categories, count: count))
  }

  public func fetchActivities(paginationUrl: String)
    -> SignalProducer<ActivityEnvelope, ErrorEnvelope> {
    return requestPaginationDecodable(paginationUrl)
  }

  // FIXME: Should be able to convert this to Apollo as it uses /v1 but check its' use cases first.
  public func fetchBacking(forProject project: Project, forUser user: User)
    -> SignalProducer<Backing, ErrorEnvelope> {
    return request(.backing(projectId: project.id, backerId: user.id))
  }

  public func fetchProjectComments(
    slug: String,
    cursor: String?,
    limit: Int?,
    withStoredCards: Bool
  ) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(query: GraphAPI.FetchProjectCommentsQuery(
        slug: slug,
        cursor: cursor,
        limit: limit,
        withStoredCards: withStoredCards
      ))
      .flatMap(CommentsEnvelope.envelopeProducer(from:))
  }

  public func fetchUpdateComments(
    id: String,
    cursor: String?,
    limit: Int?,
    withStoredCards: Bool
  ) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(query: GraphAPI.FetchUpdateCommentsQuery(
        postId: id,
        cursor: cursor,
        limit: limit,
        withStoredCards: withStoredCards
      ))
      .flatMap(CommentsEnvelope.envelopeProducer(from:))
  }

  public func fetchCommentReplies(
    id: String,
    cursor: String?,
    limit: Int,
    withStoredCards: Bool
  )
    -> SignalProducer<CommentRepliesEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(query: GraphAPI.FetchCommentRepliesQuery(
        commentId: id,
        cursor: cursor,
        limit: limit,
        withStoredCards: withStoredCards
      ))
      .flatMap(CommentRepliesEnvelope.envelopeProducer(from:))
  }

  public func fetchConfig() -> SignalProducer<Config, ErrorEnvelope> {
    return request(.config)
  }

  public func fetchDiscovery(paginationUrl: String)
    -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope> {
    return requestPaginationDecodable(paginationUrl)
  }

  public func fetchDiscovery(params: DiscoveryParams)
    -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope> {
    return request(.discover(params))
  }

  public func fetchDiscovery_combine(paginationUrl: String)
    -> AnyPublisher<DiscoveryEnvelope, ErrorEnvelope> {
    return requestPaginationDecodable(paginationUrl)
  }

  public func fetchDiscovery_combine(params: DiscoveryParams)
    -> AnyPublisher<DiscoveryEnvelope, ErrorEnvelope> {
    return request(.discover(params))
  }

  public func fetchFriends() -> SignalProducer<FindFriendsEnvelope, ErrorEnvelope> {
    return request(.friends)
  }

  public func fetchFriends(paginationUrl: String)
    -> SignalProducer<FindFriendsEnvelope, ErrorEnvelope> {
    return requestPaginationDecodable(paginationUrl)
  }

  public func fetchFriendStats() -> SignalProducer<FriendStatsEnvelope, ErrorEnvelope> {
    return request(.friendStats)
  }

  public func fetchGraphCategories()
    -> SignalProducer<RootCategoriesEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(query: GraphAPI.FetchRootCategoriesQuery())
      .flatMap(RootCategoriesEnvelope.envelopeProducer(from:))
  }

  public func fetchGraphCategory(id: String)
    -> SignalProducer<CategoryEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(query: GraphAPI.FetchCategoryQuery(id: id))
      .flatMap(CategoryEnvelope.envelopeProducer(from:))
  }

  public func fetchGraphUser(withStoredCards: Bool)
    -> SignalProducer<UserEnvelope<GraphUser>, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(query: GraphAPI.FetchUserQuery(withStoredCards: withStoredCards))
      .flatMap(UserEnvelope<GraphUser>.envelopeProducer(from:))
  }

  public func fetchGraphUserEmail()
    -> SignalProducer<UserEnvelope<GraphUserEmail>, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(query: GraphAPI.FetchUserEmailQuery())
      .flatMap(UserEnvelope<GraphUserEmail>.envelopeProducer(from:))
  }

  public func fetchGraphUserEmailCombine()
    -> AnyPublisher<UserEnvelope<GraphUserEmail>, ErrorEnvelope> {
    GraphQL.shared.client
      .fetch(query: GraphAPI.FetchUserEmailQuery())
      .mapFetchResults { (data: GraphAPI.FetchUserEmailQuery.Data) -> UserEnvelope<GraphUserEmail>? in
        UserEnvelope<GraphUserEmail>.userEnvelope(from: data)
      }
  }

  public func fetchGraphUserSetup()
    -> SignalProducer<UserEnvelope<GraphUserSetup>, ErrorEnvelope> {
    GraphQL.shared.client
      .fetch(query: GraphAPI.FetchUserSetupQuery())
      .flatMap(UserEnvelope<GraphUserSetup>.envelopeProducer(from:))
  }

  public func fetchGraphUserSetupCombine()
    -> AnyPublisher<UserEnvelope<GraphUserSetup>, ErrorEnvelope> {
    GraphQL.shared.client
      .fetch(query: GraphAPI.FetchUserSetupQuery())
      .mapFetchResults { (data: GraphAPI.FetchUserSetupQuery.Data) -> UserEnvelope<GraphUserSetup>? in
        UserEnvelope<GraphUserSetup>.userEnvelope(from: data)
      }
  }

  public func fetchGraphUserSelf()
    -> SignalProducer<UserEnvelope<User>, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(query: GraphAPI.FetchUserQuery(withStoredCards: false))
      .flatMap(UserEnvelope<User>.envelopeProducer(from:))
  }

  public func fetchErroredUserBackings(status: BackingState)
    -> SignalProducer<ErroredBackingsEnvelope, ErrorEnvelope> {
    guard let status = GraphAPI.BackingState.from(status)
    else { return SignalProducer(error: .couldNotParseJSON) }

    return GraphQL.shared.client
      .fetch(
        query: GraphAPI
          .FetchUserBackingsQuery(
            status: status,
            withStoredCards: false,
            includeShippingRules: true,
            includeLocalPickup: false
          )
      )
      .flatMap(ErroredBackingsEnvelope.producer(from:))
  }

  public func fetchBacking(id: Int, withStoredCards: Bool)
    -> SignalProducer<ProjectAndBackingEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(
        query: GraphAPI
          .FetchBackingQuery(
            id: "\(id)",
            withStoredCards: withStoredCards,
            includeShippingRules: true,
            includeLocalPickup: true
          )
      )
      .flatMap(ProjectAndBackingEnvelope.envelopeProducer(from:))
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
    return requestPaginationDecodable(paginationUrl)
  }

  /**
    Use case:
   - `ProjectPageViewModel`

   This is the only use case at the moment as it effects the `ProjectPageViewController` directly.
   */
  public func fetchProject(projectParam: Param, configCurrency: String?)
    -> SignalProducer<Project.ProjectPamphletData, ErrorEnvelope> {
    switch (projectParam.id, projectParam.slug) {
    case let (.some(projectId), _):
      let query = GraphAPI
        .FetchProjectByIdQuery(projectId: projectId, withStoredCards: false)

      return GraphQL.shared.client
        .fetch(query: query)
        .flatMap { Project.projectProducer(from: $0, configCurrency: configCurrency) }
    case let (_, .some(projectSlug)):
      let query = GraphAPI
        .FetchProjectBySlugQuery(slug: projectSlug, withStoredCards: false)

      return GraphQL.shared.client
        .fetch(query: query)
        .flatMap { Project.projectProducer(from: $0, configCurrency: configCurrency) }
    default:
      return .empty
    }
  }

  /**
    Use cases:
   - `ManagePledgeViewModel`
   - `CommentsViewModel`
   - `UpdateViewModel`
   - `UpdatePreviewViewModel`
   - `AppDelegateViewModel`

   Eventually this v1 network request can be replaced with `fetchProject(projectParam:)` if we refactor the use cases above in the future.
   */
  public func fetchProject(param: Param) -> SignalProducer<Project, ErrorEnvelope> {
    return request(.project(param))
  }

  public func fetchProjectRewards(projectId: Int)
    -> SignalProducer<[Reward], ErrorEnvelope> {
    let query = GraphAPI
      .FetchProjectRewardsByIdQuery(
        projectId: projectId,
        includeShippingRules: true,
        includeLocalPickup: true
      )

    return GraphQL.shared.client
      .fetch(query: query)
      .flatMap(Project.projectRewardsProducer(from:))
  }

  public func fetchProjectFriends(param: Param) -> SignalProducer<[User], ErrorEnvelope> {
    switch (param.id, param.slug) {
    case let (.some(projectId), _):
      let query = GraphAPI.FetchProjectFriendsByIdQuery(projectId: projectId, withStoredCards: false)

      return GraphQL.shared.client
        .fetch(query: query)
        .flatMap(Project.projectFriendsProducer(from:))
    case let (_, .some(projectSlug)):
      let query = GraphAPI.FetchProjectFriendsBySlugQuery(slug: projectSlug, withStoredCards: false)

      return GraphQL.shared.client
        .fetch(query: query)
        .flatMap(Project.projectFriendsProducer(from:))
    default:
      return .empty
    }
  }

  public func fetchProject(_ params: DiscoveryParams) -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope> {
    return request(.discover(params |> DiscoveryParams.lens.perPage .~ 1))
  }

  public func fetchProject(project: Project) -> SignalProducer<Project, ErrorEnvelope> {
    return request(.project(.id(project.id)))
  }

  public func fetchProject_combine(project: Project) -> AnyPublisher<Project, ErrorEnvelope> {
    return request(.project(.id(project.id)))
  }

  public func fetchProjectActivities(forProject project: Project) ->
    SignalProducer<ProjectActivityEnvelope, ErrorEnvelope> {
    return request(.projectActivities(project))
  }

  public func fetchProjectActivities(paginationUrl: String)
    -> SignalProducer<ProjectActivityEnvelope, ErrorEnvelope> {
    return requestPaginationDecodable(paginationUrl)
  }

  public func fetchProjectNotifications() -> SignalProducer<[ProjectNotification], ErrorEnvelope> {
    return request(.projectNotifications)
  }

  public func fetchProjects(member: Bool) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope> {
    return request(.projects(member: member))
  }

  public func fetchProjects(paginationUrl url: String) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope> {
    return requestPaginationDecodable(url)
  }

  public func fetchProjectStats(projectId: Int) ->
    SignalProducer<ProjectStatsEnvelope, ErrorEnvelope> {
    return request(.projectStats(projectId: projectId))
  }

  public func fetchRewardAddOnsSelectionViewRewards(
    slug: String,
    shippingEnabled: Bool,
    locationId: String?
  ) -> SignalProducer<Project, ErrorEnvelope> {
    let query = GraphAPI.FetchAddOnsQuery(
      projectSlug: slug,
      shippingEnabled: shippingEnabled,
      locationId: locationId,
      withStoredCards: false,
      includeShippingRules: true,
      includeLocalPickup: true
    )

    return GraphQL.shared.client
      .fetch(query: query)
      .flatMap(Project.projectProducer(from:))
  }

  public func fetchBackedProjects(
    cursor: String? = nil,
    limit: Int? = nil
  ) -> SignalProducer<FetchProjectsEnvelope, ErrorEnvelope> {
    let query = GraphAPI.FetchMyBackedProjectsQuery(first: limit, after: cursor)

    return GraphQL.shared.client
      .fetch(query: query)
      .flatMap(FetchProjectsEnvelope.fetchProjectsEnvelope(from:))
  }

  public func fetchSavedProjects(
    cursor: String? = nil,
    limit: Int? = nil
  ) -> SignalProducer<FetchProjectsEnvelope, ErrorEnvelope> {
    let query = GraphAPI.FetchMySavedProjectsQuery(first: limit, after: cursor)

    return GraphQL.shared.client
      .fetch(query: query)
      .flatMap(FetchProjectsEnvelope.fetchProjectsEnvelope(from:))
  }

  public func fetchRewardShippingRules(projectId: Int, rewardId: Int)
    -> SignalProducer<ShippingRulesEnvelope, ErrorEnvelope> {
    return request(.shippingRules(projectId: projectId, rewardId: rewardId))
  }

  public func fetchSurveyResponse(surveyResponseId id: Int) -> SignalProducer<SurveyResponse, ErrorEnvelope> {
    return request(.surveyResponse(surveyResponseId: id))
  }

  public func fetchUserSelf() -> SignalProducer<User, ErrorEnvelope> {
    return request(.userSelf)
  }

  public func fetchUserSelf_combine(withOAuthToken token: String) -> AnyPublisher<User, ErrorEnvelope> {
    return requestWithAuthentication(.userSelf, oauthToken: token)
  }

  public func fetchUser(userId: Int) -> SignalProducer<User, ErrorEnvelope> {
    return request(.user(userId: userId))
  }

  public func fetchUser(_ user: User) -> SignalProducer<User, ErrorEnvelope> {
    return self.fetchUser(userId: user.id)
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

  public func exchangeTokenForOAuthToken(params: OAuthTokenExchangeParams)
    -> AnyPublisher<OAuthTokenExchangeResponse, ErrorEnvelope> {
    return request(.exchangeToken(params: params))
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

  public func incrementVideoCompletion(forProject project: any HasServiceProjectWebURL) ->
    SignalProducer<VoidEnvelope, ErrorEnvelope> {
    let producer = request(.incrementVideoCompletion(project: project.serviceProjectWebURL))
      as SignalProducer<VoidEnvelope, ErrorEnvelope>

    return producer
      .flatMapError { env -> SignalProducer<VoidEnvelope, ErrorEnvelope> in
        if env.ksrCode == .ErrorEnvelopeJSONParsingFailed {
          return .init(value: VoidEnvelope())
        }
        return .init(error: env)
      }
  }

  public func incrementVideoStart(forProject project: any HasServiceProjectWebURL) ->
    SignalProducer<VoidEnvelope, ErrorEnvelope> {
    let producer = request(.incrementVideoStart(project: project.serviceProjectWebURL))
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

  public func postComment(input: PostCommentInput)
    -> SignalProducer<Comment, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .PostCommentMutation(input: GraphAPI.PostCommentInput.from(input))
      )
      .flatMap(PostCommentEnvelope.producer(from:))
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

  public func sendVerificationEmail(input _: EmptyInput) ->
    SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(
        mutation: GraphAPI
          .UserSendEmailVerificationMutation(input: GraphAPI.UserSendEmailVerificationInput())
      )
      .flatMap { _ in
        SignalProducer(value: EmptyResponseEnvelope())
      }
  }

  public func signInWithApple(input: SignInWithAppleInput)
    -> SignalProducer<SignInWithAppleEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(mutation: GraphAPI.SignInWithAppleMutation(input: GraphAPI.SignInWithAppleInput.from(input)))
      .flatMap(SignInWithAppleEnvelope.producer(from:))
  }

  public func signup(facebookAccessToken token: String, sendNewsletters: Bool) ->
    SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {
    return request(.facebookSignup(facebookAccessToken: token, sendNewsletters: sendNewsletters))
  }

  public func unfollowFriend(userId id: Int) -> SignalProducer<VoidEnvelope, ErrorEnvelope> {
    return request(.unfollowFriend(userId: id))
  }

  public func updateBacking(input: UpdateBackingInput)
    -> SignalProducer<UpdateBackingEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(mutation: GraphAPI.UpdateBackingMutation(input: GraphAPI.UpdateBackingInput.from(input)))
      .flatMap(UpdateBackingEnvelope.producer(from:))
  }

  public func update(draft: UpdateDraft, title: String, body: String, isPublic: Bool)
    -> SignalProducer<UpdateDraft, ErrorEnvelope> {
    return request(.updateUpdateDraft(draft, title: title, body: body, isPublic: isPublic))
  }

  public func updateProjectNotification(_ notification: ProjectNotification)
    -> SignalProducer<ProjectNotification, ErrorEnvelope> {
    return request(.updateProjectNotification(notification: notification))
  }

  public func updateUserSelf(_ user: User) -> SignalProducer<User, ErrorEnvelope> {
    return request(.updateUserSelf(user))
  }

  public func unwatchProject(input: WatchProjectInput) ->
    SignalProducer<WatchProjectResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(mutation: GraphAPI.UnwatchProjectMutation(input: GraphAPI.UnwatchProjectInput.from(input)))
      .flatMap(WatchProjectResponseEnvelope.producer(from:))
  }

  public func verifyEmail(withToken token: String)
    -> SignalProducer<EmailVerificationResponseEnvelope, ErrorEnvelope> {
    request(.verifyEmail(accessToken: token))
  }

  public func watchProject(input: WatchProjectInput) ->
    SignalProducer<WatchProjectResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(mutation: GraphAPI.WatchProjectMutation(input: GraphAPI.WatchProjectInput.from(input)))
      .flatMap(WatchProjectResponseEnvelope.producer(from:))
  }

  public func blockUser(input: BlockUserInput)
    -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .perform(mutation: GraphAPI.BlockUserMutation(input: GraphAPI.BlockUserInput.from(input)))
      .flatMap { _ in
        SignalProducer(value: EmptyResponseEnvelope())
      }
  }

  /**
   Post Campaign Pledge Validation.
   - parameter checkoutId: The Checkout Id..
   - parameter paymentSourceId: The id of the payment source.
   - parameter paymentIntentClientSecret: The client secret returned from our CreatePaymentIntent Mutation.
   */
  public func validateCheckout(
    checkoutId: String,
    paymentSourceId: String,
    paymentIntentClientSecret: String
  ) -> SignalProducer<ValidateCheckoutEnvelope, ErrorEnvelope> {
    return GraphQL.shared.client
      .fetch(query: GraphAPI.ValidateCheckoutQuery(
        checkoutId: checkoutId,
        paymentSourceId: paymentSourceId,
        paymentIntentClientSecret: paymentIntentClientSecret
      ))
      .flatMap(ValidateCheckoutEnvelope.envelopeProducer(from:))
  }

  public func confirmBackingAddress(
    backingId: String,
    addressId: String
  ) -> AnyPublisher<Bool, ErrorEnvelope> {
    let input = GraphAPI.CreateOrUpdateBackingAddressInput(backingId: backingId, addressId: addressId)
    let mutation = GraphAPI.CreateOrUpdateBackingAddressMutation(input: input)
    return GraphQL.shared.client
      .perform(mutation: mutation)
      .map { data in
        data.createOrUpdateBackingAddress?.success ?? false
      }
      .eraseToAnyPublisher()
  }

  public func fetchPledgedProjects(
    cursor: String? = nil,
    limit: Int? = nil
  ) -> AnyPublisher<GraphAPI.FetchPledgedProjectsQuery.Data, ErrorEnvelope> {
    GraphQL.shared.client
      .fetch(query: GraphAPI.FetchPledgedProjectsQuery(first: limit, after: cursor))
      .eraseToAnyPublisher()
  }
}
