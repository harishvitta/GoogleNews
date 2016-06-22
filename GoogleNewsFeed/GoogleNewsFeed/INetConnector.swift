//
//  INetConnector.swift
//  GoogleNewsFeed
//
//  Created by Harish Vitta on 3/6/16.
//  Copyright © 2016 Harish Vitta. All rights reserved.
//

import UIKit

enum Error : ErrorType{
    case INetError
    case ParseError
    case UnknownError
    
    var errorDesc : String{
        switch self{
        case .INetError:
                return "No Internet Connectivity"
        case .ParseError:
                return "Error occured while parsing XML"
        case .UnknownError:
                return "Unknown Error"
        }
    }
}

class INetConnector : NSObject {
    

    let session = NSURLSession.sharedSession()
    
    let url = NSURL(string: Constants.kGoogleNewsURL)
    
    //MARK: Methods
    // I am using completion blocks to handle data where the requested is initiated
    func getArticlesWithCompletion(completion: (data : AnyObject?, error : ErrorType?) -> Void)
    {
        let dataTask = session.dataTaskWithURL(url!)
        {
            data , response , error in
            
            if ((response as? NSHTTPURLResponse)?.statusCode == Constants.kHTTPSuccessStatusCode) && (error == nil) && (data != nil)
            {
                //Valid data with no error
                completion(data: data, error: error)
            }
            else{
                if error != nil
                {
                    if let errorCode = error?.code
                    {
                        switch errorCode {
                        case NSURLErrorNotConnectedToInternet:
                            completion(data: nil, error: Error.INetError)
                        default:
                            completion(data: nil, error: Error.UnknownError)
                        }
                    }
                }
                else{
                    completion(data: nil, error: Error.UnknownError)
                }
            }
        }
        dataTask.resume()
    }
    
    // This method takes in an NSData object and runs it through my parser class to parse the XML
    // It returns an array of ArticlePrototype structs (the prototype object used to create my Article NSManagedObject, and/or a ParsingError
    func parseAllArticleData(data: NSData, completion: (content: [ArticlePrototype]?, error: ErrorType?) -> Void){
        
        let parser = XMLParser(data: data)
        
        parser.parseDataWithCompletion{ (success) -> Void in
            if success{
                //try coredata
                CoreDataManager().fetchRecords(parser.articleList)
                completion(content: parser.articleList, error: nil)
            }
            else{
                completion(content: nil, error: Error.ParseError)
            }
        }
    }
    
    // This method takes in an array of ArticlePrototype objects, fetches the image for each object, and returns are new array of ArticlePrototype objects with image properties
    
    func downloadImagesForArticles(articles: [ArticlePrototype], completion: (articles: [ArticlePrototype]) -> Void){
        if articles.isEmpty {
            completion(articles: articles)
        }
        var articlesWithImages = [ArticlePrototype]()
        
        var index = 0
        
        
        for var article in articles {
            self.fetchImageFromURL(article.imageURL, completion: {
                (image) -> Void in
                article.image = image
                articlesWithImages.append(article)
                index = index + 1
                
                if index == articles.count
                {
                    completion(articles: articlesWithImages)
                }
            })
            
        }
    }
    
    // This method is used internally by downloadImagesForArticles
    // It performs the web request to fetch the data associated with an image URL, and return a UIIimage
    func fetchImageFromURL(url: String, completion:(image: UIImage?) -> Void) {
        let req = NSURLRequest(URL: NSURL(string: url)!)
        
        session.dataTaskWithRequest(req){
            (data,response,error) -> Void in
            if data != nil {
                
                if let unwrappedData = data as NSData! {
                    completion(image: UIImage(data: unwrappedData))
                }
            } else {
                completion(image: nil)
            }
            }.resume()
        }
    

}

