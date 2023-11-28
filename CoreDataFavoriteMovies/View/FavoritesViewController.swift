//
//  FavoritesViewController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/3/22.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    
    private let movieController = MovieController.shared
    private var datasource: UITableViewDiffableDataSource<Int, Movie>!
    private var viewContext = PersistenceController.shared.viewContext
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search movie title"
        sc.searchBar.delegate = self
        return sc
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpDataSource()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavorites()
        
        
        var snapshot = datasource.snapshot()
        guard !snapshot.sectionIdentifiers.isEmpty else { return }
        snapshot.reloadSections([0])
        datasource?.apply(snapshot, animatingDifferences: true)
    }

    func applyNewSnapshot(from movies: [Movie]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies)
        datasource?.apply(snapshot, animatingDifferences: true)
        tableView.backgroundView = movies.isEmpty ? backgroundView : nil
    }
    
    func fetchFavorites(searchText: String? = nil) {
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
        if let searchText = searchText, !searchText.isEmpty {
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            fetchRequest.predicate = predicate
        }
        
        do {
            let favoriteMovies = try viewContext.fetch(fetchRequest)
            applyNewSnapshot(from: favoriteMovies)
        } catch {
            print("error fetching favorite moivies from core data: \(error)")
        }
        
    }
    
    func removeFavorite(_ movie: Movie) {
        movieController.unfavoriteMovie(movie)
        guard let datasource = datasource, case var snapshot = datasource.snapshot() else { return }
        snapshot.deleteItems([movie])
        datasource.apply(snapshot, animatingDifferences: true)
    }
    
}

private extension FavoritesViewController {
    
    func setUpTableView() {
        tableView.backgroundView = backgroundView
        tableView.register(UINib(nibName: MovieTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)

    }
    
    func setUpDataSource() {
        datasource = UITableViewDiffableDataSource<Int, Movie>(tableView: tableView) { tableView, indexPath, movie in
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier) as! MovieTableViewCell
            cell.update(with: movie) {
                self.removeFavorite(movie)
            }
            return cell
        }
    }

    func toggleFavorite(_ movie: APIMovie) {
        print("SEE! I knew you liked \(movie.title)!")
        movieController.saveFavMovie(with: movie.title, for: movie)
    }

}

extension FavoritesViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.isEmpty {
            fetchFavorites()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchFavorites()
    }
    
}

