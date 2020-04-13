@testable import KsApi
import XCTest

final class ProjectSummaryEnvelopeTests: XCTestCase {
  func testJSONParsing_WithCompleteData() {
    let dictionary: [String: Any] = [
      "project": [
        "projectSummary": [
          [
            "question": "WHAT_IS_THE_PROJECT",
            "response": "A cool project."
          ],
          [
            "question": "WHAT_WILL_YOU_DO_WITH_THE_MONEY",
            "response": "I will use the money for buying equipment."
          ],
          [
            "question": "WHO_ARE_YOU",
            "response": "I am a writer."
          ]
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    let value = try? JSONDecoder().decode(ProjectSummaryEnvelope.self, from: data)

    XCTAssertEqual(value?.projectSummary.count, 3)
    XCTAssertEqual(
      value?.projectSummary[0],
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatIsTheProject, response: "A cool project."
      )
    )
    XCTAssertEqual(
      value?.projectSummary[1],
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatWillYouDoWithTheMoney, response: "I will use the money for buying equipment."
      )
    )
    XCTAssertEqual(
      value?.projectSummary[2],
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whoAreYou, response: "I am a writer."
      )
    )
  }

  func testJSONParsing_WithPartialData() {
    let dictionary: [String: Any] = [
      "project": [
        "projectSummary": [
          [
            "question": "WHAT_IS_THE_PROJECT",
            "response": "A cool project."
          ],
          [
            "question": "WHO_ARE_YOU",
            "response": "I am a writer."
          ]
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    let value = try? JSONDecoder().decode(ProjectSummaryEnvelope.self, from: data)

    XCTAssertNotNil(value, "Should deserialize with only some values.")
  }

  func testJSONParsing_WithUnknownQuestion() {
    let dictionary: [String: Any] = [
      "project": [
        "projectSummary": [
          [
            "question": "WHAT_IS_THE_PROJECT",
            "response": "A cool project."
          ],
          [
            "question": "UNKNOWN_QUESTION",
            "response": "I am an unknown response."
          ]
        ]
      ]
    ]

    guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) else {
      XCTFail("Should have data")
      return
    }

    let value = try? JSONDecoder().decode(ProjectSummaryEnvelope.self, from: data)

    XCTAssertEqual(value?.projectSummary.count, 1)
    XCTAssertEqual(
      value?.projectSummary[0],
      ProjectSummaryEnvelope.ProjectSummaryItem(
        question: .whatIsTheProject, response: "A cool project."
      )
    )
  }
}
