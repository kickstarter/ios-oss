// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// The bucket for a flagging (general reason).
public enum FlaggingKind: String, EnumType {
  /// prohibited-items
  case prohibitedItems = "PROHIBITED_ITEMS"
  /// charity
  case charity = "CHARITY"
  /// resale
  case resale = "RESALE"
  /// false-claims
  case falseClaims = "FALSE_CLAIMS"
  /// misrep-support
  case misrepSupport = "MISREP_SUPPORT"
  /// not-project
  case notProject = "NOT_PROJECT"
  /// guidelines-violation
  case guidelinesViolation = "GUIDELINES_VIOLATION"
  /// post-funding-issues
  case postFundingIssues = "POST_FUNDING_ISSUES"
  /// spam
  case spam = "SPAM"
  /// abuse
  case abuse = "ABUSE"
  /// vices-drugs
  case vicesDrugs = "VICES_DRUGS"
  /// vices-alcohol
  case vicesAlcohol = "VICES_ALCOHOL"
  /// vices-weapons
  case vicesWeapons = "VICES_WEAPONS"
  /// health-claims
  case healthClaims = "HEALTH_CLAIMS"
  /// health-regulations
  case healthRegulations = "HEALTH_REGULATIONS"
  /// health-gmos
  case healthGmos = "HEALTH_GMOS"
  /// health-live-animals
  case healthLiveAnimals = "HEALTH_LIVE_ANIMALS"
  /// health-energy-food-and-drink
  case healthEnergyFoodAndDrink = "HEALTH_ENERGY_FOOD_AND_DRINK"
  /// financial-contests-coupons
  case financialContestsCoupons = "FINANCIAL_CONTESTS_COUPONS"
  /// financial-services
  case financialServices = "FINANCIAL_SERVICES"
  /// financial-political-donations
  case financialPoliticalDonations = "FINANCIAL_POLITICAL_DONATIONS"
  /// offensive-content-hate
  case offensiveContentHate = "OFFENSIVE_CONTENT_HATE"
  /// offensive-content-porn
  case offensiveContentPorn = "OFFENSIVE_CONTENT_PORN"
  /// reselling
  case reselling = "RESELLING"
  /// plagiarism
  case plagiarism = "PLAGIARISM"
  /// prototype-misrepresentation
  case prototypeMisrepresentation = "PROTOTYPE_MISREPRESENTATION"
  /// undisclosed-ai-use
  case undisclosedAiUse = "UNDISCLOSED_AI_USE"
  /// misrep-support-impersonation
  case misrepSupportImpersonation = "MISREP_SUPPORT_IMPERSONATION"
  /// misrep-support-outstanding-fulfillment
  case misrepSupportOutstandingFulfillment = "MISREP_SUPPORT_OUTSTANDING_FULFILLMENT"
  /// misrep-support-suspicious-pledging
  case misrepSupportSuspiciousPledging = "MISREP_SUPPORT_SUSPICIOUS_PLEDGING"
  /// misrep-support-other
  case misrepSupportOther = "MISREP_SUPPORT_OTHER"
  /// not-project-charity
  case notProjectCharity = "NOT_PROJECT_CHARITY"
  /// not-project-stunt-or-hoax
  case notProjectStuntOrHoax = "NOT_PROJECT_STUNT_OR_HOAX"
  /// not-project-personal-expenses
  case notProjectPersonalExpenses = "NOT_PROJECT_PERSONAL_EXPENSES"
  /// not-project-barebones
  case notProjectBarebones = "NOT_PROJECT_BAREBONES"
  /// not-project-other
  case notProjectOther = "NOT_PROJECT_OTHER"
  /// guidelines-spam
  case guidelinesSpam = "GUIDELINES_SPAM"
  /// guidelines-abuse
  case guidelinesAbuse = "GUIDELINES_ABUSE"
  /// post-funding-reward-not-as-described
  case postFundingRewardNotAsDescribed = "POST_FUNDING_REWARD_NOT_AS_DESCRIBED"
  /// post-funding-reward-delayed
  case postFundingRewardDelayed = "POST_FUNDING_REWARD_DELAYED"
  /// post-funding-shipped-never-received
  case postFundingShippedNeverReceived = "POST_FUNDING_SHIPPED_NEVER_RECEIVED"
  /// post-funding-creator-selling-elsewhere
  case postFundingCreatorSellingElsewhere = "POST_FUNDING_CREATOR_SELLING_ELSEWHERE"
  /// post-funding-creator-uncommunicative
  case postFundingCreatorUncommunicative = "POST_FUNDING_CREATOR_UNCOMMUNICATIVE"
  /// post-funding-creator-inappropriate
  case postFundingCreatorInappropriate = "POST_FUNDING_CREATOR_INAPPROPRIATE"
  /// post-funding-suspicious-third-party
  case postFundingSuspiciousThirdParty = "POST_FUNDING_SUSPICIOUS_THIRD_PARTY"
  /// comment-abuse
  case commentAbuse = "COMMENT_ABUSE"
  /// comment-doxxing
  case commentDoxxing = "COMMENT_DOXXING"
  /// comment-offtopic
  case commentOfftopic = "COMMENT_OFFTOPIC"
  /// comment-spam
  case commentSpam = "COMMENT_SPAM"
  /// backing-abuse
  case backingAbuse = "BACKING_ABUSE"
  /// backing-doxxing
  case backingDoxxing = "BACKING_DOXXING"
  /// backing-fraud
  case backingFraud = "BACKING_FRAUD"
  /// backing-spam
  case backingSpam = "BACKING_SPAM"
}
