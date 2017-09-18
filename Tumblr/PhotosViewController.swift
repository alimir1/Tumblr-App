//
//  ViewController.swift
//  Tumblr
//
//  Created by Ali Mir on 9/13/17.
//  Copyright © 2017 com.AliMir. All rights reserved.
//

import UIKit
import AFNetworking

class PhotosViewController: UIViewController {
    
    var posts: [NSDictionary] = []
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        
        let tableFooterView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loadingView.startAnimating()
        loadingView.center = tableFooterView.center
        tableFooterView.addSubview(loadingView)
        self.tableView.tableFooterView = tableFooterView
        
        loadData()
    }
    
    func loadData() {
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        //print("responseDictionary: \(responseDictionary)")
                        
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        
                        // This is where you will store the returned array of posts in your posts property
                        self.posts = responseFieldDictionary["posts"] as! [NSDictionary]
                        self.tableView.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    }
                }
        });
        task.resume()
    }
    
    func loadMoreData() {
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        //print("responseDictionary: \(responseDictionary)")
                        
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        
                        // This is where you will store the returned array of posts in your posts property
                        
                        for post in responseFieldDictionary["posts"] as! [NSDictionary] {
                            self.posts.append(post)
                        }
                        
                        self.tableView.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                        
                    }
                }
        });
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postDetail" {
            let destinationCTRL = segue.destination as! DetailViewController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            
            
            let post = posts[indexPath.section]
            let caption = post["caption"] as? String
            
            
            
            if let htmlData = caption?.data(using: String.Encoding.unicode) {
                do {
                    let attributedText = try NSAttributedString(data: htmlData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                    
                    destinationCTRL.captionText = attributedText
                    
                    
                }catch let e as NSError {
                    print("Couldn't translate: \(e.localizedDescription) ")
                }
            }
            
            if let photos = post["photos"] as? [NSDictionary] {
                if ((photos[0]["original_size"] as? NSDictionary)?["url"] as? String) != nil {
                    if let postPhotos = post["photos"] as? [NSDictionary] {
                        let imagesDict = postPhotos[0]
                        let imageURLStr = (imagesDict["original_size"] as! NSDictionary)["url"] as! String
                        
                        destinationCTRL.imageURL = URL(string: imageURLStr)!
                        
                    }
                }
            }
            
            
        }
    }
}

extension PhotosViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        headerView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        let profileView = UIImageView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        profileView.clipsToBounds = true
        profileView.layer.cornerRadius = 15;
        profileView.layer.borderColor = UIColor(white: 0.7, alpha: 0.8).cgColor
        profileView.layer.borderWidth = 1;
        
        // set the avatar
        profileView.setImageWith(URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/avatar")!)
        headerView.addSubview(profileView)
        
        // Add a UILabel for the date here
        // Use the section number to get the right URL
        let date = posts[section]["date"] as! String
        let label = UILabel(frame: CGRect(x: 48, y: 10, width: headerView.frame.width - profileView.frame.width, height: 15))
        label.text = date
        headerView.addSubview(label)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(50)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.section]
        let summary = post["summary"] as? String
        if let photos = post["photos"] as? [NSDictionary] {
            if ((photos[0]["original_size"] as? NSDictionary)?["url"] as? String) != nil {
                if let postPhotos = post["photos"] as? [NSDictionary] {
                    let imagesDict = postPhotos[0]
                    let imageURLStr = (imagesDict["original_size"] as! NSDictionary)["url"] as! String
                    cell.summaryLabel?.text = summary
                    cell.summaryLabel?.sizeToFit()
                    cell.postsImageView?.setImageWith(URL(string: imageURLStr)!)
                }
            }
        }
        return cell
    }
}


