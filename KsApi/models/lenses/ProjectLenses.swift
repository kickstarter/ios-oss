import Foundation
import Prelude

extension ExtendedProjectProperties {
  public enum lens {
    public static let faqs = Lens<ExtendedProjectProperties, [ProjectFAQ]>(
      view: { $0.faqs },
      set: { ExtendedProjectProperties(
        environmentalCommitments: $1.environmentalCommitments,
        faqs: $0,
        aiDisclosure: $1.aiDisclosure,
        risks: $1.risks,
        story: $1.story,
        minimumPledgeAmount: $1.minimumPledgeAmount,
        projectNotice: $1.projectNotice
      ) }
    )
  }
}

extension Project {
  public enum lens {
    public static let availableCardTypes = Lens<Project, [String]?>(
      view: { $0.availableCardTypes },
      set: { Project(
        availableCardTypes: $0, blurb: $1.blurb, category: $1.category, country: $1.country,
        creator: $1.creator, extendedProjectProperties:
        $1.extendedProjectProperties, memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let blurb = Lens<Project, String>(
      view: { $0.blurb },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $0, category: $1.category, country: $1.country,
        creator: $1.creator, extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug, staffPick:
        $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls, video: $1.video,
        watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let staffPick = Lens<Project, Bool>(
      view: { $0.staffPick },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator, extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization,
        photo: $1.photo, isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $0, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls, video: $1.video,
        watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let category = Lens<Project, Project.Category>(
      view: { $0.category },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $0, country: $1.country,
        creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let country = Lens<Project, Country>(
      view: { $0.country },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category, country: $0,
        creator: $1.creator, extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let creator = Lens<Project, User>(
      view: { $0.creator },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $0,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let dates = Lens<Project, Project.Dates>(
      view: { $0.dates },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $0,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let displayPrelaunch = Lens<Project, Bool?>(
      view: { $0.displayPrelaunch },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator, extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $0, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let extendedProjectProperties = Lens<Project, ExtendedProjectProperties?>(
      view: { $0.extendedProjectProperties },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country,
        creator: $1.creator, extendedProjectProperties: $0, memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let id = Lens<Project, Int>(
      view: { $0.id },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $0,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let lastWave = Lens<Project, LastWave?>(
      view: { $0.lastWave },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $0,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let location = Lens<Project, Location>(
      view: { $0.location },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $0,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let memberData = Lens<Project, Project.MemberData>(
      view: { $0.memberData },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $0, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let name = Lens<Project, String>(
      view: { $0.name },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $0,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let pledgeManager = Lens<Project, PledgeManager?>(
      view: { $0.pledgeManager },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $0,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let personalization = Lens<Project, Project.Personalization>(
      view: { $0.personalization },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation, personalization: $0,
        photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let photo = Lens<Project, Project.Photo>(
      view: { $0.photo },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $0,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let isInPostCampaignPledgingPhase = Lens<Project, Bool>(
      view: { $0.isInPostCampaignPledgingPhase },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $0,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let pledgeOverTimeCollectionPlanChargeExplanation = Lens<Project, String?>(
      view: { $0.pledgeOverTimeMinimumExplanation },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $0,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let pledgeOverTimeCollectionPlanChargedAsNPayments = Lens<Project, String?>(
      view: { $0.pledgeOverTimeMinimumExplanation },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $0,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let pledgeOverTimeCollectionPlanShortPitch = Lens<Project, String?>(
      view: { $0.pledgeOverTimeMinimumExplanation },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $0,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let pledgeOverTimeMinimumExplanation = Lens<Project, String?>(
      view: { $0.pledgeOverTimeMinimumExplanation },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $0,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let postCampaignPledgingEnabled = Lens<Project, Bool>(
      view: { $0.postCampaignPledgingEnabled },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $0,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let prelaunchActivated = Lens<Project, Bool?>(
      view: { $0.prelaunchActivated },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $0,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents,
        slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let redemptionPageUrl = Lens<Project, String>(
      view: { $0.redemptionPageUrl },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $0,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents,
        slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let rewardData = Lens<Project, RewardData>(
      view: { $0.rewardData },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $0,
        sendMetaCapiEvents: $1.sendMetaCapiEvents,
        slug: $1.slug, staffPick: $1.staffPick,
        state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls, video: $1.video,
        watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let sendMetaCapiEvents = Lens<Project, Bool>(
      view: { $0.sendMetaCapiEvents },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $0,
        slug: $1.slug,
        staffPick: $1.staffPick,
        state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls, video: $1.video,
        watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let slug = Lens<Project, String>(
      view: { $0.slug },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $0,
        staffPick: $1.staffPick,
        state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls, video: $1.video,
        watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let state = Lens<Project, Project.State>(
      view: { $0.state },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $0, stats: $1.stats, tags: $1.tags, urls: $1.urls, video: $1.video,
        watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let stats = Lens<Project, Project.Stats>(
      view: { $0.stats },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $0, tags: $1.tags, urls: $1.urls, video: $1.video,
        watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let tags = Lens<Project, [String]?>(
      view: { $0.tags },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $0, urls: $1.urls, video: $1.video,
        watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let urls = Lens<Project, Project.UrlsEnvelope>(
      view: { $0.urls },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $0, video: $1.video,
        watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let video = Lens<Project, Project.Video?>(
      view: { $0.video },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls, video: $0,
        watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let watchesCount = Lens<Project, Int?>(
      view: { $0.watchesCount },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $0,
        isPledgeOverTimeAllowed: $1.isPledgeOverTimeAllowed
      ) }
    )

    public static let isPledgeOverTimeAllowed = Lens<Project, Bool?>(
      view: { $0.isPledgeOverTimeAllowed },
      set: { Project(
        availableCardTypes: $1.availableCardTypes, blurb: $1.blurb, category: $1.category,
        country: $1.country, creator: $1.creator,
        extendedProjectProperties: $1.extendedProjectProperties,
        memberData: $1.memberData, dates: $1.dates,
        displayPrelaunch: $1.displayPrelaunch, flagging: $1.flagging, id: $1.id,
        lastWave: $1.lastWave,
        location: $1.location,
        name: $1.name,
        pledgeManager: $1.pledgeManager,
        pledgeOverTimeCollectionPlanChargeExplanation: $1.pledgeOverTimeCollectionPlanChargeExplanation,
        pledgeOverTimeCollectionPlanChargedAsNPayments: $1.pledgeOverTimeCollectionPlanChargedAsNPayments,
        pledgeOverTimeCollectionPlanShortPitch: $1.pledgeOverTimeCollectionPlanShortPitch,
        pledgeOverTimeMinimumExplanation: $1.pledgeOverTimeMinimumExplanation,
        personalization: $1.personalization, photo: $1.photo,
        isInPostCampaignPledgingPhase: $1.isInPostCampaignPledgingPhase,
        postCampaignPledgingEnabled: $1.postCampaignPledgingEnabled,
        prelaunchActivated: $1.prelaunchActivated,
        redemptionPageUrl: $1.redemptionPageUrl,
        rewardData: $1.rewardData,
        sendMetaCapiEvents: $1.sendMetaCapiEvents, slug: $1.slug,
        staffPick: $1.staffPick, state: $1.state, stats: $1.stats, tags: $1.tags, urls: $1.urls,
        video: $1.video, watchesCount: $1.watchesCount,
        isPledgeOverTimeAllowed: $0
      ) }
    )
  }
}

extension Project.UrlsEnvelope {
  public enum lens {
    public static let web = Lens<Project.UrlsEnvelope, Project.UrlsEnvelope.WebEnvelope>(
      view: { $0.web },
      set: { part, _ in .init(web: part) }
    )
  }
}

extension Project.UrlsEnvelope.WebEnvelope {
  public enum lens {
    public static let project = Lens<Project.UrlsEnvelope.WebEnvelope, String>(
      view: { $0.project },
      set: { .init(project: $0, updates: $1.updates) }
    )

    public static let updates = Lens<Project.UrlsEnvelope.WebEnvelope, String?>(
      view: { $0.updates },
      set: { .init(project: $1.project, updates: $0) }
    )
  }
}

extension Lens where Whole == Project, Part == User {
  public var avatar: Lens<Project, User.Avatar> {
    return Project.lens.creator .. User.lens.avatar
  }

  public var id: Lens<Project, Int> {
    return Project.lens.creator .. User.lens.id
  }

  public var name: Lens<Project, String> {
    return Project.lens.creator .. User.lens.name
  }
}

extension Lens where Whole == Project, Part == Location {
  public var name: Lens<Project, String> {
    return Project.lens.location .. Location.lens.name
  }

  public var displayableName: Lens<Project, String> {
    return Project.lens.location .. Location.lens.displayableName
  }
}

extension Lens where Whole == Project, Part == Project.Stats {
  public var backersCount: Lens<Project, Int> {
    return Project.lens.stats .. lens(\Project.Stats.backersCount)
  }

  public var commentsCount: Lens<Project, Int?> {
    return Project.lens.stats .. lens(\Project.Stats.commentsCount)
  }

  public var convertedPledgedAmount: Lens<Project, Float?> {
    return Project.lens.stats .. lens(\Project.Stats.convertedPledgedAmount)
  }

  public var projectCurrency: Lens<Project, String> {
    return Project.lens.stats .. lens(\Project.Stats.projectCurrency)
  }

  public var userCurrency: Lens<Project, String?> {
    return Project.lens.stats .. lens(\Project.Stats.userCurrency)
  }

  public var userCurrencyRate: Lens<Project, Float?> {
    return Project.lens.stats .. lens(\Project.Stats.userCurrencyRate)
  }

  public var goal: Lens<Project, Int> {
    return Project.lens.stats .. lens(\Project.Stats.goal)
  }

  public var pledged: Lens<Project, Int> {
    return Project.lens.stats .. lens(\Project.Stats.pledged)
  }

  public var staticUsdRate: Lens<Project, Float> {
    return Project.lens.stats .. lens(\Project.Stats.staticUsdRate)
  }

  public var updatesCount: Lens<Project, Int?> {
    return Project.lens.stats .. lens(\Project.Stats.updatesCount)
  }

  public var usdExchangeRate: Lens<Project, Float?> {
    return Project.lens.stats .. lens(\Project.Stats.usdExchangeRate)
  }

  public var fundingProgress: Lens<Project, Float> {
    return Project.lens.stats .. Project.Stats.lens.fundingProgress
  }
}

extension Lens where Whole == Project, Part == Project.MemberData {
  public var lastUpdatePublishedAt: Lens<Project, TimeInterval?> {
    return Project.lens.memberData .. Project.MemberData.lens.lastUpdatePublishedAt
  }

  public var unreadMessagesCount: Lens<Project, Int?> {
    return Project.lens.memberData .. Project.MemberData.lens.unreadMessagesCount
  }

  public var unseenActivityCount: Lens<Project, Int?> {
    return Project.lens.memberData .. Project.MemberData.lens.unseenActivityCount
  }
}

extension Lens where Whole == Project, Part == Project.Dates {
  public var deadline: Lens<Project, TimeInterval?> {
    return Project.lens.dates .. Project.Dates.lens.deadline
  }

  public var featuredAt: Lens<Project, TimeInterval?> {
    return Project.lens.dates .. Project.Dates.lens.featuredAt
  }

  public var launchedAt: Lens<Project, TimeInterval?> {
    return Project.lens.dates .. Project.Dates.lens.launchedAt
  }

  public var stateChangedAt: Lens<Project, TimeInterval> {
    return Project.lens.dates .. Project.Dates.lens.stateChangedAt
  }
}

extension Lens where Whole == Project, Part == Project.Personalization {
  public var backing: Lens<Project, Backing?> {
    return Project.lens.personalization .. Project.Personalization.lens.backing
  }

  public var friends: Lens<Project, [User]?> {
    return Project.lens.personalization .. Project.Personalization.lens.friends
  }

  public var isBacking: Lens<Project, Bool?> {
    return Project.lens.personalization .. Project.Personalization.lens.isBacking
  }

  public var isStarred: Lens<Project, Bool?> {
    return Project.lens.personalization .. Project.Personalization.lens.isStarred
  }
}

extension Lens where Whole == Project, Part == Project.RewardData {
  public var addOns: Lens<Project, [Reward]?> {
    return Project.lens.rewardData .. Project.RewardData.lens.addOns
  }

  public var rewards: Lens<Project, [Reward]> {
    return Project.lens.rewardData .. Project.RewardData.lens.rewards
  }
}

extension Lens where Whole == Project, Part == Project.Photo {
  public var full: Lens<Project, String> {
    return Project.lens.photo .. Project.Photo.lens.full
  }

  public var med: Lens<Project, String> {
    return Project.lens.photo .. Project.Photo.lens.med
  }

  public var size1024x768: Lens<Project, String?> {
    return Project.lens.photo .. Project.Photo.lens.size1024x768
  }

  public var small: Lens<Project, String> {
    return Project.lens.photo .. Project.Photo.lens.small
  }
}

extension Lens where Whole == Project, Part == Project.MemberData {
  public var permissions: Lens<Whole, [Project.MemberData.Permission]> {
    return Whole.lens.memberData .. Part.lens.permissions
  }
}

extension Lens where Whole == Project, Part == Project.UrlsEnvelope {
  public var web: Lens<Whole, Project.UrlsEnvelope.WebEnvelope> {
    return Whole.lens.urls .. Part.lens.web
  }
}

extension Lens where Whole == Project, Part == Project.UrlsEnvelope.WebEnvelope {
  public var project: Lens<Whole, String> {
    return Whole.lens.urls.web .. Part.lens.project
  }
}
