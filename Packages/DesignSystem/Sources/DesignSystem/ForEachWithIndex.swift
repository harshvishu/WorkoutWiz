//
//  ForEachWithIndex.swift
//
//
//  Created by harsh vishwakarma on 14/01/24.
//

import SwiftUI

public struct ForEachWithIndex<Data: RandomAccessCollection, ID: Hashable, Content: View>: View,  DynamicViewContent where Content: View {
    public var data: Data
    public var content: (_ index: Data.Index, _ element: Data.Element) -> Content
    public var id: KeyPath<Data.Element, ID>
    
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (_ index: Data.Index, _ element: Data.Element) -> Content) {
        self.data = data
        self.id = id
        self.content = content
    }
    
    public var body: some View {
        ForEach(
            zip(self.data.indices, self.data).map { index, element in
                IndexInfo(
                    index: index,
                    id: self.id,
                    element: element
                )
            },
            id: \.elementID
        ) { indexInfo in
            self.content(indexInfo.index, indexInfo.element)
        }
    }
}

public extension ForEachWithIndex where ID == Data.Element.ID, Content: View, Data.Element: Identifiable {
    init(_ data: Data, @ViewBuilder content: @escaping (_ index: Data.Index, _ element: Data.Element) -> Content) {
        self.init(data, id: \.id, content: content)
    }
}

private struct IndexInfo<Index, Element, ID: Hashable>: Hashable {
    let index: Index
    let id: KeyPath<Element, ID>
    let element: Element
    
    var elementID: ID {
        self.element[keyPath: self.id]
    }
    
    static func == (_ lhs: IndexInfo, _ rhs: IndexInfo) -> Bool {
        lhs.elementID == rhs.elementID
    }
    
    func hash(into hasher: inout Hasher) {
        self.elementID.hash(into: &hasher)
    }
}
