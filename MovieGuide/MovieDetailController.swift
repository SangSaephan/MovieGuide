//
//  MovieDetailController.swift
//  MovieGuide
//
//  Created by Sang Saephan on 11/8/16.
//  Copyright © 2016 Sang Saephan. All rights reserved.
//

import UIKit

class MovieDetailController: UIViewController {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var movie : Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.titleLabel.text = movie?.movieTitle
        self.overviewLabel.text = movie?.movieOverview
        
        if(movie?.movieBackdropPathUrl != nil) {
            backdropImageView.af_setImageWithURL(movie!.movieBackdropPathUrl!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
