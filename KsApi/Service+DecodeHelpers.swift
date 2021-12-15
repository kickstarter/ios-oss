import Foundation
import Prelude
import ReactiveExtensions
import ReactiveSwift

extension Service {
  // MARK: - Swift.Codable

  func decodeModel<T: Decodable>(_ jsonData: Data) -> SignalProducer<T, ErrorEnvelope> {
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

  func decodeModels<T: Decodable>(_ jsonData: Data) -> SignalProducer<[T], ErrorEnvelope> {
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

  func decodeModel<T: Decodable>(data json: Data) ->
    SignalProducer<T?, ErrorEnvelope> {
    return SignalProducer(value: json)
      .map { json in try? JSONDecoder().decode(T.self, from: json) }
  }
}
