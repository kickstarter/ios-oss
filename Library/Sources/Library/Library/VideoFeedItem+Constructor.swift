import Foundation
import GraphAPI
import KsApi

/// Maps a `VideoFeedQuery` graph node to a `VideoFeedItem` to display in the video feed.
extension VideoFeedItem {
  init(node: VideoFeedQuery.Data.VideoFeed.Node) {
    let video = node.project.verticalVideo

    self.init(
      id: node.project.id,
      title: node.project.name,
      creator: node.project.creator?.name ?? "",
      creatorImageURL: node.project.creator.flatMap { URL(string: $0.imageUrl) },
      statsText: Self.statsText(for: node.project),
      categoryPillText: node.project.category?.name ?? "",
      secondaryPillText: node.badges.first?.text ?? "",
      videoURL: video?.videoSources?.hls?.src.flatMap { URL(string: $0) },
      videoPreviewImageURL: video?.previewImageUrl.flatMap { URL(string: $0) }
    )
  }

  private static func statsText(for project: VideoFeedQuery.Data.VideoFeed.Node.Project) -> String {
    let currencyCode = AppEnvironment.current.locale.currency?.identifier ?? Project.Country.us.currencyCode

    let pledgedFormatted = project.pledged.amount
      .flatMap { Double($0) }
      .map {
        Format.currency(
          $0,
          currencyCode: currencyCode,
          omitCurrencyCode: false,
          maximumFractionDigits: 0,
          minimumFractionDigits: 0
        )
      } ?? ""

    // TODO: Update with Video Feed Translations [mbl-3158](https://kickstarter.atlassian.net/browse/MBL-3158)
    return "FPO: \(pledgedFormatted) pledged • Join \(project.backersCount) backers"
  }
}
