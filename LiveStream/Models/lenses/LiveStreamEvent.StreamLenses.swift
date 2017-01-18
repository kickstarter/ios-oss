// swiftlint:disable type_name
import Prelude

extension LiveStreamEvent.Stream {
  public enum lens {
    public static let backgroundImageUrl = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.backgroundImageUrl },
      set: { .init(backgroundImageUrl: $0, description: $1.description, hasReplay: $1.hasReplay,
        hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale, liveNow: $1.liveNow,
        maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name, projectWebUrl: $1.projectWebUrl,
        projectName: $1.projectName, replayUrl: $1.replayUrl, startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let description = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.description },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $0,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let hasReplay = Lens<LiveStreamEvent.Stream, Bool>(
      view: { $0.hasReplay },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $0, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let hlsUrl = Lens<LiveStreamEvent.Stream, String?>(
      view: { $0.hlsUrl },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $0, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let isRtmp = Lens<LiveStreamEvent.Stream, Bool?>(
      view: { $0.isRtmp },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $0, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let isScale = Lens<LiveStreamEvent.Stream, Bool?>(
      view: { $0.isScale },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $0,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let liveNow = Lens<LiveStreamEvent.Stream, Bool>(
      view: { $0.liveNow },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $0, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let maxOpenTokViewers = Lens<LiveStreamEvent.Stream, Int?>(
      view: { $0.maxOpenTokViewers },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $0, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let name = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.name },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $0,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let projectWebUrl = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.projectWebUrl },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $0, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let projectName = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.projectWebUrl },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $0, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let replayUrl = Lens<LiveStreamEvent.Stream, String?>(
      view: { $0.replayUrl },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $0,
        startDate: $1.startDate, webUrl: $1.webUrl) }
    )

    public static let startDate = Lens<LiveStreamEvent.Stream, Date>(
      view: { $0.startDate },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $0, webUrl: $1.webUrl) }
    )

    public static let webUrl = Lens<LiveStreamEvent.Stream, String>(
      view: { $0.webUrl },
      set: { .init(backgroundImageUrl: $1.backgroundImageUrl, description: $1.description,
        hasReplay: $1.hasReplay, hlsUrl: $1.hlsUrl, isRtmp: $1.isRtmp, isScale: $1.isScale,
        liveNow: $1.liveNow, maxOpenTokViewers: $1.maxOpenTokViewers, name: $1.name,
        projectWebUrl: $1.projectWebUrl, projectName: $1.projectName, replayUrl: $1.replayUrl,
        startDate: $1.startDate, webUrl: $0) }
    )
  }
}
