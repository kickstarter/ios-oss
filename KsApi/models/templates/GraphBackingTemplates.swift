import Prelude

extension GraphBacking {
  internal static let template = GraphBacking(
    errorReason: nil,
    id: "UmV3YXJkLTE=",
    project: nil,
    status: GraphBacking.Status.errored
  )

  internal static let errored = GraphBacking.template
    |> \.status .~ GraphBacking.Status.errored
    |> \.errorReason .~ "Credit card expired."
    |> \.project .~ .template
}

extension GraphBacking.Project {
  internal static let template = GraphBacking.Project(
    finalCollectionDate: "2020-04-08T15:15:05Z",
    name: "Cool project",
    pid: 1,
    slug: "/cool-project"
  )
}
