//
//  DetailsViewController.swift
//  MovieViewer
//
//  Created by ruthie_berman on 9/13/17.
//  Copyright © 2017 ruthie_berman. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var navBar: UINavigationItem!

  var movie: NSDictionary!

  override func viewDidLoad() {
    super.viewDidLoad()

    scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)

    let title = movie["title"] as? String
    titleLabel.text = title
    navBar.title = title

    let overview = movie["overview"] as? String
    overviewLabel.text = overview
    overviewLabel.sizeToFit()

    var posterUrl: URL!
    if let path = movie["poster_path"] as? String {
      let baseUrl = "http://image.tmdb.org/t/p/w500"
      posterUrl = URL(string: baseUrl + path)
      posterImageView.setImageWith(posterUrl)
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */

}
