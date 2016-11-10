//
//  Movie.swift
//  MovieGuide
//
//  Created by Sang Saephan on 11/7/16.
//  Copyright © 2016 Sang Saephan. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

let baseImageURL = "http://image.tmdb.org/t/p/w500"

class Movie: Object {
    
    dynamic var moviePosterUrl: String?
    dynamic var movieTitle: String?
    dynamic var movieOverview: String?
    dynamic var movieBackdropPathUrl: String?
    
    class func newMovie(dictionary: NSDictionary) -> Movie {
        let movie = Movie()
        
        if let moviePosterUrlString = dictionary["poster_path"] as? String {
            movie.moviePosterUrl = baseImageURL + moviePosterUrlString
        } else {
            movie.moviePosterUrl = nil
        }
        
        if let movieBackdropPathString = dictionary["backdrop_path"] as? String {
            movie.movieBackdropPathUrl = baseImageURL + movieBackdropPathString
        } else {
            movie.movieBackdropPathUrl = nil
        }
        
        movie.movieTitle = dictionary["title"] as? String
        
        movie.movieOverview = dictionary["overview"] as? String
        
        return movie
    }
    
    class func movies(array: [NSDictionary]) -> [Movie] {
        var movies = [Movie]()
        for dictionary in array {
            let movie = newMovie(dictionary)
            
            //write the settings object to db for persistence
            try! realmObject.write() {
                realmObject.add(movie)
                print("New Movie saved with name: \(movie.movieTitle)")
                movies.append(movie)
            }
        }
        return movies
    }

}
