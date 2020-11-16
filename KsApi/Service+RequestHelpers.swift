import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift

extension Service {
  private static let session = URLSession(configuration: .default)

  func fetch<A: Decodable>(query: NonEmptySet<Query>) -> SignalProducer<A, GraphError> {
    let queryString: String = Query.build(query)

    let request = self.preparedRequest(
      forURL: self.serverConfig.graphQLEndpointUrl,
      queryString: queryString
    )

    print("⚪️ [KsApi] Starting query:\n \(queryString)")
    return Service.session.rac_graphDataResponse(request)
      .flatMap(self.decodeGraphModel)
  }

  func applyMutation<A: Decodable, B: GraphMutation>(mutation: B) -> SignalProducer<A, GraphError> {
    do {
      let request = try self.preparedGraphRequest(
        forURL: self.serverConfig.graphQLEndpointUrl,
        queryString: mutation.description,
        input: mutation.input.toInputDictionary()
      )
      print("⚪️ [KsApi] Starting mutation:\n \(mutation.description)")
      print("⚪️ [KsApi] Input:\n \(mutation.input.toInputDictionary())")

      return Service.session.rac_graphDataResponse(request)
        .flatMap(self.decodeGraphModel)
    } catch {
      return SignalProducer(error: .invalidInput)
    }
  }

  func request<M: Decodable>(_ route: Route)
    -> SignalProducer<M, ErrorEnvelope> {
    let properties = route.requestProperties

    guard let URL = URL(string: properties.path, relativeTo: self.serverConfig.apiBaseUrl as URL) else {
      fatalError(
        "URL(string: \(properties.path), relativeToURL: \(self.serverConfig.apiBaseUrl)) == nil"
      )
    }

    return Service.session.rac_dataResponse(
      preparedRequest(forURL: URL, method: properties.method, query: properties.query),
      uploading: properties.file.map { ($1, $0.rawValue) }
    )
    .flatMap(self.decodeModel)
  }

  func requestPaginationDecodable<M: Decodable>(_ paginationUrl: String)
    -> SignalProducer<M, ErrorEnvelope> {
    guard let paginationUrl = URL(string: paginationUrl) else {
      return .init(error: .invalidPaginationUrl)
    }

    return Service.session.rac_dataResponse(preparedRequest(forURL: paginationUrl))
      .flatMap(self.decodeModel)
  }
}
