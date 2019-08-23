//
//  MasterViewController.swift
//  RedditDemo
//
//  Created by Swati Chawla on 8/22/19.
//  Copyright © 2019 ABC. All rights reserved.
//

import UIKit

class RedditPostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postAuthorLabel: UILabel!
    @IBOutlet weak var postThumbnailImg: UIImageView!
}

class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var redditPostsArray = [RedditPostDetails]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPosts = [RedditPostDetails]()
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchFooter: SearchFooter!
    @IBOutlet weak var navigationBarTitle: UILabel!
    var currentRedditPostAfterTag = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        // Do any additional setup after loading the view, typically from a nib.
        navigationBarTitle.text = "Reddit Posts @" + getTodayString()
        parseJSON(urlString: "http://www.reddit.com/.json")
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Reddit Posts"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        // Setup the search footer
        tableView.tableFooterView = searchFooter
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if splitViewController!.isCollapsed {
            if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
            }
        }
        super.viewWillAppear(animated)
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                let post: RedditPostDetails
                if isFiltering() {
                    post = filteredPosts[indexPath.row]
                } else {
                    post = redditPostsArray[indexPath.row]
                }
                controller.detailItem = post
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            searchFooter.setIsFilteringToShow(filteredItemCount: filteredPosts.count, of: redditPostsArray.count)
            return filteredPosts.count
        }
        searchFooter.setNotFiltering()
        return redditPostsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RedditPostTableViewCell", for: indexPath) as! RedditPostTableViewCell
        cell.postThumbnailImg.layer.cornerRadius = cell.postThumbnailImg.frame.size.width / 2
        cell.postThumbnailImg.clipsToBounds = true
        let post : RedditPostDetails
        if isFiltering() {
            post = filteredPosts[indexPath.row]
        }
        else {
            post = redditPostsArray[indexPath.row]
        }

        cell.postTitleLabel?.text = post.title
        cell.postThumbnailImg?.image = post.thumbnail
        cell.postAuthorLabel?.text = post.authorName
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
    
    func parseJSON(urlString:String) {
        
        let url = URL(string: urlString)
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            
            guard error == nil else {
                print("returning error")
                return
            }
            
            guard let content = data else {
                print("not returning data")
                return
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                print("Not containing JSON")
                return
            }
            
            var img = UIImage(named:"se-icon")
            if let dict = json["data"] as? [String: Any] {
                self.currentRedditPostAfterTag = (dict["after"] as? String)!
                self.objects = dict["children"] as! [Any]
                for i in 0 ..< self.objects.count {
                    let object = self.objects[i] as? [String:Any]
                    let data = object!["data"] as? [String:Any]
                    let name = data!["author"] as? String
                    let title = data!["title"] as? String
                    let thumbnailURLStr = (data!["thumbnail"] as? String)
                    if !thumbnailURLStr!.isEmpty && thumbnailURLStr != "self"{
                        img = self.getImage(url: URL(string: thumbnailURLStr!)!)
                    }
                    else {
                        img = UIImage(named:"se-icon")
                    }
                    let redditPost = RedditPostDetails(authorName: name!, title: title!, thumbnail: img!)
                    self.redditPostsArray.append(redditPost)
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }

        }
        task.resume()
    }
    
    func getImage(url: URL) -> UIImage {
        var thumbnailImage = UIImage(named:"se-icon")
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.sync {
                        thumbnailImage = image
                    }
                }
        }
        return thumbnailImage!
    }
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredPosts = redditPostsArray.filter({( post : RedditPostDetails) -> Bool in
            return post.authorName.lowercased().contains(searchText.lowercased()) || post.title.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
    }
}

extension MasterViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension MasterViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let urlForFetchingNextPosts = "https://www.reddit.com/.json?after=" + currentRedditPostAfterTag
        parseJSON(urlString: urlForFetchingNextPosts)
    }
    
//    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
//        print("cancelPrefetchingForRowsAt \(indexPaths)")
//    }
}




