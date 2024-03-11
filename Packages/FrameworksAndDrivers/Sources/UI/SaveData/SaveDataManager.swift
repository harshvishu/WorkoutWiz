//
//  SaveDataManager.swift
//
//
//  Created by harsh vishwakarma on 23/12/23.
//

import Foundation
import Domain
import ApplicationServices
import Persistence
import Foundation
import DesignSystem
import SwiftData
import OSLog

@Observable
public final class SaveDataManager {
    
    var saveDataUseCase: SaveDataIOPort?
    
    init(saveDataUseCase: SaveDataIOPort? = nil) {
        self.saveDataUseCase = saveDataUseCase
    }
    
    public func createDataFor(exerciseName name: String, sets: [Rep]) async {
        do {
            _ = try await saveDataUseCase?.createSaveDataFor(exerciseName: name, sets: sets)
        } catch (SaveDataError.createFailed(.duplicate)) {
            Logger.ui.error("Save data already exists for \(name). Try updating instead")
        } catch {
            Logger.ui.error("\(error)")
        }
    }
    
    public func updateSaveDataFor(record: SaveDataRecord) async {
        do {
            _ = try await saveDataUseCase?.updateSaveDataFor(record: record)
        } catch (SaveDataError.updateFailed(.noRecordFound)) {
            Logger.ui.error("No save data exists for \(record.exerciseName). Try creating a new")
        } catch {
            Logger.ui.error("\(error)")
        }
    }
    
    public func readSaveDataFor(exerciseName: String) async -> SaveDataRecord? {
        await saveDataUseCase?.readSavedDataFor(exerciseName: exerciseName)
    }
    
}
