//
//  TemplateRowView.swift
//
//
//  Created by harsh vishwakarma on 16/02/24.
//

import SwiftUI
import Domain
import DesignSystem
import Dependencies

struct ExerciseBluePrintRowView: View {
    var exercise: ExerciseBluePrint
    var isSelected: Bool
    var highlightText: String?
    
    @Dependency(\.exerciseThumbnailFetcher) var imageFetcher

    var body: some View {
//        VStack(spacing: 0) {
            HStack(alignment: .center) {
                if let url = imageFetcher.imageUrlFor(imageNames: exercise.images).first {
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

                
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        if let highlightText = highlightText, highlightText.isNotEmpty {
                            Text(exercise.name.highlighted(highlightText: highlightText, highlightColor: .red))
                        } else {
                            Text(exercise.name)
                        }
                    }
                    
                    Group {
                        let primaryMuscles = exercise.primaryMuscles.map(\.rawValue)
                        if primaryMuscles.isNotEmpty {
                            
                            Text("Primary Muscles ")
                                .bold()
                            +
                            Text(primaryMuscles, format: .list(type: .and))
                        }
                        
                        let secondaryMuscles = exercise.secondaryMuscles.map(\.rawValue)
                        if secondaryMuscles.isNotEmpty {
                            
                            Text("Secondary Muscles ")
                                .bold()
                            +
                            Text(secondaryMuscles, format: .list(type: .and))
                        }
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                                
//                Button(action: {
//                    // TODO: pending
//                    //                                routerPath.navigate(to: .exerciseDetails(exercise))
//                }, label: {
//                    Image(systemName: "info.circle")
//                })
//                .tint(.primary)
//                .buttonStyle(.borderless)
            }
            .contentShape(Rectangle())
            //        .onTapGesture {
            //            selectionMap[exercise] = !isSelected
            //        }
            .selectableRow(isSelected: isSelected, edge: .trailing)
            .padding(.listRowContentInset)
//            Divider()
//                .padding(.leading)
//                .opacity(isSelected ? 0 : 1)
//        }
//        .listRowInsets(.listRowInset)
//        .listRowBackground(isSelected ? Color.secondary.opacity(0.2) : Color.clear)
//        .listRowSeparator(.hidden)
    }
}
