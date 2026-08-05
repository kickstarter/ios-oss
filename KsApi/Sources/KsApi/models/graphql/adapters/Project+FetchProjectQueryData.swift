import Apollo
import Foundation
import GraphAPI
import Prelude
import ReactiveSwift

extension Project {
  public struct ProjectPamphletData: Decodable {
    let project: Project
    let backingId: Int?
  }

  static func projectProducer(
    from data: GraphAPI.FetchProjectByParamQuery.Data
  ) -> SignalProducer<ProjectPamphletData, ErrorEnvelope> {
    let projectAndBackingId = Project.project(
      from: data
    )

    guard let project = projectAndBackingId.0 else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    let data = ProjectPamphletData(
      project: project,
      backingId: projectAndBackingId.1
    )

    return SignalProducer(value: data)
  }

  internal static func project(
    from data: GraphAPI.FetchProjectByParamQuery.Data
  ) -> (Project?, Int?) {
    var projectBackingId: Int?

    if let backingId = data.project?.backing?.id {
      projectBackingId = decompose(id: backingId)
    }

    guard
      let fragment = data.project?.fragments.projectFragment,
      let noRewardFragment = data.project?.fragments.noRewardRewardFragment,
      let extendedFragment = data.project?.fragments.extendedProjectPropertiesFragment,
      let project = Project.project(
        from: fragment,
        flagging: data.project?.flagging != nil,
        rewards: [Reward.noRewardReward(from: noRewardFragment)],
        addOns: nil,
        backing: nil
      )
    else { return (nil, nil) }

    return (project, projectBackingId)
  }
}

public struct ProjectPageExtraProperties {
  let extendedProjectProperties: ExtendedProjectProperties
  let video: Project.Video?
  let flagging: Bool

  public func addExtraProperties(toProject project: Project) -> Project {
    var updatedProject = project
    updatedProject.flagging = self.flagging
    updatedProject.extendedProjectProperties = self.extendedProjectProperties
    updatedProject.video = self.video

    return updatedProject
  }

  internal static func extraPropertiesProducer(
    from data: GraphAPI.FastFetchProjectPage_ExtendedPropertiesQuery.Data
  ) -> SignalProducer<ProjectPageExtraProperties, ErrorEnvelope> {
    let properties = ProjectPageExtraProperties.extraProperties(from: data)

    guard let properties else {
      return SignalProducer(error: ErrorEnvelope.couldNotParseJSON)
    }

    return SignalProducer(value: properties)
  }

  internal static func extraProperties(
    from data: GraphAPI.FastFetchProjectPage_ExtendedPropertiesQuery.Data
  ) -> ProjectPageExtraProperties? {
    guard let project = data.project else { return nil }

    let videoFragment = project.video?.fragments.projectVideoFragment
    let video = Project.Video.from(videoFragment)

    let extendedFragment = project.fragments.extendedProjectPropertiesFragment
    let extendedProperties = ExtendedProjectProperties.from(extendedFragment)

    let flagging = project.flagging?.kind.isSome ?? false

    return ProjectPageExtraProperties(
      extendedProjectProperties: extendedProperties,
      video: video,
      flagging: flagging
    )
  }
}

extension Project {
  static func projectProducer(
    from data: GraphAPI.FastFetchProjectPage_CheckoutQuery.Data
  ) -> SignalProducer<Project, ErrorEnvelope> {
    guard let project = Project.project(from: data) else {
      return .empty
    }

    return SignalProducer(value: project)
  }

  internal static func project(
    from data: GraphAPI.FastFetchProjectPage_CheckoutQuery.Data
  ) -> Project? {
    guard let project = data.project else { return nil }

    var backing: Backing?
    if let backingFragment = project.backing?.fragments.backingFragment {
      backing = Backing.backing(from: backingFragment)
    }

    let rewards: [Reward] = project.rewards?.nodes?.compactMap { node in
      guard let fragment = node?.fragments.rewardFragment else { return nil }
      return Reward.reward(from: fragment)
    } ?? []

    let noRewardFragment = project.fragments.noRewardRewardFragment
    let noReward = Reward.noRewardReward(from: noRewardFragment)

    return Project.project(
      from: project.fragments.projectFragment,
      rewards: [noReward] + rewards,
      backing: backing,
    )
  }
}
