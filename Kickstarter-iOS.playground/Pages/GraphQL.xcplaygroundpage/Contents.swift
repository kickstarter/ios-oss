import Foundation
@testable import KsApi
import Prelude
import ReactiveExtensions
import ReactiveSwift
import Result
import PlaygroundSupport

func query(withSlug slug: String) -> NonEmptySet<Query> {
  return Query.project(slug: slug,
     .slug +| [
      .id
    ]
  ) +| []
}

struct ProjectEnvelope: Decodable {
  let project: Project

  struct Project: Decodable {
    let slug: String
    let id: String
  }
}


let client = Service()
let signal: SignalProducer<ProjectEnvelope, GraphError> =
  client.fetchGraph(query: query(withSlug:"splatware-unique-ceramic-tableware"))
let (fakeTaps, sink) = Signal<Void, NoError>.pipe()

let project = fakeTaps.switchMap {
  signal.materialize()
}.logEvents(identifier: "Project!")

sink.send(value: ())
PlaygroundPage.current.needsIndefiniteExecution = true

