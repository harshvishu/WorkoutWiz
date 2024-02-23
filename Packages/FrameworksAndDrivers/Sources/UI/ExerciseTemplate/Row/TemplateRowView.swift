//
//  TemplateRowView.swift
//  
//
//  Created by harsh vishwakarma on 16/02/24.
//

import SwiftUI
import Domain
import ApplicationServices
import Persistence
import DesignSystem
import SwiftData

struct TemplateRowView: View {
    @Environment(RouterPath.self) private var routerPath
    
    var exercise: ExerciseBluePrint
    var viewModel: ListExerciseViewModel
    
    @Binding var selectionMap: [ExerciseBluePrint : Bool]
    
    var body: some View {
        let isSelected = selectionMap[exercise, default: false]
        
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(exercise.name)
                        .previewBorder(Color.black.opacity(0.2))
                    Spacer()
                }
                
                let primaryMuscles = exercise.primaryMuscles.map(\.rawValue)
                if primaryMuscles.isNotEmpty {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Primary Muscles")
                            .bold()
                        Text(primaryMuscles, format: .list(type: .and))
                            .lineLimit(1)
                            .previewBorder(.red.opacity(0.2))
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                }
                
                let secondaryMuscles = exercise.secondaryMuscles.map(\.rawValue)
                if secondaryMuscles.isNotEmpty {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Secondary Muscles")
                            .bold()
                        Text(secondaryMuscles, format: .list(type: .and))
                            .lineLimit(1)
                            .previewBorder(.red.opacity(0.2))
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                }
            }
            
            if let url = viewModel.imageUrlFor(exercise: exercise).first {
                AsyncImage(url: url, transaction: Transaction(animation: .easeInOut)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .transition(.scale(scale: 0.1, anchor: .center))
                    case .failure:
                        Image(systemName: "wifi.slash")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: .exerciseTemplatePreviewImageSize, height: .exerciseTemplatePreviewImageSize)
                .clipShape(RoundedRectangle(cornerRadius: .exerciseTemplatePreviewImageCornerRadius))
                .overlay {
                    RoundedRectangle(cornerRadius: .exerciseTemplatePreviewImageCornerRadius)
                        .fill(Color.clear)
                        .stroke(.tertiary, lineWidth: 0.5)
                        .shadow(color: .secondary.opacity(0.1), radius: 20, x: 0.0, y: 2.0)
                }
            }
            
            Button(action: {
                // TODO: pending
//                                routerPath.navigate(to: .exerciseDetails(exercise))
            }, label: {
                Image(systemName: "info.circle")
            })
            .tint(.primary)
            .buttonStyle(.borderless)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectionMap[exercise] = !isSelected
        }
        .previewBorder(Color.accentColor.opacity(0.2))
        .selectableRow(isSelected: isSelected)
        .id(exercise.id)
    }
}

extension View {
    func selectableRow(isSelected: Bool) -> some View {
        modifier(SelectableRowItem(isSelected: isSelected))
    }
}

struct SelectableRowItem: ViewModifier {
    var isSelected: Bool = false
    
    func body(content: Content) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                .contentTransition(.symbolEffect(.replace.byLayer.offUp))
                .symbolEffect(.bounce, value: isSelected)
                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                .layoutPriority(0)
                .previewBorder(Color.blue.opacity(0.2))
            
            content
                .layoutPriority(1)
        }
        .previewBorder(Color.green.opacity(0.2))
    }
}
