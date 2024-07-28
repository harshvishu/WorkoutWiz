//
//  NextPageView.swift
//  
//
//  Created by harsh vishwakarma on 10/03/24.
//

import SwiftUI

public struct NextPageView: View {
  @State private var isLoadingNextPage: Bool = false
  @State private var showRetry: Bool = false

  let loadNextPage: () async throws -> Void

  public init(loadNextPage: @escaping (() async throws -> Void)) {
    self.loadNextPage = loadNextPage
  }

  public var body: some View {
    HStack {
      if showRetry {
        Button {
          Task {
            showRetry = false
            await executeTask()
          }
        } label: {
          Label("Retry", systemImage: "arrow.clockwise")
        }
        .buttonStyle(.bordered)
      } else {
        Label("Loading...", systemImage: "arrow.down")
          .font(.footnote)
          .foregroundStyle(.secondary)
          .symbolEffect(.pulse, value: isLoadingNextPage)
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
    .task {
      await executeTask()
    }
    .listRowSeparator(.hidden, edges: .all)
  }

  private func executeTask() async {
    showRetry = false
    defer {
      isLoadingNextPage = false
    }
    guard !isLoadingNextPage else { return }
    isLoadingNextPage = true
    do {
      try await loadNextPage()
    } catch {
      showRetry = true
    }
  }
}


@available(iOS 18.0, *)
#Preview {
  List {
    Text("Item 1")
    NextPageView {
      
    }
  }
  .listStyle(.plain)
}
