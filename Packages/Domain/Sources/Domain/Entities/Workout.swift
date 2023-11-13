import Foundation

public struct Workout {
    public private(set) var id: String
    public private(set) var date: Date
    public private(set) var duration: TimeInterval
    public private(set) var notes: String
    
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
