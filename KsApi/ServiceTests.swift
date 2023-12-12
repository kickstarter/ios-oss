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

  func testSwiftDecodeModel_ValidModel_Combine() {
    let expectedResult = MySwiftModel(
      array: ["string1", "string2"],
      bool: true,
      dict: ["key1": "value1", "key2": "value2"],
      id: 5,
      name: "Swift Name"
    )

    let jsonData: String = """
    {
        "array": ["string1", "string2"],
        "bool": true,
        "dict": {"key1": "value1", "key2": "value2"},
        "id": 5,
        "name": "Swift Name"
    }
    """

    let data = jsonData.data(using: .utf8)!
    let result: Result<MySwiftModel?, ErrorEnvelope> = Service()
      .decodeModel(data: data, ofType: MySwiftModel.self)

    switch result {
    case let .success(decodedModel):
      if let decodedModelUnwrapped = decodedModel {
        XCTAssertEqual(expectedResult, decodedModelUnwrapped)
      } else {
        XCTFail("Decoded model is nil")
      }
    case .failure: XCTFail("Failed to decode model")
    }
  }

  func testSwiftDecodeModel_InvalidModel_Combine() {
    let jsonData: String = """
    {
        "notAValidKey": "foo"
    }
    """

    let data = jsonData.data(using: .utf8)!
    let result: Result<MySwiftModel?, ErrorEnvelope> = Service()
      .decodeModel(data: data, ofType: MySwiftModel.self)

    switch result {
    case .success: XCTFail("Decode should have failed.")
    case let .failure(error): XCTAssertNotNil(error)
    }
  }

  /*
   These two tests shouldn't actually *run* in our testing environment, because we don't want to make real network requests
   in our real tests. But it's a useful little utility for comparing the Combine and ReactiveSwift version of the
   API V1 call Request.
   */

  /*
   func testCompareRequest_Successful_RAC_vs_Combine() {
     let service = Service(serverConfig: ServerConfig.production)
     var project = Project.template
     project.id = 152885112

     let rac_publisher = service.fetchProject(project: project)
     let combine_publisher = service.fetchProject_combine(project: project)

     let combine_observer = CombineTestObserver<Project, ErrorEnvelope>()
     combine_observer.observe(combine_publisher)

     _ = XCTWaiter.wait(for: [expectation(description: "Wait 10 seconds for the server call.")], timeout: 10.0)

     let r1 = rac_publisher.first()
     let r2 = combine_observer.events.first

     if case let .success(p1) = r1 {
       if case let .value(p2) = r2 {
         XCTAssertEqual(p1, p2)
         return
       }
     }

     XCTFail()
   }

   func testCompareRequest_Failure_RAC_vs_Combine() {
     let service = Service(serverConfig: ServerConfig.production)
     var project = Project.template
     project.id = 1 //Not a real project ID

     let rac_publisher = service.fetchProject(project: project)
     let combine_publisher = service.fetchProject_combine(project: project)

     let combine_observer = CombineTestObserver<Project, ErrorEnvelope>()
     combine_observer.observe(combine_publisher)

     _ = XCTWaiter.wait(for: [expectation(description: "Wait 10 seconds for the server call.")], timeout: 10.0)

     let r1 = rac_publisher.first()
     let r2 = combine_observer.events.first

     if case let .failure(e1) = r1 {
       if case let .error(e2) = r2 {
         XCTAssertEqual(e1.errorMessages, e2.errorMessages)
         return
       }
     }

     XCTFail()
   }
   */
}
