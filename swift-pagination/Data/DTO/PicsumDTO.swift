//
//  PicsumDTO.swift
//  swift-pagination
//
//  Created by Vokal-Ican on 28/10/26.
//

import Foundation

struct PicsumDTO: Decodable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let downloadUrl: String   //download_url -> convertFromSnakeCase
}
