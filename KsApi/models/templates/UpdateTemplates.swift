import Foundation

// swiftlint:disable line_length
extension Update {
  internal static let template = Update(
    body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam id vulputate augue. Donec elementum est facilisis dolor accumsan feugiat. Nam et pellentesque massa. Sed sit amet commodo ligula. Sed viverra, est viverra pretium luctus, arcu ligula congue neque, sed bibendum neque quam vel elit. Nunc varius orci et tempus consequat. Nullam tempor velit vitae consectetur mattis. Proin dignissim id turpis ac fermentum.",
    commentsCount: 2,
    hasLiked: false,
    id: 1,
    isPublic: true,
    likesCount: 3,
    projectId: 1,
    publishedAt: Date(timeIntervalSince1970: 1475361315).timeIntervalSince1970,
    sequence: 1,
    title: "Hello",
    urls: Update.UrlsEnvelope(web: Update.UrlsEnvelope.WebEnvelope(
      update: "https://www.kickstarter.com/projects/udoo/udoo-x86/posts/1571540")
    ),
    user: nil,
    visible: true
  )
}
