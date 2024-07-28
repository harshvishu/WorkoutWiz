//
//  ExerciseTemplateDetailView.swift
//
//
//  Created by harsh vishwakarma on 05/04/24.
//

import SwiftUI
import Domain
import ComposableArchitecture
import DesignSystem
import Persistence

@Reducer
public struct ExerciseTemplateDetails {
    @ObservableState
    public struct State: Equatable {
        var exercise: ExerciseTemplate
        
        public var images: [URL]? {
            @Dependency(\.exerciseThumbnailFetcher) var imageFetcher
            let images = imageFetcher.imageUrlFor(imageNames: exercise.images)
            return images.isEmpty ? nil : images
        }
    }
    
    public enum Action: Equatable {
        
    }
}

struct ExerciseTemplateDetailView: View {
    let store: StoreOf<ExerciseTemplateDetails>
    
    var body: some View {
        Form {
            
            if let images = store.images {
                Section {
                    imagesCarouselView(images)
                }
                .listRowInsets(EdgeInsets())
                .previewBorder()
            }
            
            if let force = store.exercise.force?.rawValue {
                
                LabeledContent("Force", value: force.capitalized)
            }
            LabeledContent("Level", value: store.exercise.level.rawValue.capitalized)
            
            if let mechanic = store.exercise.mechanic?.rawValue {
                LabeledContent("Mechanic", value: mechanic.capitalized)
            }
            if let equipment = store.exercise.equipment?.rawValue {
                LabeledContent("Equipment", value: equipment.capitalized)
            }
            Section("Category") {
                Label(store.exercise.category.rawValue.capitalized, systemImage: store.exercise.category.iconForCategory())
            }
            
            if store.exercise.primaryMuscles.isNotEmpty {
                Section("Primary Muscles") {
                    ForEach(store.exercise.primaryMuscles, id: \.self) { muscle in
                        Text(muscle.rawValue.capitalized)
                    }
                }
            }
            if store.exercise.secondaryMuscles.isNotEmpty {
                Section("Secondary Muscles") {
                    ForEach(store.exercise.secondaryMuscles, id: \.self) { muscle in
                        Text(muscle.rawValue.capitalized)
                    }
                }
            }
            
            if store.exercise.instructions.isNotEmpty {
                Section("Instructions") {
                    ForEachWithIndex(store.exercise.instructions, id: \.self) { idx, instruction in
                        Label(instruction, systemImage: "\(idx + 1).circle.fill")
                    }
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle(store.exercise.name)
    }
    
    fileprivate func imagesCarouselView(_ images: [URL]) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(alignment: .center, spacing: 0) {
                ForEach(images, id: \.self) { url in
                    AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .transition(.opacity)
                        case .failure:
                            Image(systemName: "wifi.slash")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .containerRelativeFrame(.horizontal)
                }
            }
            .overlay(alignment: .bottom) {
                PagingIndicator(activeTint: .white, inActiveTint: .black.opacity(0.25), opacityEffect: false, clipEdges: true)
            }
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.paging)
        .frame(height: 220)
    }
}

@available(iOS 18.0, *)
#Preview {
    let container = SwiftDataModelConfigurationProvider.shared.container
    return ExerciseTemplateDetailView(store: StoreOf<ExerciseTemplateDetails>(initialState: ExerciseTemplateDetails.State(exercise: ExerciseTemplate(BaseExerciseTemplate.mock_1)), reducer: {
        ExerciseTemplateDetails()
    }))
    .modelContainer(container)
}
