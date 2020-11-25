//
//  ExerciseLoader.swift
//  Home Active Man
//
//  Created by Josef Santamaria on 2020-11-24.
//

import Foundation

enum LoadExerciseResult {
    case success([ExerciseItem])
    case error(Error)
}

protocol ExerciseLoader {
    func load(completion: @escaping (LoadExerciseResult) -> Void)
}
