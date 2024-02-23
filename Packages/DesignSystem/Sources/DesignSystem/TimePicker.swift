//
//  TimePicker.swift
//
//
//  Created by harsh vishwakarma on 17/02/24.
//

import SwiftUI
import Domain

@Observable
public final class TimerPickerModel {
    
    public enum PickerMode {
        case full
        case hourAndMinutes
        case minutesAndSeconds
    }
  
    var mode: PickerMode = .minutesAndSeconds
    var selectedHoursAmount: Int
    var selectedMinutesAmount: Int
    var selectedSecondsAmount : Int
    
    public init(mode: PickerMode = .minutesAndSeconds, selectedHoursAmount: Int = 0, selectedMinutesAmount: Int = 0, selectedSecondsAmount: Int = 45) {
        self.mode = mode
        self.selectedHoursAmount = selectedHoursAmount
        self.selectedMinutesAmount = selectedMinutesAmount
        self.selectedSecondsAmount = selectedSecondsAmount
    }
    
    
    let hoursRange = 0...23
    let minutesRange = 0...59
    let secondsRange = 0...59
    
    public var totalTimeForCurrentSelection: Int {
        (selectedHoursAmount * 3600) + (selectedMinutesAmount * 60) + selectedSecondsAmount
    }
    
    public var totalHMS: (Int, Int, Int) {
        (selectedHoursAmount,
         selectedMinutesAmount,
         selectedSecondsAmount)
    }
    
    public var totalElapsedTime: ElapsedTime {
        ElapsedTime(timeInSeconds: totalTimeForCurrentSelection)
    }
}

public struct TimePickerView: View {
    
    @Binding public var model: TimerPickerModel
    
    public var body: some View {
        HStack() {
            if model.mode == .full || model.mode == .hourAndMinutes {
                IndividualTimePickerView(title: "hours", range: model.hoursRange, binding: $model.selectedHoursAmount)
            }
            if model.mode == .full || model.mode == .hourAndMinutes || model.mode == .minutesAndSeconds {
                IndividualTimePickerView(title: "min", range: model.minutesRange, binding: $model.selectedMinutesAmount)
            }
            if model.mode == .full || model.mode == .minutesAndSeconds {
                IndividualTimePickerView(title: "sec", range: model.secondsRange, binding: $model.selectedSecondsAmount)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .padding(.all)
    }
}

struct IndividualTimePickerView: View {
    // This is used to tighten up the spacing between the Picker and its
    // respective label
    //
    // This allows us to avoid having to use custom
    private let pickerViewTitlePadding: CGFloat = 4.0
    
    let title: String
    let range: ClosedRange<Int>
    let binding: Binding<Int>
    
    var body: some View {
        HStack(spacing: -pickerViewTitlePadding) {
            Picker(title, selection: binding) {
                ForEach(range, id: \.self) { timeIncrement in
                    HStack {
                        // Forces the text in the Picker to be right-aligned
                        Spacer()
                        Text("\(timeIncrement)")
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .pickerStyle(InlinePickerStyle())
            .labelsHidden()
            
            Text(title)
                .fontWeight(.bold)
        }
    }
}

// Extension to convert total time in seconds into formatted string
public extension Int {
    var asTimestamp: String {
        let hour = self / 3600
        let minute = self / 60 % 60
        let second = self % 60

        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
}
