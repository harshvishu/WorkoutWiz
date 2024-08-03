//
//  DaySelectItemView.swift
//  
//
//  Created by harsh on 16/09/22.
//

import SwiftUI

struct DaySelectItemView: View {
    var viewModel: DaySelectItemViewModel
    var itemSize: CGSize
    var padding: CGFloat
    
    public init(viewModel: DaySelectItemViewModel, itemSize: CGSize, padding: CGFloat = 5) {
        self.viewModel = viewModel
        self.itemSize = itemSize
        self.padding = padding
    }
    
    
    var body: some View {
        VStack(spacing: 10) {
            Text(viewModel.extractDate(format: "dd"))
                .font(.headline)
            Text(viewModel.extractDate(format: "EEE"))
                .font(.subheadline)
            
            Circle()
                .fill(.primary)
                .frame(width: 8, height: 8)
                .opacity(viewModel.isToday() ? 1 : 0)
        }
        .foregroundStyle(Color(uiColor: viewModel.isSelected ? UIColor.white : UIColor.systemBackground))
        // MARK: Capsule Shape
        .frame(width: itemSize.width, height: itemSize.height)
        .background(viewModel.isSelected ? Color.accentColor : Color.primary)
        .clipShape(Capsule())
        .padding([.horizontal], padding)
    }
}


struct DaySelectItemView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            // Same Day Selected
            DaySelectItemView(viewModel: DaySelectItemViewModel(date: Date(), isSelected: true), itemSize: CGSize(width: 45, height: 90))
            // Same Day Un-Selected
            DaySelectItemView(viewModel: DaySelectItemViewModel(date: Date(), isSelected: false), itemSize: CGSize(width: 45, height: 90))
            // Different Day Selected
            DaySelectItemView(viewModel: DaySelectItemViewModel(date: Date().addingTimeInterval(86000), isSelected: true), itemSize: CGSize(width: 45, height: 90))
            // Different Day Un-Selected
            DaySelectItemView(viewModel: DaySelectItemViewModel(date: Date().addingTimeInterval(86000), isSelected: false), itemSize: CGSize(width: 45, height: 90))
        }
    }
}
