import BrazeKit
import SegmentBraze
import Foundation

// MARK: - BrazeInAppMessageType

public protocol BrazeInAppMessageType {}

extension Braze.InAppMessage: BrazeInAppMessageType {}

// MARK: - AppboyType

public protocol AppboyType {}

//extension SEGAppboyHelper: AppboyType {}
