import Prelude

extension Project.Category {
  internal static let template = Project.Category(
    analyticsName: "Ceramics",
    id: 1,
    name: "Ceramics",
    parentAnalyticsName: "Art",
    parentId: nil,
    parentName: "Art"
  )

  internal static let spanishTemplate = Project.Category(
    analyticsName: "Ceramics",
    id: 1,
    name: "Cerámica",
    parentAnalyticsName: "Art",
    parentId: nil,
    parentName: "Art"
  )

  internal static let art = template
    |> \.id .~ 1
    <> \.name .~ "Art"

  internal static let filmAndVideo = template
    |> \.id .~ 11
    <> \.name .~ "Film & Video"

  internal static let games = template
    |> \.id .~ 12
    <> \.name .~ "Games"

  internal static let illustration = template
    |> \.analyticsName .~ "Illustration"
    |> \.id .~ 22
    |> \.name .~ "Illustration"
    |> \.parentId .~ Project.Category.art.id
    |> \.parentName .~ Project.Category.art.name

  internal static let documentary = template
    |> \.analyticsName .~ "Documentary"
    |> \.id .~ 30
    |> \.name .~ "Documentary"
    |> \.parentId .~ Project.Category.filmAndVideo.id
    |> \.parentName .~ Project.Category.filmAndVideo.name

  internal static let tabletopGames = template
    |> \.analyticsName .~ "Tabletop Games"
    |> \.id .~ 34
    |> \.name .~ "Tabletop Games"
    |> \.parentId .~ Project.Category.games.id
    |> \.parentName .~ Project.Category.games.name
}
