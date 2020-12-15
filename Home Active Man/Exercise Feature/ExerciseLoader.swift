//
//  ExerciseLoader.swift
//  Home Active Man
//
//  Created by Josef Santamaria on 2020-11-24.
//

import Foundation

public enum LoadExerciseResult {
    case success([ExerciseItem])
    case failure(Error)
}

public protocol ExerciseLoader {
    func load(completion: @escaping (LoadExerciseResult) -> Void)
}

