//
//  SearchBar.swift
//
//
//  Created by harsh vishwakarma on 03/04/24.
//

import SwiftUI

public struct SearchBar: View {
    
    @Binding var searchText: String
    var prompt: String
    var action: (() -> Void)
    
    public init(searchText: Binding<String>, prompt: String, action: @escaping (() -> Void)) {
        self._searchText = searchText
        self.prompt = prompt
        self.action = action
    }
    
    public var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("Search", text: $searchText, prompt: Text(prompt))
                .onSubmit(of: .search, action)
                .submitLabel(.search)
            
            Button(action: {
                self.searchText = ""
            }) {
                Image(systemName: "xmark.circle.fill")
                    .aspectRatio(contentMode: .fit)
                    .opacity(searchText.isEmpty ? 0 : 1)
                    .animation(.easeIn, value: searchText.isEmpty)
            }
            .foregroundStyle(.secondary)
        }
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .background {
            RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                .fill(.quinary)
        }
        
    }
}

@available(iOS 18.0, *)
#Preview {
    @State var searchText = ""
    
    return SearchBar(searchText: $searchText, prompt: "Search for exercises")
    {
        
    }
}
