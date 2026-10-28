//
//  APIClient.swift
//  swift-pagination
//
//  Created by Vokal-Ican on 28/10/26.
//
 
import Foundation

final class APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared, decoder: JSONDecoder = APIClient.defaultDecoder ) {
        self.session = session
        self.decoder = decoder
    }
    
    static let defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func request <T: Decodable>(
        url: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        as Type: T.Type
    ) async throws -> T {
        
        var components = URLComponents(string: url)
        components?.queryItems = query.isEmpty ? nil : query
        
        guard let finalURL = components?.url else { throw APIError.invalidURL }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
    
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw APIError.transport(error)
        }
        
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        
        guard (200...299).contains(http.statusCode) else { throw APIError.httpStatus(http.statusCode) }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
            
    }
    
}
