import Argo
import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift

extension Service {
  func decodeModel<M: Argo.Decodable>(_ json: Any) ->
    SignalProducer<M, ErrorEnvelope> where M == M.DecodedType {
    return SignalProducer(value: json)
      .map { json in decode(json) as Decoded<M> }
      .flatMap(.concat) { (decoded: Decoded<M>) -> SignalProducer<M, ErrorEnvelope> in
        switch decoded {
        case let .success(value):
          return .init(value: value)
        case let .failure(error):
          print("🔴 [KsApi] Failure - Argo decoding model \(M.self) error: \(error)")
          return .init(error: .couldNotDecodeJSON(error))
        }
      }
  }

  func decodeModels<M: Argo.Decodable>(_ json: Any)
    -> SignalProducer<[M], ErrorEnvelope> where M == M.DecodedType {
    return SignalProducer(value: json)
      .map { json in decode(json) as Decoded<[M]> }
      .flatMap(.concat) { (decoded: Decoded<[M]>) -> SignalProducer<[M], ErrorEnvelope> in
        switch decoded {
        case let .success(value):
          return .init(value: value)
        case let .failure(error):
          print("🔴 [KsApi] Failure - Argo decoding model error: \(error)")
          return .init(error: .couldNotDecodeJSON(error))
        }
      }
  }

  func decodeModel<M: Argo.Decodable>(_ json: Any) ->
    SignalProducer<M?, ErrorEnvelope> where M == M.DecodedType {
    return SignalProducer(value: json)
      .map { json in decode(json) as M? }
  }

  // MARK: - Swift.Codable

  func decodeGraphModel<T: Swift.Decodable>(_ jsonData: Data) -> SignalProducer<T, GraphError> {
    return SignalProducer(value: jsonData)
      .flatMap { data -> SignalProducer<T, GraphError> in
        do {
          let decodedObject = try JSONDecoder().decode(GraphResponse<T>.self, from: data)

          print("🔵 [KsApi] Successfully Decoded Data")

          return .init(value: decodedObject.data)
        } catch {
          print("🔴 [KsApi] Failure - Decoding error: \((error as NSError).description)")
          return .init(error: .jsonDecodingError(
            responseString: String(data: data, encoding: .utf8),
            error: error
          ))
        }
      }
  }

  func decodeModel<T: Swift.Decodable>(_ jsonData: Data) -> SignalProducer<T, ErrorEnvelope> {
    return SignalProducer(value: jsonData)
      .flatMap { data -> SignalProducer<T, ErrorEnvelope> in
        do {
          let decodedObject = try JSONDecoder().decode(T.self, from: data)

          print("🔵 [KsApi] Successfully Decoded Data")

          return .init(value: decodedObject)
        } catch {
          print("🔴 [KsApi] Failure - Decoding error: \(error)")
          return .init(error: .couldNotDecodeJSON(error))
        }
      }
  }

  func decodeModels<T: Swift.Decodable>(_ jsonData: Data) -> SignalProducer<[T], ErrorEnvelope> {
    return SignalProducer(value: jsonData)
      .flatMap { data -> SignalProducer<[T], ErrorEnvelope> in
        do {
          let decodedObject = try JSONDecoder().decode([T].self, from: data)

          print("🔵 [KsApi] Successfully Decoded Data")

          return .init(value: decodedObject)
        } catch {
          print("🔴 [KsApi] Failure - Decoding error: \(error)")
          return .init(error: .couldNotDecodeJSON(error))
        }
      }
  }

  func decodeModel<T: Swift.Decodable>(data json: Data) ->
    SignalProducer<T?, ErrorEnvelope> {
    return SignalProducer(value: json)
      .map { json in try? JSONDecoder().decode(T.self, from: json) }
  }
}
