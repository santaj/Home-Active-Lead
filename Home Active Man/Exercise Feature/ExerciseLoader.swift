//
//  ExerciseLoader.swift
//  Home Active Man
//
//  Created by Josef Santamaria on 2020-11-24.
//

import Foundation

public enum LoadExerciseResult<Error: Swift.Error> {
    case success([ExerciseItem])
    case failure(Error)
}

extension LoadExerciseResult: Equatable where Error: Equatable {}

protocol ExerciseLoader {
    associatedtype Error: Swift.Error
    
    func load(completion: @escaping (LoadExerciseResult<Error>) -> Void)
}

