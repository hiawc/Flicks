//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Nhat Truong on 3/7/16.
//  Copyright © 2016 Nhat Truong. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    var movies:[NSDictionary]?
    var endpoint: String!
    var searchBar = UISearchBar()
    var cancelButtonBar:Bool = false
    let posterPath = "https://image.tmdb.org/t/p/original"
    let posterPathLowRes = "https://image.tmdb.org/t/p/w45"
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var toggleView: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        searchBar.delegate = self
        
        errorView.hidden = true
        collectionView.hidden = true
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        //collectionView.insertSubview(refreshControl, atIndex: 1)

        fetchMovie()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleView(sender: AnyObject) {
        if toggleView.selectedSegmentIndex == 0 {
            tableView.hidden = false
            collectionView.hidden = true
        }
        else {
            tableView.hidden = true
            collectionView.hidden = false
        }
    }
    
    @IBAction func searchButtonPressed(sender: AnyObject) {
        if cancelButtonBar == false {
            showSearchBar()
        }
        else{
            hideSearchBar()
        }
    }
   
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Set the number of items in your collection view.
        return 20
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        // Access
        let grid = collectionView.dequeueReusableCellWithReuseIdentifier("GridCollectionViewCell", forIndexPath: indexPath) as! GridCollectionViewCell
        // Do any custom modifications you your cell, referencing the outlets you defined in the Custom cell file.
        let movie = movies?[indexPath.item]
        grid.backgroundColor = UIColor.whiteColor()
        if let posterUrl = movie?["poster_path"] as? String {
            let url = NSURLRequest(URL: NSURL(string: posterPath + posterUrl)!)
            let urlLow = NSURLRequest(URL: NSURL(string: posterPathLowRes + posterUrl)!)
            grid.gridImage.setImageWithURLRequest(
                urlLow,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    if smallImageResponse == nil {
                        grid.gridImage.image = smallImage
                        grid.gridImage.setImageWithURLRequest(
                            url,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                if largeImageResponse == nil {
                                    grid.gridImage.image = largeImage
                                }
                                else {
                                    grid.gridImage.alpha = 0.0
                                    grid.gridImage.image = largeImage
                                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                                        grid.gridImage.alpha = 1.0
                                    })
                                }
                            },
                            failure: { (request, response, error) -> Void in
                                grid.gridImage.image = nil
                            })
                    }
                    else {
                        grid.gridImage.alpha = 0.0
                        grid.gridImage.image = smallImage
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            grid.gridImage.alpha = 1.0
                            }, completion: { (sucess) -> Void in
                                grid.gridImage.setImageWithURLRequest(
                                    url,
                                    placeholderImage: smallImage,
                                    success: { (largeImageRequest, largeImageResponse, largeImage) ->   Void in
                                        grid.gridImage.image = largeImage
                                    },
                                    failure: { (request, response, error) -> Void in
                                        grid.gridImage.image = nil
                                })
                        })
                    }
                },
                failure: { (request, response, error) -> Void in
                    grid.gridImage.image = nil
            })
        }
        else {
            grid.gridImage.image = nil
        }
        return grid
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        return 1
    }

    
    func showSearchBar() {
        self.searchBar.alpha = 0
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        navigationItem.titleView = searchBar
        searchBarButtonItem.image = nil
        searchBarButtonItem.title = "Cancel"
        UIView.animateWithDuration(0.5, animations: {
            self.searchBar.alpha = 1
            }, completion: { finished in
                self.searchBar.becomeFirstResponder()
        })
        cancelButtonBar = true
    }
    
    func hideSearchBar() {
        navigationItem.titleView = nil
        searchBarButtonItem.title = nil
        searchBarButtonItem.image = UIImage(named: "search")
        UIView.animateWithDuration(0.3, animations: {
            
            }, completion: { finished in
                
        })
        cancelButtonBar = false
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchMovie()
        refreshControl.endRefreshing()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return movies?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0/255.0, green: 139/255.0, blue: 232/255.0, alpha: 1.0)
        cell.selectedBackgroundView = backgroundView
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        if let posterUrl = movie["poster_path"] as? String {
            let url = NSURLRequest(URL: NSURL(string: posterPath + posterUrl)!)
            let urlLow = NSURLRequest(URL: NSURL(string: posterPathLowRes + posterUrl)!)
            cell.posterView.setImageWithURLRequest(
                urlLow,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
            
                    if smallImageResponse == nil {
                        cell.posterView.image = smallImage
                        cell.posterView.setImageWithURLRequest(
                            url,
                            placeholderImage: smallImage,
                            success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                if largeImageResponse == nil {
                                    cell.posterView.image = largeImage
                                }
                                else {
                                    cell.posterView.alpha = 0.0
                                    cell.posterView.image = largeImage
                                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                                        cell.posterView.alpha = 1.0
                                    })
                                }
                            },
                            failure: { (request, response, error) -> Void in
                                cell.posterView.image = nil
                            })
                    }
                    else {
                        cell.posterView.alpha = 0.0
                        cell.posterView.image = smallImage
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            cell.posterView.alpha = 1.0
                            }, completion: { (sucess) -> Void in
                                cell.posterView.setImageWithURLRequest(
                                    url,
                                    placeholderImage: smallImage,
                                    success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                        cell.posterView.image = largeImage
                                    },
                                    failure: { (request, response, error) -> Void in
                                        cell.posterView.image = nil
                                })
                        })
                    }
                },
                failure: { (request, response, error) -> Void in
                    cell.posterView.image = nil
            })
        }
        else {
            cell.posterView.image = nil
        }
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        return cell
    }
    
    func fetchMovie(){
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        

        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let requestError = error{
                    self.errorView.hidden = false
                }
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                    if let data = dataOrNil{
                        if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.errorView.hidden = true
                            self.tableView.reloadData()
                            self.collectionView.reloadData()
                        }
                    }
        })
        task.resume()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if toggleView.selectedSegmentIndex == 0 {
            
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)
            let vc = segue.destinationViewController as! MovieDetailsViewController
            tableView.deselectRowAtIndexPath(indexPath!, animated: true)
            let movie = movies![indexPath!.row]
            vc.movie = movie
        }
        else {
            let indexPath = collectionView.indexPathForCell(sender as! UICollectionViewCell)
            let vc = segue.destinationViewController as! MovieDetailsViewController
            collectionView.deselectItemAtIndexPath(indexPath!, animated: true)
            let movie = movies![indexPath!.item]
            vc.movie = movie
        }
    }
}

