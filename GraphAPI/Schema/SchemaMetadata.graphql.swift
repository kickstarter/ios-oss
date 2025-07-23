// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == GraphAPI.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == GraphAPI.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == GraphAPI.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == GraphAPI.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
    switch typename {
    case "Mutation": return GraphAPI.Objects.Mutation
    case "UpdateBackingPayload": return GraphAPI.Objects.UpdateBackingPayload
    case "Checkout": return GraphAPI.Objects.Checkout
    case "SavedSearchSegment": return GraphAPI.Objects.SavedSearchSegment
    case "Backing": return GraphAPI.Objects.Backing
    case "Reward": return GraphAPI.Objects.Reward
    case "Photo": return GraphAPI.Objects.Photo
    case "RewardItem": return GraphAPI.Objects.RewardItem
    case "Project": return GraphAPI.Objects.Project
    case "CreatorInterview": return GraphAPI.Objects.CreatorInterview
    case "FreeformPost": return GraphAPI.Objects.FreeformPost
    case "Comment": return GraphAPI.Objects.Comment
    case "User": return GraphAPI.Objects.User
    case "Address": return GraphAPI.Objects.Address
    case "Conversation": return GraphAPI.Objects.Conversation
    case "Message": return GraphAPI.Objects.Message
    case "CuratedPage": return GraphAPI.Objects.CuratedPage
    case "Location": return GraphAPI.Objects.Location
    case "Organization": return GraphAPI.Objects.Organization
    case "UserUrl": return GraphAPI.Objects.UserUrl
    case "Category": return GraphAPI.Objects.Category
    case "AiDisclosure": return GraphAPI.Objects.AiDisclosure
    case "Flagging": return GraphAPI.Objects.Flagging
    case "Video": return GraphAPI.Objects.Video
    case "VideoTrack": return GraphAPI.Objects.VideoTrack
    case "VideoTrackCue": return GraphAPI.Objects.VideoTrackCue
    case "Order": return GraphAPI.Objects.Order
    case "AttachedAudio": return GraphAPI.Objects.AttachedAudio
    case "AttachedVideo": return GraphAPI.Objects.AttachedVideo
    case "ProjectProfile": return GraphAPI.Objects.ProjectProfile
    case "Tag": return GraphAPI.Objects.Tag
    case "InterviewAnswer": return GraphAPI.Objects.InterviewAnswer
    case "InterviewQuestion": return GraphAPI.Objects.InterviewQuestion
    case "CreatorPrompt": return GraphAPI.Objects.CreatorPrompt
    case "ShippingRule": return GraphAPI.Objects.ShippingRule
    case "AdjustmentSummary": return GraphAPI.Objects.AdjustmentSummary
    case "Refund": return GraphAPI.Objects.Refund
    case "Survey": return GraphAPI.Objects.Survey
    case "PostCommentPayload": return GraphAPI.Objects.PostCommentPayload
    case "CommentConnection": return GraphAPI.Objects.CommentConnection
    case "CompleteOnSessionCheckoutPayload": return GraphAPI.Objects.CompleteOnSessionCheckoutPayload
    case "CreateCheckoutPayload": return GraphAPI.Objects.CreateCheckoutPayload
    case "CreatePaymentIntentPayload": return GraphAPI.Objects.CreatePaymentIntentPayload
    case "AddUserToSecretRewardGroupPayload": return GraphAPI.Objects.AddUserToSecretRewardGroupPayload
    case "ProjectRewardConnection": return GraphAPI.Objects.ProjectRewardConnection
    case "UpdateUserAccountPayload": return GraphAPI.Objects.UpdateUserAccountPayload
    case "UnwatchProjectPayload": return GraphAPI.Objects.UnwatchProjectPayload
    case "CreateAttributionEventPayload": return GraphAPI.Objects.CreateAttributionEventPayload
    case "UpdateUserProfilePayload": return GraphAPI.Objects.UpdateUserProfilePayload
    case "CreateSetupIntentPayload": return GraphAPI.Objects.CreateSetupIntentPayload
    case "BlockUserPayload": return GraphAPI.Objects.BlockUserPayload
    case "ClearUserUnseenActivityPayload": return GraphAPI.Objects.ClearUserUnseenActivityPayload
    case "CreatePaymentSourcePayload": return GraphAPI.Objects.CreatePaymentSourcePayload
    case "CreditCard": return GraphAPI.Objects.CreditCard
    case "BankAccount": return GraphAPI.Objects.BankAccount
    case "CreateOrUpdateBackingAddressPayload": return GraphAPI.Objects.CreateOrUpdateBackingAddressPayload
    case "SignInWithApplePayload": return GraphAPI.Objects.SignInWithApplePayload
    case "CreateFlaggingPayload": return GraphAPI.Objects.CreateFlaggingPayload
    case "CreateBackingPayload": return GraphAPI.Objects.CreateBackingPayload
    case "WatchProjectPayload": return GraphAPI.Objects.WatchProjectPayload
    case "UserSendEmailVerificationPayload": return GraphAPI.Objects.UserSendEmailVerificationPayload
    case "CancelBackingPayload": return GraphAPI.Objects.CancelBackingPayload
    case "PaymentSourceDeletePayload": return GraphAPI.Objects.PaymentSourceDeletePayload
    case "UserCreditCardTypeConnection": return GraphAPI.Objects.UserCreditCardTypeConnection
    case "TriggerThirdPartyEventPayload": return GraphAPI.Objects.TriggerThirdPartyEventPayload
    case "Query": return GraphAPI.Objects.Query
    case "Country": return GraphAPI.Objects.Country
    case "UserBackingsConnection": return GraphAPI.Objects.UserBackingsConnection
    case "UserCreatedProjectsConnection": return GraphAPI.Objects.UserCreatedProjectsConnection
    case "NewsletterSubscriptions": return GraphAPI.Objects.NewsletterSubscriptions
    case "Notification": return GraphAPI.Objects.Notification
    case "UserSavedProjectsConnection": return GraphAPI.Objects.UserSavedProjectsConnection
    case "SurveyResponsesConnection": return GraphAPI.Objects.SurveyResponsesConnection
    case "EnvironmentalCommitment": return GraphAPI.Objects.EnvironmentalCommitment
    case "ProjectFaqConnection": return GraphAPI.Objects.ProjectFaqConnection
    case "ProjectFaq": return GraphAPI.Objects.ProjectFaq
    case "Money": return GraphAPI.Objects.Money
    case "CheckoutWave": return GraphAPI.Objects.CheckoutWave
    case "PledgeManager": return GraphAPI.Objects.PledgeManager
    case "PostConnection": return GraphAPI.Objects.PostConnection
    case "VideoSources": return GraphAPI.Objects.VideoSources
    case "VideoSourceInfo": return GraphAPI.Objects.VideoSourceInfo
    case "ProjectsConnectionWithTotalCount": return GraphAPI.Objects.ProjectsConnectionWithTotalCount
    case "PageInfo": return GraphAPI.Objects.PageInfo
    case "RewardTotalCountConnection": return GraphAPI.Objects.RewardTotalCountConnection
    case "RewardConnection": return GraphAPI.Objects.RewardConnection
    case "RewardItemsConnection": return GraphAPI.Objects.RewardItemsConnection
    case "RewardItemEdge": return GraphAPI.Objects.RewardItemEdge
    case "ResourceAudience": return GraphAPI.Objects.ResourceAudience
    case "PaymentIncrement": return GraphAPI.Objects.PaymentIncrement
    case "PaymentIncrementAmount": return GraphAPI.Objects.PaymentIncrementAmount
    case "CategorySubcategoriesConnection": return GraphAPI.Objects.CategorySubcategoriesConnection
    case "PaymentPlan": return GraphAPI.Objects.PaymentPlan
    case "Validation": return GraphAPI.Objects.Validation
    case "CommentEdge": return GraphAPI.Objects.CommentEdge
    case "LocationsConnection": return GraphAPI.Objects.LocationsConnection
    case "ProjectBackerFriendsConnection": return GraphAPI.Objects.ProjectBackerFriendsConnection
    case "SimpleShippingRule": return GraphAPI.Objects.SimpleShippingRule
    case "RewardShippingRulesConnection": return GraphAPI.Objects.RewardShippingRulesConnection
    case "PledgeProjectsOverview": return GraphAPI.Objects.PledgeProjectsOverview
    case "PledgedProjectsOverviewPledgesConnection": return GraphAPI.Objects.PledgedProjectsOverviewPledgesConnection
    case "PledgeProjectOverviewItemEdge": return GraphAPI.Objects.PledgeProjectOverviewItemEdge
    case "PledgeProjectOverviewItem": return GraphAPI.Objects.PledgeProjectOverviewItem
    case "PledgedProjectsOverviewPledgeFlags": return GraphAPI.Objects.PledgedProjectsOverviewPledgeFlags
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
