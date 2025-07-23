import GraphAPI
@testable import KsApi
import Library
import ReactiveExtensions_TestHelpers
import ReactiveSwift
import XCTest

final class FetchLocationsUseCaseTests: TestCase {
  private var useCase: FetchLocationsUseCase!
  private let defaultLocations = TestObserver<[KsApi.Location], Never>()
  private let suggestedLocations = TestObserver<[KsApi.Location], Never>()
  private let (initialSignal, initialObserver) = Signal<Void, Never>.pipe()

  override func setUp() {
    super.setUp()

    self.useCase = FetchLocationsUseCase(initialSignal: self.initialSignal)
    self.useCase.dataOutputs.defaultLocations.observe(self.defaultLocations.observer)
    self.useCase.dataOutputs.suggestedLocations.observe(self.suggestedLocations.observer)
  }

  func test_initialSignal_triggersEmptyOutputs() {
    self.defaultLocations.assertDidNotEmitValue()
    self.suggestedLocations.assertDidNotEmitValue()

    self.initialObserver.send(value: ())

    self.defaultLocations.assertLastValue([])
    self.suggestedLocations.assertLastValue([])
  }

  func test_initialSignal_triggersDefaultLocationsToLoad() {
    let response: GraphAPI.DefaultLocationsQuery.Data =
      try! testGraphObject(jsonString: threeLocationsResponseJSON)
    let mockService = MockService(fetchGraphQLResponses: [(
      GraphAPI.DefaultLocationsQuery.self,
      response
    )])

    withEnvironment(apiService: mockService) {
      self.initialObserver.send(value: ())

      if let defaultLocations = self.defaultLocations.lastValue {
        XCTAssertTrue(defaultLocations.count == 3)
      } else {
        XCTFail("Expected defaultLocations locations to be sent")
      }
    }
  }

  func test_settingQuery_triggersSuggestedLocationsToLoad() {
    let response: GraphAPI.LocationsByTermQuery.Data =
      try! testGraphObject(jsonString: threeLocationsResponseJSON)
    let mockService = MockService(fetchGraphQLResponses: [(
      GraphAPI.LocationsByTermQuery.self,
      response
    )])

    withEnvironment(apiService: mockService) {
      self.initialObserver.send(value: ())

      self.suggestedLocations.assertLastValue([])

      self.useCase.inputs.searchedForLocations("fairfax")

      if let suggestedLocations = self.suggestedLocations.lastValue {
        XCTAssertTrue(suggestedLocations.count == 3, "Search should have returned results from response")
      } else {
        XCTFail("Expected suggested locations to be sent")
      }

      self.useCase.inputs.searchedForLocations("")

      if let suggestedLocations = self.suggestedLocations.lastValue {
        XCTAssertTrue(suggestedLocations.isEmpty, "Triggering an empty search should return empty results")
      } else {
        XCTFail("Expected suggested locations to be sent")
      }
    }
  }
}

private let threeLocationsResponseJSON = """
{
    "locations": {
      "__typename": "LocationsConnection",
      "nodes": [
        {
          "__typename": "Location",
          "country": "US",
          "countryName": "United States",
          "displayableName": "Fairfax, VA",
          "id": "TG9jYXRpb24tMjQwMTM0OA==",
          "name": "Fairfax"
        },
        {
          "__typename": "Location",
          "country": "US",
          "countryName": "United States",
          "displayableName": "Fairfax, CA",
          "id": "TG9jYXRpb24tMjQwMTM0OQ==",
          "name": "Fairfax"
        },
        {
          "__typename": "Location",
          "country": "US",
          "countryName": "United States",
          "displayableName": "Fairfax, Jacksonville, FL",
          "id": "TG9jYXRpb24tMjkyMjk5NTk=",
          "name": "Fairfax"
        }
      ]
    }
}
"""
