//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Nhat Truong on 3/10/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var movieRating: UILabel!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pushPoster: UIImageView!
    var movie : NSDictionary!
    let posterPath = "https://image.tmdb.org/t/p/original"
    let posterPathLowRes = "https://image.tmdb.org/t/p/w45"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, detailsView.frame.origin.y + detailsView.frame.size.height)
        let title = movie["title"] as! String
        titleLabel.text = title
        navigationItem.title = title
        titleLabel.sizeToFit()
        
        let date = movie["release_date"] as! String
        releaseDate.text = "Release date: \(date)"
        releaseDate.sizeToFit()
        
        let rating = movie["vote_average"] as! Float
        movieRating.text = String("Rating " + String(rating))
        movieRating.sizeToFit()
        
        let overview = movie["overview"] as! String
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        if let posterUrl = movie["poster_path"] as? String {
            let url = NSURLRequest(URL: NSURL(string: posterPath + posterUrl)!)
            let urlLow = NSURLRequest(URL: NSURL(string: posterPathLowRes + posterUrl)!)
            pushPoster.setImageWithURLRequest(
                urlLow,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                        self.pushPoster.image = smallImage
                        self.pushPoster.setImageWithURLRequest(
                            url,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                self.pushPoster.alpha = 0.0
                                self.pushPoster.image = largeImage
                                UIView.animateWithDuration(0.5, animations: { () -> Void in
                                    self.pushPoster.alpha = 1.0
                                })
                            },
                            failure: { (request, response, error) -> Void in
                                self.pushPoster.image = nil
                        })
                },
                failure: { (request, response, error) -> Void in
                    self.pushPoster.image = nil
            })
        }
        else {
            pushPoster.image = nil
        }


                        
        // Do any additional setup after loading the view.
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
