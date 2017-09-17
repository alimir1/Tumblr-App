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
        tableView.refreshControl?.addTarget(self, action: #selector(fetchData), for: .valueChanged)
        
        fetchData()
    }
    
    func fetchData() {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postDetail" {
            let destinationCTRL = segue.destination as! DetailViewController
            let indexPath = tableView.indexPath(for: sender as! UITableViewCell)!
            
            
            let post = posts[indexPath.row]
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
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photoCell", for: indexPath) as! PhotoCell
        let post = posts[indexPath.row]
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







