import Foundation
import KsApi

public protocol ProjectPageParam {
  var param: Param { get }
  var initialProject: (any ProjectPamphletMainCellConfiguration)? { get }
}

public struct ProjectPageParamBox: ProjectPageParam {
  public let param: Param
  public let initialProject: (any ProjectPamphletMainCellConfiguration)?

  public init(param: Param, initialProject: (any ProjectPamphletMainCellConfiguration)?) {
    self.param = param
    self.initialProject = initialProject
  }
}

extension Param: ProjectPageParam {
  public var param: Param { self }
  public var initialProject: (any ProjectPamphletMainCellConfiguration)? { nil }
}
