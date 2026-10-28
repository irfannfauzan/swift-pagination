//
//  ImageLoader.swift
//  swift-pagination
//
//  Created by Vokal-Ican on 28/10/26.
//

import UIKit

final class ImageLoader {
    
    static let shared = ImageLoader()
    
    private init() {}
    
    private let cache = NSCache<NSURL, UIImage>()
    
    func cachedImage(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }
    
    func load(_ url: URL) async -> UIImage? {
        if let cached = cachedImage(for: url) { return cached }
        
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let image = UIImage(data: data) else { return nil }
        
        cache.setObject(image, forKey: url as NSURL)
        
        return image
    }
}
