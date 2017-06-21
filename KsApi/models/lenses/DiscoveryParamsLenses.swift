import Prelude

extension DiscoveryParams {
  public enum lens {
    public static let backed = Lens<DiscoveryParams, Bool?>(
      view: { $0.backed },
      set: { DiscoveryParams(backed: $0, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social, sort: $1.sort,
        staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let category = Lens<DiscoveryParams, Category?>(
      view: { $0.category },
      set: { DiscoveryParams(backed: $1.backed, category: $0, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social, sort: $1.sort,
        staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let collaborated = Lens<DiscoveryParams, Bool?>(
      view: { $0.collaborated },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $0,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social, sort: $1.sort,
        staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let created = Lens<DiscoveryParams, Bool?>(
      view: { $0.created },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $0, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social, sort: $1.sort,
        staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let hasLiveStreams = Lens<DiscoveryParams, Bool?>(
      view: { $0.hasLiveStreams },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $0, hasVideo: $1.hasVideo, includePOTD: $1.includePOTD,
        page: $1.page, perPage: $1.perPage, query: $1.query, recommended: $1.recommended, seed: $1.seed,
        similarTo: $1.similarTo, social: $1.social, sort: $1.sort, staffPicks: $1.staffPicks,
        starred: $1.starred, state: $1.state) }
    )
    public static let hasVideo = Lens<DiscoveryParams, Bool?>(
      view: { $0.hasVideo },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $0, includePOTD: $1.includePOTD,
        page: $1.page, perPage: $1.perPage, query: $1.query, recommended: $1.recommended, seed: $1.seed,
        similarTo: $1.similarTo, social: $1.social, sort: $1.sort, staffPicks: $1.staffPicks,
        starred: $1.starred, state: $1.state) }
    )
    public static let includePOTD = Lens<DiscoveryParams, Bool?>(
      view: { $0.includePOTD },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo, includePOTD: $0,
        page: $1.page, perPage: $1.perPage, query: $1.query, recommended: $1.recommended, seed: $1.seed,
        similarTo: $1.similarTo, social: $1.social, sort: $1.sort, staffPicks: $1.staffPicks,
        starred: $1.starred, state: $1.state) }
    )
    public static let page = Lens<DiscoveryParams, Int?>(
      view: { $0.page },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $0, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social, sort: $1.sort,
        staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let perPage = Lens<DiscoveryParams, Int?>(
      view: { $0.perPage },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $0, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social,
        sort: $1.sort, staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let query = Lens<DiscoveryParams, String?>(
      view: { $0.query },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $0,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social,
        sort: $1.sort, staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let recommended = Lens<DiscoveryParams, Bool?>(
      view: { $0.recommended },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $0, seed: $1.seed, similarTo: $1.similarTo, social: $1.social, sort: $1.sort,
        staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let seed = Lens<DiscoveryParams, Int?>(
      view: { $0.seed },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $0, similarTo: $1.similarTo, social: $1.social, sort: $1.sort,
        staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let similarTo = Lens<DiscoveryParams, Project?>(
      view: { $0.similarTo },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $0, social: $1.social, sort: $1.sort,
        staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let social = Lens<DiscoveryParams, Bool?>(
      view: { $0.social },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $0, sort: $1.sort,
        staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let sort = Lens<DiscoveryParams, DiscoveryParams.Sort?>(
      view: { $0.sort },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social,
        sort: $0, staffPicks: $1.staffPicks, starred: $1.starred, state: $1.state) }
    )
    public static let staffPicks = Lens<DiscoveryParams, Bool?>(
      view: { $0.staffPicks },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social,
        sort: $1.sort, staffPicks: $0, starred: $1.starred, state: $1.state) }
    )
    public static let starred = Lens<DiscoveryParams, Bool?>(
      view: { $0.starred },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social,
        sort: $1.sort, staffPicks: $1.staffPicks, starred: $0, state: $1.state) }
    )
    public static let state = Lens<DiscoveryParams, DiscoveryParams.State?>(
      view: { $0.state },
      set: { DiscoveryParams(backed: $1.backed, category: $1.category, collaborated: $1.collaborated,
        created: $1.created, hasLiveStreams: $1.hasLiveStreams, hasVideo: $1.hasVideo,
        includePOTD: $1.includePOTD, page: $1.page, perPage: $1.perPage, query: $1.query,
        recommended: $1.recommended, seed: $1.seed, similarTo: $1.similarTo, social: $1.social, sort: $1.sort,
        staffPicks: $1.staffPicks, starred: $1.starred, state: $0) }
    )
  }
}
