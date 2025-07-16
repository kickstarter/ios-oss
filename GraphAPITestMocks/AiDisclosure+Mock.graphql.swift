// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import GraphAPI

public class AiDisclosure: MockObject {
  public static let objectType: ApolloAPI.Object = GraphAPI.Objects.AiDisclosure
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<AiDisclosure>>

  public struct MockFields {
    @Field<Bool>("fundingForAiAttribution") public var fundingForAiAttribution
    @Field<Bool>("fundingForAiConsent") public var fundingForAiConsent
    @Field<Bool>("fundingForAiOption") public var fundingForAiOption
    @Field<String>("generatedByAiConsent") public var generatedByAiConsent
    @Field<String>("generatedByAiDetails") public var generatedByAiDetails
    @Field<GraphAPI.ID>("id") public var id
    @Field<Bool>("involvesAi") public var involvesAi
    @Field<Bool>("involvesFunding") public var involvesFunding
    @Field<Bool>("involvesGeneration") public var involvesGeneration
    @Field<Bool>("involvesOther") public var involvesOther
    @Field<String>("otherAiDetails") public var otherAiDetails
  }
}

public extension Mock where O == AiDisclosure {
  convenience init(
    fundingForAiAttribution: Bool? = nil,
    fundingForAiConsent: Bool? = nil,
    fundingForAiOption: Bool? = nil,
    generatedByAiConsent: String? = nil,
    generatedByAiDetails: String? = nil,
    id: GraphAPI.ID? = nil,
    involvesAi: Bool? = nil,
    involvesFunding: Bool? = nil,
    involvesGeneration: Bool? = nil,
    involvesOther: Bool? = nil,
    otherAiDetails: String? = nil
  ) {
    self.init()
    _setScalar(fundingForAiAttribution, for: \.fundingForAiAttribution)
    _setScalar(fundingForAiConsent, for: \.fundingForAiConsent)
    _setScalar(fundingForAiOption, for: \.fundingForAiOption)
    _setScalar(generatedByAiConsent, for: \.generatedByAiConsent)
    _setScalar(generatedByAiDetails, for: \.generatedByAiDetails)
    _setScalar(id, for: \.id)
    _setScalar(involvesAi, for: \.involvesAi)
    _setScalar(involvesFunding, for: \.involvesFunding)
    _setScalar(involvesGeneration, for: \.involvesGeneration)
    _setScalar(involvesOther, for: \.involvesOther)
    _setScalar(otherAiDetails, for: \.otherAiDetails)
  }
}
