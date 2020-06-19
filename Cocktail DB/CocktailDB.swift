//
//  CoctailDB.swift
//  Cocktail DB
//
//  Created by Maksym Saliuta on 18.06.2020.
//  Copyright © 2020 Maksym Saliuta. All rights reserved.
//

import Foundation
import UIKit

enum Constants {
    static let apiBaseURL = "https://www.thecocktaildb.com/api/json/v1/1/"
    static let apiFiltersEndpoint = "list.php?c=list"
    static let apiDrinksEndpoint = "filter.php?c="
    static let defaultFilter = "Ordinary Drink"
    static let segueIdentifier = "PresentFilters"
}

struct DrinksResponse: Codable {
    let drinks: [Drink]
}

struct FiltersResponse: Codable {
    let drinks: [Filter]
}

struct Drink: Codable {
    let name: String
    let imageURL: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case name = "strDrink"
        case imageURL = "strDrinkThumb"
        case id = "idDrink"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        imageURL = try container.decode(String.self, forKey: .imageURL)
        id = try container.decode(String.self, forKey: .id)
    }
}

struct Filter: Codable {
    let name: String
    var isSelected: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case name = "strCategory"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }
}


class CocktailDB {
    static let shared = CocktailDB()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    private var components = URLComponents()
    private let baseURL = Constants.apiBaseURL
    private let filtersEndpoint = Constants.apiFiltersEndpoint
    private let drinksEndpoint = Constants.apiDrinksEndpoint
    
    private enum APIError: Error {
        case invalidURL
        case serverDoNotResponse
        case serverResponseError
        case canNotReceiveData
        case filterQueryItemPercentEncodingError
    }
    
    private init() {}

    func fetchFilters(completion: @escaping (Result<FiltersResponse, Error>) -> Void) {
        let filtersURL = baseURL.appending(filtersEndpoint)
        fetchData(from: filtersURL, completion: completion)
    }
    
    func fetchCocktails(filter filterValue: String, completion: @escaping (Result<DrinksResponse, Error>) -> Void) {
        if let filter = filterValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let drinkURL = baseURL.appending(drinksEndpoint).appending(filter)
            fetchData(from: drinkURL, completion: completion)
        } else {
            completion(.failure(APIError.filterQueryItemPercentEncodingError))
        }
    }
     
    private func fetchData<Object: Decodable>(from url: String, completion: @escaping (Result<Object, Error>) -> Void) {
        request(url: url) { (result) in
            switch result {
            case .success(let data):
                do {
                    let object = try self.decoder.decode(Object.self, from: data)
                    completion(.success(object))
                } catch let error {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func request(url: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(APIError.invalidURL))
            return
        }
        let task = session.dataTask(with: url) { (data, urlResponse, error) in
            if let error = error {
                completion(.failure(error))
            }
            guard let responseUnwrapped = urlResponse as? HTTPURLResponse else {
                completion(.failure(APIError.serverDoNotResponse))
                return
            }
            switch responseUnwrapped.statusCode {
            case 200:
                guard let data = data else {
                    completion(.failure(APIError.canNotReceiveData))
                    return
                }
                completion(.success(data))
            default:
                completion(.failure(APIError.serverResponseError))
            }
        }
        task.resume()
    }
}
