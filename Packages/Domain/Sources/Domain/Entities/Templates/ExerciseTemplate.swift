//
//  ExerciseTemplate.swift
//
//
//  Created by harsh vishwakarma on 03/01/24.
//

import Foundation

public struct ExerciseTemplate: Identifiable, Codable, Hashable {
    public let id: String
    public let name: String
    public let force: ExerciseForce?
    public let level: ExerciseLevel
    public let mechanic: ExerciseMechanic?
    public let equipment: ExerciseEquipment?
    public let primaryMuscles: [ExerciseMuscles]
    public let secondaryMuscles: [ExerciseMuscles]
    public let instructions: [String]
    public let category: ExerciseCategory
    public let images: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case force
        case level
        case mechanic
        case equipment
        case primaryMuscles
        case secondaryMuscles
        case instructions
        case category
        case images
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

public extension ExerciseTemplate {
    func abbreviatedMuscle() ->  ExerciseMuscles? {
        let wordCounts = primaryMuscles
            .reduce(into: [:]) { counts, word in
                counts[word, default: 0] += 1
            }
        
        return wordCounts.max { $0.value < $1.value }?.key
    }
    
    func preferredRepCountUnit() -> RepCountUnit {
        mechanic != nil ? .rep : .time
    }
}

// MARK: ExerciseTemplate convenience initializers and mutators

public extension ExerciseTemplate {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(ExerciseTemplate.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Helper functions for creating encoders and decoders

private func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

private func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

//#if DEBUG
public extension ExerciseTemplate {
    static let mock_1: ExerciseTemplate = try! ExerciseTemplate("""
{"name":"3/4 Sit-Up","force":"pull","level":"beginner","mechanic":"compound","equipment":"body only","primaryMuscles":["abdominals"],"secondaryMuscles":["abdominals","shoulders","adductors","glutes"],"instructions":["Lie down on the floor and secure your feet. Your legs should be bent at the knees.","Place your hands behind or to the side of your head. You will begin with your back on the ground. This will be your starting position.","Flex your hips and spine to raise your torso toward your knees.","At the top of the contraction your torso should be perpendicular to the ground. Reverse the motion, going only Â¾ of the way down.","Repeat for the recommended amount of repetitions."],"category":"strength","images":["3_4_Sit-Up/0.jpg","3_4_Sit-Up/1.jpg"],"id":"3_4_Sit-Up"}
""")
}
//#endif
