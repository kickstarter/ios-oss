import Foundation
import GraphAPI
import KsApi

/// Maps a `VideoFeedQuery` graph node to a `VideoFeedItem` to display in the video feed.
extension VideoFeedItem {
  init(node: VideoFeedQuery.Data.VideoFeed.Node) {
    let video = node.project.verticalVideo

    self.init(
      id: node.project.id,
      pid: node.project.pid,
      slug: node.project.slug,
      projectURL: node.project.url,
      title: node.project.name,
      creator: node.project.creator?.name ?? "",
      creatorImageURL: node.project.creator.flatMap { URL(string: $0.imageUrl) },
      statsText: Self.statsText(for: node.project),
      categoryPillText: node.project.category?.name ?? "",
      secondaryPillText: node.badges.first?.text ?? "",
      videoURL: video?.videoSources?.hls?.src.flatMap { URL(string: $0) },
      videoPreviewImageURL: video?.previewImageUrl.flatMap { URL(string: $0) },
      projectId: node.project.id,
      isSaved: node.project.isWatched,
      sharesCount: node.project.sharesCount,
      watchesCount: node.project.watchesCount ?? 0,
      percentFunded: node.project.percentFunded
    )
  }

  /// Formats a string using a pledge amount in the user's preferred currency and a given backers count.
  static func statsTextInUserPreferredCurrency(pledgedAmount: Double, backersCount: Int) -> String {
    let currencyCode = AppEnvironment.current.locale.currency?.identifier ?? Project.Country.us.currencyCode

    let pledgedFormatted = Format.currency(
      pledgedAmount,
      currencyCode: currencyCode,
      omitCurrencyCode: true,
      maximumFractionDigits: 0,
      minimumFractionDigits: 0
    )

    return Strings.video_feed_campaign_subtitle(
      pledged: pledgedFormatted,
      backers: backersCount.toString()
    )
  }

  private static func statsText(for project: VideoFeedQuery.Data.VideoFeed.Node.Project) -> String {
    let amount = project.pledged.amount
      .flatMap { Double($0) } ?? 0

    return Self.statsTextInUserPreferredCurrency(pledgedAmount: amount, backersCount: project.backersCount)
  }
}
