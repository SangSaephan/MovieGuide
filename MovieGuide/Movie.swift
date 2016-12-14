//
//  Movie.swift
//  MovieGuide
//
//  Created by Sang Saephan on 11/7/16.
//  Copyright © 2016 Sang Saephan. All rights reserved.
//

import UIKit
import CoreData
import Alamofire

let baseImageURL = "http://image.tmdb.org/t/p/w500"

class Movie: NSObject {
    
    var moviePosterUrl: String?
    var movieTitle: String?
    var movieOverview: String?
    var movieBackdropPathUrl: String?
    var movieReleaseDate: String?
    var movieVoteAverage = 0.0
    
    // Sets primary key so duplicate movies won't be added to database
    /*override static func primaryKey() -> String? {
        return "movieTitle"
    }*/
    
    // Parses each movie
    init(moviePosterUrl: String?, movieTitle: String?, movieOverview: String?, movieBackdropUrl: String?, movieReleaseDate: String?, movieVoteAverage: Double?) {
        self.moviePosterUrl = moviePosterUrl
        self.movieTitle = movieTitle
        self.movieOverview = movieOverview
        self.movieBackdropPathUrl = movieBackdropUrl
        self.movieReleaseDate = movieReleaseDate
        self.movieVoteAverage = movieVoteAverage!
    }
    
    init(dictionary: NSDictionary){
        super.init()
        
        if let moviePosterUrlString = dictionary["poster_path"] as? String {
            moviePosterUrl = baseImageURL + moviePosterUrlString
        } else {
            moviePosterUrl = nil
        }
        
        if let movieBackdropPathString = dictionary["backdrop_path"] as? String {
            movieBackdropPathUrl = baseImageURL + movieBackdropPathString
        } else {
            movieBackdropPathUrl = nil
        }
        
        movieTitle = dictionary["title"] as? String
        movieOverview = dictionary["overview"] as? String
        movieReleaseDate = dictionary["release_date"] as? String
        //movieVoteAverage = (dictionary["vote_average"] as? Int)!
        
        someRating() {rating in
            self.movieVoteAverage = rating
        }
    }
    
    // Adds the new movie to the database
    class func movies(array: [NSDictionary]) -> [Movie] {
        var movies = [Movie]()
        for dictionary in array {
            let movie = Movie(dictionary: dictionary)
            saveMovies(movie)
            
            //write the settings object to db for persistence
            /*try! realmObject.write() {
                realmObject.add(movie, update: true)*/
                movies.append(movie)
            //}
        }
        return movies
    }
    
    /*
    Save movies to database
    */
    class func saveMovies(movie: Movie) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entityForName("Movies", inManagedObjectContext: managedContext)
        
        let individualMovie = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        individualMovie.setValue(movie.moviePosterUrl, forKey: "moviePosterUrl")
        individualMovie.setValue(movie.movieTitle, forKey: "movieTitle")
        individualMovie.setValue(movie.movieBackdropPathUrl, forKey: "movieBackdropPathUrl")
        individualMovie.setValue(movie.movieReleaseDate, forKey: "movieReleaseDate")
        individualMovie.setValue(movie.movieOverview, forKey: "movieOverview")
        individualMovie.setValue(movie.movieVoteAverage, forKey: "movieVoteAverage")
        
        do {
            try managedContext.save()
            movieList.append(individualMovie)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    func someRating(completionHandler: (Double) -> ()) {
        getRating(completionHandler)
    }
    
    func getRating(completionHandler: (Double) -> ()) {
        let movieString = movieTitle!.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let releaseDate = movieReleaseDate!.substringWithRange(Range<String.Index>(start: movieReleaseDate!.startIndex, end: movieReleaseDate!.startIndex.advancedBy(4)))
        
        // Makes call to another API to retrieve additional movie info
        Alamofire.request(.GET, "http://www.omdbapi.com/?t=\(movieString)&y=\(releaseDate)").responseJSON { response in
            if let json = response.result.value {
                if let error = json["Error"] as? String {
                    print("Error: " + error)
                    completionHandler(0.0)
                } else {
                    var someRating = 0.0
                    let rating = json["imdbRating"] as! String
                    if rating != "N/A" {
                        someRating = Double(rating)!
                        completionHandler(someRating)
                    } else {
                        completionHandler(0.0)
                    }
                }
            }
        }
    }

}
