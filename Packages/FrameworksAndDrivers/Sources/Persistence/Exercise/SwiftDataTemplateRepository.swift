//
//  SwiftDataTemplateRepository.swift
//
//
//  Created by harsh vishwakarma on 15/02/24.
//

import Foundation
import Domain
import ApplicationServices
import SwiftData
import OSLog


public final class SwiftDataTemplateRepository {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: String(describing: SwiftDataTemplateRepository.self))
    
    private let listExerciseUseCase: ListExerciseIOPort
    
    public init(listExerciseUseCase: ListExerciseIOPort) {
        self.listExerciseUseCase = listExerciseUseCase
    }
    
    public func insertTemplatesData(container: ModelContainer) async {
        
        do {
            let context = ModelContext(container)
            let fetchDescriptor = FetchDescriptor<ExerciseBluePrint>()
            let count = try context.fetchCount(fetchDescriptor)
            
            if count == 0 {
                let allExerciseTemplates = await listExerciseUseCase.listExercise()
                let templates = allExerciseTemplates.map(ExerciseBluePrint.init)
                for template in templates {
                    context.insert(template)
                    
                    let searchString: String = [template.name,
                                                template.primaryMuscles.map({$0.rawValue}).joined(separator: " ") ,
                                                template.secondaryMuscles.map({$0.rawValue}).joined() , 
                                                template.category.rawValue,
                                                template.equipment?.rawValue ?? "" ,
                                                template.instructions.joined(separator: " ")
                    ].joined()
                    
                    template.searchString = searchString
                }
                
                try context.save()
            }
        } catch {
            logger.error("\(error)")
        }
        
    }
    
}

public extension ExerciseBluePrint {
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
