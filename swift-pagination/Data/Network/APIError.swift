//
//  APIError.swift
//  swift-pagination
//
//  Created by Vokal-Ican on 28/10/26.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case transport(URLError)
    case invalidResponse
    case httpStatus(Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL tidak valid!"

        case .transport(let error):
            switch error.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
                return "Tidak ada koneksi internet!"
            case .cannotFindHost, .dnsLookupFailed:
                return "Server tidak ditemukan!"
            case .cannotConnectToHost:
                return "Tidak dapat terhubung ke server!"
            case .timedOut:
                return "Koneksi timeout, coba lagi."
            case .badURL, .unsupportedURL:
                return "URL tidak valid!"
            case .cancelled:
                return "Request dibatalkan."
            default:
                return "Terjadi kesalahan jaringan: \(error.localizedDescription)"
            }

        case .invalidResponse:
            return "Response server error!"
        case .httpStatus(let code):
            return "Server error!: \(code)"
        case .decoding(let error):
            return "Error decode data: \(error.localizedDescription)"
        }
    }
}




