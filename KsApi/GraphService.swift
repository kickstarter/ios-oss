import Foundation
import Prelude
import ReactiveSwift
import Result

/**
 A `GraphQLService` that requests data from a GraphQL webservice.
 */
public struct GraphQLService: Servicetype {
  public let appId: String
  public let buildVersion: String
  public let language: String
  public let oauthToken: OauthTokenAuthType?
  public let serverConfig: ServerConfigType

  public init(appId: String = Bundle.main.bundleIdentifier ?? "com.kickstarter.kickstarter",
              serverConfig: ServerConfigType = ServerConfig.production,
              oauthToken: OauthTokenAuthType? = nil,
              language: String = "en",
              buildVersion: String = Bundle.main._buildVersion) {

    self.appId = appId
    self.buildVersion = buildVersion
    self.language = language
    self.oauthToken = oauthToken
    self.serverConfig = serverConfig
  }

  public func fetch<A: Decodable>(query: NonEmptySet<Query>) -> SignalProducer<A, GraphError> {
      return SignalProducer<A, GraphError> { observer, disposable in

        let request = self.preparedRequest(forURL: self.serverConfig.graphQLEndpointUrl,
                                           queryString: Query.build(query))

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          if let error = error {
            observer.send(error: .requestError(error, response))
            return
          }

          guard let data = data else {
            observer.send(error: .emptyResponse(response))
            return
          }

          guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
            observer.send(error: .invalidJson(responseString: String(data: data, encoding: .utf8)))
            return
          }

          let json = JSON(jsonObject)
          let decoded = A.decode(json)

          switch decoded {
          case let .success(value):
            observer.send(value: value)
            observer.sendCompleted()
          case let .failure(error):
            let jsonString = String(data: data, encoding: .utf8)
            if let gqlError = GraphQLErrorEnvelope.decode(JSON(jsonObject)).value {
              observer.send(error: .graphQLError(gqlError))
            } else {
              observer.send(error: .argoError(jsonString: jsonString, error))
            }
          }
        }

        disposable.add(task.cancel)
        task.resume()
      }
  }
}

