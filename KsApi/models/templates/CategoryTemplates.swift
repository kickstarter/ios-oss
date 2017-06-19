import Prelude

extension KsApi.Category {
  internal static let template = Category(
    color: nil,
    id: 1,
    name: "Art",
    parent: nil,
    parentId: nil,
    position: 1,
    projectsCount: 450,
    slug: "art"
  )

  internal static let art = template
    |> Category.lens.id .~ 1
    <> Category.lens.name .~ "Art"
    <> Category.lens.slug .~ "art"
    <> Category.lens.position .~ 1

  internal static let filmAndVideo = template
    |> Category.lens.id .~ 11
    <> Category.lens.name .~ "Film & Video"
    <> Category.lens.slug .~ "film-and-video"
    <> Category.lens.position .~ 7

  internal static let games = template
    |> Category.lens.id .~ 12
    <> Category.lens.name .~ "Games"
    <> Category.lens.slug .~ "games"
    <> Category.lens.position .~ 9

  internal static let illustration = template
    |> Category.lens.id .~ 22
    <> Category.lens.name .~ "Illustration"
    <> Category.lens.slug .~ "art/illustration"
    <> Category.lens.position .~ 4
    <> Category.lens.parentId .~ Category.art.id
    <> Category.lens.parent .~ Category.art

  internal static let documentary = template
    |> Category.lens.id .~ 30
    <> Category.lens.name .~ "Documentary"
    <> Category.lens.slug .~ "film-and-video/documentary"
    <> Category.lens.position .~ 4
    <> Category.lens.parentId .~ Category.filmAndVideo.id
    <> Category.lens.parent .~ Category.filmAndVideo

  internal static let tabletopGames = template
    |> Category.lens.id .~ 34
    <> Category.lens.name .~ "Tabletop Games"
    <> Category.lens.slug .~ "games/tabletop-games"
    <> Category.lens.position .~ 9
    <> Category.lens.parentId .~ Category.games.id
    <> Category.lens.parent .~ Category.games
}
