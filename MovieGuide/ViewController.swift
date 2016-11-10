//
//  ViewController.swift
//  MovieGuide
//
//  Created by Sang Saephan on 11/5/16.
//  Copyright © 2016 Sang Saephan. All rights reserved.
//

import UIKit
import Alamofire
import Realm
import RealmSwift

let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
let realmObject = try! Realm()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [Movie]? = []
    var refreshControl: UIRefreshControl!
    var date = NSDate()
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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
        print(Realm.Configuration.defaultConfiguration.description)
        
        let dbMovies = realmObject.objects(Movie.self)
        
        if dbMovies.count > 0 {
            print("Found movies in DB")
            var newMoviesArray = [Movie]()
            for movie in dbMovies {
                newMoviesArray.append(movie)
            }
            movies = newMoviesArray
        } else {
            //make API call and save data in the realm db
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
        Alamofire.request(.GET, "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)").responseJSON { response in
            if let json = response.result.value {
                if let status_code = json["status_code"] as? Int {
                    print("ERROR: Unable to hit the API with status code: \(status_code)")
                    print("Got status message: \(json["status_message"] as! String)")
                }
                else {
                    print("Connection to API successful!")
                    self.movies = Movie.movies((json["results"] as? [NSDictionary])!)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func refresh(sender: AnyObject) {
        makeAPICall()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        cell.setSelected(false, animated: false)
        
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let movieDetailController = segue.destinationViewController as! MovieDetailController
        
        movieDetailController.movie = movie
    }

}

