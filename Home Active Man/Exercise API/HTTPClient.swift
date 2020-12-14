//
//  HTTPClient.swift
//  Home Active Man
//
//  Created by Josef Santamaria on 2020-12-14.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
