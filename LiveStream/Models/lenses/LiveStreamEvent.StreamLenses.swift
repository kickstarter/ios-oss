// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent.Stream {
  public enum lens {
    public static let backgroundImageUrl = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.backgroundImageUrl },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $0, maxOpenTokViewers: $1.maxOpenTokViewers,
        webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, isRtmp: $1.isRtmp,
        isScale: $1.isScale, hasReplay: $1.hasReplay, replayUrl: $1.replayUrl) }
    )

    public static let description = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.description },
      set: { .init(name: $1.name, description: $0, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl,
        projectName: $1.projectName, isRtmp: $1.isRtmp, isScale: $1.isScale, hasReplay: $1.hasReplay,
        replayUrl: $1.replayUrl) }
    )

    public static let hasReplay = Lens<LiveStreamEvent.Stream, Bool>(
      view: { $0.hasReplay },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl,
        projectName: $1.projectName, isRtmp: $1.isRtmp, isScale: $1.isScale, hasReplay: $0,
        replayUrl: $1.replayUrl) }
    )

    public static let hlsUrl = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.hlsUrl },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $0, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl,
        projectName: $1.projectName, isRtmp: $1.isRtmp, isScale: $1.isScale, hasReplay: $1.hasReplay,
        replayUrl: $1.replayUrl) }
    )

    public static let isRtmp = Lens<LiveStreamEvent.Stream, Bool>(
      view: { $0.isRtmp },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl,
        projectName: $1.projectName, isRtmp: $0, isScale: $1.isScale, hasReplay: $1.hasReplay,
        replayUrl: $1.replayUrl) }
    )

    public static let isScale = Lens<LiveStreamEvent.Stream, Bool>(
      view: { $0.isScale },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl,
        projectName: $1.projectName, isRtmp: $1.isRtmp, isScale: $0, hasReplay: $1.hasReplay,
        replayUrl: $1.replayUrl) }
    )

    public static let liveNow = Lens<LiveStreamEvent.Stream, Bool>(
      view: { $0.liveNow },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $0,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl,
        projectName: $1.projectName, isRtmp: $1.isRtmp, isScale: $1.isScale, hasReplay: $1.hasReplay,
        replayUrl: $1.replayUrl) }
    )

    public static let maxOpenTokViewers = Lens<LiveStreamEvent.Stream, Int>(
      view: { $0.maxOpenTokViewers },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl, maxOpenTokViewers: $0,
        webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, isRtmp: $1.isRtmp,
        isScale: $1.isScale, hasReplay: $1.hasReplay, replayUrl: $1.replayUrl) }
    )

    public static let projectName = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.projectName },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl,
        projectName: $0, isRtmp: $1.isRtmp, isScale: $1.isScale, hasReplay: $1.hasReplay,
        replayUrl: $1.replayUrl) }
    )

    public static let projectWebUrl = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.projectWebUrl },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $1.webUrl, projectWebUrl: $0,
        projectName: $1.projectWebUrl, isRtmp: $1.isRtmp, isScale: $1.isScale, hasReplay: $1.hasReplay,
        replayUrl: $1.replayUrl) }
    )

    public static let replayUrl = Lens<LiveStreamEvent.Stream, String?>(
      view: { $0.replayUrl },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl,
        projectName: $1.projectName, isRtmp: $1.isRtmp, isScale: $1.isScale, hasReplay: $1.hasReplay,
        replayUrl: $0) }
    )

    public static let startDate = Lens<LiveStreamEvent.Stream, NSDate>(
      view: { $0.startDate },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $0, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $1.webUrl, projectWebUrl: $1.projectWebUrl,
        projectName: $1.projectName, isRtmp: $1.isRtmp, isScale: $1.isScale, hasReplay: $1.hasReplay,
        replayUrl: $1.replayUrl) }
    )

    public static let webUrl = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.webUrl },
      set: { .init(name: $1.name, description: $1.description, hlsUrl: $1.hlsUrl, liveNow: $1.liveNow,
        startDate: $1.startDate, backgroundImageUrl: $1.backgroundImageUrl,
        maxOpenTokViewers: $1.maxOpenTokViewers, webUrl: $0, projectWebUrl: $1.projectWebUrl,
        projectName: $1.projectName, isRtmp: $1.isRtmp, isScale: $1.isScale, hasReplay: $1.hasReplay,
        replayUrl: $1.replayUrl) }
    )
  }
}
