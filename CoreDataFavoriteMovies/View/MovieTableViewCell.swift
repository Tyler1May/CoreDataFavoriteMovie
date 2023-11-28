//
//  MovieTableViewCell.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 10/31/22.
//

import UIKit
import Kingfisher

class MovieTableViewCell: UITableViewCell {

    static let reuseIdentifier = "MovieTableViewCell"
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!

    var onFavorite: (() -> Void)?
    
    private var apiMovie: APIMovie?
    private var movie: Movie?
    
    private var heart = UIImage(systemName: "heart")
    private var favoritedHeart = UIImage(systemName: "heart.fill")
    private let placeholder = UIImage(named: "moviePlaceholder")
    
    
    func update(with movie: APIMovie, onFavorite: (() -> Void)?) {
        updateInternal(with: movie, onFavorite: onFavorite)
    }
    
    func update(with movie: Movie, onFavorite: (() -> Void)?) {
        let apiMovie = APIMovie(title: movie.title ?? "", year: movie.year ?? "", imdbID: movie.imdbID ?? "", posterURL: URL(string: movie.posterURL ?? ""))
        updateInternal(with: apiMovie, onFavorite: onFavorite)
    }
    
    private func updateInternal(with movie: APIMovie, onFavorite: (() -> Void)?) {
        self.apiMovie = movie
        self.onFavorite = onFavorite
        posterImageView.kf.setImage(with: movie.posterURL, placeholder: placeholder)
        titleLabel.text = movie.title
        yearLabel.text = movie.year
        if MovieController.shared.favoriteMovie(from: movie.imdbID) != nil {
            setFavorite()
        } else {
            setUnFavorite()
        }
    }
    

    func setFavorite() {
        heartButton.setImage(favoritedHeart, for: .normal)
        heartButton.tintColor = .red
    }
    
    func setUnFavorite() {
        heartButton.setImage(heart, for: .normal)
        heartButton.tintColor = .gray
    }
    
    @IBAction func favoriteButtonPressed() {
        onFavorite?()
    }
    
}
