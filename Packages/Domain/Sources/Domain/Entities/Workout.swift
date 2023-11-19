import Foundation

public struct Workout {
    public private(set) var id: String
    public var date: Date
    public var duration: TimeInterval
    public var notes: String
    
    public init(id: String = UUID().uuidString, date: Date = Date(), duration: TimeInterval = 0.0, notes: String = "") {
        self.id = id
        self.date = date
        self.duration = duration
        self.notes = notes
    }
    
    public init() {
        self.id = UUID().uuidString
        self.date = Date()
        self.duration = 0.0
        self.notes = ""
    }
}
