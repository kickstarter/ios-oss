import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift

extension Service {
  // MARK: - Swift.Codable

  func decodeModelToSignal<T: Decodable>(_ jsonData: Data) -> SignalProducer<T, ErrorEnvelope> {
    return SignalProducer(value: jsonData)
      .flatMap { data -> SignalProducer<T, ErrorEnvelope> in
        do {
          let decodedObject = try JSONDecoder().decode(T.self, from: data)

          print("🔵 [KsApi] Successfully Decoded Data")

          return .init(value: decodedObject)
        } catch {
          print("🔴 [KsApi] Failure - Decoding error: \(error), \(T.self)")
          return .init(error: .couldNotDecodeJSON(error))
        }
      }
  }

  func decodeModelToSignal<T: Decodable>(data json: Data) ->
    SignalProducer<T?, ErrorEnvelope> {
    return SignalProducer(value: json)
      .map { json in try? JSONDecoder().decode(T.self, from: json) }
  }

  func decodeModelToResult<T: Decodable>(data json: Data, ofType type: T.Type) -> Result<T?, ErrorEnvelope> {
    do {
      let decodedObject = try JSONDecoder().decode(type, from: json)
      return .success(decodedObject)
    } catch {
      return .failure(.couldNotDecodeJSON(error))
    }
  }
}
