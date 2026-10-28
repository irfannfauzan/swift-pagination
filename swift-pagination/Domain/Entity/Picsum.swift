//
//  Picsum.swift
//  swift-pagination
//
//  Created by Vokal-Ican on 28/10/26.
//

import Foundation

struct Picsum {
    let id: String
    let author: String
    let size: String
    let thumbnailURL: URL?
    let fullURL: URL?
}

extension PicsumDTO {
    func toDomain() -> Picsum {
        Picsum(id: id,
               author: author,
               size: "\(width) * \(height)",
               thumbnailURL: URL(string: "https://picsum.photos/id/\(id)/200/300"),
               fullURL: URL(string: "https://picsum.photos/id/\(id)/800/600")
        )
    }
}
