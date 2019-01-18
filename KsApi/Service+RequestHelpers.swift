import Argo
import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift

extension Service {
  private static let session = URLSession(configuration: .default)

  private func decodeModel<M: Argo.Decodable>(_ json: Any) ->
    SignalProducer<M, ErrorEnvelope> where M == M.DecodedType {

      return SignalProducer(value: json)
        .map { json in decode(json) as Decoded<M> }
        .flatMap(.concat) { (decoded: Decoded<M>) -> SignalProducer<M, ErrorEnvelope> in
          switch decoded {
          case let .success(value):
            return .init(value: value)
          case let .failure(error):
            print("Argo decoding model \(M.self) error: \(error)")
            return .init(error: .couldNotDecodeJSON(error))
          }
      }
  }

  private func decodeModels<M: Argo.Decodable>(_ json: Any)
    -> SignalProducer<[M], ErrorEnvelope> where M == M.DecodedType {

      return SignalProducer(value: json)
        .map { json in decode(json) as Decoded<[M]> }
        .flatMap(.concat) { (decoded: Decoded<[M]>) -> SignalProducer<[M], ErrorEnvelope> in
          switch decoded {
          case let .success(value):
            return .init(value: value)
          case let .failure(error):
            print("Argo decoding model error: \(error)")
            return .init(error: .couldNotDecodeJSON(error))
          }
      }
  }

  private func decodeModel<M: Argo.Decodable>(_ json: Any) ->
    SignalProducer<M?, ErrorEnvelope> where M == M.DecodedType {

      return SignalProducer(value: json)
        .map { json in decode(json) as M? }
  }

  private func performRequest<A: Swift.Decodable>(request: URLRequest) -> SignalProducer<A, GraphError> {
    return SignalProducer<A, GraphError> { observer, disposable in
      let task = URLSession.shared.dataTask(with: request) {  data, response, error in
        if let error = error {
          observer.send(error: .requestError(error, response))
          print("🔴 [KsApi] Failure - Request error: \(error.localizedDescription)")
        }

        guard let data = data else {
          print("🔴 [KsApi] Failure - Empty response")
          observer.send(error: .emptyResponse(response))
          return
        }

        do {
          let decodedObject = try JSONDecoder().decode(GraphResponse<A>.self, from: data)
          if let errors = decodedObject.errors, let error = errors.first {
            observer.send(error: .decodeError(error))
            print("🔴 [KsApi] Failure - Decoding error: \(error.message)")
          } else if let value = decodedObject.data {
            print("🔵 [KsApi] Success")
            observer.send(value: value)
          }
        } catch let error {
          print("🔴 [KsApi] Failure - JSON decoding error: \(error.localizedDescription)")
          observer.send(error: .jsonDecodingError(responseString: String(data: data, encoding: .utf8),
                                                  error: error))
        }
        observer.sendCompleted()
      }

      disposable.observeEnded {
        task.cancel()
      }

      task.resume()
    }
  }

  // MARK: Public Request Functions
  func fetch<A: Swift.Decodable>(query: NonEmptySet<Query>) -> SignalProducer<A, GraphError> {
    let queryString: String = Query.build(query)
    let request = self.preparedRequest(forURL: self.serverConfig.graphQLEndpointUrl,
                                       queryString: queryString)

    print("⚪️ [KsApi] Starting query:\n \(queryString)")
    return performRequest(request: request)
  }

  func applyMutation<A: Swift.Decodable, B: GraphMutation>(mutation: B) -> SignalProducer<A, GraphError> {
    do {
      let request = try self.preparedGraphRequest(forURL: self.serverConfig.graphQLEndpointUrl,
                                                  queryString: mutation.description,
                                                  input: mutation.input.toInputDictionary())
      print("⚪️ [KsApi] Starting mutation:\n \(mutation.description)")
      return performRequest(request: request)
    } catch {
      return SignalProducer(error: .invalidInput)
    }
  }

  func requestPagination<M: Argo.Decodable>(_ paginationUrl: String)
    -> SignalProducer<M, ErrorEnvelope> where M == M.DecodedType {

      guard let paginationUrl = URL(string: paginationUrl) else {
        return .init(error: .invalidPaginationUrl)
      }

      return Service.session.rac_JSONResponse(preparedRequest(forURL: paginationUrl))
        .flatMap(decodeModel)
  }

  func request<M: Argo.Decodable>(_ route: Route)
    -> SignalProducer<M, ErrorEnvelope> where M == M.DecodedType {

      let properties = route.requestProperties

      guard let URL = URL(string: properties.path, relativeTo: self.serverConfig.apiBaseUrl as URL) else {
        fatalError(
          "URL(string: \(properties.path), relativeToURL: \(self.serverConfig.apiBaseUrl)) == nil"
        )
      }

      return Service.session.rac_JSONResponse(
        preparedRequest(forURL: URL, method: properties.method, query: properties.query),
        uploading: properties.file.map { ($1, $0.rawValue) }
        )
        .flatMap(decodeModel)
  }

  func request<M: Argo.Decodable>(_ route: Route)
    -> SignalProducer<[M], ErrorEnvelope> where M == M.DecodedType {

      let properties = route.requestProperties

      let url = self.serverConfig.apiBaseUrl.appendingPathComponent(properties.path)

      return Service.session.rac_JSONResponse(
        preparedRequest(forURL: url, method: properties.method, query: properties.query),
        uploading: properties.file.map { ($1, $0.rawValue) }
        )
        .flatMap(decodeModels)
  }

  func request<M: Argo.Decodable>(_ route: Route)
    -> SignalProducer<M?, ErrorEnvelope> where M == M.DecodedType {

      let properties = route.requestProperties

      guard let URL = URL(string: properties.path, relativeTo: self.serverConfig.apiBaseUrl as URL) else {
        fatalError(
          "URL(string: \(properties.path), relativeToURL: \(self.serverConfig.apiBaseUrl)) == nil"
        )
      }

      return Service.session.rac_JSONResponse(
        preparedRequest(forURL: URL, method: properties.method, query: properties.query),
        uploading: properties.file.map { ($1, $0.rawValue) }
        )
        .flatMap(decodeModel)
  }
}
