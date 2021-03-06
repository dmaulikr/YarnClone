//
//  StoryScreen.swift
//  YarnClone
//
//  Created by Ольга Клюшкина on 24.08.17.
//  Copyright © 2017 klyushkina. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class StoryScreen: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var navigationBar = UINavigationBar()
    var navStoryNameItem = UIBarButtonItem()
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var allUrlsToFullStories = [String]()
    var storyNameLabelText = String()
    var index = 0
    var label = UILabel()
    var messagesForOneStory = [Any]()
    let tableView = UITableView()
    var allStoryMessages = [String: [Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTableView()
        createTapGestureRecognizer()
        createNavigationBar()
        getStoryMessagesAndUpdateUI()
    }
    
    func createTableView() {
        //registering the custom cell for our tableView (see the cell class at tht bottom of this file)
        tableView.register(MyCell.self, forCellReuseIdentifier: "cellId")
        
        //customizing our tableView
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        tableView.frame = CGRect(x: 0, y: 50, width: screenWidth, height: screenHeight - 55)
        tableView.separatorColor = .white
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //creating a tapping gesture recognizer to add then a new cell with message after a tap on the Story Screen
    func createTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappingStoryScreen))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //programmatically creating a custom navigation bar
    func createNavigationBar() {
        navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height:44))
        navigationBar.backgroundColor = .white
        navigationBar.isTranslucent = false
        self.view.addSubview(navigationBar)
        
        let navigationItem = UINavigationItem()
        
        //creating the item on navbar with story name, passed from the screen with stories list
        let labelWidth: CGFloat = navigationBar.frame.width / 3
        let frame = CGRect(x: 0, y: 0, width: labelWidth, height: navigationBar.frame.height)
        label = UILabel(frame: frame)
        label.textAlignment = .left
        label.textColor = .darkGray //using our custom color, created in the UIColor Extension (see the bottom of ViewController file)
        label.text = storyNameLabelText
        label.font = UIFont(name: "Avenir-Book", size: 13)
        navStoryNameItem = UIBarButtonItem(customView: label)
        navigationItem.leftBarButtonItem = navStoryNameItem
        navigationBar.setItems([navigationItem], animated: false)
        
        //creating custom close button
        let button =  UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: navigationBar.frame.height)
        button.setImage(UIImage(named: "CloseButton"), for: .normal)
        button.addTarget(self, action: #selector(closingTheStoryScreen), for: .touchUpInside)
        let navBarButtonClose = UIBarButtonItem(customView: button)
        navigationItem.rightBarButtonItem = navBarButtonClose
        
        //adding the custom tableView to the StoryScreen view
        self.view.addSubview(tableView)
    }
    
    //func for starting showing activity indicator while loading something
    func startShowingActivityIndicator() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
    }
    //func for stopping showing activity indictor at the end of loading process
    func endShowingActivityIdicator() {
        activityIndicator.stopAnimating()
    }
    
    func getStoryMessagesAndUpdateUI() {
        startShowingActivityIndicator()
        DispatchQueue.global(qos: .background).async {
            let url = self.allUrlsToFullStories[self.index]
            print("json request sent")
            Alamofire.request(url).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print (error)
                case .success(let value):
                    print ("INDEX - \(self.index)")
                    let json = JSON(value)
                    if let story = json["messages"].array {
                        self.messagesForOneStory.append(story)
                        
                        self.allStoryMessages[url] = self.messagesForOneStory
                        print ("Dictionary with messages for the story \(url) - \(self.allStoryMessages)")
                    }
                }
                self.messagesForOneStory.removeAll()
                //updating the UI, putting the data into the tableView cells
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.endShowingActivityIdicator()
                    
                    //TODO: add the message "Tap anywhere to continue reading" to the bottom of the screen after showing the first message of the story. After first tap it should hide
                    
                    //TODO: Caching the messages, which have already been shown
                }
            }
        }
        
        
        //TODO: add the functionality of adding a new cell with message after tapping the screen
        
        //TODO: add the functionality of showing the image of next story if all the messages for curent story are already shown
    }
    
    //func for closing the StoryScreen viewcontroller after tapping the close X button
    @objc func closingTheStoryScreen() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tappingStoryScreen(recognizer: UITapGestureRecognizer) {
        print ("I WAS TAPPED!")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStoryMessages.count
    }
    
    //TODO: improve the logic of cell's height depending on the text of message
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = CGFloat()
        height = 120
        
        return height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! MyCell
        let url = allUrlsToFullStories[index]
        
        if allStoryMessages[url] != nil {
            let bundleOfMessagesForExactStory = allStoryMessages[url] as! [[JSON]]
            
            if let textMessage =  bundleOfMessagesForExactStory[0][indexPath.row]["message"].string {
                cell.messageLabel.text = textMessage
            }
            if let senderName =  bundleOfMessagesForExactStory[0][indexPath.row]["author"].string {
                cell.senderNameLabel.text = senderName
            }
        }
        return cell
    }
}

//create a cell for tableView
class MyCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder) has not been implemented")
    }
    
    //TODO: add the logic of making the label width smaller if the text is short
    
    let senderNameLabel: UILabel = {
        let label = UILabel()
        //TODO: to create the logic for setting different colors for messages depending on author
        label.text = ""//senderName
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = UIColor.pinkForBackground
        label.font = UIFont(name: "Avenir-Book", size: 14)
        label.textColor = UIColor.pinkForTitle
        return label
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        //TODO: to create the logic for setting different colors for messages depending on author
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.numberOfLines = 5
        label.backgroundColor = UIColor.pinkForBackground
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""//message
        label.font = UIFont(name: "Avenir-Medium", size: 16)
        return label
    }()
    
    func setUpViews() {
        addSubview(senderNameLabel)
        addSubview(messageLabel)
        
        //setting the positions for Author name label and message label in the tableView cell
        //ISSUE: fix the UI to prevent overlapping the labels
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[v0]-10-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": senderNameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]-20-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": senderNameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[v0]-10-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": messageLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-55-[v0]-20-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": messageLabel]))
    }
}

