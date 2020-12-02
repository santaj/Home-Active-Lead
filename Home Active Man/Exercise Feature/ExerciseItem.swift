//
//  ExerciseItem.swift
//  Home Active Man
//
//  Created by Josef Santamaria on 2020-11-24.
//sf

import Foundation


public struct ExerciseItem: Equatable {
    let id: Int
    let frontImage: URL
    let title: String
    let category: String
}

struct ExerciseDetailInfo {
    let id: Int
    let secondImage: URL
    let instructionText: String
}
