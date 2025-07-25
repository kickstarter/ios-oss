#if DEBUG
  import Apollo
  import Combine
  import Foundation
  import GraphAPI
  import Prelude
  import ReactiveSwift

  internal struct MockService: ServiceType {
    internal let apolloClient: ApolloClientType?
    internal let appId: String
    internal let serverConfig: ServerConfigType
    internal let oauthToken: OauthTokenAuthType?
    internal let language: String
    internal let currency: String
    internal let buildVersion: String
    internal let deviceIdentifier: String

    fileprivate let addNewCreditCardResult: Result<CreatePaymentSourceEnvelope, ErrorEnvelope>?

    fileprivate let addPaymentSheetPaymentSourceResult: Result<CreatePaymentSourceEnvelope, ErrorEnvelope>?

    fileprivate let addUserToSecretRewardGroup: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let blockUserResult: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let buildPaymentPlanResult: Result<GraphAPI.BuildPaymentPlanQuery.Data, ErrorEnvelope>?

    fileprivate let cancelBackingResult: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let changeCurrencyResult: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let changeEmailResult: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let changePasswordResult: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let createAttributionEventResult: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let createBackingResult: Result<CreateBackingEnvelope, ErrorEnvelope>?

    fileprivate let completeOnSessionCheckoutResult: Result<
      GraphAPI.CompleteOnSessionCheckoutMutation.Data,
      ErrorEnvelope
    >?

    fileprivate let createCheckoutResult: Result<CreateCheckoutEnvelope, ErrorEnvelope>?

    fileprivate let createFlaggingResult: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let createPaymentIntentResult: Result<PaymentIntentEnvelope, ErrorEnvelope>?

    fileprivate let createPasswordResult: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let createStripeSetupIntentResult: Result<ClientSecretEnvelope, ErrorEnvelope>?

    fileprivate let changePaymentMethodResult: Result<ChangePaymentMethodEnvelope, ErrorEnvelope>?

    fileprivate let clearUserUnseenActivityResult: Result<ClearUserUnseenActivityEnvelope, ErrorEnvelope>?

    fileprivate let confirmBackingAddressResult: Result<Bool, ErrorEnvelope>?

    fileprivate let deletePaymentMethodResult: Result<DeletePaymentMethodEnvelope, ErrorEnvelope>?

    fileprivate let triggerThirdPartyEventResult: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let facebookConnectResponse: User?
    fileprivate let facebookConnectError: ErrorEnvelope?

    fileprivate let fetchGraphQLResponses: [(any GraphQLQuery.Type, any GraphAPI.SelectionSet)]?

    fileprivate let fetchActivitiesResponse: [Activity]?
    fileprivate let fetchActivitiesError: ErrorEnvelope?

    fileprivate let fetchBackingResponse: Backing
    fileprivate let backingUpdate: Backing

    fileprivate let fetchGraphCategoryResult: Result<CategoryEnvelope, ErrorEnvelope>?

    fileprivate let fetchGraphCategoriesResult: Result<RootCategoriesEnvelope, ErrorEnvelope>?

    fileprivate let fetchProjectCommentsEnvelopeResult: Result<CommentsEnvelope, ErrorEnvelope>?
    fileprivate let fetchUpdateCommentsEnvelopeResult: Result<CommentsEnvelope, ErrorEnvelope>?

    fileprivate let fetchCommentRepliesEnvelopeResult: Result<CommentRepliesEnvelope, ErrorEnvelope>?

    fileprivate let fetchConfigResponse: Config?

    fileprivate let fetchDiscoveryResponse: DiscoveryEnvelope?
    fileprivate let fetchDiscoveryError: ErrorEnvelope?

    fileprivate let fetchFriendsResponse: FindFriendsEnvelope?
    fileprivate let fetchFriendsError: ErrorEnvelope?

    fileprivate let fetchFriendStatsResponse: FriendStatsEnvelope?
    fileprivate let fetchFriendStatsError: ErrorEnvelope?

    fileprivate let fetchDraftResponse: UpdateDraft?
    fileprivate let fetchDraftError: ErrorEnvelope?

    fileprivate let fetchGraphUserResult: Result<UserEnvelope<GraphUser>, ErrorEnvelope>?
    fileprivate let fetchGraphUserSelfResult: Result<UserEnvelope<User>, ErrorEnvelope>?
    fileprivate let fetchGraphUserEmailResult: Result<UserEnvelope<GraphUserEmail>, ErrorEnvelope>?
    fileprivate let fetchGraphUserSetupResult: Result<UserEnvelope<GraphUserSetup>, ErrorEnvelope>?
    fileprivate let fetchErroredUserBackingsResult: Result<ErroredBackingsEnvelope, ErrorEnvelope>?

    fileprivate let addAttachmentResponse: UpdateDraft.Image?
    fileprivate let addAttachmentError: ErrorEnvelope?
    fileprivate let removeAttachmentResponse: UpdateDraft.Image?
    fileprivate let removeAttachmentError: ErrorEnvelope?

    fileprivate let publishUpdateError: ErrorEnvelope?

    fileprivate let fetchBackerSavedProjectsResponse: FetchProjectsEnvelope?
    fileprivate let fetchBackerBackedProjectsResponse: FetchProjectsEnvelope?

    fileprivate let fetchManagePledgeViewBackingResult:
      Result<ProjectAndBackingEnvelope, ErrorEnvelope>?

    fileprivate let fetchMessageThreadResult: Result<MessageThread?, ErrorEnvelope>?
    fileprivate let fetchMessageThreadsResponse: [MessageThread]

    fileprivate let fetchPledgedProjectsResult:
      Result<GraphAPI.FetchPledgedProjectsQuery.Data, ErrorEnvelope>?

    /**
     FIXME: Eventually combine `fetchProjectEnvelopeResult` and `fetchProjectPamphletEnvelopeResult` once all calls returning `Project` are using GQL. https://kickstarter.atlassian.net/browse/NTV-219
     */
    fileprivate let fetchProjectEnvelopeResult: Result<Project, ErrorEnvelope>?
    fileprivate let fetchProjectPamphletEnvelopeResult: Result<Project.ProjectPamphletData, ErrorEnvelope>?
    fileprivate let fetchProjectFriendsEnvelopeResult: Result<[User], ErrorEnvelope>?
    fileprivate let fetchProjectRewardsAndPledgeOverTimeDataResult: Result<
      RewardsAndPledgeOverTimeEnvelope,

      ErrorEnvelope
    >?
    fileprivate let fetchProjectRewardsEnvelopeResult: Result<[Reward], ErrorEnvelope>?
    fileprivate let fetchProjectsResponse: [Project]?
    fileprivate let fetchProjectsError: ErrorEnvelope?

    fileprivate let fetchProjectNotificationsResponse: [ProjectNotification]

    fileprivate let fetchProjectStatsResponse: ProjectStatsEnvelope?
    fileprivate let fetchProjectStatsError: ErrorEnvelope?

    fileprivate let fetchRewardAddOnsSelectionViewRewardsResult:
      Result<Project, ErrorEnvelope>?

    fileprivate let fetchShippingRulesResult: Result<[ShippingRule], ErrorEnvelope>?

    fileprivate let fetchSurveyResponseResponse: SurveyResponse?
    fileprivate let fetchSurveyResponseError: ErrorEnvelope?

    fileprivate let fetchUnansweredSurveyResponsesResponse: [SurveyResponse]

    fileprivate let fetchUpdateResponse: Update

    fileprivate let fetchUserResult: Result<User, ErrorEnvelope>?

    fileprivate let fetchUserSelfResponse: User?
    fileprivate let fetchUserSelfError: ErrorEnvelope?

    fileprivate let followFriendError: ErrorEnvelope?

    fileprivate let incrementVideoCompletionError: ErrorEnvelope?

    fileprivate let incrementVideoStartError: ErrorEnvelope?

    fileprivate let postCommentResult: Result<Comment, ErrorEnvelope>?

    fileprivate let fetchProjectActivitiesResponse: [Activity]?
    fileprivate let fetchProjectActivitiesError: ErrorEnvelope?

    fileprivate let loginResponse: AccessTokenEnvelope?
    fileprivate let loginError: ErrorEnvelope?
    fileprivate let resendCodeResponse: ErrorEnvelope?
    fileprivate let resendCodeError: ErrorEnvelope?

    fileprivate let resetPasswordResponse: User?
    fileprivate let resetPasswordError: ErrorEnvelope?

    fileprivate let sendEmailVerificationResult: Result<EmptyResponseEnvelope, ErrorEnvelope>?

    fileprivate let signInWithAppleResult: Result<SignInWithAppleEnvelope, ErrorEnvelope>?

    fileprivate let signupResponse: AccessTokenEnvelope?
    fileprivate let signupError: ErrorEnvelope?
    fileprivate let tokenExchangeResponse: OAuthTokenExchangeResponse?

    fileprivate let unfollowFriendError: ErrorEnvelope?

    fileprivate let updateBackingResult: Result<UpdateBackingEnvelope, ErrorEnvelope>?

    fileprivate let updateDraftError: ErrorEnvelope?

    fileprivate let updatePledgeResult: Result<UpdatePledgeEnvelope, ErrorEnvelope>?

    fileprivate let updateProjectNotificationResponse: ProjectNotification?
    fileprivate let updateProjectNotificationError: ErrorEnvelope?

    fileprivate let updateUserSelfError: ErrorEnvelope?

    fileprivate let unwatchProjectMutationResult: Result<
      WatchProjectResponseEnvelope,
      ErrorEnvelope
    >?

    fileprivate let validateCheckoutResult: Result<ValidateCheckoutEnvelope, ErrorEnvelope>?

    fileprivate let verifyEmailResult: Result<EmailVerificationResponseEnvelope, ErrorEnvelope>?

    fileprivate let watchProjectMutationResult: Result<
      WatchProjectResponseEnvelope,
      ErrorEnvelope
    >?

    internal init(
      appId: String = "com.kickstarter.kickstarter.mock",
      serverConfig: ServerConfigType,
      oauthToken: OauthTokenAuthType?,
      language: String,
      currency: String,
      buildVersion: String = "1",
      deviceIdentifier: String = "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF",
      apolloClient: ApolloClientType? = nil
    ) {
      self.init(
        appId: appId,
        serverConfig: serverConfig,
        oauthToken: oauthToken,
        language: language,
        currency: currency,
        buildVersion: buildVersion,
        deviceIdentifier: deviceIdentifier,
        apolloClient: apolloClient
      )
    }

    internal init(
      appId: String = "com.kickstarter.kickstarter.mock",
      serverConfig: ServerConfigType = ServerConfig.production,
      oauthToken: OauthTokenAuthType? = nil,
      language: String = "en",
      currency: String = "USD",
      buildVersion: String = "1",
      deviceIdentifier: String = "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF",
      addNewCreditCardResult: Result<CreatePaymentSourceEnvelope, ErrorEnvelope>? = nil,
      addPaymentSheetPaymentSourceResult: Result<CreatePaymentSourceEnvelope, ErrorEnvelope>? = nil,
      addUserToSecretRewardGroup: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      apolloClient: ApolloClientType? = nil,
      blockUserResult: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      buildPaymentPlanResult: Result<GraphAPI.BuildPaymentPlanQuery.Data, ErrorEnvelope>? = nil,
      cancelBackingResult: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      changeEmailResult: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      changePasswordResult: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      createAttributionEventResult: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      createBackingResult: Result<CreateBackingEnvelope, ErrorEnvelope>? = nil,
      completeOnSessionCheckoutResult: Result<
        GraphAPI.CompleteOnSessionCheckoutMutation.Data,
        ErrorEnvelope
      >? = nil,
      createCheckoutResult: Result<CreateCheckoutEnvelope, ErrorEnvelope>? = nil,
      createFlaggingResult: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      createPaymentIntentResult: Result<PaymentIntentEnvelope, ErrorEnvelope>? = nil,
      createPasswordResult: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      createStripeSetupIntentResult: Result<ClientSecretEnvelope, ErrorEnvelope>? = nil,
      changeCurrencyResult: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      changePaymentMethodResult: Result<ChangePaymentMethodEnvelope, ErrorEnvelope>? = nil,
      confirmBackingAddressResult: Result<Bool, ErrorEnvelope>? = nil,
      deletePaymentMethodResult: Result<DeletePaymentMethodEnvelope, ErrorEnvelope>? = nil,
      triggerThirdPartyEventResult: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      clearUserUnseenActivityResult: Result<ClearUserUnseenActivityEnvelope, ErrorEnvelope>? = nil,
      facebookConnectResponse: User? = nil,
      facebookConnectError: ErrorEnvelope? = nil,
      fetchGraphQLResponses: [(any GraphQLQuery.Type, any GraphAPI.SelectionSet)]? = nil,
      fetchActivitiesResponse: [Activity]? = nil,
      fetchActivitiesError: ErrorEnvelope? = nil,
      fetchBackingResponse: Backing = .template,
      backingUpdate: Backing = .template,
      fetchBackerSavedProjectsResponse: FetchProjectsEnvelope? = nil,
      fetchBackerBackedProjectsResponse: FetchProjectsEnvelope? = nil,
      fetchGraphCategoryResult: Result<CategoryEnvelope, ErrorEnvelope>? = nil,
      fetchGraphCategoriesResult: Result<RootCategoriesEnvelope, ErrorEnvelope>? = nil,
      fetchCommentsResponse _: [ActivityComment]? = nil,
      fetchCommentsError _: ErrorEnvelope? = nil,
      fetchProjectCommentsEnvelopeResult: Result<CommentsEnvelope, ErrorEnvelope>? = nil,
      fetchUpdateCommentsEnvelopeResult: Result<CommentsEnvelope, ErrorEnvelope>? = nil,
      fetchCommentRepliesEnvelopeResult: Result<CommentRepliesEnvelope, ErrorEnvelope>? = nil,
      fetchConfigResponse: Config? = nil,
      fetchDiscoveryResponse: DiscoveryEnvelope? = nil,
      fetchDiscoveryError: ErrorEnvelope? = nil,
      fetchFriendsResponse: FindFriendsEnvelope? = nil,
      fetchFriendsError: ErrorEnvelope? = nil,
      fetchFriendStatsResponse: FriendStatsEnvelope? = nil,
      fetchFriendStatsError: ErrorEnvelope? = nil,
      fetchDraftResponse: UpdateDraft? = nil,
      fetchDraftError: ErrorEnvelope? = nil,
      fetchGraphUserResult: Result<UserEnvelope<GraphUser>, ErrorEnvelope>? = nil,
      fetchGraphUserSelfResult: Result<UserEnvelope<User>, ErrorEnvelope>? = nil,
      fetchGraphUserEmailResult: Result<UserEnvelope<GraphUserEmail>, ErrorEnvelope>? = nil,
      fetchGraphUserSetupResult: Result<UserEnvelope<GraphUserSetup>, ErrorEnvelope>? = nil,
      fetchErroredUserBackingsResult: Result<ErroredBackingsEnvelope, ErrorEnvelope>? = nil,
      addAttachmentResponse: UpdateDraft.Image? = nil,
      addAttachmentError: ErrorEnvelope? = nil,
      removeAttachmentResponse: UpdateDraft.Image? = nil,
      removeAttachmentError: ErrorEnvelope? = nil,
      publishUpdateError: ErrorEnvelope? = nil,
      fetchManagePledgeViewBackingResult: Result<ProjectAndBackingEnvelope, ErrorEnvelope>? = nil,
      fetchMessageThreadResult: Result<MessageThread?, ErrorEnvelope>? = nil,
      fetchMessageThreadsResponse: [MessageThread]? = nil,
      fetchPledgedProjectsResult: Result<GraphAPI.FetchPledgedProjectsQuery.Data, ErrorEnvelope>? = nil,
      fetchProjectResult: Result<Project, ErrorEnvelope>? = nil,
      fetchProjectPamphletResult: Result<Project.ProjectPamphletData, ErrorEnvelope>? = nil,
      fetchProjectFriendsResult: Result<[User], ErrorEnvelope>? = nil,
      fetchProjectRewardsAndPledgeOverTimeDataResult: Result<
        RewardsAndPledgeOverTimeEnvelope,

        ErrorEnvelope
      >? = nil,
      fetchProjectRewardsResult: Result<[Reward], ErrorEnvelope>? = nil,
      fetchProjectActivitiesResponse: [Activity]? = nil,
      fetchProjectActivitiesError: ErrorEnvelope? = nil,
      fetchProjectNotificationsResponse: [ProjectNotification]? = nil,
      fetchProjectsResponse: [Project]? = nil,
      fetchProjectsError: ErrorEnvelope? = nil,
      fetchProjectStatsResponse: ProjectStatsEnvelope? = nil,
      fetchProjectStatsError: ErrorEnvelope? = nil,
      fetchShippingRulesResult: Result<[ShippingRule], ErrorEnvelope>? = nil,
      fetchUserProjectsBackedError _: ErrorEnvelope? = nil,
      fetchUserResult: Result<User, ErrorEnvelope>? = nil,
      fetchUserSelfResponse: User? = nil,
      followFriendError: ErrorEnvelope? = nil,
      incrementVideoCompletionError: ErrorEnvelope? = nil,
      incrementVideoStartError: ErrorEnvelope? = nil,
      fetchRewardAddOnsSelectionViewRewardsResult: Result<Project, ErrorEnvelope>? =
        nil,
      fetchSurveyResponseResponse: SurveyResponse? = nil,
      fetchSurveyResponseError: ErrorEnvelope? = nil,
      fetchUnansweredSurveyResponsesResponse: [SurveyResponse] = [],
      fetchUpdateResponse: Update = .template,
      fetchUserSelfError: ErrorEnvelope? = nil,
      postCommentResult: Result<Comment, ErrorEnvelope>? = nil,
      loginResponse: AccessTokenEnvelope? = nil,
      loginError: ErrorEnvelope? = nil,
      tokenExchangeResponse: OAuthTokenExchangeResponse? = nil,
      resendCodeResponse: ErrorEnvelope? = nil,
      resendCodeError: ErrorEnvelope? = nil,
      resetPasswordResponse: User? = nil,
      resetPasswordError: ErrorEnvelope? = nil,
      sendEmailVerificationResult: Result<EmptyResponseEnvelope, ErrorEnvelope>? = nil,
      signInWithAppleResult: Result<SignInWithAppleEnvelope, ErrorEnvelope>? = nil,
      signupResponse: AccessTokenEnvelope? = nil,
      signupError: ErrorEnvelope? = nil,
      unfollowFriendError: ErrorEnvelope? = nil,
      updateBackingResult: Result<UpdateBackingEnvelope, ErrorEnvelope>? = nil,
      updateDraftError: ErrorEnvelope? = nil,
      updatePledgeResult: Result<UpdatePledgeEnvelope, ErrorEnvelope>? = nil,
      updateProjectNotificationResponse: ProjectNotification? = nil,
      updateProjectNotificationError: ErrorEnvelope? = nil,
      updateUserSelfError: ErrorEnvelope? = nil,
      unwatchProjectMutationResult: Result<WatchProjectResponseEnvelope, ErrorEnvelope>? = nil,
      validateCheckoutResult: Result<ValidateCheckoutEnvelope, ErrorEnvelope>? = nil,
      verifyEmailResult: Result<EmailVerificationResponseEnvelope, ErrorEnvelope>? = nil,
      watchProjectMutationResult: Result<WatchProjectResponseEnvelope, ErrorEnvelope>? = nil
    ) {
      self.appId = appId
      self.serverConfig = serverConfig
      self.oauthToken = oauthToken
      self.language = language
      self.currency = currency
      self.buildVersion = buildVersion
      self.deviceIdentifier = deviceIdentifier

      self.addNewCreditCardResult = addNewCreditCardResult

      self.addPaymentSheetPaymentSourceResult = addPaymentSheetPaymentSourceResult

      self.addUserToSecretRewardGroup = addUserToSecretRewardGroup

      self.apolloClient = apolloClient ?? MockGraphQLClient.shared.client

      self.blockUserResult = blockUserResult

      self.buildPaymentPlanResult = buildPaymentPlanResult

      self.cancelBackingResult = cancelBackingResult

      self.changeEmailResult = changeEmailResult

      self.changeCurrencyResult = changeCurrencyResult

      self.changePasswordResult = changePasswordResult

      self.clearUserUnseenActivityResult = clearUserUnseenActivityResult

      self.createAttributionEventResult = createAttributionEventResult

      self.createBackingResult = createBackingResult

      self.completeOnSessionCheckoutResult = completeOnSessionCheckoutResult

      self.createCheckoutResult = createCheckoutResult

      self.createFlaggingResult = createFlaggingResult

      self.createPaymentIntentResult = createPaymentIntentResult

      self.createPasswordResult = createPasswordResult

      self.createStripeSetupIntentResult = createStripeSetupIntentResult

      self.changePaymentMethodResult = changePaymentMethodResult

      self.confirmBackingAddressResult = confirmBackingAddressResult

      self.deletePaymentMethodResult = deletePaymentMethodResult

      self.triggerThirdPartyEventResult = triggerThirdPartyEventResult

      self.facebookConnectResponse = facebookConnectResponse
      self.facebookConnectError = facebookConnectError

      self.fetchGraphQLResponses = fetchGraphQLResponses

      self.fetchActivitiesResponse = fetchActivitiesResponse ?? [
        .template,
        .template |> Activity.lens.category .~ .backing,
        .template |> Activity.lens.category .~ .success
      ]

      self.fetchActivitiesError = fetchActivitiesError

      self.fetchBackingResponse = fetchBackingResponse

      self.fetchBackerSavedProjectsResponse = fetchBackerSavedProjectsResponse
      self.fetchBackerBackedProjectsResponse = fetchBackerBackedProjectsResponse

      self.backingUpdate = backingUpdate

      self.fetchGraphCategoryResult = fetchGraphCategoryResult

      self.fetchGraphCategoriesResult = fetchGraphCategoriesResult

      self.fetchGraphUserResult = fetchGraphUserResult
      self.fetchGraphUserSelfResult = fetchGraphUserSelfResult
      self.fetchGraphUserEmailResult = fetchGraphUserEmailResult
      self.fetchGraphUserSetupResult = fetchGraphUserSetupResult

      self.fetchErroredUserBackingsResult = fetchErroredUserBackingsResult

      self.fetchPledgedProjectsResult = fetchPledgedProjectsResult

      self.fetchProjectCommentsEnvelopeResult = fetchProjectCommentsEnvelopeResult
      self.fetchUpdateCommentsEnvelopeResult = fetchUpdateCommentsEnvelopeResult

      self.fetchCommentRepliesEnvelopeResult = fetchCommentRepliesEnvelopeResult

      self.fetchConfigResponse = fetchConfigResponse ?? .template

      self.fetchDiscoveryResponse = fetchDiscoveryResponse
      self.fetchDiscoveryError = fetchDiscoveryError

      self.fetchFriendsResponse = fetchFriendsResponse
      self.fetchFriendsError = fetchFriendsError

      self.fetchFriendStatsResponse = fetchFriendStatsResponse
      self.fetchFriendStatsError = fetchFriendStatsError

      self.fetchDraftResponse = fetchDraftResponse
      self.fetchDraftError = fetchDraftError

      self.addAttachmentResponse = addAttachmentResponse
      self.addAttachmentError = addAttachmentError
      self.removeAttachmentResponse = removeAttachmentResponse
      self.removeAttachmentError = removeAttachmentError

      self.publishUpdateError = publishUpdateError

      self.fetchManagePledgeViewBackingResult = fetchManagePledgeViewBackingResult

      self.fetchRewardAddOnsSelectionViewRewardsResult = fetchRewardAddOnsSelectionViewRewardsResult

      self.fetchMessageThreadResult = fetchMessageThreadResult

      self.fetchMessageThreadsResponse = fetchMessageThreadsResponse ?? [
        .template |> MessageThread.lens.id .~ 1,
        .template |> MessageThread.lens.id .~ 2,
        .template |> MessageThread.lens.id .~ 3
      ]

      self.fetchProjectActivitiesResponse = fetchProjectActivitiesResponse ?? [
        .template,
        .template |> Activity.lens.category .~ .backing,
        .template |> Activity.lens.category .~ .commentProject
      ]
      .enumerated()
      .map(Activity.lens.id.set)

      self.fetchProjectActivitiesError = fetchProjectActivitiesError

      self.fetchProjectNotificationsResponse = fetchProjectNotificationsResponse ?? [
        .template |> ProjectNotification.lens.id .~ 1,
        .template |> ProjectNotification.lens.id .~ 2,
        .template |> ProjectNotification.lens.id .~ 3
      ]

      self.fetchProjectsResponse = fetchProjectsResponse ?? []

      self.fetchProjectsError = fetchProjectsError

      self.fetchProjectEnvelopeResult = fetchProjectResult
      self.fetchProjectPamphletEnvelopeResult = fetchProjectPamphletResult
      self.fetchProjectFriendsEnvelopeResult = fetchProjectFriendsResult
      self.fetchProjectRewardsAndPledgeOverTimeDataResult = fetchProjectRewardsAndPledgeOverTimeDataResult
      self.fetchProjectRewardsEnvelopeResult = fetchProjectRewardsResult

      self.fetchProjectStatsResponse = fetchProjectStatsResponse
      self.fetchProjectStatsError = fetchProjectStatsError

      self.fetchShippingRulesResult = fetchShippingRulesResult

      self.fetchSurveyResponseResponse = fetchSurveyResponseResponse
      self.fetchSurveyResponseError = fetchSurveyResponseError

      self.fetchUnansweredSurveyResponsesResponse = fetchUnansweredSurveyResponsesResponse

      self.fetchUpdateResponse = fetchUpdateResponse

      self.fetchUserResult = fetchUserResult

      self.fetchUserSelfResponse = fetchUserSelfResponse ?? .template
      self.fetchUserSelfError = fetchUserSelfError

      self.followFriendError = followFriendError

      self.incrementVideoCompletionError = incrementVideoCompletionError

      self.incrementVideoStartError = incrementVideoStartError

      self.postCommentResult = postCommentResult

      self.loginResponse = loginResponse

      self.loginError = loginError

      self.resendCodeResponse = resendCodeResponse

      self.resendCodeError = resendCodeError

      self.resetPasswordResponse = resetPasswordResponse

      self.resetPasswordError = resetPasswordError

      self.sendEmailVerificationResult = sendEmailVerificationResult

      self.signInWithAppleResult = signInWithAppleResult

      self.signupResponse = signupResponse

      self.signupError = signupError

      self.unfollowFriendError = unfollowFriendError

      self.updateBackingResult = updateBackingResult

      self.updateDraftError = updateDraftError

      self.updatePledgeResult = updatePledgeResult

      self.updateProjectNotificationResponse = updateProjectNotificationResponse

      self.updateProjectNotificationError = updateProjectNotificationError

      self.updateUserSelfError = updateUserSelfError

      self.unwatchProjectMutationResult = unwatchProjectMutationResult

      self.validateCheckoutResult = validateCheckoutResult

      self.verifyEmailResult = verifyEmailResult

      self.watchProjectMutationResult = watchProjectMutationResult

      self.tokenExchangeResponse = tokenExchangeResponse
    }

    public func addNewCreditCard(input: CreatePaymentSourceInput)
      -> SignalProducer<CreatePaymentSourceEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .CreatePaymentSourceMutation(input: GraphAPI.CreatePaymentSourceInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.addNewCreditCardResult)
    }

    public func addPaymentSheetPaymentSource(input: CreatePaymentSourceSetupIntentInput)
      -> SignalProducer<CreatePaymentSourceEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .CreatePaymentSourceMutation(input: GraphAPI.CreatePaymentSourceInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.addPaymentSheetPaymentSourceResult)
    }

    public func addUserToSecretRewardGroup(input: AddUserToSecretRewardGroupInput)
      -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .AddUserToSecretRewardGroupMutation(input: GraphAPI.AddUserToSecretRewardGroupInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.addUserToSecretRewardGroup)
    }

    public func blockUser(input: BlockUserInput)
      -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .BlockUserMutation(input: GraphAPI.BlockUserInput(blockUserId: input.blockUserId))

      return client.performWithResult(mutation: mutation, result: self.blockUserResult)
    }

    func buildPaymentPlan(
      projectSlug: String,
      pledgeAmount: String
    ) -> SignalProducer<GraphAPI.BuildPaymentPlanQuery.Data, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let query = GraphAPI.BuildPaymentPlanQuery(slug: projectSlug, amount: pledgeAmount)

      return client.fetchWithResult(query: query, result: self.buildPaymentPlanResult)
    }

    public func cancelBacking(input: CancelBackingInput)
      -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .CancelBackingMutation(input: GraphAPI.CancelBackingInput(id: input.backingId))

      return client.performWithResult(mutation: mutation, result: self.cancelBackingResult)
    }

    internal func changeEmail(input: ChangeEmailInput)
      -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .UpdateUserAccountMutation(input: GraphAPI.UpdateUserAccountInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.changeEmailResult)
    }

    internal func facebookConnect(facebookAccessToken _: String)
      -> SignalProducer<User, ErrorEnvelope> {
      if let response = facebookConnectResponse {
        return SignalProducer(value: response)
      } else if let error = facebookConnectError {
        return SignalProducer(error: error)
      }

      return SignalProducer(
        value:
        User.template
          |> \.id .~ 1
          |> \.facebookConnected .~ true
      )
    }

    internal func changePassword(input: ChangePasswordInput)
      -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .UpdateUserAccountMutation(input: GraphAPI.UpdateUserAccountInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.changePasswordResult)
    }

    public func createAttributionEvent(input: GraphAPI.CreateAttributionEventInput) ->
      SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI.CreateAttributionEventMutation(input: input)

      return client.performWithResult(mutation: mutation, result: self.createAttributionEventResult)
    }

    internal func createBacking(input: CreateBackingInput)
      -> SignalProducer<CreateBackingEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI.CreateBackingMutation(input: GraphAPI.CreateBackingInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.createBackingResult)
    }

    internal func completeOnSessionCheckout(input: GraphAPI.CompleteOnSessionCheckoutInput) ->
      SignalProducer<GraphAPI.CompleteOnSessionCheckoutMutation.Data, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI.CompleteOnSessionCheckoutMutation(input: input)
      return client.performWithResult(mutation: mutation, result: self.completeOnSessionCheckoutResult)
    }

    internal func createCheckout(input: CreateCheckoutInput)
      -> SignalProducer<CreateCheckoutEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI.CreateCheckoutMutation(
        input: GraphAPI
          .CreateCheckoutInput(
            projectId: input.projectId,
            amount: GraphQLNullable.someOrNil(input.amount),
            locationId: GraphQLNullable.someOrNil(input.locationId),
            rewardIds: GraphQLNullable.someOrNil(input.rewardIds),
            refParam: GraphQLNullable.someOrNil(input.refParam)
          )
      )

      return client.performWithResult(mutation: mutation, result: self.createCheckoutResult)
    }

    internal func createFlaggingInput(input: CreateFlaggingInput) -> ReactiveSwift
      .SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .CreateFlaggingMutation(input: GraphAPI.CreateFlaggingInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.createFlaggingResult)
    }

    internal func createFlaggingInputCombine(input: CreateFlaggingInput)
      -> AnyPublisher<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return Empty(completeImmediately: false).eraseToAnyPublisher()
      }

      let mutation = GraphAPI
        .CreateFlaggingMutation(input: GraphAPI.CreateFlaggingInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.createFlaggingResult)
    }

    internal func createPaymentIntentInput(input: CreatePaymentIntentInput) -> ReactiveSwift
      .SignalProducer<PaymentIntentEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .CreatePaymentIntentMutation(input: GraphAPI.CreatePaymentIntentInput(
          projectId: input.projectId,
          amount: input.amountDollars,
          digitalMarketingAttributed: GraphQLNullable.someOrNil(input.digitalMarketingAttributed)
        ))

      return client.performWithResult(mutation: mutation, result: self.createPaymentIntentResult)
    }

    internal func createPassword(input: CreatePasswordInput)
      -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .UpdateUserAccountMutation(input: GraphAPI.UpdateUserAccountInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.createPasswordResult)
    }

    internal func createStripeSetupIntent(input: CreateSetupIntentInput)
      -> SignalProducer<ClientSecretEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .CreateSetupIntentMutation(input: GraphAPI.CreateSetupIntentInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.createStripeSetupIntentResult)
    }

    internal func changeCurrency(input: ChangeCurrencyInput)
      -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .UpdateUserProfileMutation(input: GraphAPI.UpdateUserProfileInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.changeCurrencyResult)
    }

    internal func clearUserUnseenActivity(input _: EmptyInput)
      -> SignalProducer<ClearUserUnseenActivityEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .ClearUserUnseenActivityMutation(input: GraphAPI.ClearUserUnseenActivityInput())

      return client.performWithResult(mutation: mutation, result: self.clearUserUnseenActivityResult)
    }

    func fetchProjectComments(
      slug: String,
      cursor: String?,
      limit: Int?
    ) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchProjectCommentsQuery = GraphAPI.FetchProjectCommentsQuery(
        slug: slug,
        cursor: GraphQLNullable.someOrNil(cursor),
        limit: GraphQLNullable.someOrNil(limit)
      )

      return client
        .fetchWithResult(query: fetchProjectCommentsQuery, result: self.fetchProjectCommentsEnvelopeResult)
    }

    func fetchUpdateComments(
      id: String,
      cursor: String?,
      limit: Int?
    ) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchUpdateCommentsQuery = GraphAPI.FetchUpdateCommentsQuery(
        postId: id,
        cursor: GraphQLNullable.someOrNil(cursor),
        limit: GraphQLNullable.someOrNil(limit)
      )

      return client
        .fetchWithResult(query: fetchUpdateCommentsQuery, result: self.fetchUpdateCommentsEnvelopeResult)
    }

    func fetchCommentReplies(
      id: String,
      cursor: String?,
      limit: Int
    ) -> SignalProducer<CommentRepliesEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchCommentRepliesQuery = GraphAPI.FetchCommentRepliesQuery(
        commentId: id,
        cursor: GraphQLNullable.someOrNil(cursor),
        limit: limit
      )

      return client
        .fetchWithResult(query: fetchCommentRepliesQuery, result: self.fetchCommentRepliesEnvelopeResult)
    }

    internal func fetchConfig() -> SignalProducer<Config, ErrorEnvelope> {
      guard let config = self.fetchConfigResponse else { return .empty }
      return SignalProducer(value: config)
    }

    internal func fetchFriends() -> SignalProducer<FindFriendsEnvelope, ErrorEnvelope> {
      if let response = fetchFriendsResponse {
        return SignalProducer(value: response)
      } else if let error = fetchFriendsError {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: .template)
    }

    internal func fetchFriends(paginationUrl _: String)
      -> SignalProducer<FindFriendsEnvelope, ErrorEnvelope> {
      return self.fetchFriends()
    }

    internal func fetchFriendStats() -> SignalProducer<FriendStatsEnvelope, ErrorEnvelope> {
      if let response = fetchFriendStatsResponse {
        return SignalProducer(value: response)
      } else if let error = fetchFriendStatsError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: .template)
    }

    internal func followAllFriends() -> SignalProducer<VoidEnvelope, ErrorEnvelope> {
      return SignalProducer(value: VoidEnvelope())
    }

    internal func followFriend(userId id: Int) -> SignalProducer<User, ErrorEnvelope> {
      if let error = followFriendError {
        return SignalProducer(error: error)
      }

      return SignalProducer(
        value:
        User.template
          |> \.id .~ id
          |> \.isFriend .~ true
      )
    }

    internal func fetch<Q: GraphQLQuery>(query _: Q) -> SignalProducer<Q.Data, ErrorEnvelope> {
      for (queryType, result) in self.fetchGraphQLResponses ?? [] {
        if queryType == Q.self, let response = result as? Q.Data {
          return SignalProducer(value: response)
        }
      }
      return SignalProducer(error: ErrorEnvelope.graphError("Unimplemented mock"))
    }

    internal func fetchGraphCategories()
      -> SignalProducer<RootCategoriesEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchGraphCategoriesQuery = GraphAPI.FetchRootCategoriesQuery()

      return client.fetchWithResult(query: fetchGraphCategoriesQuery, result: self.fetchGraphCategoriesResult)
    }

    internal func fetchGraphCategory(id: String)
      -> SignalProducer<CategoryEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchGraphCategoryQuery = GraphAPI.FetchCategoryQuery(id: id)

      return client.fetchWithResult(query: fetchGraphCategoryQuery, result: self.fetchGraphCategoryResult)
    }

    internal func fetchGraphUserSelf()
      -> SignalProducer<UserEnvelope<User>, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchGraphUserQuery = GraphAPI.FetchUserQuery(withStoredCards: false)

      return client.fetchWithResult(query: fetchGraphUserQuery, result: self.fetchGraphUserSelfResult)
    }

    internal func fetchGraphUser(withStoredCards: Bool)
      -> SignalProducer<UserEnvelope<GraphUser>, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchGraphUserQuery = GraphAPI.FetchUserQuery(withStoredCards: withStoredCards)

      return client.fetchWithResult(query: fetchGraphUserQuery, result: self.fetchGraphUserResult)
    }

    internal func fetchGraphUserEmail() -> SignalProducer<UserEnvelope<GraphUserEmail>, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchGraphUserEmailQuery = GraphAPI.FetchUserEmailQuery()

      return client.fetchWithResult(query: fetchGraphUserEmailQuery, result: self.fetchGraphUserEmailResult)
    }

    func fetchGraphUserEmailCombine() -> AnyPublisher<UserEnvelope<GraphUserEmail>, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return Empty(completeImmediately: false).eraseToAnyPublisher()
      }

      let fetchGraphUserEmailQuery = GraphAPI.FetchUserEmailQuery()
      return client.fetchWithResult(query: fetchGraphUserEmailQuery, result: self.fetchGraphUserEmailResult)
    }

    internal func fetchGraphUserSetup() -> SignalProducer<UserEnvelope<GraphUserSetup>, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchGraphUserSetupQuery = GraphAPI.FetchUserSetupQuery()

      return client.fetchWithResult(query: fetchGraphUserSetupQuery, result: self.fetchGraphUserSetupResult)
    }

    func fetchGraphUserSetupCombine() -> AnyPublisher<UserEnvelope<GraphUserSetup>, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return Empty(completeImmediately: false).eraseToAnyPublisher()
      }

      let fetchGraphUserSetupQuery = GraphAPI.FetchUserSetupQuery()
      return client.fetchWithResult(query: fetchGraphUserSetupQuery, result: self.fetchGraphUserSetupResult)
    }

    // TODO: Refactor this test to use `self.apolloClient`, `ErroredBackingsEnvelope` needs to be `Decodable` and tested in-app.
    internal func fetchErroredUserBackings(status _: BackingState)
      -> SignalProducer<ErroredBackingsEnvelope, ErrorEnvelope> {
      return producer(for: self.fetchErroredUserBackingsResult)
    }

    internal func unfollowFriend(userId _: Int) -> SignalProducer<VoidEnvelope, ErrorEnvelope> {
      if let error = unfollowFriendError {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: VoidEnvelope())
    }

    internal func login(_ oauthToken: OauthTokenAuthType) -> MockService {
      return self |> MockService.lens.oauthToken .~ oauthToken
    }

    internal func logout() -> MockService {
      return self |> MockService.lens.oauthToken .~ nil
    }

    internal func fetchActivities(count _: Int?) -> SignalProducer<ActivityEnvelope, ErrorEnvelope> {
      if let error = fetchActivitiesError {
        return SignalProducer(error: error)
      } else if let activities = fetchActivitiesResponse {
        return SignalProducer(
          value: ActivityEnvelope(
            activities: activities,
            urls: ActivityEnvelope.UrlsEnvelope(
              api: ActivityEnvelope.UrlsEnvelope.ApiEnvelope(
                moreActivities: "http://\(Secrets.Api.Endpoint.production)/gimme/more"
              )
            )
          )
        )
      }
      return .empty
    }

    internal func fetchActivities(paginationUrl _: String)
      -> SignalProducer<ActivityEnvelope, ErrorEnvelope> {
      return self.fetchActivities(count: nil)
    }

    func fetchBacking(forProject project: Project, forUser user: User)
      -> SignalProducer<Backing, ErrorEnvelope> {
      return SignalProducer(
        value: self.fetchBackingResponse
          |> Backing.lens.backer .~ user
          |> Backing.lens.backerId .~ user.id
          |> Backing.lens.projectId .~ project.id
      )
    }

    func backingUpdate(forProject project: Project, forUser user: User, received: Bool)
      -> SignalProducer<Backing, ErrorEnvelope> {
      return SignalProducer(
        value: self.fetchBackingResponse
          |> Backing.lens.backer .~ user
          |> Backing.lens.backerId .~ user.id
          |> Backing.lens.projectId .~ project.id
          |> Backing.lens.backerCompleted .~ received
      )
    }

    internal func fetchDiscovery(paginationUrl: String)
      -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope> {
      if let error = fetchDiscoveryError {
        return SignalProducer(error: error)
      }

      let project: (Int) -> Project = {
        .template |> Project.lens.id .~ ($0 + paginationUrl.hashValue)
      }
      let envelope = self.fetchDiscoveryResponse ?? (
        .template
          |> DiscoveryEnvelope.lens.projects .~ (1...4).map(project)
          |> DiscoveryEnvelope.lens.urls.api.moreProjects .~ (paginationUrl + "+1")
      )

      return SignalProducer(value: envelope)
    }

    internal func fetchDiscovery(params: DiscoveryParams)
      -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope> {
      if let error = fetchDiscoveryError {
        return SignalProducer(error: error)
      }

      let project: (Int) -> Project = {
        .template |> Project.lens.id %~ const($0 + params.hashValue)
      }
      let envelope = self.fetchDiscoveryResponse ?? (
        .template
          |> DiscoveryEnvelope.lens.projects .~ (1...4).map(project)
      )

      return SignalProducer(value: envelope)
    }

    // TODO: Refactor this test to use `self.apolloClient`, `ProjectAndBackingEnvelope` needs to be `Decodable` and tested in-app.
    func fetchBacking(id _: Int, withStoredCards _: Bool)
      -> SignalProducer<ProjectAndBackingEnvelope, ErrorEnvelope> {
      return producer(for: self.fetchManagePledgeViewBackingResult)
    }

    func fetchRewardAddOnsSelectionViewRewards(slug: String, shippingEnabled: Bool, locationId: String?)
      -> SignalProducer<Project, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchRewardAddOnsSelectionViewRewardsQuery = GraphAPI.FetchAddOnsQuery(
        projectSlug: slug,
        shippingEnabled: shippingEnabled,
        locationId: GraphQLNullable.someOrNil(locationId),
        withStoredCards: false,
        includeShippingRules: true,
        includeLocalPickup: true
      )

      return client
        .fetchWithResult(
          query: fetchRewardAddOnsSelectionViewRewardsQuery,
          result: self.fetchRewardAddOnsSelectionViewRewardsResult
        )
    }

    internal func fetchMessageThread(messageThreadId _: Int)
      -> SignalProducer<MessageThreadEnvelope, ErrorEnvelope> {
      if let error = self.fetchMessageThreadResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(
        value: MessageThreadEnvelope(
          participants: [.template, .template |> \.id .~ 2],
          messages: [
            .template |> Message.lens.id .~ 1,
            .template |> Message.lens.id .~ 2,
            .template |> Message.lens.id .~ 3
          ],
          messageThread: self.fetchMessageThreadResult?.value as? MessageThread ?? .template
        )
      )
    }

    internal func fetchMessageThread(backing _: Backing)
      -> SignalProducer<MessageThreadEnvelope?, ErrorEnvelope> {
      if let error = self.fetchMessageThreadResult?.error {
        return SignalProducer(error: error)
      }

      if let thread = self.fetchMessageThreadResult?.value as? MessageThread {
        return SignalProducer(
          value: MessageThreadEnvelope(
            participants: [.template, .template |> \.id .~ 2],
            messages: [
              .template |> Message.lens.id .~ 1,
              .template |> Message.lens.id .~ 2,
              .template |> Message.lens.id .~ 3
            ],
            messageThread: thread
          )
        )
      } else {
        return SignalProducer(value: nil)
      }
    }

    internal func fetchMessageThreads(mailbox _: Mailbox, project _: Project?)
      -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope> {
      return SignalProducer(
        value:
        MessageThreadsEnvelope(
          messageThreads: self.fetchMessageThreadsResponse,
          urls: MessageThreadsEnvelope.UrlsEnvelope(
            api: MessageThreadsEnvelope.UrlsEnvelope.ApiEnvelope(
              moreMessageThreads: ""
            )
          )
        )
      )
    }

    internal func fetchMessageThreads(paginationUrl _: String)
      -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope> {
      return SignalProducer(
        value:
        MessageThreadsEnvelope(
          messageThreads: self.fetchMessageThreadsResponse,
          urls: MessageThreadsEnvelope.UrlsEnvelope(
            api: MessageThreadsEnvelope.UrlsEnvelope.ApiEnvelope(
              moreMessageThreads: ""
            )
          )
        )
      )
    }

    internal func fetchProjectNotifications() -> SignalProducer<[ProjectNotification], ErrorEnvelope> {
      return SignalProducer(value: self.fetchProjectNotificationsResponse)
    }

    public func fetchSavedProjects(
      cursor _: String? = nil,
      limit _: Int? = nil
    ) -> SignalProducer<FetchProjectsEnvelope, ErrorEnvelope> {
      guard let result = self.fetchBackerSavedProjectsResponse else {
        return .empty
      }
      return SignalProducer(value: result)
    }

    public func fetchBackedProjects(
      cursor _: String? = nil,
      limit _: Int? = nil
    ) -> SignalProducer<
      FetchProjectsEnvelope,
      ErrorEnvelope
    > {
      guard let result = self.fetchBackerBackedProjectsResponse else {
        return .empty
      }
      return SignalProducer(value: result)
    }

    internal func fetchProject(param _: Param) -> SignalProducer<Project, ErrorEnvelope> {
      guard let result = self.fetchProjectEnvelopeResult else {
        return .empty
      }

      switch result {
      case let .success(project):
        return SignalProducer(value: project)
      case let .failure(error):
        return SignalProducer(error: error)
      }
    }

    internal func fetchProject(projectParam: Param, configCurrency _: String?)
      -> SignalProducer<Project.ProjectPamphletData, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      switch (projectParam.id, projectParam.slug) {
      case let (.some(paramId), _):
        let fetchProjectQuery = GraphAPI
          .FetchProjectByIdQuery(projectId: paramId, withStoredCards: false)

        let projectOrErrorOnlyResult: Result<Project, ErrorEnvelope>

        switch self.fetchProjectPamphletEnvelopeResult {
        case let .success(projectPamphletData):
          projectOrErrorOnlyResult = .success(projectPamphletData.project)
        case let .failure(errorEnvelope):
          projectOrErrorOnlyResult = .failure(errorEnvelope)
        case .none:
          return .empty
        }

        /**
         FIXME: Separately attaching passed in `backingId` from `Project.ProjectPamphletData` and not calling the mock client directly with `Project.ProjectPamphletData` because it is not `Decodable` (error, unsure how to correct at this time, because `Project` which is not decodable can be passed in on its' own)
         */
        let producer = client
          .fetchWithResult(query: fetchProjectQuery, result: projectOrErrorOnlyResult)
          .switchMap { project -> SignalProducer<Project.ProjectPamphletData, ErrorEnvelope> in
            let pamphletData = Project
              .ProjectPamphletData(
                project: project,
                backingId: self.fetchProjectPamphletEnvelopeResult?.value?.backingId
              )

            return SignalProducer(value: pamphletData)
          }

        return producer
      case let (_, .some(paramSlug)):
        let fetchProjectQuery = GraphAPI
          .FetchProjectBySlugQuery(slug: paramSlug, withStoredCards: false)

        let projectOrErrorOnlyResult: Result<Project, ErrorEnvelope>

        switch self.fetchProjectPamphletEnvelopeResult {
        case let .success(projectPamphletData):
          projectOrErrorOnlyResult = .success(projectPamphletData.project)
        case let .failure(errorEnvelope):
          projectOrErrorOnlyResult = .failure(errorEnvelope)
        case .none:
          return .empty
        }

        var producer: SignalProducer<Project.ProjectPamphletData, ErrorEnvelope> =
          SignalProducer(error: .couldNotParseJSON)

        /**
         FIXME: Separately attaching passed in `backingId` from `Project.ProjectPamphletData` and not calling the mock client directly with `Project.ProjectPamphletData` because it is not `Decodable` (error, unsure how to correct at this time, because `Project` which is not decodable can be passed in on its' own)
         */
        _ = client
          .fetchWithResult(query: fetchProjectQuery, result: projectOrErrorOnlyResult)
          .on(
            failed: { errorEnvelope in
              producer = SignalProducer(error: errorEnvelope)
            },
            value: { project in
              let pamphletData = Project
                .ProjectPamphletData(
                  project: project,
                  backingId: self.fetchProjectPamphletEnvelopeResult?.value?.backingId
                )

              producer = SignalProducer(value: pamphletData)
            }
          )

        return producer
      default:
        return .empty
      }
    }

    internal func fetchProjectFriends(param: Param) -> SignalProducer<[User], ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      switch (param.id, param.slug) {
      case let (.some(paramId), _):
        let fetchProjectWithFriendsQuery = GraphAPI
          .FetchProjectFriendsByIdQuery(projectId: paramId, withStoredCards: false)

        return client
          .fetchWithResult(
            query: fetchProjectWithFriendsQuery,
            result: self.fetchProjectFriendsEnvelopeResult
          )
      case let (_, .some(paramSlug)):
        let fetchProjectWithFriendsQuery = GraphAPI
          .FetchProjectFriendsBySlugQuery(slug: paramSlug, withStoredCards: false)

        return client
          .fetchWithResult(
            query: fetchProjectWithFriendsQuery,
            result: self.fetchProjectFriendsEnvelopeResult
          )
      default:
        return .empty
      }
    }

    func fetchProjectRewardsAndPledgeOverTimeData(projectId: Int)
      -> SignalProducer<
        RewardsAndPledgeOverTimeEnvelope,
        ErrorEnvelope
      > {
      guard let client = self.apolloClient else {
        return .empty
      }

      let query = GraphAPI
        .FetchProjectRewardsByIdQuery(
          projectId: projectId,
          includeShippingRules: false,
          includeLocalPickup: true,
          includePledgeOverTime: true
        )

      return client
        .fetchWithResult(
          query: query,
          result: self.fetchProjectRewardsAndPledgeOverTimeDataResult
        )
    }

    internal func fetchProjectRewards(projectId: Int) -> SignalProducer<[Reward], ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchProjectRewardsQuery = GraphAPI
        .FetchProjectRewardsByIdQuery(
          projectId: projectId,
          includeShippingRules: false,
          includeLocalPickup: true,
          includePledgeOverTime: false
        )

      return client
        .fetchWithResult(
          query: fetchProjectRewardsQuery,
          result: self.fetchProjectRewardsEnvelopeResult
        )
    }

    internal func fetchProject(
      _ params: DiscoveryParams
    ) -> SignalProducer<DiscoveryEnvelope, ErrorEnvelope> {
      if let envelope = self.fetchDiscoveryResponse {
        return SignalProducer(value: envelope)
      }
      let envelope = .template
        |> DiscoveryEnvelope.lens.projects .~ [
          .template |> Project.lens.id .~ params.hashValue
        ]
      return SignalProducer(value: envelope)
    }

    internal func fetchProject(project: Project) -> SignalProducer<Project, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let fetchProjectCommentsQuery = GraphAPI
        .FetchProjectByIdQuery(projectId: project.id, withStoredCards: false)

      let projectOnlyResult: Result<Project, ErrorEnvelope>

      switch self.fetchProjectEnvelopeResult {
      case let .success(project):
        projectOnlyResult = .success(project)
      case let .failure(errorEnvelope):
        projectOnlyResult = .failure(errorEnvelope)
      case .none:
        return .empty
      }

      return client
        .fetchWithResult(query: fetchProjectCommentsQuery, result: projectOnlyResult)
    }

    internal func fetchProject_combine(project _: Project) -> AnyPublisher<Project, ErrorEnvelope> {
      fatalError("Sorry, this is unimplemented!")
    }

    internal func fetchProjectActivities(forProject _: Project) ->
      SignalProducer<ProjectActivityEnvelope, ErrorEnvelope> {
      if let error = fetchProjectActivitiesError {
        return SignalProducer(error: error)
      } else if let activities = fetchProjectActivitiesResponse {
        return SignalProducer(
          value: ProjectActivityEnvelope(
            activities: activities,
            urls: ProjectActivityEnvelope.UrlsEnvelope(
              api: ProjectActivityEnvelope.UrlsEnvelope.ApiEnvelope(
                moreActivities: "http://\(Secrets.Api.Endpoint.production)/gimme/more"
              )
            )
          )
        )
      }
      return .empty
    }

    internal func fetchProjectActivities(paginationUrl _: String)
      -> SignalProducer<ProjectActivityEnvelope, ErrorEnvelope> {
      if let error = fetchProjectActivitiesError {
        return SignalProducer(error: error)
      } else if let activities = fetchProjectActivitiesResponse {
        return SignalProducer(
          value: ProjectActivityEnvelope(
            activities: activities,
            urls: ProjectActivityEnvelope.UrlsEnvelope(
              api: ProjectActivityEnvelope.UrlsEnvelope.ApiEnvelope(
                moreActivities: ""
              )
            )
          )
        )
      }
      return .empty
    }

    internal func fetchProjects(member _: Bool) -> SignalProducer<ProjectsEnvelope, ErrorEnvelope> {
      if let error = fetchProjectsError {
        return SignalProducer(error: error)
      } else if let projects = fetchProjectsResponse {
        return SignalProducer(
          value: ProjectsEnvelope(
            projects: projects,
            urls: ProjectsEnvelope.UrlsEnvelope(
              api: ProjectsEnvelope.UrlsEnvelope.ApiEnvelope(
                moreProjects: ""
              )
            )
          )
        )
      }
      return .empty
    }

    internal func fetchProjects(paginationUrl _: String) ->
      SignalProducer<ProjectsEnvelope, ErrorEnvelope> {
      return self.fetchProjects(member: true)
    }

    internal func fetchProjectStats(projectId _: Int) ->
      SignalProducer<ProjectStatsEnvelope, ErrorEnvelope> {
      if let error = fetchProjectStatsError {
        return SignalProducer(error: error)
      } else if let response = fetchProjectStatsResponse {
        return SignalProducer(value: response)
      }

      return SignalProducer(value: .template)
    }

    internal func fetchRewardShippingRules(projectId _: Int, rewardId _: Int)
      -> SignalProducer<ShippingRulesEnvelope, ErrorEnvelope> {
      if let error = self.fetchShippingRulesResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: .init(shippingRules: self.fetchShippingRulesResult?.value ?? [.template]))
    }

    internal func fetchUserSelf() -> SignalProducer<User, ErrorEnvelope> {
      if let error = fetchUserSelfError {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: self.fetchUserSelfResponse ?? .template)
    }

    func fetchUserSelf_combine(withOAuthToken _: String) -> AnyPublisher<User, ErrorEnvelope> {
      if let error = fetchUserSelfError {
        return Fail(outputType: User.self, failure: self.fetchUserSelfError!).eraseToAnyPublisher()
      }

      return Just(self.fetchUserSelfResponse ?? .template).setFailureType(to: ErrorEnvelope.self)
        .eraseToAnyPublisher()
    }

    internal func fetchSurveyResponse(surveyResponseId id: Int)
      -> SignalProducer<SurveyResponse, ErrorEnvelope> {
      if let response = fetchSurveyResponseResponse {
        return SignalProducer(value: response)
      } else if let error = fetchSurveyResponseError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: .template |> SurveyResponse.lens.id .~ id)
    }

    internal func fetchUnansweredSurveyResponses() -> SignalProducer<[SurveyResponse], ErrorEnvelope> {
      return SignalProducer(value: self.fetchUnansweredSurveyResponsesResponse)
    }

    internal func fetchUser(userId _: Int) -> SignalProducer<User, ErrorEnvelope> {
      return producer(for: self.fetchUserResult)
    }

    internal func fetchUser(_: User) -> SignalProducer<User, ErrorEnvelope> {
      return producer(for: self.fetchUserResult)
    }

    internal func incrementVideoCompletion(for _: any HasProjectWebURL) ->
      SignalProducer<VoidEnvelope, ErrorEnvelope> {
      if let error = incrementVideoCompletionError {
        return .init(error: error)
      } else {
        return .init(value: VoidEnvelope())
      }
    }

    internal func incrementVideoStart(forProject _: any HasProjectWebURL) ->
      SignalProducer<VoidEnvelope, ErrorEnvelope> {
      if let error = incrementVideoStartError {
        return .init(error: error)
      } else {
        return .init(value: VoidEnvelope())
      }
    }

    internal func login(email _: String, password _: String, code _: String?) ->
      SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {
      if let error = loginError {
        return SignalProducer(error: error)
      } else if let accessTokenEnvelope = loginResponse {
        return SignalProducer(value: accessTokenEnvelope)
      } else if let resendCodeResponse = resendCodeResponse {
        return SignalProducer(error: resendCodeResponse)
      } else if let resendCodeError = resendCodeError {
        return SignalProducer(error: resendCodeError)
      }

      return SignalProducer(value: AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
    }

    internal func login(facebookAccessToken _: String, code _: String?) ->
      SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {
      if let error = loginError {
        return SignalProducer(error: error)
      } else if let accessTokenEnvelope = loginResponse {
        return SignalProducer(value: accessTokenEnvelope)
      } else if let resendCodeResponse = resendCodeResponse {
        return SignalProducer(error: resendCodeResponse)
      } else if let resendCodeError = resendCodeError {
        return SignalProducer(error: resendCodeError)
      }

      return SignalProducer(value: AccessTokenEnvelope(accessToken: "deadbeef", user: .template))
    }

    internal func markAsRead(messageThread: MessageThread)
      -> SignalProducer<MessageThread, ErrorEnvelope> {
      return SignalProducer(value: messageThread)
    }

    func postComment(input: PostCommentInput)
      -> SignalProducer<Comment, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .PostCommentMutation(input: GraphAPI.PostCommentInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.postCommentResult)
    }

    func resetPassword(email _: String) -> SignalProducer<User, ErrorEnvelope> {
      if let response = resetPasswordResponse {
        return SignalProducer(value: response)
      } else if let error = resetPasswordError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: .template)
    }

    func register(pushToken _: String) -> SignalProducer<VoidEnvelope, ErrorEnvelope> {
      return SignalProducer(value: VoidEnvelope())
    }

    internal func searchMessages(query _: String, project _: Project?)
      -> SignalProducer<MessageThreadsEnvelope, ErrorEnvelope> {
      return SignalProducer(
        value:
        MessageThreadsEnvelope(
          messageThreads: self.fetchMessageThreadsResponse,
          urls: MessageThreadsEnvelope.UrlsEnvelope(
            api: MessageThreadsEnvelope.UrlsEnvelope.ApiEnvelope(
              moreMessageThreads: ""
            )
          )
        )
      )
    }

    internal func sendMessage(body: String, toSubject _: MessageSubject)
      -> SignalProducer<Message, ErrorEnvelope> {
      return SignalProducer(
        value: .template
          |> Message.lens.id .~ body.hashValue
          |> Message.lens.body .~ body
      )
    }

    internal func sendVerificationEmail(input _: EmptyInput)
      -> SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutationSendVerificationEmail = GraphAPI
        .UserSendEmailVerificationMutation(input: GraphAPI.UserSendEmailVerificationInput())

      return client
        .performWithResult(mutation: mutationSendVerificationEmail, result: self.sendEmailVerificationResult)
    }

    internal func signInWithApple(input: SignInWithAppleInput)
      -> SignalProducer<SignInWithAppleEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutationSignInWithApple = GraphAPI
        .SignInWithAppleMutation(input: GraphAPI.SignInWithAppleInput.from(input))

      return client
        .performWithResult(mutation: mutationSignInWithApple, result: self.signInWithAppleResult)
    }

    internal func signup(facebookAccessToken _: String, sendNewsletters _: Bool) ->
      SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {
      if let error = signupError {
        return SignalProducer(error: error)
      } else if let accessTokenEnvelope = signupResponse {
        return SignalProducer(value: accessTokenEnvelope)
      }
      return SignalProducer(
        value:
        AccessTokenEnvelope(
          accessToken: "deadbeef",
          user: .template
        )
      )
    }

    internal func updateProjectNotification(_ notification: ProjectNotification)
      -> SignalProducer<ProjectNotification, ErrorEnvelope> {
      if let error = updateProjectNotificationError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: notification)
    }

    internal func updateUserSelf(_ user: User) -> SignalProducer<User, ErrorEnvelope> {
      if let error = updateUserSelfError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: user)
    }

    internal func fetchUpdate(updateId: Int, projectParam _: Param)
      -> SignalProducer<Update, ErrorEnvelope> {
      return SignalProducer(value: self.fetchUpdateResponse |> Update.lens.id .~ updateId)
    }

    internal func fetchUpdateDraft(forProject _: Project) -> SignalProducer<UpdateDraft, ErrorEnvelope> {
      if let error = self.fetchDraftError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: self.fetchDraftResponse ?? .template)
    }

    internal func update(draft: UpdateDraft, title: String, body: String, isPublic: Bool)
      -> SignalProducer<UpdateDraft, ErrorEnvelope> {
      if let error = self.updateDraftError {
        return SignalProducer(error: error)
      }
      let updatedDraft = draft
        |> UpdateDraft.lens.update.title .~ title
        |> UpdateDraft.lens.update.body .~ body
        |> UpdateDraft.lens.update.isPublic .~ isPublic

      return SignalProducer(value: updatedDraft)
    }

    internal func updateBacking(input: UpdateBackingInput)
      -> SignalProducer<UpdateBackingEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutationUpdateBacking = GraphAPI
        .UpdateBackingMutation(input: GraphAPI.UpdateBackingInput.from(input))

      return client
        .performWithResult(mutation: mutationUpdateBacking, result: self.updateBackingResult)
    }

    internal func unwatchProject(input: WatchProjectInput)
      -> SignalProducer<WatchProjectResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutationUnwatchProject = GraphAPI
        .UnwatchProjectMutation(input: GraphAPI.UnwatchProjectInput.from(input))

      return client
        .performWithResult(mutation: mutationUnwatchProject, result: self.unwatchProjectMutationResult)
    }

    internal func validateCheckout(
      checkoutId _: String,
      paymentSourceId _: String,
      paymentIntentClientSecret _: String
    ) -> SignalProducer<ValidateCheckoutEnvelope, ErrorEnvelope> {
      return producer(for: self.validateCheckoutResult)
    }

    internal func verifyEmail(withToken _: String)
      -> SignalProducer<EmailVerificationResponseEnvelope, ErrorEnvelope> {
      return producer(for: self.verifyEmailResult)
    }

    internal func watchProject(input: WatchProjectInput)
      -> SignalProducer<WatchProjectResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutationWatchProject = GraphAPI.WatchProjectMutation(input: GraphAPI.WatchProjectInput.from(input))

      return client
        .performWithResult(mutation: mutationWatchProject, result: self.watchProjectMutationResult)
    }

    internal func addImage(file _: URL, toDraft _: UpdateDraft)
      -> SignalProducer<UpdateDraft.Image, ErrorEnvelope> {
      if let error = addAttachmentError {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: self.addAttachmentResponse ?? .template)
    }

    internal func delete(image _: UpdateDraft.Image, fromDraft _: UpdateDraft)
      -> SignalProducer<UpdateDraft.Image, ErrorEnvelope> {
      if let error = removeAttachmentError {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: self.removeAttachmentResponse ?? .template)
    }

    internal func deletePaymentMethod(input: PaymentSourceDeleteInput) -> SignalProducer<
      DeletePaymentMethodEnvelope, ErrorEnvelope
    > {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .DeletePaymentSourceMutation(input: GraphAPI.PaymentSourceDeleteInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.deletePaymentMethodResult)
    }

    internal func triggerThirdPartyEventInput(input: TriggerThirdPartyEventInput) -> ReactiveSwift
      .SignalProducer<EmptyResponseEnvelope, ErrorEnvelope> {
      guard let client = self.apolloClient else {
        return .empty
      }

      let mutation = GraphAPI
        .TriggerThirdPartyEventMutation(input: GraphAPI.TriggerThirdPartyEventInput.from(input))

      return client.performWithResult(mutation: mutation, result: self.triggerThirdPartyEventResult)
    }

    internal func publish(draft _: UpdateDraft) -> SignalProducer<Update, ErrorEnvelope> {
      if let error = publishUpdateError {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: self.fetchUpdateResponse)
    }

    internal func previewUrl(forDraft draft: UpdateDraft) -> URL? {
      return URL(
        string: "https://\(Secrets.Api.Endpoint.production)/projects/\(draft.update.projectId)/updates/"
          + "\(draft.update.id)/preview"
      )
    }

    func fetchDiscovery_combine(params _: DiscoveryParams) -> AnyPublisher<DiscoveryEnvelope, ErrorEnvelope> {
      return Empty(completeImmediately: false).eraseToAnyPublisher()
    }

    func fetchDiscovery_combine(paginationUrl _: String) -> AnyPublisher<DiscoveryEnvelope, ErrorEnvelope> {
      Empty(completeImmediately: false).eraseToAnyPublisher()
    }

    func exchangeTokenForOAuthToken(params _: OAuthTokenExchangeParams)
      -> AnyPublisher<OAuthTokenExchangeResponse, ErrorEnvelope> {
      if let tokenExchangeResponse = self.tokenExchangeResponse {
        return Just(tokenExchangeResponse).setFailureType(to: ErrorEnvelope.self).eraseToAnyPublisher()
      } else if let loginError = self.loginError {
        return Fail(outputType: OAuthTokenExchangeResponse.self, failure: loginError).eraseToAnyPublisher()
      } else {
        return Empty(completeImmediately: false).eraseToAnyPublisher()
      }
    }

    func confirmBackingAddress(
      backingId _: String,
      addressId _: String
    ) -> AnyPublisher<Bool, ErrorEnvelope> {
      guard let confirmResponse = self.confirmBackingAddressResult else {
        return Fail(outputType: Bool.self, failure: ErrorEnvelope.couldNotParseErrorEnvelopeJSON)
          .eraseToAnyPublisher()
      }

      switch confirmResponse {
      case let .success(didMutationSucceed):
        return Just(didMutationSucceed).setFailureType(to: ErrorEnvelope.self).eraseToAnyPublisher()

      case let .failure(envelope):
        return Fail(outputType: Bool.self, failure: envelope).eraseToAnyPublisher()
      }
    }

    func fetchPledgedProjects(
      cursor _: String?,
      limit _: Int?
    ) -> AnyPublisher<GraphAPI.FetchPledgedProjectsQuery.Data, ErrorEnvelope> {
      guard let response = self.fetchPledgedProjectsResult else {
        return Fail(
          outputType: GraphAPI.FetchPledgedProjectsQuery.Data.self,
          failure: ErrorEnvelope.couldNotParseErrorEnvelopeJSON
        )
        .eraseToAnyPublisher()
      }

      switch response {
      case let .success(pledgedProjectsData):
        return Just(pledgedProjectsData).setFailureType(to: ErrorEnvelope.self).delay(
          for: 0.01,
          scheduler: DispatchQueue.main
        ).eraseToAnyPublisher()

      case let .failure(envelope):
        return Fail(outputType: GraphAPI.FetchPledgedProjectsQuery.Data.self, failure: envelope)
          .eraseToAnyPublisher()
      }
    }
  }

  private extension MockService {
    enum lens {
      static let oauthToken = Lens<MockService, OauthTokenAuthType?>(
        view: { $0.oauthToken },
        set: {
          MockService(
            appId: $1.appId,
            serverConfig: $1.serverConfig,
            oauthToken: $0,
            language: $1.language,
            buildVersion: $1.buildVersion,
            addNewCreditCardResult: $1.addNewCreditCardResult,
            changePaymentMethodResult: $1.changePaymentMethodResult,
            deletePaymentMethodResult: $1.deletePaymentMethodResult,
            clearUserUnseenActivityResult: $1.clearUserUnseenActivityResult,
            facebookConnectResponse: $1.facebookConnectResponse,
            facebookConnectError: $1.facebookConnectError,
            fetchActivitiesResponse: $1.fetchActivitiesResponse,
            fetchActivitiesError: $1.fetchActivitiesError,
            fetchBackingResponse: $1.fetchBackingResponse,
            fetchGraphCategoryResult: $1.fetchGraphCategoryResult,
            fetchGraphCategoriesResult: $1.fetchGraphCategoriesResult,
            fetchProjectCommentsEnvelopeResult: $1.fetchProjectCommentsEnvelopeResult,
            fetchConfigResponse: $1.fetchConfigResponse,
            fetchDiscoveryResponse: $1.fetchDiscoveryResponse,
            fetchDiscoveryError: $1.fetchDiscoveryError,
            fetchFriendsResponse: $1.fetchFriendsResponse,
            fetchFriendsError: $1.fetchFriendsError,
            fetchFriendStatsResponse: $1.fetchFriendStatsResponse,
            fetchFriendStatsError: $1.fetchFriendStatsError,
            fetchDraftResponse: $1.fetchDraftResponse,
            fetchDraftError: $1.fetchDraftError,
            fetchGraphUserResult: $1.fetchGraphUserResult,
            fetchGraphUserSelfResult: $1.fetchGraphUserSelfResult,
            fetchGraphUserEmailResult: $1.fetchGraphUserEmailResult,
            addAttachmentResponse: $1.addAttachmentResponse,
            addAttachmentError: $1.addAttachmentError,
            removeAttachmentResponse: $1.removeAttachmentResponse,
            removeAttachmentError: $1.removeAttachmentError,
            publishUpdateError: $1.publishUpdateError,
            fetchManagePledgeViewBackingResult: $1.fetchManagePledgeViewBackingResult,
            fetchMessageThreadResult: $1.fetchMessageThreadResult,
            fetchMessageThreadsResponse: $1.fetchMessageThreadsResponse,
            fetchProjectResult: $1.fetchProjectEnvelopeResult,
            fetchProjectFriendsResult: $1.fetchProjectFriendsEnvelopeResult,
            fetchProjectRewardsResult: $1.fetchProjectRewardsEnvelopeResult,
            fetchProjectActivitiesResponse: $1.fetchProjectActivitiesResponse,
            fetchProjectActivitiesError: $1.fetchProjectActivitiesError,
            fetchProjectNotificationsResponse: $1.fetchProjectNotificationsResponse,
            fetchProjectsResponse: $1.fetchProjectsResponse,
            fetchProjectsError: $1.fetchProjectsError,
            fetchProjectStatsResponse: $1.fetchProjectStatsResponse,
            fetchProjectStatsError: $1.fetchProjectStatsError,
            fetchShippingRulesResult: $1.fetchShippingRulesResult,
            fetchUserResult: $1.fetchUserResult,
            fetchUserSelfResponse: $1.fetchUserSelfResponse,
            followFriendError: $1.followFriendError,
            incrementVideoCompletionError: $1.incrementVideoCompletionError,
            incrementVideoStartError: $1.incrementVideoStartError,
            fetchSurveyResponseResponse: $1.fetchSurveyResponseResponse,
            fetchSurveyResponseError: $1.fetchSurveyResponseError,
            fetchUnansweredSurveyResponsesResponse: $1.fetchUnansweredSurveyResponsesResponse,
            fetchUpdateResponse: $1.fetchUpdateResponse,
            fetchUserSelfError: $1.fetchUserSelfError,
            postCommentResult: $1.postCommentResult,
            loginResponse: $1.loginResponse,
            loginError: $1.loginError,
            resendCodeResponse: $1.resendCodeResponse,
            resendCodeError: $1.resendCodeError,
            resetPasswordResponse: $1.resetPasswordResponse,
            resetPasswordError: $1.resetPasswordError,
            signupResponse: $1.signupResponse,
            signupError: $1.signupError,
            unfollowFriendError: $1.unfollowFriendError,
            updateBackingResult: $1.updateBackingResult,
            updateDraftError: $1.updateDraftError,
            updatePledgeResult: $1.updatePledgeResult,
            updateProjectNotificationResponse: $1.updateProjectNotificationResponse,
            updateProjectNotificationError: $1.updateProjectNotificationError,
            updateUserSelfError: $1.updateUserSelfError,
            unwatchProjectMutationResult: $1.unwatchProjectMutationResult,
            watchProjectMutationResult: $1.watchProjectMutationResult
          )
        }
      )
    }
  }

  private func producer<T, E>(for property: Result<T, E>?) -> SignalProducer<T, E> {
    guard let result = property else { return .empty }
    switch result {
    case let .success(value): return .init(value: value)
    case let .failure(error): return .init(error: error)
    }
  }
#endif

private extension Result {
  var value: Success? {
    switch self {
    case let .success(value): return value
    case .failure: return nil
    }
  }

  var error: Failure? {
    switch self {
    case .success: return nil
    case let .failure(error): return error
    }
  }
}

extension GraphAPI.CompleteOnSessionCheckoutMutation.Data: Decodable {
  public init(from _: Decoder) throws {
    fatalError("The test code should not actually be decoding this object.")
  }
}

extension GraphAPI.BuildPaymentPlanQuery.Data: Decodable {
  public init(from _: Decoder) throws {
    fatalError("The test code should not actually be decoding this object.")
  }
}
