//
//  PopupPresenterView.swift
//
//
//  Created by harsh vishwakarma on 04/02/24.
//

import SwiftUI
import DesignSystem
import Domain

struct EditRep {
    var exercise: Exercise?
    var rep: Rep?
}

struct AddRep {
    var exercise: Exercise?
}

struct PopupPresenterView: View {
    @Environment(\.keyboardShowing) var keyboardShowing
    
    @State private var state: PopupMessage?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if state != nil {
                TransparentBlurView(removeAllFilters: true)
                    .blur(radius: 9, opaque: true)
                    .background(.background.opacity(0.05))
                    .ignoresSafeArea(.all)
                    .transition(.opacity.animation(.easeInOut))
                    .onTapGesture {
                        dismiss()
                    }
            }
            Group {
                if case let .addSetToExercise(exercise) = state {
                    RepInputView(exercise: exercise, onClose: dismiss)
                } else if case let .editSetForExercise(exercise, rep) = state {
                    RepInputView(exercise: exercise, rep: rep, onClose: dismiss)
                }
            }
            .transition(.move(edge: .bottom))
        }
        // TODO:
//        .onReceive(appState.signal){ message in
//            if case .popup(let message) = message {
//                withAnimation {
//                    self.state = message
//                }
//            }
//        }
    }
    
    private func dismiss() {
        withAnimation(.easeInOut(duration: 0.3)) {
            state = nil
        }
    }
}
