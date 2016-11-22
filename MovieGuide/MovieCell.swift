//
//  MovieCell.swift
//  MovieGuide
//
//  Created by Sang Saephan on 11/5/16.
//  Copyright © 2016 Sang Saephan. All rights reserved.
//

import UIKit
import AlamofireImage

class MovieCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var voteAverageLabel: UILabel!
    let dateFormatter = NSDateFormatter()
    let stringFormatter = NSDateFormatter()
    var date: NSDate?
    var stringDate: String?
    
    var movie : Movie! {
        didSet {
            titleLabel.text = movie.movieTitle!
            
            if(movie.moviePosterUrl != nil) {
                posterImageView.af_setImageWithURL(NSURL(string: movie.moviePosterUrl!)!)
            }
            
            // Convert release date to NSDate(), the convert back to String in correct format
            dateFormatter.dateStyle = NSDateFormatterStyle.FullStyle
            dateFormatter.dateFormat = "yyyy-MM-dd"
            stringFormatter.dateFormat = "MMM dd, yyyy"
            date = dateFormatter.dateFromString(movie.movieReleaseDate!)
            stringDate = stringFormatter.stringFromDate(date!)
            //releaseDateLabel.text = "Released: " + stringDate!
            if (UIScreen.mainScreen().bounds.size.height == 568 || UIScreen.mainScreen().bounds.size.height == 480) {
                releaseDateLabel.text = "Released:\n" + stringDate!
            } else {
                releaseDateLabel.text = "Released: " + stringDate!
            }
            
            // Color code the ratings based on its value
            switch(movie.movieVoteAverage) {
            case 0, 1, 2, 3:
                voteAverageLabel.textColor = UIColor.redColor()
            case 8, 9, 10:
                voteAverageLabel.textColor = UIColor.greenColor()
            default:
                voteAverageLabel.textColor = UIColor.yellowColor()
            }
            
            voteAverageLabel.text = "Rating: " + String(movie.movieVoteAverage) + "/10"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if (UIScreen.mainScreen().bounds.size.height == 568 || UIScreen.mainScreen().bounds.size.height == 480) {
            titleLabel.font = titleLabel.font.fontWithSize(14)
            releaseDateLabel.font = releaseDateLabel.font.fontWithSize(10)
            voteAverageLabel.font = voteAverageLabel.font.fontWithSize(10)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
