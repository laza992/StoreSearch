//
//  Search.swift
//  StoreSearch
//
//  Created by Lazar Stojkovic on 6/5/20.
//  Copyright © 2020 lazar. All rights reserved.
//

import UIKit

class Search {
    
    // MARK: - Properties
    
    typealias SearchComplete = (Bool) -> Void
    private var dataTask: URLSessionDataTask? = nil
    private(set) var state: State = .notSearchedYet
    
    // MARK: - Public methods
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
            
            // Update state
            state = .loading
            
            let url = iTunesURL(searchText: text, category: category)
            
            let session = URLSession.shared
            dataTask = session.dataTask(with: url, completionHandler: { data, response, error in
                var newState = State.notSearchedYet
                var success = false
                
                // Was the search cancelled?
                if let error = error as NSError?, error.code == -999 {
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data {
                    var searchResults = self.parse(data: data)
                    if searchResults.isEmpty {
                        newState = .noResults
                    } else {
                        searchResults.sort(by: <)
                        newState = .results(searchResults)
                    }
                    success = true
                }
                DispatchQueue.main.async {
                    self.state = newState
                    completion(success)
                }
            })
            dataTask?.resume()
        }
    }
    
    private func iTunesURL(searchText: String, category: Category) -> URL {
        let kind = category.type
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = "https://itunes.apple.com/search?" + "term=\(encodedText)&limit=200&entity=\(kind)"
        let url = URL(string: urlString)
        return url!
    }
    
    private func parse(data: Data) -> [SearchResult] {
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ResultArray.self, from:data)
            return result.results
        } catch {
            print("JSON Error: \(error)")
            return []
        }
    }
}
