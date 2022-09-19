import Appboy_iOS_SDK
import Foundation
import AppboySegment

// MARK: - BrazeInAppMessageType

public protocol BrazeInAppMessageType {}

extension ABKInAppMessage: BrazeInAppMessageType {}

// MARK: - AppboyType

public protocol AppboyType {}

extension Appboy: AppboyType {}
