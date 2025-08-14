import BrazeKit
import Foundation
import SegmentBraze

// MARK: - BrazeInAppMessageType

public protocol BrazeInAppMessageType {}

extension Braze.InAppMessage: BrazeInAppMessageType {}

// MARK: - AppboyType

public protocol AppboyType {}

// extension SEGAppboyHelper: AppboyType {}
