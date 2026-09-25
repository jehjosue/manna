import ActivityKit
import Foundation

struct BreadActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var breadDays: Int
        var deadline: Date
        var studied: Bool
    }
}
