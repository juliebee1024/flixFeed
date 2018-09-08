//
//  MoviesViewController.swift
//  flixFeed
//
//  Created by Julie Bao on 9/6/18.
//  Copyright © 2018 Julie Bao. All rights reserved.
//

import UIKit
import AlamofireImage

class MoviesViewController: UIViewController, UITableViewDataSource
{


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var movies:[[String: Any]] = []; //Empty array of type string
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.didPullToRefresh(_:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self; //get data from this view controller
        fetchMovies() //Network Request
        didPullToRefresh(refreshControl)

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl)
    {
        fetchMovies()
    }
    
    func fetchMovies()
    {
        // Start the activity indicator
        activityIndicator.startAnimating()
        
        //Network Request Snippet given by Assignment on Codepath
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                print(dataDictionary);
                // TODO: Get the array of movies
                let movies = dataDictionary["results"] as! [[String: Any]] //Array!
                
                // TODO: Store the movies in a property to use elsewhere
                self.movies = movies; //not local var movies = local var movies
                self.tableView.reloadData();
                self.refreshControl.endRefreshing();
                self.activityIndicator.stopAnimating()
                //print(title);
            }
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        //return 10; //10 rows -> row 0 to row 9
        return movies.count;
    }
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //Table View Cell reuse identifier is "MovieCell", set in the storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell;
        //cell.textLabel!.text = "row \(indexPath.row)"; //the label used for the main textual content of the table cell.the current text that is displayed by the label -> displays row # within each cell through indexPath.row
        let movie = movies[indexPath.row];
        let title = movie["title"] as! String;
        let overview = movie["overview"] as! String;
        
        cell.titleLabel.text = title;
        cell.overviewLabel.text = overview;
        cell.overviewLabel.sizeToFit(); //moves text to the top
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.posterImageView.af_setImage(withURL: posterURL)
        
        //print("row \(indexPath.row)"); //displays row # on console
        tableView.rowHeight = 300
        
        return cell;
    }
}
