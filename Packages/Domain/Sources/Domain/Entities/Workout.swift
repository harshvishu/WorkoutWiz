import Foundation

public struct Workout {
    var id: String
    var date: Date
    var duration: TimeInterval
    var notes: String
    
    public init(id: String, date: Date, duration: TimeInterval, notes: String) {
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
