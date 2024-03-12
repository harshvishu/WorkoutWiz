//
//  ImageFetchorRepository.swift
//  
//
//  Created by harsh vishwakarma on 12/03/24.
//

import Foundation

public protocol ImageFetchorRepository {
    func imageUrlFor(imageNames: [String]) -> [URL]
    var imageBaseURL: URL {get}
}
