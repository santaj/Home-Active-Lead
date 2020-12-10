//
//  ExerciseItem.swift
//  Home Active Man
//
//  Created by Josef Santamaria on 2020-11-24.
//sf

import Foundation


public struct ExerciseItem: Equatable {
    public let id: UUID
    public let frontImage: URL
    public let title: String
    public let category: String
    
    public init(id: UUID, frontImage: URL, title: String, category: String) {
        self.id = id
        self.frontImage = frontImage
        self.title = title
        self.category = category
    }
}
