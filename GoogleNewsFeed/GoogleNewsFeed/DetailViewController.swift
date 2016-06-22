//
//  DetailViewController.swift
//  GoogleNewsFeed
//
//  Created by Harish Vitta on 31/5/16.
//  Copyright © 2016 Harish Vitta. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UITableViewController{

    var article: Article?
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //setup row height
        self.tableView.estimatedRowHeight = 96
        self.tableView.rowHeight = self.tableView.estimatedRowHeight 
        
        //Estimate the height of webview footer
        // height= height of table view - height of header cell (only cell) - navigation bar height - status bar height
        let webViewHeight = self.tableView.frame.size.height - self.tableView.rowHeight - (self.navigationController?.navigationBar.frame.size.height)! - UIApplication.sharedApplication().statusBarFrame.height
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: webViewHeight))
        webView.loadRequest(NSURLRequest(URL: NSURL(string: (self.article?.articleURL)!)!))
        
        //set delegate to self
        webView.navigationDelegate = self
        
//        let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: webViewHeight))
//        
//        webView.loadRequest(NSURLRequest(URL: NSURL(string: (self.article?.articleURL)!)!))
//        
//        webView.delegate = self
        
        //set Webview to tableview footer
        self.tableView.tableFooterView = webView
        
        //setup Activity Indicator for web view loading
        self.activityIndicator.center = self.view.center
        self.activityIndicator.color = UIColor.blackColor()
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubviewToFront(self.activityIndicator)
        self.activityIndicator.startAnimating()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "DetailViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! DetailTableViewControllerCell
        
        cell.articleTitleLabel?.text = self.article?.articleTitle
        
        if let imageObj = self.article?.image {
            if let image: UIImage = imageObj as? UIImage {
                cell.articleImageView?.image = image
            }
        } else {
            cell.articleImageView?.image = UIImage(named: "image_placeholder")
        }
        
        return cell
    }

    deinit{
        print("Detail View :: Deinilitization")
        webView = nil
        //self.article = nil
    }

}

//MARK: WKWebView Extension

extension DetailViewController : WKNavigationDelegate{
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        //stop activity indicator and hide it
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        var errorMessage : String?
        
        switch error.code{
        case NSURLErrorNotConnectedToInternet:
            errorMessage = Constants.kNetworkFailureMessage
        default:
            errorMessage = Constants.kUnknownErrorMessage
            }
        self.alertUserWithTitleAndMessage("Error", message: errorMessage)
        //stop activity indicator and hide it
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
    }
    @IBAction func shareButton(sender: UIBarButtonItem) {
        
        let textToShare = ""
        
        let newsFeedURL = NSURL(string: (self.article?.articleURL)!)
        
        
        let activityController = UIActivityViewController(activityItems: [textToShare, newsFeedURL!], applicationActivities: nil)
//        activityController.completionWithItemsHandler = {
//            (activity, success, items, error) in
//            print("Activity: \(activity), status: \(success), items: \(items), error: \(error)")
//        }
        
        activityController.excludedActivityTypes = [UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypeAddToReadingList]
        
        
        navigationController?.presentViewController(activityController, animated: true, completion: nil)
        
    }
    
}


extension DetailViewController: UIWebViewDelegate{
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        return true;
        
    }
    func webViewDidStartLoad(webView: UIWebView){
        print("Started Loading")
    }
    func webViewDidFinishLoad(webView: UIWebView){
        print("Finished Loading")
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        print("Error")
    }
    
    

    
}