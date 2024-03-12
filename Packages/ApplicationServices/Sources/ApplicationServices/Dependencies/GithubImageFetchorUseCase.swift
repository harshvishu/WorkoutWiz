//
//  GithubImageFetchorUseCase.swift
//  
//
//  Created by harsh vishwakarma on 12/03/24.
//

import Foundation
import Dependencies

public final class GithubImageFetchorUseCase: ImageFetchorRepository {
    public let imageBaseURL: URL = URL(string: "https://raw.githubusercontent.com/harshvishu/free-exercise-db/main/exercises/")!
    
    public func imageUrlFor(imageNames: [String]) -> [URL] {
        imageNames.map({imageBaseURL.appending(path: $0)})
    }
    
    public init() {}
}

public extension DependencyValues {
    var exerciseThumbnailFetcher: GithubImageFetchorUseCase {
        get { self[GithubImageFetchorUseCase.self] }
        set { self[GithubImageFetchorUseCase.self] = newValue }
    }
}

extension GithubImageFetchorUseCase: DependencyKey {
    public static let liveValue: GithubImageFetchorUseCase = .init()
}
