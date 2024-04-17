//
//  ExerciseBluePrint.swift
//
//
//  Created by harsh vishwakarma on 07/03/24.
//

import ComposableArchitecture
import Domain
import SwiftData
import Foundation

// MARK: ExerciseBluePrint Database
public extension DependencyValues {
    var exerciseBluePrintDatabase: ExerciseBlueprintDatabase {
        get{self[ExerciseBlueprintDatabase.self]}
        set{self[ExerciseBlueprintDatabase.self] = newValue}
    }
}

public struct ExerciseBlueprintDatabase {
    public var fetchAll: @Sendable () throws -> [ExerciseBluePrint]
    public var fetch: @Sendable (FetchDescriptor<ExerciseBluePrint>) throws -> [ExerciseBluePrint]
    public var count: @Sendable (FetchDescriptor<ExerciseBluePrint>) throws -> Int
}

extension ExerciseBlueprintDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService) var databaseService
                let databaseContext = try databaseService.context()
                
                let descriptor = FetchDescriptor<ExerciseBluePrint>(sortBy: [SortDescriptor(\ExerciseBluePrint.name)])
                return try databaseContext.fetch(descriptor)
            } catch {
                print(error)
                return []
            }
        }, fetch: { descriptor in
            do {
                @Dependency(\.databaseService.context) var context
                let databaseContext = try context()
                
                return try databaseContext.fetch(descriptor)
            } catch {
                print(error)
                return []
            }
        }, count: { descriptor in
            do {
                @Dependency(\.databaseService.context) var context
                let databaseContext = try context()
                
                return try databaseContext.fetchCount(descriptor)
            } catch {
                print(error)
                return 0
            }
        }
    )
}
    
    /*
#if DEBUG
    public static let previewValue: ExerciseBlueprintDatabase = Self(
        fetchAll: {
            templates
        }, fetch: { _ in
            templates
        }
    )
    
    private static let templates: [ExerciseBluePrint] =  [
        ExerciseBluePrint(try! ExerciseTemplate("""
{"name":"3/4 Sit-Up","force":"pull","level":"beginner","mechanic":"compound","equipment":"body only","primaryMuscles":["abdominals"],"secondaryMuscles":[],"instructions":["Lie down on the floor and secure your feet. Your legs should be bent at the knees.","Place your hands behind or to the side of your head. You will begin with your back on the ground. This will be your starting position.","Flex your hips and spine to raise your torso toward your knees.","At the top of the contraction your torso should be perpendicular to the ground. Reverse the motion, going only Â¾ of the way down.","Repeat for the recommended amount of repetitions."],"category":"strength","images":["3_4_Sit-Up/0.jpg","3_4_Sit-Up/1.jpg"],"id":"3_4_Sit-Up"}
""")),
        
        ExerciseBluePrint(try! ExerciseTemplate("""
  {
    "name": "Ab Roller",
    "force": "pull",
    "level": "intermediate",
    "mechanic": "compound",
    "equipment": "other",
    "primaryMuscles": [
      "abdominals"
    ],
    "secondaryMuscles": [
      "shoulders"
    ],
    "instructions": [
      "Hold the Ab Roller with both hands and kneel on the floor.",
      "Now place the ab roller on the floor in front of you so that you are on all your hands and knees (as in a kneeling push up position). This will be your starting position.",
      "Slowly roll the ab roller straight forward, stretching your body into a straight position. Tip: Go down as far as you can without touching the floor with your body. Breathe in during this portion of the movement.",
      "After a pause at the stretched position, start pulling yourself back to the starting position as you breathe out. Tip: Go slowly and keep your abs tight at all times."
    ],
    "category": "strength",
    "images": [
      "Ab_Roller/0.jpg",
      "Ab_Roller/1.jpg"
    ],
    "id": "Ab_Roller"
  }
"""))
    ]
#endif
}

#if DEBUG
fileprivate extension ExerciseBluePrint {
    convenience init(_ exerciseTemplate: ExerciseTemplate) {
        self.init(
            id: exerciseTemplate.id,
            name: exerciseTemplate.name,
            force: exerciseTemplate.force,
            level: exerciseTemplate.level,
            mechanic: exerciseTemplate.mechanic,
            equipment: exerciseTemplate.equipment,
            primaryMuscles: exerciseTemplate.primaryMuscles,
            secondaryMuscles: exerciseTemplate.secondaryMuscles,
            instructions: exerciseTemplate.instructions,
            category: exerciseTemplate.category,
            images: exerciseTemplate.images
        )
    }
}
#endif
*/
