#if DEBUG
  import Foundation
  import Prelude
  import ReactiveSwift

  internal struct MockService: ServiceType {
    internal let appId: String
    internal let serverConfig: ServerConfigType
    internal let oauthToken: OauthTokenAuthType?
    internal let language: String
    internal let currency: String
    internal let buildVersion: String
    internal let deviceIdentifier: String

    fileprivate let addNewCreditCardResult: Result<CreatePaymentSourceEnvelope, GraphError>?

    fileprivate let cancelBackingResult: Result<GraphMutationEmptyResponseEnvelope, GraphError>?

    fileprivate let changeCurrencyResponse: GraphMutationEmptyResponseEnvelope?
    fileprivate let changeCurrencyError: GraphError?

    fileprivate let changeEmailError: GraphError?
    fileprivate let changeEmailResponse: UserEnvelope<UserEmailFields>?

    fileprivate let changePasswordError: GraphError?

    fileprivate let createBackingResult: Result<CreateBackingEnvelope, GraphError>?

    fileprivate let createPasswordError: GraphError?

    fileprivate let changePaymentMethodResult: Result<ChangePaymentMethodEnvelope, ErrorEnvelope>?

    fileprivate let clearUserUnseenActivityResult: Result<ClearUserUnseenActivityEnvelope, GraphError>?

    fileprivate let deletePaymentMethodResult: Result<DeletePaymentMethodEnvelope, GraphError>?

    fileprivate let facebookConnectResponse: User?
    fileprivate let facebookConnectError: ErrorEnvelope?

    fileprivate let fetchActivitiesResponse: [Activity]?
    fileprivate let fetchActivitiesError: ErrorEnvelope?

    fileprivate let fetchBackingResponse: Backing
    fileprivate let backingUpdate: Backing

    fileprivate let fetchGraphCategoriesResponse: RootCategoriesEnvelope?
    fileprivate let fetchGraphCategoriesError: GraphError?

    fileprivate let fetchCommentsResponse: [Comment]?
    fileprivate let fetchCommentsError: ErrorEnvelope?

    fileprivate let fetchConfigResponse: Config?

    fileprivate let fetchDiscoveryResponse: DiscoveryEnvelope?
    fileprivate let fetchDiscoveryError: ErrorEnvelope?

    fileprivate let fetchFriendsResponse: FindFriendsEnvelope?
    fileprivate let fetchFriendsError: ErrorEnvelope?

    fileprivate let fetchFriendStatsResponse: FriendStatsEnvelope?
    fileprivate let fetchFriendStatsError: ErrorEnvelope?

    fileprivate let fetchExportStateResponse: ExportDataEnvelope?
    fileprivate let fetchExportStateError: ErrorEnvelope?

    fileprivate let exportDataError: ErrorEnvelope?

    fileprivate let fetchDraftResponse: UpdateDraft?
    fileprivate let fetchDraftError: ErrorEnvelope?

    fileprivate let fetchGraphUserEmailFieldsResponse: UserEmailFields?

    fileprivate let fetchGraphCreditCardsResponse: UserEnvelope<GraphUserCreditCard>?
    fileprivate let fetchGraphCreditCardsError: GraphError?

    fileprivate let fetchGraphUserAccountFieldsResponse: UserEnvelope<GraphUser>?
    fileprivate let fetchGraphUserAccountFieldsError: GraphError?

    fileprivate let fetchGraphUserBackingsResponse: UserEnvelope<GraphBackingEnvelope>?
    fileprivate let fetchGraphUserBackingsError: GraphError?

    fileprivate let addAttachmentResponse: UpdateDraft.Image?
    fileprivate let addAttachmentError: ErrorEnvelope?
    fileprivate let removeAttachmentResponse: UpdateDraft.Image?
    fileprivate let removeAttachmentError: ErrorEnvelope?

    fileprivate let publishUpdateError: ErrorEnvelope?

    fileprivate let fetchManagePledgeViewBackingResult: Result<ManagePledgeViewBackingEnvelope, GraphError>?

    fileprivate let fetchMessageThreadResult: Result<MessageThread?, ErrorEnvelope>?
    fileprivate let fetchMessageThreadsResponse: [MessageThread]

    fileprivate let fetchProjectResponse: Project?
    fileprivate let fetchProjectError: ErrorEnvelope?

    fileprivate let fetchProjectsResponse: [Project]?
    fileprivate let fetchProjectsError: ErrorEnvelope?

    fileprivate let fetchProjectCreatorDetailsResult: Result<ProjectCreatorDetailsEnvelope, GraphError>?

    fileprivate let fetchProjectNotificationsResponse: [ProjectNotification]

    fileprivate let fetchProjectStatsResponse: ProjectStatsEnvelope?
    fileprivate let fetchProjectStatsError: ErrorEnvelope?

    fileprivate let fetchProjectSummaryResult: Result<ProjectSummaryEnvelope, GraphError>?

    fileprivate let fetchShippingRulesResult: Result<[ShippingRule], ErrorEnvelope>?

    fileprivate let fetchSurveyResponseResponse: SurveyResponse?
    fileprivate let fetchSurveyResponseError: ErrorEnvelope?

    fileprivate let fetchUnansweredSurveyResponsesResponse: [SurveyResponse]

    fileprivate let fetchUpdateCommentsResponse: Result<CommentsEnvelope, ErrorEnvelope>?

    fileprivate let fetchUpdateResponse: Update

    fileprivate let fetchUserProjectsBackedResponse: [Project]?
    fileprivate let fetchUserProjectsBackedError: ErrorEnvelope?

    fileprivate let fetchUserResponse: User?
    fileprivate let fetchUserError: ErrorEnvelope?

    fileprivate let fetchUserSelfResponse: User?
    fileprivate let fetchUserSelfError: ErrorEnvelope?

    fileprivate let followFriendError: ErrorEnvelope?

    fileprivate let incrementVideoCompletionError: ErrorEnvelope?

    fileprivate let incrementVideoStartError: ErrorEnvelope?

    fileprivate let postCommentResponse: Comment?
    fileprivate let postCommentError: ErrorEnvelope?

    fileprivate let fetchProjectActivitiesResponse: [Activity]?
    fileprivate let fetchProjectActivitiesError: ErrorEnvelope?

    fileprivate let loginResponse: AccessTokenEnvelope?
    fileprivate let loginError: ErrorEnvelope?
    fileprivate let resendCodeResponse: ErrorEnvelope?
    fileprivate let resendCodeError: ErrorEnvelope?

    fileprivate let resetPasswordResponse: User?
    fileprivate let resetPasswordError: ErrorEnvelope?

    fileprivate let sendEmailVerificationResponse: GraphMutationEmptyResponseEnvelope?
    fileprivate let sendEmailVerificationError: GraphError?

    fileprivate let signInWithAppleResult: Result<SignInWithAppleEnvelope, GraphError>?

    fileprivate let signupResponse: AccessTokenEnvelope?
    fileprivate let signupError: ErrorEnvelope?

    fileprivate let unfollowFriendError: ErrorEnvelope?

    fileprivate let updateBackingResult: Result<UpdateBackingEnvelope, GraphError>?

    fileprivate let updateDraftError: ErrorEnvelope?

    fileprivate let updatePledgeResult: Result<UpdatePledgeEnvelope, ErrorEnvelope>?

    fileprivate let updateProjectNotificationResponse: ProjectNotification?
    fileprivate let updateProjectNotificationError: ErrorEnvelope?

    fileprivate let updateUserSelfError: ErrorEnvelope?

    fileprivate let unwatchProjectMutationResult: Result<
      GraphMutationWatchProjectResponseEnvelope,
      GraphError
    >?

    fileprivate let watchProjectMutationResult: Result<GraphMutationWatchProjectResponseEnvelope, GraphError>?

    internal init(
      appId: String = "com.kickstarter.kickstarter.mock",
      serverConfig: ServerConfigType,
      oauthToken: OauthTokenAuthType?,
      language: String,
      currency: String,
      buildVersion: String = "1",
      deviceIdentifier: String = "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFBEEF"
    ) {
      self.init(
        appId: appId,
        serverConfig: serverConfig,
        oauthToken: oauthToken,
        language: language,
        currency: currency,
        buildVersion: buildVersion,
        deviceIdentifier: deviceIdentifier,
        fetchActivitiesResponse: nil
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
      addNewCreditCardResult: Result<CreatePaymentSourceEnvelope, GraphError>? = nil,
      cancelBackingResult: Result<GraphMutationEmptyResponseEnvelope, GraphError>? = nil,
      changeEmailError: GraphError? = nil,
      changeEmailResponse: UserEnvelope<UserEmailFields>? = UserEnvelope<UserEmailFields>(
        me: .template
      ),
      changePasswordError: GraphError? = nil,
      createBackingResult: Result<CreateBackingEnvelope, GraphError>? = nil,
      createPasswordError: GraphError? = nil,
      changeCurrencyResponse: GraphMutationEmptyResponseEnvelope? = nil,
      changeCurrencyError: GraphError? = nil,
      changePaymentMethodResult: Result<ChangePaymentMethodEnvelope, ErrorEnvelope>? = nil,
      clearUserUnseenActivityResult: Result<ClearUserUnseenActivityEnvelope, GraphError>? = nil,
      deletePaymentMethodResult: Result<DeletePaymentMethodEnvelope, GraphError>? = nil,
      facebookConnectResponse: User? = nil,
      facebookConnectError: ErrorEnvelope? = nil,
      fetchActivitiesResponse: [Activity]? = nil,
      fetchActivitiesError: ErrorEnvelope? = nil,
      fetchBackingResponse: Backing = .template,
      backingUpdate: Backing = .template,
      fetchGraphCategoriesResponse: RootCategoriesEnvelope? = nil,
      fetchGraphCategoriesError: GraphError? = nil,
      fetchCommentsResponse: [Comment]? = nil,
      fetchCommentsError: ErrorEnvelope? = nil,
      fetchConfigResponse: Config? = nil,
      fetchDiscoveryResponse: DiscoveryEnvelope? = nil,
      fetchDiscoveryError: ErrorEnvelope? = nil,
      fetchFriendsResponse: FindFriendsEnvelope? = nil,
      fetchFriendsError: ErrorEnvelope? = nil,
      fetchFriendStatsResponse: FriendStatsEnvelope? = nil,
      fetchFriendStatsError: ErrorEnvelope? = nil,
      fetchExportStateResponse: ExportDataEnvelope? = nil,
      fetchExportStateError: ErrorEnvelope? = nil,
      fetchGraphCreditCardsResponse: UserEnvelope<GraphUserCreditCard>? = nil,
      fetchGraphCreditCardsError: GraphError? = nil,
      exportDataError: ErrorEnvelope? = nil,
      fetchDraftResponse: UpdateDraft? = nil,
      fetchDraftError: ErrorEnvelope? = nil,
      fetchGraphUserEmailFieldsResponse: UserEmailFields? = nil,
      fetchGraphUserAccountFieldsResponse: UserEnvelope<GraphUser>? = nil,
      fetchGraphUserAccountFieldsError: GraphError? = nil,
      fetchGraphUserBackingsResponse: UserEnvelope<GraphBackingEnvelope>? = nil,
      fetchGraphUserBackingsError: GraphError? = nil,
      addAttachmentResponse: UpdateDraft.Image? = nil,
      addAttachmentError: ErrorEnvelope? = nil,
      removeAttachmentResponse: UpdateDraft.Image? = nil,
      removeAttachmentError: ErrorEnvelope? = nil,
      publishUpdateError: ErrorEnvelope? = nil,
      fetchManagePledgeViewBackingResult: Result<ManagePledgeViewBackingEnvelope, GraphError>? = nil,
      fetchMessageThreadResult: Result<MessageThread?, ErrorEnvelope>? = nil,
      fetchMessageThreadsResponse: [MessageThread]? = nil,
      fetchProjectResponse: Project? = nil,
      fetchProjectError: ErrorEnvelope? = nil,
      fetchProjectActivitiesResponse: [Activity]? = nil,
      fetchProjectActivitiesError: ErrorEnvelope? = nil,
      fetchProjectCreatorDetailsResult: Result<ProjectCreatorDetailsEnvelope, GraphError>? = nil,
      fetchProjectNotificationsResponse: [ProjectNotification]? = nil,
      fetchProjectsResponse: [Project]? = nil,
      fetchProjectsError: ErrorEnvelope? = nil,
      fetchProjectStatsResponse: ProjectStatsEnvelope? = nil,
      fetchProjectStatsError: ErrorEnvelope? = nil,
      fetchProjectSummaryResult: Result<ProjectSummaryEnvelope, GraphError>? = nil,
      fetchShippingRulesResult: Result<[ShippingRule], ErrorEnvelope>? = nil,
      fetchUserProjectsBackedResponse: [Project]? = nil,
      fetchUserProjectsBackedError: ErrorEnvelope? = nil,
      fetchUserResponse: User? = nil,
      fetchUserError: ErrorEnvelope? = nil,
      fetchUserSelfResponse: User? = nil,
      followFriendError: ErrorEnvelope? = nil,
      incrementVideoCompletionError: ErrorEnvelope? = nil,
      incrementVideoStartError: ErrorEnvelope? = nil,
      fetchSurveyResponseResponse: SurveyResponse? = nil,
      fetchSurveyResponseError: ErrorEnvelope? = nil,
      fetchUnansweredSurveyResponsesResponse: [SurveyResponse] = [],
      fetchUpdateCommentsResponse: Result<CommentsEnvelope, ErrorEnvelope>? = nil,
      fetchUpdateResponse: Update = .template,
      fetchUserSelfError: ErrorEnvelope? = nil,
      postCommentResponse: Comment? = nil,
      postCommentError: ErrorEnvelope? = nil,
      loginResponse: AccessTokenEnvelope? = nil,
      loginError: ErrorEnvelope? = nil,
      resendCodeResponse: ErrorEnvelope? = nil,
      resendCodeError: ErrorEnvelope? = nil,
      resetPasswordResponse: User? = nil,
      resetPasswordError: ErrorEnvelope? = nil,
      sendEmailVerificationResponse: GraphMutationEmptyResponseEnvelope? = nil,
      sendEmailVerificationError: GraphError? = nil,
      signInWithAppleResult: Result<SignInWithAppleEnvelope, GraphError>? = nil,
      signupResponse: AccessTokenEnvelope? = nil,
      signupError: ErrorEnvelope? = nil,
      unfollowFriendError: ErrorEnvelope? = nil,
      updateBackingResult: Result<UpdateBackingEnvelope, GraphError>? = nil,
      updateDraftError: ErrorEnvelope? = nil,
      updatePledgeResult: Result<UpdatePledgeEnvelope, ErrorEnvelope>? = nil,
      updateProjectNotificationResponse: ProjectNotification? = nil,
      updateProjectNotificationError: ErrorEnvelope? = nil,
      updateUserSelfError: ErrorEnvelope? = nil,
      unwatchProjectMutationResult: Result<GraphMutationWatchProjectResponseEnvelope, GraphError>? = nil,
      watchProjectMutationResult: Result<GraphMutationWatchProjectResponseEnvelope, GraphError>? = nil
    ) {
      self.appId = appId
      self.serverConfig = serverConfig
      self.oauthToken = oauthToken
      self.language = language
      self.currency = currency
      self.buildVersion = buildVersion
      self.deviceIdentifier = deviceIdentifier

      self.addNewCreditCardResult = addNewCreditCardResult

      self.cancelBackingResult = cancelBackingResult

      self.changeCurrencyResponse = changeCurrencyResponse
      self.changeCurrencyError = changeCurrencyError

      self.changeEmailResponse = changeEmailResponse
      self.changeEmailError = changeEmailError

      self.changePasswordError = changePasswordError

      self.clearUserUnseenActivityResult = clearUserUnseenActivityResult

      self.createBackingResult = createBackingResult

      self.createPasswordError = createPasswordError

      self.changePaymentMethodResult = changePaymentMethodResult
      self.deletePaymentMethodResult = deletePaymentMethodResult

      self.facebookConnectResponse = facebookConnectResponse
      self.facebookConnectError = facebookConnectError

      self.fetchActivitiesResponse = fetchActivitiesResponse ?? [
        .template,
        .template |> Activity.lens.category .~ .backing,
        .template |> Activity.lens.category .~ .success
      ]

      self.fetchActivitiesError = fetchActivitiesError

      self.fetchBackingResponse = fetchBackingResponse

      self.backingUpdate = backingUpdate

      self.fetchGraphCategoriesResponse = fetchGraphCategoriesResponse ?? (RootCategoriesEnvelope.template
        |> RootCategoriesEnvelope.lens.categories .~ [
          .art,
          .filmAndVideo,
          .illustration,
          .documentary
        ]
      )

      self.fetchGraphCategoriesError = fetchGraphCategoriesError

      self.fetchGraphUserAccountFieldsResponse = fetchGraphUserAccountFieldsResponse
        ?? UserEnvelope(me: GraphUser.template)
      self.fetchGraphUserAccountFieldsError = fetchGraphUserAccountFieldsError

      self.fetchGraphUserEmailFieldsResponse = fetchGraphUserEmailFieldsResponse

      self.fetchGraphUserBackingsResponse = fetchGraphUserBackingsResponse
      self.fetchGraphUserBackingsError = fetchGraphUserBackingsError

      self.fetchCommentsResponse = fetchCommentsResponse ?? [
        .template |> Comment.lens.id .~ 2,
        .template |> Comment.lens.id .~ 1
      ]

      self.fetchCommentsError = fetchCommentsError

      self.fetchConfigResponse = fetchConfigResponse ?? .template

      self.fetchDiscoveryResponse = fetchDiscoveryResponse
      self.fetchDiscoveryError = fetchDiscoveryError

      self.fetchFriendsResponse = fetchFriendsResponse
      self.fetchFriendsError = fetchFriendsError

      self.fetchFriendStatsResponse = fetchFriendStatsResponse
      self.fetchFriendStatsError = fetchFriendStatsError

      self.fetchExportStateResponse = fetchExportStateResponse
      self.fetchExportStateError = fetchExportStateError

      self.exportDataError = exportDataError

      self.fetchDraftResponse = fetchDraftResponse
      self.fetchDraftError = fetchDraftError

      self.addAttachmentResponse = addAttachmentResponse
      self.addAttachmentError = addAttachmentError
      self.removeAttachmentResponse = removeAttachmentResponse
      self.removeAttachmentError = removeAttachmentError

      self.publishUpdateError = publishUpdateError

      self.fetchManagePledgeViewBackingResult = fetchManagePledgeViewBackingResult

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

      self.fetchProjectResponse = fetchProjectResponse
      self.fetchProjectError = fetchProjectError

      self.fetchProjectNotificationsResponse = fetchProjectNotificationsResponse ?? [
        .template |> ProjectNotification.lens.id .~ 1,
        .template |> ProjectNotification.lens.id .~ 2,
        .template |> ProjectNotification.lens.id .~ 3
      ]

      self.fetchProjectsResponse = fetchProjectsResponse ?? []

      self.fetchProjectCreatorDetailsResult = fetchProjectCreatorDetailsResult

      self.fetchProjectsError = fetchProjectsError

      self.fetchProjectStatsResponse = fetchProjectStatsResponse
      self.fetchProjectStatsError = fetchProjectStatsError

      self.fetchProjectSummaryResult = fetchProjectSummaryResult

      self.fetchShippingRulesResult = fetchShippingRulesResult

      self.fetchSurveyResponseResponse = fetchSurveyResponseResponse
      self.fetchSurveyResponseError = fetchSurveyResponseError

      self.fetchUnansweredSurveyResponsesResponse = fetchUnansweredSurveyResponsesResponse

      self.fetchUpdateCommentsResponse = fetchUpdateCommentsResponse

      self.fetchUpdateResponse = fetchUpdateResponse

      self.fetchUserProjectsBackedResponse = fetchUserProjectsBackedResponse
      self.fetchUserProjectsBackedError = fetchUserProjectsBackedError

      self.fetchUserResponse = fetchUserResponse
      self.fetchUserError = fetchUserError
      self.fetchGraphCreditCardsError = fetchGraphCreditCardsError

      self.fetchGraphCreditCardsResponse = fetchGraphCreditCardsResponse

      self.fetchUserSelfResponse = fetchUserSelfResponse ?? .template
      self.fetchUserSelfError = fetchUserSelfError

      self.followFriendError = followFriendError

      self.incrementVideoCompletionError = incrementVideoCompletionError

      self.incrementVideoStartError = incrementVideoStartError

      self.postCommentResponse = postCommentResponse ?? .template

      self.postCommentError = postCommentError

      self.loginResponse = loginResponse

      self.loginError = loginError

      self.resendCodeResponse = resendCodeResponse

      self.resendCodeError = resendCodeError

      self.resetPasswordResponse = resetPasswordResponse

      self.resetPasswordError = resetPasswordError

      self.sendEmailVerificationResponse = sendEmailVerificationResponse

      self.sendEmailVerificationError = sendEmailVerificationError

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

      self.watchProjectMutationResult = watchProjectMutationResult
    }

    public func addNewCreditCard(input _: CreatePaymentSourceInput)
      -> SignalProducer<CreatePaymentSourceEnvelope, GraphError> {
      return producer(for: self.addNewCreditCardResult)
    }

    public func cancelBacking(input _: CancelBackingInput)
      -> SignalProducer<GraphMutationEmptyResponseEnvelope, GraphError> {
      return producer(for: self.cancelBackingResult)
    }

    internal func changeEmail(input _: ChangeEmailInput) ->
      SignalProducer<GraphMutationEmptyResponseEnvelope, GraphError> {
      if let error = self.changeEmailError {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: GraphMutationEmptyResponseEnvelope())
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

    internal func changePassword(input _: ChangePasswordInput) ->
      SignalProducer<GraphMutationEmptyResponseEnvelope, GraphError> {
      if let error = self.changePasswordError {
        return SignalProducer(error: error)
      } else {
        return SignalProducer(value: GraphMutationEmptyResponseEnvelope())
      }
    }

    internal func createBacking(input _: CreateBackingInput)
      -> SignalProducer<CreateBackingEnvelope, GraphError> {
      return producer(for: self.createBackingResult)
    }

    internal func createPassword(input _: CreatePasswordInput) ->
      SignalProducer<GraphMutationEmptyResponseEnvelope, GraphError> {
      if let error = self.createPasswordError {
        return SignalProducer(error: error)
      } else {
        return SignalProducer(value: GraphMutationEmptyResponseEnvelope())
      }
    }

    internal func changeCurrency(input _: ChangeCurrencyInput) ->
      SignalProducer<GraphMutationEmptyResponseEnvelope, GraphError> {
      if let response = self.changeCurrencyResponse {
        return SignalProducer(value: response)
      } else if let error = self.changeCurrencyError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: GraphMutationEmptyResponseEnvelope())
    }

    internal func clearUserUnseenActivity(input _: EmptyInput)
      -> SignalProducer<ClearUserUnseenActivityEnvelope, GraphError> {
      return producer(for: self.clearUserUnseenActivityResult)
    }

    internal func fetchComments(project _: Project) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
      if let error = fetchCommentsError {
        return SignalProducer(error: error)
      } else if let comments = fetchCommentsResponse {
        return SignalProducer(
          value: CommentsEnvelope(
            comments: comments,
            urls: CommentsEnvelope.UrlsEnvelope(
              api: CommentsEnvelope.UrlsEnvelope.ApiEnvelope(
                moreComments: ""
              )
            )
          )
        )
      }
      return .empty
    }

    internal func fetchComments(paginationUrl _: String) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
      if let error = fetchCommentsError {
        return SignalProducer(error: error)
      } else if let comments = fetchCommentsResponse {
        return SignalProducer(
          value: CommentsEnvelope(
            comments: comments,
            urls: CommentsEnvelope.UrlsEnvelope(
              api: CommentsEnvelope.UrlsEnvelope.ApiEnvelope(
                moreComments: ""
              )
            )
          )
        )
      }
      return .empty
    }

    internal func fetchComments(update _: Update) -> SignalProducer<CommentsEnvelope, ErrorEnvelope> {
      if let error = fetchUpdateCommentsResponse?.error {
        return SignalProducer(error: error)
      } else if let comments = fetchUpdateCommentsResponse {
        return SignalProducer(value: comments.value ?? .template)
      }
      return .empty
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

    internal func exportData() -> SignalProducer<VoidEnvelope, ErrorEnvelope> {
      if let error = exportDataError {
        return SignalProducer(error: error)
      }
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

    internal func fetchGraphCategories(query _: NonEmptySet<Query>)
      -> SignalProducer<RootCategoriesEnvelope, GraphError> {
      if let error = self.fetchGraphCategoriesError {
        return SignalProducer(error: error)
      } else if let response = self.fetchGraphCategoriesResponse {
        return SignalProducer(value: response)
      }
      return SignalProducer(value: RootCategoriesEnvelope.template)
    }

    internal func fetchGraphCategory(query: NonEmptySet<Query>)
      -> SignalProducer<CategoryEnvelope, GraphError> {
      return SignalProducer(value: CategoryEnvelope(node: .template |> Category.lens.id .~ "\(query.head)"))
    }

    internal func fetchGraphCreditCards(query _: NonEmptySet<Query>)
      -> SignalProducer<UserEnvelope<GraphUserCreditCard>, GraphError> {
      if let error = fetchGraphCreditCardsError {
        return SignalProducer(error: error)
      }

      return SignalProducer(
        value: self.fetchGraphCreditCardsResponse ??
          UserEnvelope<GraphUserCreditCard>(me: GraphUserCreditCard.template)
      )
    }

    internal func fetchGraphUserEmailFields(query _: NonEmptySet<Query>)
      -> SignalProducer<UserEnvelope<UserEmailFields>, GraphError> {
      let response = self.fetchGraphUserEmailFieldsResponse ?? .template

      return SignalProducer(value: UserEnvelope(me: response))
    }

    internal func fetchGraphUserAccountFields(query _: NonEmptySet<Query>)
      -> SignalProducer<UserEnvelope<GraphUser>, GraphError> {
      if let error = self.fetchGraphUserAccountFieldsError {
        return SignalProducer(error: error)
      } else if let response = self.fetchGraphUserAccountFieldsResponse {
        return SignalProducer(value: response)
      } else {
        return .empty
      }
    }

    internal func fetchGraphUserBackings(query _: NonEmptySet<Query>)
      -> SignalProducer<UserEnvelope<GraphBackingEnvelope>, GraphError> {
      if let error = fetchGraphUserBackingsError {
        return SignalProducer(error: error)
      }
      let backings = GraphBackingEnvelope.GraphBackingConnection(nodes: [])
      let emptyEnvelope = GraphBackingEnvelope.template
        |> \.backings .~ backings
      let emptyResponse = UserEnvelope<GraphBackingEnvelope>(me: emptyEnvelope)

      let response = self.fetchGraphUserBackingsResponse ?? emptyResponse
      return SignalProducer(value: response)
    }

    internal func fetchGraph<A>(
      query _: NonEmptySet<Query>
    ) -> SignalProducer<A, GraphError> where A: Decodable {
      return .empty
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
      let envelope = self.fetchDiscoveryResponse ?? (.template
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
      let envelope = self.fetchDiscoveryResponse ?? (.template
        |> DiscoveryEnvelope.lens.projects .~ (1...4).map(project)
      )

      return SignalProducer(value: envelope)
    }

    func fetchManagePledgeViewBacking(query _: NonEmptySet<Query>)
      -> SignalProducer<ManagePledgeViewBackingEnvelope, GraphError> {
      return producer(for: self.fetchManagePledgeViewBackingResult)
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

    internal func fetchProject(param: Param) -> SignalProducer<Project, ErrorEnvelope> {
      if let error = self.fetchProjectError {
        return SignalProducer(error: error)
      }
      if let project = self.fetchProjectResponse {
        return SignalProducer(value: project)
      }

      let projectWithId = Project.template
        |> Project.lens.id %~ { param.id ?? $0 }

      let projectWithSlugAndId = projectWithId
        |> Project.lens.slug %~ { param.slug ?? $0 }

      return SignalProducer(
        value: projectWithSlugAndId
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
      if let project = self.fetchProjectResponse {
        return SignalProducer(value: project)
      }
      return SignalProducer(value: project)
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

    func fetchProjectCreatorDetails(query _: NonEmptySet<Query>)
      -> SignalProducer<ProjectCreatorDetailsEnvelope, GraphError> {
      return producer(for: self.fetchProjectCreatorDetailsResult)
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

    internal func fetchProjectSummary(query _: NonEmptySet<Query>)
      -> SignalProducer<ProjectSummaryEnvelope, GraphError> {
      return producer(for: self.fetchProjectSummaryResult)
    }

    internal func fetchRewardShippingRules(projectId _: Int, rewardId _: Int)
      -> SignalProducer<ShippingRulesEnvelope, ErrorEnvelope> {
      if let error = self.fetchShippingRulesResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: .init(shippingRules: self.fetchShippingRulesResult?.value ?? [.template]))
    }

    internal func fetchUserProjectsBacked() -> SignalProducer<ProjectsEnvelope, ErrorEnvelope> {
      if let error = fetchUserProjectsBackedError {
        return SignalProducer(error: error)
      } else if let projects = fetchUserProjectsBackedResponse {
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

    internal func fetchUserProjectsBacked(paginationUrl _: String)
      -> SignalProducer<ProjectsEnvelope, ErrorEnvelope> {
      if let error = fetchUserProjectsBackedError {
        return SignalProducer(error: error)
      } else if let projects = fetchUserProjectsBackedResponse {
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

    internal func fetchUserSelf() -> SignalProducer<User, ErrorEnvelope> {
      if let error = fetchUserSelfError {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: self.fetchUserSelfResponse ?? .template)
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

    internal func fetchUser(userId: Int) -> SignalProducer<User, ErrorEnvelope> {
      if let error = self.fetchUserError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: self.fetchUserResponse ?? (.template |> \.id .~ userId))
    }

    internal func fetchUser(_ user: User) -> SignalProducer<User, ErrorEnvelope> {
      if let error = self.fetchUserError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: self.fetchUserResponse ?? user)
    }

    internal func fetchCategory(param: Param)
      -> SignalProducer<KsApi.Category, GraphError> {
      switch param {
      case let .id(id):
        return SignalProducer(value: .template |> Category.lens.id .~ "\(id)")
      default:
        return .empty
      }
    }

    internal func incrementVideoCompletion(forProject _: Project) ->
      SignalProducer<VoidEnvelope, ErrorEnvelope> {
      if let error = incrementVideoCompletionError {
        return .init(error: error)
      } else {
        return .init(value: VoidEnvelope())
      }
    }

    internal func incrementVideoStart(forProject _: Project) ->
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

    internal func postComment(_: String, toProject _: Project) ->
      SignalProducer<Comment, ErrorEnvelope> {
      if let error = self.postCommentError {
        return SignalProducer(error: error)
      } else if let comment = self.postCommentResponse {
        return SignalProducer(value: comment)
      }
      return .empty
    }

    func postComment(_: String, toUpdate _: Update) -> SignalProducer<Comment, ErrorEnvelope> {
      if let error = self.postCommentError {
        return SignalProducer(error: error)
      } else if let comment = self.postCommentResponse {
        return SignalProducer(value: comment)
      }
      return .empty
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

    func exportDataState() -> SignalProducer<ExportDataEnvelope, ErrorEnvelope> {
      if let response = fetchExportStateResponse {
        return SignalProducer(value: response)
      } else if let error = fetchExportStateError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: .template)
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
      -> SignalProducer<GraphMutationEmptyResponseEnvelope, GraphError> {
      if let error = sendEmailVerificationError {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: GraphMutationEmptyResponseEnvelope())
    }

    internal func signInWithApple(input _: SignInWithAppleInput)
      -> SignalProducer<SignInWithAppleEnvelope, GraphError> {
      if let error = self.signInWithAppleResult?.error {
        return SignalProducer(error: error)
      }
      return SignalProducer(value: self.signInWithAppleResult?.value ?? SignInWithAppleEnvelope.template)
    }

    internal func signup(
      name: String,
      email _: String,
      password _: String,
      passwordConfirmation _: String,
      sendNewsletters: Bool
    ) -> SignalProducer<AccessTokenEnvelope, ErrorEnvelope> {
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
            |> \.name .~ name
            |> \.newsletters.weekly .~ sendNewsletters
        )
      )
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

    internal func updateBacking(input _: UpdateBackingInput)
      -> SignalProducer<UpdateBackingEnvelope, GraphError> {
      return producer(for: self.updateBackingResult)
    }

    internal func updatePledge(
      project _: Project,
      amount _: Double,
      reward _: Reward?,
      shippingLocation _: Location?,
      tappedReward _: Bool
    ) -> SignalProducer<UpdatePledgeEnvelope, ErrorEnvelope> {
      if let error = self.updatePledgeResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: self.updatePledgeResult?.value ?? .template)
    }

    internal func unwatchProject(input _: WatchProjectInput)
      -> SignalProducer<GraphMutationWatchProjectResponseEnvelope, GraphError> {
      return producer(for: self.unwatchProjectMutationResult)
    }

    internal func watchProject(input _: WatchProjectInput)
      -> SignalProducer<GraphMutationWatchProjectResponseEnvelope, GraphError> {
      return producer(for: self.watchProjectMutationResult)
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

    internal func addVideo(file _: URL, toDraft _: UpdateDraft)
      -> SignalProducer<UpdateDraft.Video, ErrorEnvelope> {
      return .empty
    }

    internal func changePaymentMethod(project _: Project)
      -> SignalProducer<ChangePaymentMethodEnvelope, ErrorEnvelope> {
      if let error = self.changePaymentMethodResult?.error {
        return SignalProducer(error: error)
      }

      return SignalProducer(value: self.changePaymentMethodResult?.value ?? .template)
    }

    internal func deletePaymentMethod(input _: PaymentSourceDeleteInput) -> SignalProducer<
      DeletePaymentMethodEnvelope, GraphError
    > {
      return producer(for: self.deletePaymentMethodResult)
    }

    internal func delete(video _: UpdateDraft.Video, fromDraft _: UpdateDraft)
      -> SignalProducer<UpdateDraft.Video, ErrorEnvelope> {
      return .empty
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
            clearUserUnseenActivityResult: $1.clearUserUnseenActivityResult,
            deletePaymentMethodResult: $1.deletePaymentMethodResult,
            facebookConnectResponse: $1.facebookConnectResponse,
            facebookConnectError: $1.facebookConnectError,
            fetchActivitiesResponse: $1.fetchActivitiesResponse,
            fetchActivitiesError: $1.fetchActivitiesError,
            fetchBackingResponse: $1.fetchBackingResponse,
            fetchGraphCategoriesResponse: $1.fetchGraphCategoriesResponse,
            fetchCommentsResponse: $1.fetchCommentsResponse,
            fetchCommentsError: $1.fetchCommentsError,
            fetchConfigResponse: $1.fetchConfigResponse,
            fetchDiscoveryResponse: $1.fetchDiscoveryResponse,
            fetchDiscoveryError: $1.fetchDiscoveryError,
            fetchFriendsResponse: $1.fetchFriendsResponse,
            fetchFriendsError: $1.fetchFriendsError,
            fetchFriendStatsResponse: $1.fetchFriendStatsResponse,
            fetchFriendStatsError: $1.fetchFriendStatsError,
            fetchExportStateResponse: $1.fetchExportStateResponse,
            fetchExportStateError: $1.fetchExportStateError,
            exportDataError: $1.exportDataError,
            fetchDraftResponse: $1.fetchDraftResponse,
            fetchDraftError: $1.fetchDraftError,
            addAttachmentResponse: $1.addAttachmentResponse,
            addAttachmentError: $1.addAttachmentError,
            removeAttachmentResponse: $1.removeAttachmentResponse,
            removeAttachmentError: $1.removeAttachmentError,
            publishUpdateError: $1.publishUpdateError,
            fetchManagePledgeViewBackingResult: $1.fetchManagePledgeViewBackingResult,
            fetchMessageThreadResult: $1.fetchMessageThreadResult,
            fetchMessageThreadsResponse: $1.fetchMessageThreadsResponse,
            fetchProjectResponse: $1.fetchProjectResponse,
            fetchProjectActivitiesResponse: $1.fetchProjectActivitiesResponse,
            fetchProjectActivitiesError: $1.fetchProjectActivitiesError,
            fetchProjectCreatorDetailsResult: $1.fetchProjectCreatorDetailsResult,
            fetchProjectNotificationsResponse: $1.fetchProjectNotificationsResponse,
            fetchProjectsResponse: $1.fetchProjectsResponse,
            fetchProjectsError: $1.fetchProjectsError,
            fetchProjectStatsResponse: $1.fetchProjectStatsResponse,
            fetchProjectStatsError: $1.fetchProjectStatsError,
            fetchProjectSummaryResult: $1.fetchProjectSummaryResult,
            fetchShippingRulesResult: $1.fetchShippingRulesResult,
            fetchUserProjectsBackedResponse: $1.fetchUserProjectsBackedResponse,
            fetchUserProjectsBackedError: $1.fetchUserProjectsBackedError,
            fetchUserResponse: $1.fetchUserResponse,
            fetchUserError: $1.fetchUserError,
            fetchUserSelfResponse: $1.fetchUserSelfResponse,
            followFriendError: $1.followFriendError,
            incrementVideoCompletionError: $1.incrementVideoCompletionError,
            incrementVideoStartError: $1.incrementVideoStartError,
            fetchSurveyResponseResponse: $1.fetchSurveyResponseResponse,
            fetchSurveyResponseError: $1.fetchSurveyResponseError,
            fetchUnansweredSurveyResponsesResponse: $1.fetchUnansweredSurveyResponsesResponse,
            fetchUpdateCommentsResponse: $1.fetchUpdateCommentsResponse,
            fetchUpdateResponse: $1.fetchUpdateResponse,
            fetchUserSelfError: $1.fetchUserSelfError,
            postCommentResponse: $1.postCommentResponse,
            postCommentError: $1.postCommentError,
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
