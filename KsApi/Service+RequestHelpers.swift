import Combine
import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift

extension Service {
  private static let session = URLSession(configuration: .default)

  func request<Model: Decodable>(_ route: Route)
    -> SignalProducer<Model, ErrorEnvelope> {
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
    .flatMap(self.decodeModelToSignal)
  }

  func request<Model: Decodable>(_ route: Route) -> AnyPublisher<Model, ErrorEnvelope> {
    let properties = route.requestProperties

    guard let URL = URL(string: properties.path, relativeTo: self.serverConfig.apiBaseUrl as URL) else {
      fatalError(
        "URL(string: \(properties.path), relativeToURL: \(self.serverConfig.apiBaseUrl)) == nil"
      )
    }

    return Service.session.combine_dataResponse(
      preparedRequest(forURL: URL, method: properties.method, query: properties.query),
      uploading: properties.file.map { ($1, $0.rawValue) },
      and: self.perimeterXClient
    ).handle_combine_dataResponse(service: self)
  }

  func requestWithAuthentication<Model: Decodable>(_ route: Route,
                                                   oauthToken: String) -> AnyPublisher<Model, ErrorEnvelope> {
    let properties = route.requestProperties

    guard let URL = URL(string: properties.path, relativeTo: self.serverConfig.apiBaseUrl as URL) else {
      fatalError(
        "URL(string: \(properties.path), relativeToURL: \(self.serverConfig.apiBaseUrl)) == nil"
      )
    }

    var preparedRequest = preparedRequest(forURL: URL, method: properties.method, query: properties.query)
    addV1AuthenticationToRequest(&preparedRequest, oauthToken: oauthToken)

    return Service.session.combine_dataResponse(
      preparedRequest,
      uploading: properties.file.map { ($1, $0.rawValue) },
      and: self.perimeterXClient
    ).handle_combine_dataResponse(service: self)
  }

  func requestPaginationDecodable<Model: Decodable>(_ paginationUrl: String)
    -> SignalProducer<Model, ErrorEnvelope> {
    guard let paginationUrl = URL(string: paginationUrl) else {
      return .init(error: .invalidPaginationUrl)
    }

    return Service.session
      .rac_dataResponse(preparedRequest(forURL: paginationUrl), and: self.perimeterXClient)
      .flatMap(self.decodeModelToSignal)
  }

  func requestPaginationDecodable<Model: Decodable>(_ paginationUrl: String)
    -> AnyPublisher<Model, ErrorEnvelope> {
    guard let paginationUrl = URL(string: paginationUrl) else {
      fatalError("Invalid pagination URL \(paginationUrl)")
    }

    return Service.session
      .combine_dataResponse(preparedRequest(forURL: paginationUrl), and: self.perimeterXClient)
      .handle_combine_dataResponse(service: self)
  }
}

extension Publisher where Output == Data, Failure == ErrorEnvelope {
  func handle_combine_dataResponse<Model: Decodable>(service: Service) -> AnyPublisher<Model, ErrorEnvelope> {
    return self
      .tryMap { data in
        let result: Result<Model?, ErrorEnvelope> = service
          .decodeModelToResult(data: data, ofType: Model.self)

        switch result {
        case let .success(value):
          return value
        case let .failure(error):
          throw error
        }
      }
      .compactMap { $0 }
      .mapError { error in
        error as! ErrorEnvelope
      }.eraseToAnyPublisher()
  }
}
