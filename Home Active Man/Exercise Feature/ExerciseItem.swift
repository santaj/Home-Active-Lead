//
//  ExerciseItem.swift
//  Home Active Man
//
//  Created by Josef Santamaria on 2020-11-24.
//sf

import Foundation


public struct ExerciseItem: Equatable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let image: URL
  
    public init(id: UUID, description: String?, location: String?, image: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.image = image
    }
}
