import Prelude

extension DiscoveryEnvelope {
  public enum lens {
    public static let projects = Lens<DiscoveryEnvelope, [Project]>(
      view: { $0.projects },
      set: { DiscoveryEnvelope(projects: $0, urls: $1.urls, stats: $1.stats) }
    )
    public static let urls = Lens<DiscoveryEnvelope, UrlsEnvelope>(
      view: { $0.urls },
      set: { DiscoveryEnvelope(projects: $1.projects, urls: $0, stats: $1.stats) }
    )
    public static let stats = Lens<DiscoveryEnvelope, StatsEnvelope>(
      view: { $0.stats },
      set: { DiscoveryEnvelope(projects: $1.projects, urls: $1.urls, stats: $0) }
    )
  }
}

extension DiscoveryEnvelope.UrlsEnvelope {
  public enum lens {
    public static let api = Lens<DiscoveryEnvelope.UrlsEnvelope, ApiEnvelope>(
      view: { $0.api },
      set: { part, _ in DiscoveryEnvelope.UrlsEnvelope(api: part) }
    )
  }
}

extension DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope {
  public enum lens {
    public static let moreProjects = Lens<DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope, String>(
      view: { $0.moreProjects },
      set: { part, _ in DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope(more_projects: part) }
    )
  }
}

extension DiscoveryEnvelope.StatsEnvelope {
  public enum lens {
    public static let count = Lens<DiscoveryEnvelope.StatsEnvelope, Int>(
      view: { $0.count },
      set: { part, _ in DiscoveryEnvelope.StatsEnvelope(count: part) }
    )
  }
}

extension Lens where Whole == DiscoveryEnvelope, Part == DiscoveryEnvelope.UrlsEnvelope {
  public var api: Lens<DiscoveryEnvelope, DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope> {
    return DiscoveryEnvelope.lens.urls..DiscoveryEnvelope.UrlsEnvelope.lens.api
  }
}

extension Lens where Whole == DiscoveryEnvelope, Part == DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope {
  public var moreProjects: Lens<DiscoveryEnvelope, String> {
    return DiscoveryEnvelope.lens.urls.api..DiscoveryEnvelope.UrlsEnvelope.ApiEnvelope.lens.moreProjects
  }
}
