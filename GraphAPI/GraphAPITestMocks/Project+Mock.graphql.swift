// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class Project: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.Project
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<Project>>

  public struct MockFields {
    @Field<ProjectRewardConnection>("addOns") public var addOns
    @Field<AiDisclosure>("aiDisclosure") public var aiDisclosure
    @Field<[GraphQLEnum<GraphAPI.CreditCardTypes>]>("availableCardTypes") public var availableCardTypes
    @Field<Int>("backersCount") public var backersCount
    @Field<Backing>("backing") public var backing
    @Field<Bool>("canComment") public var canComment
    @Field<Category>("category") public var category
    @Field<CommentConnection>("comments") public var comments
    @Field<Int>("commentsCount") public var commentsCount
    @Field<Country>("country") public var country
    @Field<User>("creator") public var creator
    @Field<GraphQLEnum<GraphAPI.CurrencyCode>>("currency") public var currency
    @Field<GraphAPI.DateTime>("deadlineAt") public var deadlineAt
    @Field<String>("description") public var description
    @Field<[EnvironmentalCommitment?]>("environmentalCommitments") public var environmentalCommitments
    @Field<ProjectFaqConnection>("faqs") public var faqs
    @Field<GraphAPI.ISO8601DateTime>("finalCollectionDate") public var finalCollectionDate
    @Field<Flagging>("flagging") public var flagging
    @Field<ProjectBackerFriendsConnection>("friends") public var friends
    @Field<Double>("fxRate") public var fxRate
    @Field<Money>("goal") public var goal
    @Field<GraphAPI.ID>("id") public var id
    @Field<Photo>("image") public var image
    @Field<Bool>("isInPostCampaignPledgingPhase") public var isInPostCampaignPledgingPhase
    @Field<Bool>("isLaunched") public var isLaunched
    @Field<Bool>("isPledgeOverTimeAllowed") public var isPledgeOverTimeAllowed
    @Field<Bool>("isPrelaunchActivated") public var isPrelaunchActivated
    @Field<Bool>("isProjectOfTheDay") public var isProjectOfTheDay
    @Field<Bool>("isProjectWeLove") public var isProjectWeLove
    @Field<Bool>("isWatched") public var isWatched
    @Field<CheckoutWave>("lastWave") public var lastWave
    @Field<GraphAPI.DateTime>("launchedAt") public var launchedAt
    @Field<Location>("location") public var location
    @Field<Int>("maxPledge") public var maxPledge
    @Field<Int>("minPledge") public var minPledge
    @Field<String>("name") public var name
    @Field<PaymentPlan>("paymentPlan") public var paymentPlan
    @Field<Int>("percentFunded") public var percentFunded
    @Field<Int>("pid") public var pid
    @Field<PledgeManager>("pledgeManager") public var pledgeManager
    @Field<String>("pledgeOverTimeCollectionPlanChargeExplanation") public var pledgeOverTimeCollectionPlanChargeExplanation
    @Field<String>("pledgeOverTimeCollectionPlanChargedAsNPayments") public var pledgeOverTimeCollectionPlanChargedAsNPayments
    @Field<String>("pledgeOverTimeCollectionPlanShortPitch") public var pledgeOverTimeCollectionPlanShortPitch
    @Field<String>("pledgeOverTimeMinimumExplanation") public var pledgeOverTimeMinimumExplanation
    @Field<Money>("pledged") public var pledged
    @Field<Bool>("postCampaignPledgingEnabled") public var postCampaignPledgingEnabled
    @Field<PostConnection>("posts") public var posts
    @Field<Bool>("prelaunchActivated") public var prelaunchActivated
    @Field<String>("projectDescription") public var projectDescription
    @Field<GraphAPI.ID>("projectId") public var projectId
    @Field<GraphAPI.DateTime>("projectLaunchedAt") public var projectLaunchedAt
    @Field<String>("projectNotice") public var projectNotice
    @Field<Bool>("projectPrelaunchActivated") public var projectPrelaunchActivated
    @Field<GraphQLEnum<GraphAPI.ProjectState>>("projectState") public var projectState
    @Field<[Tag?]>("projectTags") public var projectTags
    @Field<Double>("projectUsdExchangeRate") public var projectUsdExchangeRate
    @Field<String>("redemptionPageUrl") public var redemptionPageUrl
    @Field<ProjectRewardConnection>("rewards") public var rewards
    @Field<String>("risks") public var risks
    @Field<Bool>("sendMetaCapiEvents") public var sendMetaCapiEvents
    @Field<String>("slug") public var slug
    @Field<GraphQLEnum<GraphAPI.ProjectState>>("state") public var state
    @Field<GraphAPI.DateTime>("stateChangedAt") public var stateChangedAt
    @Field<GraphAPI.HTML>("story") public var story
    @Field<[Tag?]>("tags") public var tags
    @Field<String>("url") public var url
    @Field<Double>("usdExchangeRate") public var usdExchangeRate
    @Field<Video>("video") public var video
    @Field<Int>("watchesCount") public var watchesCount
  }
}

public extension Mock where O == Project {
  convenience init(
    addOns: Mock<ProjectRewardConnection>? = nil,
    aiDisclosure: Mock<AiDisclosure>? = nil,
    availableCardTypes: [GraphQLEnum<GraphAPI.CreditCardTypes>]? = nil,
    backersCount: Int? = nil,
    backing: Mock<Backing>? = nil,
    canComment: Bool? = nil,
    category: Mock<Category>? = nil,
    comments: Mock<CommentConnection>? = nil,
    commentsCount: Int? = nil,
    country: Mock<Country>? = nil,
    creator: Mock<User>? = nil,
    currency: GraphQLEnum<GraphAPI.CurrencyCode>? = nil,
    deadlineAt: GraphAPI.DateTime? = nil,
    description: String? = nil,
    environmentalCommitments: [Mock<EnvironmentalCommitment>?]? = nil,
    faqs: Mock<ProjectFaqConnection>? = nil,
    finalCollectionDate: GraphAPI.ISO8601DateTime? = nil,
    flagging: Mock<Flagging>? = nil,
    friends: Mock<ProjectBackerFriendsConnection>? = nil,
    fxRate: Double? = nil,
    goal: Mock<Money>? = nil,
    id: GraphAPI.ID? = nil,
    image: Mock<Photo>? = nil,
    isInPostCampaignPledgingPhase: Bool? = nil,
    isLaunched: Bool? = nil,
    isPledgeOverTimeAllowed: Bool? = nil,
    isPrelaunchActivated: Bool? = nil,
    isProjectOfTheDay: Bool? = nil,
    isProjectWeLove: Bool? = nil,
    isWatched: Bool? = nil,
    lastWave: Mock<CheckoutWave>? = nil,
    launchedAt: GraphAPI.DateTime? = nil,
    location: Mock<Location>? = nil,
    maxPledge: Int? = nil,
    minPledge: Int? = nil,
    name: String? = nil,
    paymentPlan: Mock<PaymentPlan>? = nil,
    percentFunded: Int? = nil,
    pid: Int? = nil,
    pledgeManager: Mock<PledgeManager>? = nil,
    pledgeOverTimeCollectionPlanChargeExplanation: String? = nil,
    pledgeOverTimeCollectionPlanChargedAsNPayments: String? = nil,
    pledgeOverTimeCollectionPlanShortPitch: String? = nil,
    pledgeOverTimeMinimumExplanation: String? = nil,
    pledged: Mock<Money>? = nil,
    postCampaignPledgingEnabled: Bool? = nil,
    posts: Mock<PostConnection>? = nil,
    prelaunchActivated: Bool? = nil,
    projectDescription: String? = nil,
    projectId: GraphAPI.ID? = nil,
    projectLaunchedAt: GraphAPI.DateTime? = nil,
    projectNotice: String? = nil,
    projectPrelaunchActivated: Bool? = nil,
    projectState: GraphQLEnum<GraphAPI.ProjectState>? = nil,
    projectTags: [Mock<Tag>?]? = nil,
    projectUsdExchangeRate: Double? = nil,
    redemptionPageUrl: String? = nil,
    rewards: Mock<ProjectRewardConnection>? = nil,
    risks: String? = nil,
    sendMetaCapiEvents: Bool? = nil,
    slug: String? = nil,
    state: GraphQLEnum<GraphAPI.ProjectState>? = nil,
    stateChangedAt: GraphAPI.DateTime? = nil,
    story: GraphAPI.HTML? = nil,
    tags: [Mock<Tag>?]? = nil,
    url: String? = nil,
    usdExchangeRate: Double? = nil,
    video: Mock<Video>? = nil,
    watchesCount: Int? = nil
  ) {
    self.init()
    _setEntity(addOns, for: \.addOns)
    _setEntity(aiDisclosure, for: \.aiDisclosure)
    _setScalarList(availableCardTypes, for: \.availableCardTypes)
    _setScalar(backersCount, for: \.backersCount)
    _setEntity(backing, for: \.backing)
    _setScalar(canComment, for: \.canComment)
    _setEntity(category, for: \.category)
    _setEntity(comments, for: \.comments)
    _setScalar(commentsCount, for: \.commentsCount)
    _setEntity(country, for: \.country)
    _setEntity(creator, for: \.creator)
    _setScalar(currency, for: \.currency)
    _setScalar(deadlineAt, for: \.deadlineAt)
    _setScalar(description, for: \.description)
    _setList(environmentalCommitments, for: \.environmentalCommitments)
    _setEntity(faqs, for: \.faqs)
    _setScalar(finalCollectionDate, for: \.finalCollectionDate)
    _setEntity(flagging, for: \.flagging)
    _setEntity(friends, for: \.friends)
    _setScalar(fxRate, for: \.fxRate)
    _setEntity(goal, for: \.goal)
    _setScalar(id, for: \.id)
    _setEntity(image, for: \.image)
    _setScalar(isInPostCampaignPledgingPhase, for: \.isInPostCampaignPledgingPhase)
    _setScalar(isLaunched, for: \.isLaunched)
    _setScalar(isPledgeOverTimeAllowed, for: \.isPledgeOverTimeAllowed)
    _setScalar(isPrelaunchActivated, for: \.isPrelaunchActivated)
    _setScalar(isProjectOfTheDay, for: \.isProjectOfTheDay)
    _setScalar(isProjectWeLove, for: \.isProjectWeLove)
    _setScalar(isWatched, for: \.isWatched)
    _setEntity(lastWave, for: \.lastWave)
    _setScalar(launchedAt, for: \.launchedAt)
    _setEntity(location, for: \.location)
    _setScalar(maxPledge, for: \.maxPledge)
    _setScalar(minPledge, for: \.minPledge)
    _setScalar(name, for: \.name)
    _setEntity(paymentPlan, for: \.paymentPlan)
    _setScalar(percentFunded, for: \.percentFunded)
    _setScalar(pid, for: \.pid)
    _setEntity(pledgeManager, for: \.pledgeManager)
    _setScalar(pledgeOverTimeCollectionPlanChargeExplanation, for: \.pledgeOverTimeCollectionPlanChargeExplanation)
    _setScalar(pledgeOverTimeCollectionPlanChargedAsNPayments, for: \.pledgeOverTimeCollectionPlanChargedAsNPayments)
    _setScalar(pledgeOverTimeCollectionPlanShortPitch, for: \.pledgeOverTimeCollectionPlanShortPitch)
    _setScalar(pledgeOverTimeMinimumExplanation, for: \.pledgeOverTimeMinimumExplanation)
    _setEntity(pledged, for: \.pledged)
    _setScalar(postCampaignPledgingEnabled, for: \.postCampaignPledgingEnabled)
    _setEntity(posts, for: \.posts)
    _setScalar(prelaunchActivated, for: \.prelaunchActivated)
    _setScalar(projectDescription, for: \.projectDescription)
    _setScalar(projectId, for: \.projectId)
    _setScalar(projectLaunchedAt, for: \.projectLaunchedAt)
    _setScalar(projectNotice, for: \.projectNotice)
    _setScalar(projectPrelaunchActivated, for: \.projectPrelaunchActivated)
    _setScalar(projectState, for: \.projectState)
    _setList(projectTags, for: \.projectTags)
    _setScalar(projectUsdExchangeRate, for: \.projectUsdExchangeRate)
    _setScalar(redemptionPageUrl, for: \.redemptionPageUrl)
    _setEntity(rewards, for: \.rewards)
    _setScalar(risks, for: \.risks)
    _setScalar(sendMetaCapiEvents, for: \.sendMetaCapiEvents)
    _setScalar(slug, for: \.slug)
    _setScalar(state, for: \.state)
    _setScalar(stateChangedAt, for: \.stateChangedAt)
    _setScalar(story, for: \.story)
    _setList(tags, for: \.tags)
    _setScalar(url, for: \.url)
    _setScalar(usdExchangeRate, for: \.usdExchangeRate)
    _setEntity(video, for: \.video)
    _setScalar(watchesCount, for: \.watchesCount)
  }
}
