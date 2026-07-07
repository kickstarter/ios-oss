// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public struct ExtendedProjectPropertiesFragment: GraphAPI.SelectionSet, Fragment {
  public static var fragmentDefinition: StaticString {
    #"fragment ExtendedProjectPropertiesFragment on Project { __typename aiDisclosure { __typename id fundingForAiAttribution fundingForAiConsent fundingForAiOption generatedByAiConsent generatedByAiDetails involvesAi involvesFunding involvesGeneration involvesOther otherAiDetails } environmentalCommitments { __typename commitmentCategory description id } faqs { __typename nodes { __typename question answer id createdAt } } minPledge projectNotice risks story }"#
  }

  public let __data: DataDict
  public init(_dataDict: DataDict) { __data = _dataDict }

  public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.Project }
  public static var __selections: [ApolloAPI.Selection] { [
    .field("__typename", String.self),
    .field("aiDisclosure", AiDisclosure?.self),
    .field("environmentalCommitments", [EnvironmentalCommitment?]?.self),
    .field("faqs", Faqs?.self),
    .field("minPledge", Int.self),
    .field("projectNotice", String?.self),
    .field("risks", String.self),
    .field("story", GraphAPI.HTML.self),
  ] }

  public var aiDisclosure: AiDisclosure? { __data["aiDisclosure"] }
  /// The environmental commitments of the project.
  public var environmentalCommitments: [EnvironmentalCommitment?]? { __data["environmentalCommitments"] }
  /// List of FAQs of a project
  public var faqs: Faqs? { __data["faqs"] }
  /// The min pledge amount for a single reward tier.
  public var minPledge: Int { __data["minPledge"] }
  /// The text of the currently applied project notice, empty if there is no notice
  public var projectNotice: String? { __data["projectNotice"] }
  /// Potential hurdles to project completion.
  public var risks: String { __data["risks"] }
  /// The story behind the project, parsed for presentation.
  public var story: GraphAPI.HTML { __data["story"] }

  public init(
    aiDisclosure: AiDisclosure? = nil,
    environmentalCommitments: [EnvironmentalCommitment?]? = nil,
    faqs: Faqs? = nil,
    minPledge: Int,
    projectNotice: String? = nil,
    risks: String,
    story: GraphAPI.HTML
  ) {
    self.init(_dataDict: DataDict(
      data: [
        "__typename": GraphAPI.Objects.Project.typename,
        "aiDisclosure": aiDisclosure._fieldData,
        "environmentalCommitments": environmentalCommitments._fieldData,
        "faqs": faqs._fieldData,
        "minPledge": minPledge,
        "projectNotice": projectNotice,
        "risks": risks,
        "story": story,
      ],
      fulfilledFragments: [
        ObjectIdentifier(ExtendedProjectPropertiesFragment.self)
      ]
    ))
  }

  /// AiDisclosure
  ///
  /// Parent Type: `AiDisclosure`
  public struct AiDisclosure: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.AiDisclosure }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("id", GraphAPI.ID.self),
      .field("fundingForAiAttribution", Bool?.self),
      .field("fundingForAiConsent", Bool?.self),
      .field("fundingForAiOption", Bool?.self),
      .field("generatedByAiConsent", String?.self),
      .field("generatedByAiDetails", String?.self),
      .field("involvesAi", Bool.self),
      .field("involvesFunding", Bool.self),
      .field("involvesGeneration", Bool.self),
      .field("involvesOther", Bool.self),
      .field("otherAiDetails", String?.self),
    ] }

    public var id: GraphAPI.ID { __data["id"] }
    public var fundingForAiAttribution: Bool? { __data["fundingForAiAttribution"] }
    public var fundingForAiConsent: Bool? { __data["fundingForAiConsent"] }
    public var fundingForAiOption: Bool? { __data["fundingForAiOption"] }
    public var generatedByAiConsent: String? { __data["generatedByAiConsent"] }
    public var generatedByAiDetails: String? { __data["generatedByAiDetails"] }
    public var involvesAi: Bool { __data["involvesAi"] }
    public var involvesFunding: Bool { __data["involvesFunding"] }
    public var involvesGeneration: Bool { __data["involvesGeneration"] }
    public var involvesOther: Bool { __data["involvesOther"] }
    public var otherAiDetails: String? { __data["otherAiDetails"] }

    public init(
      id: GraphAPI.ID,
      fundingForAiAttribution: Bool? = nil,
      fundingForAiConsent: Bool? = nil,
      fundingForAiOption: Bool? = nil,
      generatedByAiConsent: String? = nil,
      generatedByAiDetails: String? = nil,
      involvesAi: Bool,
      involvesFunding: Bool,
      involvesGeneration: Bool,
      involvesOther: Bool,
      otherAiDetails: String? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.AiDisclosure.typename,
          "id": id,
          "fundingForAiAttribution": fundingForAiAttribution,
          "fundingForAiConsent": fundingForAiConsent,
          "fundingForAiOption": fundingForAiOption,
          "generatedByAiConsent": generatedByAiConsent,
          "generatedByAiDetails": generatedByAiDetails,
          "involvesAi": involvesAi,
          "involvesFunding": involvesFunding,
          "involvesGeneration": involvesGeneration,
          "involvesOther": involvesOther,
          "otherAiDetails": otherAiDetails,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ExtendedProjectPropertiesFragment.AiDisclosure.self)
        ]
      ))
    }
  }

  /// EnvironmentalCommitment
  ///
  /// Parent Type: `EnvironmentalCommitment`
  public struct EnvironmentalCommitment: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.EnvironmentalCommitment }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("commitmentCategory", GraphQLEnum<GraphAPI.EnvironmentalCommitmentCategory>.self),
      .field("description", String.self),
      .field("id", GraphAPI.ID.self),
    ] }

    /// The type of environmental commitment
    public var commitmentCategory: GraphQLEnum<GraphAPI.EnvironmentalCommitmentCategory> { __data["commitmentCategory"] }
    /// An environmental commitment description
    public var description: String { __data["description"] }
    public var id: GraphAPI.ID { __data["id"] }

    public init(
      commitmentCategory: GraphQLEnum<GraphAPI.EnvironmentalCommitmentCategory>,
      description: String,
      id: GraphAPI.ID
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.EnvironmentalCommitment.typename,
          "commitmentCategory": commitmentCategory,
          "description": description,
          "id": id,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ExtendedProjectPropertiesFragment.EnvironmentalCommitment.self)
        ]
      ))
    }
  }

  /// Faqs
  ///
  /// Parent Type: `ProjectFaqConnection`
  public struct Faqs: GraphAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ProjectFaqConnection }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__typename", String.self),
      .field("nodes", [Node?]?.self),
    ] }

    /// A list of nodes.
    public var nodes: [Node?]? { __data["nodes"] }

    public init(
      nodes: [Node?]? = nil
    ) {
      self.init(_dataDict: DataDict(
        data: [
          "__typename": GraphAPI.Objects.ProjectFaqConnection.typename,
          "nodes": nodes._fieldData,
        ],
        fulfilledFragments: [
          ObjectIdentifier(ExtendedProjectPropertiesFragment.Faqs.self)
        ]
      ))
    }

    /// Faqs.Node
    ///
    /// Parent Type: `ProjectFaq`
    public struct Node: GraphAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GraphAPI.Objects.ProjectFaq }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("question", String.self),
        .field("answer", String.self),
        .field("id", GraphAPI.ID.self),
        .field("createdAt", GraphAPI.DateTime?.self),
      ] }

      /// Faq question
      public var question: String { __data["question"] }
      /// Faq answer
      public var answer: String { __data["answer"] }
      public var id: GraphAPI.ID { __data["id"] }
      /// When faq was posted
      public var createdAt: GraphAPI.DateTime? { __data["createdAt"] }

      public init(
        question: String,
        answer: String,
        id: GraphAPI.ID,
        createdAt: GraphAPI.DateTime? = nil
      ) {
        self.init(_dataDict: DataDict(
          data: [
            "__typename": GraphAPI.Objects.ProjectFaq.typename,
            "question": question,
            "answer": answer,
            "id": id,
            "createdAt": createdAt,
          ],
          fulfilledFragments: [
            ObjectIdentifier(ExtendedProjectPropertiesFragment.Faqs.Node.self)
          ]
        ))
      }
    }
  }
}
