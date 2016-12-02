//
//  ViewController.swift
//  MovieGuide
//
//  Created by Sang Saephan on 11/5/16.
//  Copyright © 2016 Sang Saephan. All rights reserved.
//

import UIKit
import Alamofire
/*import Realm
import RealmSwift*/
import CoreData

let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
//let realmObject = try! Realm()
var movieList = [NSManagedObject]()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var alphabeticalButton: UIBarButtonItem!
    @IBOutlet weak var ratingButton: UIBarButtonItem!
    @IBOutlet weak var releaseDateButton: UIBarButtonItem!
    
    /*
    Sorts movies by title
    */
    @IBAction func alphabeticalSort(sender: AnyObject) {
        var temp: Movie?
        var j: Int
        
        for i in 1..<movies!.count {
            j = i
            while(j > 0 && movies![j].movieTitle < movies![j - 1].movieTitle) {
                temp = movies![j]
                movies![j] = movies![j - 1]
                movies![j - 1] = temp!
                j--
            }
        }
        
        // Color-code the selected sort filter
        alphabeticalButton.tintColor = UIColor.grayColor()
        ratingButton.tintColor = UIColor.whiteColor()
        releaseDateButton.tintColor = UIColor.whiteColor()
        
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.init(x: 0.0, y: -64.0), animated: false)
    }
    
    /*
    Sorts movies by rating
    */
    @IBAction func ratingSort(sender: AnyObject) {
        var temp: Movie?
        var j: Int
        
        for i in 1..<movies!.count {
            j = i
            while(j > 0 && movies![j].movieVoteAverage > movies![j - 1].movieVoteAverage) {
                temp = movies![j]
                movies![j] = movies![j - 1]
                movies![j - 1] = temp!
                j--
            }
        }
        
        // Color-code the selected sort filter
        alphabeticalButton.tintColor = UIColor.whiteColor()
        ratingButton.tintColor = UIColor.grayColor()
        releaseDateButton.tintColor = UIColor.whiteColor()
        
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.init(x: 0.0, y: -64.0), animated: false)
    }
    
    /*
    Sort movies by release date
    */
    @IBAction func releaseDateSort(sender: AnyObject) {
        var temp: Movie?
        var j: Int
        
        for i in 1..<movies!.count {
            j = i
            while(j > 0 && movies![j].movieReleaseDate > movies![j - 1].movieReleaseDate) {
                temp = movies![j]
                movies![j] = movies![j - 1]
                movies![j - 1] = temp!
                j--
            }
        }
        
        // Color-code the selected sort filter
        alphabeticalButton.tintColor = UIColor.whiteColor()
        ratingButton.tintColor = UIColor.whiteColor()
        releaseDateButton.tintColor = UIColor.grayColor()
        
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.init(x: 0.0, y: -64.0), animated: false)
    }
    
    var movies: [Movie]? = []
    var refreshControl: UIRefreshControl!
    var date = NSDate()
    let dateFormatter = NSDateFormatter()
    var movieCast: String?
    var movieList = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set initial sort tab and color scheme
        releaseDateButton.tintColor = UIColor.grayColor()
        navigationController?.navigationBar.barTintColor = UIColor.darkGrayColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Set style for date formatter
        dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Implement pull-to-refresh function
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Last updated: " + dateFormatter.stringFromDate(date))
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        //Realm db path: DEBUG
        /*print(Realm.Configuration.defaultConfiguration.description)
        
        let dbMovies = realmObject.objects(Movie.self)
        
        if dbMovies.count > 0 {
            print("Found movies in DB")
            var newMoviesArray = [Movie]()
            for movie in dbMovies {
                newMoviesArray.append(movie)
            }
            movies = newMoviesArray
            sortMovies(&movies!)
        } else {
            //make API call and save data in the realm db
            makeAPICall()
        }*/
        
        // Load movies from database
        loadMovies()
        if movieList.count > 0 {
            for items in movieList {
                let movieItem = Movie(moviePosterUrl: items.valueForKey("moviePosterUrl") as? String, movieTitle: items.valueForKey("movieTitle") as? String, movieOverview: items.valueForKey("movieOverview") as? String, movieBackdropUrl: items.valueForKey("movieBackdropPathUrl") as? String, movieReleaseDate: items.valueForKey("movieReleaseDate") as? String, movieVoteAverage: items.valueForKey("movieVoteAverage") as! Int)
                
                movies?.append(movieItem)
                sortMovies(&movies!)
            }
        } else {
            makeAPICall()
        }
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies!.count ?? 0
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        cell.setSelected(false, animated: false)
        cell.movie = movies![indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 149
    }
    
    func makeAPICall() {
        Alamofire.request(.GET, "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)&region=US").responseJSON { response in
            if let json = response.result.value {
                if let status_code = json["status_code"] as? Int {
                    print("ERROR: Unable to hit the API with status code: \(status_code)")
                    print("Got status message: \(json["status_message"] as! String)")
                }
                else {
                    // Delete current database before making call for new movies
                    /*try! realmObject.write() {
                        realmObject.deleteAll()
                        realmObject.refresh()
                        print("Database Deleted")
                    }*/
                    self.deleteMovies()
                    self.movies = Movie.movies((json["results"] as? [NSDictionary])!)
                    self.sortMovies(&self.movies!)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // Called when view is pulled to refresh
    func refresh(sender: AnyObject) {
        makeAPICall()
        refreshControl.endRefreshing()
        alphabeticalButton.tintColor = UIColor.whiteColor()
        ratingButton.tintColor = UIColor.whiteColor()
        releaseDateButton.tintColor = UIColor.grayColor()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        cell.setSelected(false, animated: false)
        
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let movieDetailController = segue.destinationViewController as! MovieDetailController
        let movieString = movie.movieTitle!.stringByReplacingOccurrencesOfString(" ", withString: "+")
        let releaseDate = movie.movieReleaseDate!.substringWithRange(Range<String.Index>(start: movie.movieReleaseDate!.startIndex, end: movie.movieReleaseDate!.startIndex.advancedBy(4)))
        
        // Makes call to another API to retrieve additional movie info
        Alamofire.request(.GET, "http://www.omdbapi.com/?t=\(movieString)&y=\(releaseDate)").responseJSON { response in
            if let json = response.result.value {
                if let error = json["Error"] as? String {
                    print("Error: " + error)
                    movieDetailController.castLabel.text = "CAST: N/A"
                    movieDetailController.directorLabel.text = "DIRECTOR: N/A"
                    movieDetailController.ratedLabel.text = "RATED: N/A"
                    movieDetailController.runtimeLabel.text = "RUNTIME: N/A"
                } else {
                    movieDetailController.castLabel.text = "CAST: " + (json["Actors"] as? String)!
                    movieDetailController.directorLabel.text = "DIRECTOR: " + (json["Director"] as? String)!
                    movieDetailController.ratedLabel.text = "RATED: " + (json["Rated"] as? String)!
                    movieDetailController.runtimeLabel.text = "RUNTIME: " + (json["Runtime"] as? String)!
                }
            }
        }
        
        movieDetailController.movie = movie
        
        // Set text of back button
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        navigationItem.backBarButtonItem = backItem
    }
    
    /*
    Sorts movies by release date
    */
    func sortMovies(inout movies: [Movie]) {
        var temp: Movie?
        var j: Int
        
        for i in 1..<movies.count {
            j = i
            while(j > 0 && movies[j].movieReleaseDate > movies[j - 1].movieReleaseDate) {
                temp = movies[j]
                movies[j] = movies[j - 1]
                movies[j - 1] = temp!
                j--
            }
        }
    }
    
    /*
    Load movies from the database
    */
    func loadMovies() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Movies")
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            movieList = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    /*
    Delete movies from the database
    */
    func deleteMovies() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Movies")
        
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            for item in results {
                managedContext.deleteObject(item as! NSManagedObject)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete \(error), \(error.userInfo)")
        }
    }

}

