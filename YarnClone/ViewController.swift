//  ViewController.swift
//  YarnClone
//  Created by Ольга Клюшкина on 22.08.17.
//  Copyright © 2017 klyushkina. All rights reserved.

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let emptyDict = [String: Any]()
    var storiesInfoDictionary = [[String: Any]]()
    var sortedStoryDictionary = [[String: Any]]()
    var imageURLArray = [String]()
    var storyImagesArray = [UIImage]()
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var loadingView = UIView()
    var navigationBar = UINavigationBar()
    var myIndex = 0
    var urlsToFullStories = [String?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: add the functionality of changing progress bar state depending on how many messages are shown now on the Story Screen for this story
        
        //TODO: add the functionality of getting info if it's ONLINE or OFFLINE (Reachability)
        
        self.view.addSubview(loadingView)
        startShowingActivityIndicator()
        createLoadingView()
        createNavigationBar()
        getStoriesListAndUpdateUI()
    }
    
    // Create a navigation item with a YARN title
    func createNavigationBar() {
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:44))
        navigationBar.isTranslucent = true
        let navigationItem = UINavigationItem(title: "YARN")
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "AvenirNextCondensed-DemiBold", size: 24) as Any]
        navigationBar.setItems([navigationItem], animated: false)
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        navigationBar.backgroundColor = UIColor.clear
        self.view.addSubview(navigationBar)
    }
    
    //creating the view which will be shown while data is being loaded
    func createLoadingView() {
        loadingView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        // using a custom darkBlue color, created in the Extension (see at the bottom)
        loadingView.backgroundColor = .darkBlue
        loadingView.alpha = 1
        loadingView.tag = 100
        loadingView.isUserInteractionEnabled = true
    }
    
    func getStoriesListAndUpdateUI() {
        DispatchQueue.global(qos: .background).async {
            // in the background we are loading the data about the stories
            guard let url = Constants().urlToStories
                else { return }
            
            Alamofire.request(url).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print (error)
                case .success(let value):
                    self.startShowingActivityIndicator()
                    let json = JSON(value)
                    //putting the stories names into array to get the information about total number of stories
                    var storyNames = [String]()
                    var i = 0
                    while let storyName = json[i]["storyName"].string, let storyImage = json[i]["coverImageUrl"].string {
                        self.imageURLArray.append(Constants().prefix + storyImage)
                        storyNames.append(storyName)
                        if let urlToFullStory = json[i]["url"].string {
                            //putting all the urls to stories
                            self.urlsToFullStories.append(urlToFullStory)
                        }
                        i += 1
                    }
                    
                    //preparing to convert later the date from string to date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = Constants().monthDayYear
                    
                    for i in 0..<storyNames.count {
                        self.storiesInfoDictionary.append(self.emptyDict)
                        self.storiesInfoDictionary[i]["storyName"] = json[i]["storyName"].string
                        self.storiesInfoDictionary[i]["storyAuthorName"] = json[i]["storyAuthorName"].string
                        self.storiesInfoDictionary[i]["shortDescription"] = json[i]["shortDescription"].string
                        //self.storiesInfoDictionary[i]["coverImageURL"] = Constants().prefix + json[i]["coverImageUrl"].string
                        
                        //putting the converted date into the dictionary
                        if let date = json[i]["date"].string {
                            self.storiesInfoDictionary[i]["date"] = dateFormatter.date(from: date)
                        }
                        self.storiesInfoDictionary[i]["url"] = json[i]["url"].string
                    }
                }
                //sorting the dicionaries in array by date
                self.sortedStoryDictionary =  self.storiesInfoDictionary.sorted { (dict1, dict2) in
                    if let date1 = dict1.keys.first,
                        let date2 = dict2.keys.first {
                        return date1.compare(date2) == ComparisonResult.orderedAscending
                    }
                    return false
                }
                //print ("STORIES INFORMATION: \(self.storiesInfoDictionary)")
                DispatchQueue.main.async {
                    // removing the loading view and updating UI
                    self.tableView.reloadData()
                    
                    //TODO: (!!!!!) show activity indicator only while loading data, without hardcoded time
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.endShowingActivityIdicator()
                        self.loadingView.removeFromSuperview()
                    }
                }
            }
        }
    }
    //func for starting showing activity indicator while loading something
    func startShowingActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    //func for stopping showing activity indictor at the end of loading process
    func endShowingActivityIdicator() {
        activityIndicator.stopAnimating()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedStoryDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //create the cell
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        
        //getting the data for Story Name label
        if self.sortedStoryDictionary.count > 0 {
            for _ in 0..<self.sortedStoryDictionary.count {
                cell?.storyName.text = self.sortedStoryDictionary[indexPath.row]["storyName"] as? String
                cell?.shortDescription.text = self.sortedStoryDictionary[indexPath.row]["shortDescription"] as? String
            }
        }
        
        //getting the picture for each story
        if let cell = cell {
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.sd_setImage(with: URL(string: imageURLArray[indexPath.row]))
            print ("The deal with images is done!")
        }
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segue" {
            let DestViewController: StoryScreen = segue.destination as! StoryScreen
            DestViewController.storyNameLabelText = sortedStoryDictionary[myIndex]["storyName"] as! String
            DestViewController.allUrlsToFullStories = urlsToFullStories as! [String]
            DestViewController.index = myIndex
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        performSegue(withIdentifier: "segue", sender: self)
    }
}

//adding custom colors for the app UI
extension UIColor {
    static let darkBlue = UIColor(red: 16, green: 7, blue: 55)
    static let darkGray = UIColor(red: 68, green: 65, blue: 65)
    static let pinkForBackground = UIColor(red: 245, green: 234, blue: 239)
    static let pinkForTitle = UIColor(red: 255, green: 102, blue: 178)
    static let blueForBackground = UIColor(red: 204, green: 229, blue: 255)
    static let blueForTitle = UIColor(red: 0, green: 128, blue: 255)
    
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red)/255,
            green: CGFloat(green)/255,
            blue: CGFloat(blue)/255,
            alpha: a
        )
    }
}
