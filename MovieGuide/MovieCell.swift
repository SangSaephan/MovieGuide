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
    
    var movie : Movie! {
        didSet {
            titleLabel.text = movie.movieTitle!
            
            if(movie.moviePosterUrl != nil) {
                posterImageView.af_setImageWithURL(movie.moviePosterUrl!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
