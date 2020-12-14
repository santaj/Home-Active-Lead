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
    }

    private struct Item: Decodable {
        public let id: UUID
        public let frontImage: URL
        public let title: String
        public let category: String
        
        var item: ExerciseItem {
            return ExerciseItem(id: id, frontImage: frontImage, title: title, category: category)
        }
    }
    
    private static var OK200: Int { return 200 }
    
    internal static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [ExerciseItem] {
        guard response.statusCode == OK200 else {
            throw RemoteExerciseLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map { $0.item }
    }
}
