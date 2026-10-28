//
//  PicsumService.swift
//  swift-pagination
//
//  Created by Vokal-Ican on 28/10/26.
//

import Foundation

final class PicsumService {
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    func fetchPicsum(page: Int, limit: Int = 10) async throws -> [Picsum] {
        let dtos = try await client.request(
            url: "https://picsum.photos/v2/list",
            query: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")
            ],
            as: [PicsumDTO].self
        )
        return dtos.map { $0.toDomain() }
    }
}
