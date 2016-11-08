//
//  ViewController.swift
//  MovieGuide
//
//  Created by Sang Saephan on 11/5/16.
//  Copyright © 2016 Sang Saephan. All rights reserved.
//

import UIKit
import Alamofire

let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [Movie]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        makeAPICall()
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let cell = sender as! UITableViewCell
        cell.setSelected(false, animated: false)
        
        let indexPath = tableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let movieDetailController = segue.destinationViewController as! MovieDetailController
        
        movieDetailController.movie = movie
    }

}

