@testable import KsApi
import ReactiveExtensions
import ReactiveSwift
import XCTest

struct MySwiftModel: Decodable, Equatable {
  public let array: [String]
  public let bool: Bool
  public let dict: [String: String]
  public let id: Int
  public let name: String
}

final class ServiceTests: XCTestCase {
  func testDefaults() {
    XCTAssertTrue(Service().serverConfig == ServerConfig.production)
    XCTAssertNil(Service().oauthToken)
    XCTAssertEqual(Service().language, "en")
  }

  func testEquals() {
    let s1 = Service()
    let s2 = Service(serverConfig: ServerConfig.staging)
    let s3 = Service(oauthToken: OauthToken(token: "deadbeef"))
    let s4 = Service(language: "es")

    XCTAssertTrue(s1 == s1)
    XCTAssertTrue(s2 == s2)
    XCTAssertTrue(s3 == s3)
    XCTAssertTrue(s4 == s4)

    XCTAssertFalse(s1 == s2)
    XCTAssertFalse(s1 == s3)
    XCTAssertFalse(s1 == s4)

    XCTAssertFalse(s2 == s3)
    XCTAssertFalse(s2 == s4)

    XCTAssertFalse(s3 == s4)
  }

  func testLogin() {
    let loggedOut = Service()
    let loggedIn = loggedOut.login(OauthToken(token: "deadbeef"))

    XCTAssertTrue(loggedIn == Service(oauthToken: OauthToken(token: "deadbeef")))
  }

  func testLogout() {
    let loggedIn = Service(oauthToken: OauthToken(token: "deadbeef"))
    let loggedOut = loggedIn.logout()

    XCTAssertTrue(loggedOut == Service())
  }

  func testSwiftDecodeModel_ValidModel() {
    let jsonData: String = """
    {
        "array": ["string1", "string2"],
        "bool": true,
        "dict": {"key1": "value1", "key2": "value2"},
        "id": 5,
        "name": "Swift Name"
    }
    """

    let expectedResult = try! JSONDecoder().decode(MySwiftModel.self, from: jsonData.data(using: .utf8)!)

    let model: SignalProducer<MySwiftModel, ErrorEnvelope> = Service()
      .decodeModel(jsonData.data(using: .utf8)!)
    let result = try! model.single()?.get()
    XCTAssertEqual(result, expectedResult)
  }

  func testSwiftDecodeModel_WrongKeyModel() {
    let jsonData: String = """
    {
        "array": ["string1", "string2"],
        "bool": true,
        "dict": {"key1": "value1", "key2": "value2"},
        "id": 5,
        "wrong_key": "Swift Name"
    }
    """

    let model: SignalProducer<MySwiftModel, ErrorEnvelope> = Service()
      .decodeModel(jsonData.data(using: .utf8)!)
    XCTAssertThrowsError(try model.single()?.get(), "wrong key should throw an error")
  }

  func testSwiftDecodeModel_WrongTypeModel() {
    let jsonData: String = """
    {
        "array": ["string1", "string2"],
        "bool": "wrong_type",
        "dict": {"key1": "value1", "key2": "value2"},
        "id": 5,
        "name": "Swift Name"
    }
    """

    let model: SignalProducer<MySwiftModel, ErrorEnvelope> = Service()
      .decodeModel(jsonData.data(using: .utf8)!)
    XCTAssertThrowsError(try model.single()?.get(), "wrong key should throw an error")
  }

  func testSwiftDecodeModel_Optional_WrongTypeModel() {
    let jsonData: String = """
    {
        "array": ["string1", "string2"],
        "bool": "wrong_type",
        "dict": {"key1": "value1", "key2": "value2"},
        "id": 5,
        "name": "Swift Name"
    }
    """
    let data = jsonData.data(using: .utf8)!
    let model: SignalProducer<MySwiftModel?, ErrorEnvelope> = Service().decodeModel(data: data)
    let result = try! model.single()?.get()
    XCTAssertNil(result)
  }

  func test_Array_SwiftDecodeModel_ValidModel() {
    let jsonData: String = """
    [
       {
          "array":[
             "string1",
             "string2"
          ],
          "bool":true,
          "dict":{
             "key1":"value1",
             "key2":"value2"
          },
          "id":5,
          "name":"Swift Name"
       },
       {
          "array":[
             "string1",
             "string2"
          ],
          "bool":true,
          "dict":{
             "key1":"value1",
             "key2":"value2"
          },
          "id":6,
          "name":"Swift Name"
       }
    ]
    """

    let expectedResult = try! JSONDecoder().decode([MySwiftModel].self, from: jsonData.data(using: .utf8)!)

    let model: SignalProducer<[MySwiftModel], ErrorEnvelope> = Service()
      .decodeModels(jsonData.data(using: .utf8)!)
    let result = try! model.single()?.get()
    XCTAssertEqual(result, expectedResult)
  }

  func test_Array_SwiftDecodeModel_EmptyArray() {
    let jsonData: String = """
    [
    ]
    """

    let model: SignalProducer<[MySwiftModel], ErrorEnvelope> = Service()
      .decodeModels(jsonData.data(using: .utf8)!)
    let result = try! model.single()?.get()
    XCTAssertEqual(result?.count, 0)
  }
}
