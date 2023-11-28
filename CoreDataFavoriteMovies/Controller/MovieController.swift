//
//  MovieController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/1/22.
//

import Foundation
import CoreData

class MovieController {
    static let shared = MovieController()
    
    private let apiController = MovieAPIController()
    private var viewContext = PersistenceController.shared.viewContext
    
    func fetchMovies(with searchTerm: String) async throws -> [APIMovie] {
        return try await apiController.fetchMovies(with: searchTerm)
    }
    
    func saveFavMovie(with title: String, for movie: APIMovie) {
        let favMovie = Movie(context: viewContext)
        favMovie.imdbID = movie.imdbID
        favMovie.posterURL = movie.posterURL?.absoluteString
        favMovie.title  = movie.title
        favMovie.year = movie.year
        try? viewContext.save()
    }
    
    func unfavoriteMovie(_ movie: Movie) {
        viewContext.delete(movie)
        try? viewContext.save()
    }
    
    func favoriteMovie(from movieIMDBID: String) -> Movie? {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        let predicate = NSPredicate(format: "imdbID == %@", movieIMDBID)
        fetchRequest.predicate = predicate
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.first
        } catch {
            print(error)
            return nil
        }
    }
    
}
