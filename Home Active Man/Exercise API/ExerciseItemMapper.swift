//
//  ExerciseItemMapper.swift
//  Home Active Man
//
//  Created by Josef Santamaria on 2020-12-14.
//

import Foundation

internal final class ExerciseItemMapper {
    
    private struct Root: Decodable {
        let items: [Item]
        
        var exercises: [ExerciseItem] {
            return items.map { $0.item }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: ExerciseItem {
            return ExerciseItem(id: id, description: description, location: location, image: image)
        }
    }
    
    private static var OK200: Int { return 200 }
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteExerciseLoader.Result {
        guard response.statusCode == OK200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteExerciseLoader.Error.invalidData)
        }
        return .success(root.exercises)
    }
}
