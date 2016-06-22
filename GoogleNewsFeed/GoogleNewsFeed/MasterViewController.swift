//
//  MasterViewController.swift
//  GoogleNewsFeed
//
//  Created by Harish Vitta on 31/5/16.
//  Copyright © 2016 Harish Vitta. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController{
    
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    
    // Set up an NSFetchedResultsController to fetch articles
    
    lazy var fetchedResultsController : NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest(entityName: "Article")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "articleDate", ascending: false)]
        
        let fetchResults = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResults
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        do{
            try self.fetchedResultsController.performFetch()
            
            self.tableView.reloadData()
        }catch{
            print("Error performing initial fetch : \(error)")
        }
        
        self.reloadTableWithArticles()
        
        
        
    }
    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadTableWithArticles() {
        //Download new feeds
        INetConnector().getArticlesWithCompletion{(data , error) -> Void in
            if error != nil {
                if let networkError = error as? Error{
                    switch networkError
                    {
                    case .INetError:
                        self.alertUserWithTitleAndMessage("Network Error", message: Constants.kNetworkFailureMessage)
                        return
                    default:
                        self.alertUserWithTitleAndMessage("Unknown Error", message: Constants.kUnknownErrorMessage)
                        return
                    }
                }
            }
            
            if let unwrappedData = data as? NSData {
                
                INetConnector().parseAllArticleData(unwrappedData, completion: {(content , error) -> Void in
                    
                    if error == nil
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            do {
                                try self.fetchedResultsController.performFetch()
                                if self.fetchedResultsController.fetchedObjects?.count > 0{
                                    self.tableView.reloadData()
                                }else{
                                    CoreDataManager().fetchRecords(content!)
                                    try self.fetchedResultsController.performFetch()
                                    self.tableView.reloadData()
                                }
                            }catch{
                                print("Error : \(error)")
                            }
                            
                        })
                    }else{
                        if let networkError = error as? Error{
                            switch networkError{
                            case .ParseError:
                                self.alertUserWithTitleAndMessage("Network Error", message: Constants.kParsingErrorMessage)
                                return
                            default:
                                self.alertUserWithTitleAndMessage("Unknown Error", message: Constants.kUnknownErrorMessage)
                            }
                        }
                    }
                })
                
            }
        }
    }
    // MARK: - Table View
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let results = self.fetchedResultsController.fetchedObjects?.count{
            if results == 0{
                startAnimation()
            }else{ stopAnimation()}
            return results
        }
        
        return 0
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ArticleCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MasterTableViewCell
        
        if let dataSource = self.fetchedResultsController.fetchedObjects as? [Article] {
            cell.articleTitleLabel?.text = dataSource[indexPath.row].articleTitle
            cell.articleDescriptionLabel?.text = dataSource[indexPath.row].articleDescription
            if let cellImage : UIImage = dataSource[indexPath.row].image as? UIImage{
                cell.imageView?.image = cellImage
            }else{
                cell.imageView?.image = UIImage(named: "image_placeholder")
            }
        }
        
        
        return cell
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                if let dataSource = self.fetchedResultsController.fetchedObjects as? [Article]{
                    controller.article = dataSource[indexPath.row]
                    
                }
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        
    }
    
    func startAnimation()
    {
        //setup Activity Indicator for web view loading
        self.activityIndicator.center = self.view.center
        self.activityIndicator.color = UIColor.blackColor()
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    func stopAnimation()
    {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
    }
    
    deinit {
        print("Master View:: Deinilitization")
        
    }
}

