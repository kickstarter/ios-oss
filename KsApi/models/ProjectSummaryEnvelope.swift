import Foundation

public struct ProjectSummaryEnvelope: Equatable {
  public let projectSummary: [ProjectSummaryItem]

  public struct ProjectSummaryItem: Decodable, Equatable {
    public let question: ProjectSummaryQuestion
    public let response: String

    public enum ProjectSummaryQuestion: String, Decodable, Equatable {
      case whatIsTheProject = "WHAT_IS_THE_PROJECT"
      case whatWillYouDoWithTheMoney = "WHAT_WILL_YOU_DO_WITH_THE_MONEY"
      case whoAreYou = "WHO_ARE_YOU"
    }
  }
}

extension ProjectSummaryEnvelope: Decodable {
  private enum CodingKeys: String, CodingKey {
    case project
    case projectSummary
    case question
    case response
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
      .nestedContainer(keyedBy: CodingKeys.self, forKey: .project)

    var summaryItemsContainer = try values.nestedUnkeyedContainer(forKey: .projectSummary)

    var summaryItems: [ProjectSummaryItem] = []

    // Decode known ProjectSummaryItem values, discard unknown.
    while !summaryItemsContainer.isAtEnd {
      do {
        let value = try summaryItemsContainer.decode(ProjectSummaryItem.self)
        summaryItems.append(value)
      } catch {
        _ = try? summaryItemsContainer.decode(VoidEnvelope.self)
      }
    }

    self.projectSummary = summaryItems
  }
}
