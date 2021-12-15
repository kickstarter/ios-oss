import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift

extension Service {
  private static let session = URLSession(configuration: .default)

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
      uploading: properties.file.map { ($1, $0.rawValue) },
      and: self.perimeterXClient
    )
    .flatMap(self.decodeModel)
  }

  func requestPaginationDecodable<M: Decodable>(_ paginationUrl: String)
    -> SignalProducer<M, ErrorEnvelope> {
    guard let paginationUrl = URL(string: paginationUrl) else {
      return .init(error: .invalidPaginationUrl)
    }

    return Service.session
      .rac_dataResponse(preparedRequest(forURL: paginationUrl), and: self.perimeterXClient)
      .flatMap(self.decodeModel)
  }
}
