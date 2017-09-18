//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by ruthie_berman on 9/12/17.
//  Copyright © 2017 ruthie_berman. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var alertView: UIView!
  @IBOutlet weak var warningIcon: UIImageView!
  
  var movies: [[String: Any]] = [[String: Any]]()
  var filteredMovies: [[String: Any]] = [[String: Any]]()
  var endpoint: String = ""

  private var isSearching = false
  private let backgroundColor = UIColor.init(red: 0.82, green: 0.77, blue: 0.95, alpha: 1.0)

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self
    searchBar.delegate = self
    searchBar.returnKeyType = UIReturnKeyType.done
    searchBar.barTintColor = backgroundColor
    navigationController?.navigationBar.barTintColor = backgroundColor
    tabBarController?.tabBar.barTintColor = backgroundColor

    self.tableView.backgroundColor = backgroundColor
    alertView.isHidden = true
    warningIcon.image = UIImage(named: "warning-icon")

    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
    tableView.insertSubview(refreshControl, at: 0)

    loadDataFromNetwork()
  }

  func refreshControlAction(_ refreshControl: UIRefreshControl) {
    self.alertView.isHidden = true
    loadDataFromNetwork()
    refreshControl.endRefreshing()
  }

  func loadDataFromNetwork() {
    let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")
    var request = URLRequest(url: url!)
    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    let session = URLSession(
      configuration: URLSessionConfiguration.default,
      delegate:nil,
      delegateQueue:OperationQueue.main
    )

    MBProgressHUD.showAdded(to: self.view, animated: true)
    let task : URLSessionDataTask = session.dataTask(with: request, completionHandler:
    { (dataOrNil, response, error) in
      MBProgressHUD.hide(for: self.view, animated: true)
      if let data = dataOrNil {
        let dictionary = try! JSONSerialization.jsonObject( with: data, options: []) as! [String: Any]
        self.movies = dictionary["results"] as! [[String: Any]]
        self.tableView.reloadData()
      } else {
        self.alertView.isHidden = false
      }
    });
    task.resume()
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isSearching {
      return filteredMovies.count
    }
    return movies.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
    cell.backgroundColor = UIColor.clear
    cell.selectionStyle = .none
    var movie = [String: Any]()
    if isSearching {
      movie = filteredMovies[indexPath.row]
    } else {
      movie = movies[indexPath.row]
    }
    let title = movie["title"] as? String
    let synopsis = movie["overview"] as? String
    var posterUrl: URL!
    if let path = movie["poster_path"] as? String {
      let baseUrl = "http://image.tmdb.org/t/p/w500"
      posterUrl = URL(string: baseUrl + path)
    }

    cell.movieTitleLabel.text = title
    cell.synopsisLabel.text = synopsis
    let posterRequest = URLRequest(url: posterUrl as URL)
    cell.posterView.setImageWith(
      posterRequest,
      placeholderImage: nil,
      success: { (imageRequest, imageResponse, image) -> Void in
        if imageResponse != nil {
          cell.posterView.alpha = 0.0
          cell.posterView.image = image
          UIView.animate(withDuration: 0.3, animations: { () -> Void in
            cell.posterView.alpha = 1.0
          })
        } else {
          cell.posterView.image = image
        }
      },
      failure: { (imageRequest, imageResponse, error) -> Void in
        cell.posterView.image = UIImage(named: "camera-icon")
      })
    cell.posterView.setImageWith(posterUrl)

    return cell
  }

  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchBar.text == nil || searchBar.text == "" {
      isSearching = false
      view.endEditing(true)
    } else {
      isSearching = true
      filteredMovies = movies.filter({($0["title"] as! String).lowercased().range(of:(searchBar.text?.lowercased())!) != nil})
    }
    tableView.reloadData()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    let cell = sender as! UITableViewCell
    let indexPath = tableView.indexPath(for: cell)
    let movie = isSearching ? filteredMovies[indexPath!.row] : movies[indexPath!.row]

    let detailsViewController = segue.destination as! DetailsViewController
    detailsViewController.movie = movie as NSDictionary
  }
  
  
}
