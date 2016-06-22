//
//  XMLParser.swift
//  GoogleNewsFeed
//
//  Created by Harish Vitta on 31/5/16.
//  Copyright © 2016 Harish Vitta. All rights reserved.
//

import Foundation
import UIKit

//Creating a prototype used to store data

struct ArticlePrototype{
    var title: String!
    var description: String!
    var imageURL: String!
    var image: UIImage?
    var articleURL: String!
    var articleDate : NSDate!
}

class XMLParser: NSObject{
    
    var articleParser : NSXMLParser!
    //MARK: properties
    //will create prototype objects using this properties
    var articleList = [ArticlePrototype]()
    var articleTitle : String = ""
    var articleDescription : String = ""
    var articleImageURL : String = ""
    var articleURL : String = ""
    var articleDate = ""
    
    var element : String?
    
    //Convenience initializers are secondary, supporting initializers for a class. You can define a convenience initializer to call a designated initializer from the same class as the convenience initializer with some of the designated initializer’s parameters set to default values.
    
    //MARK: Initilizations
    convenience init(data : NSData)
    {
        self.init()
        
        self.articleParser = NSXMLParser(data: data)
        self.articleParser.delegate = self
    }
    
    // This method allows the INetManager class to inerface with the XML parser used by this parsing class, without accessing it directly
    // On sucessful parsing, it also invokes the image downloading method
    func parseDataWithCompletion(completion: (success: Bool) -> Void) {
        
        if self.articleParser.parse(){
            // called to start the event-driven parse. Returns YES in the event of a successful parse, and NO in case of error.
            // If parsing is successful , download images
            INetConnector().downloadImagesForArticles(self.articleList, completion: {
                (articlesWithImages) -> Void in
                self.articleList = articlesWithImages
                completion(success: true)
            })
            
        }
        else{
            completion(success: false)
        }
    }
        
    // MARK: Parser Helper Methods
    
    // This method uses Regular Expressions to convert HTML to HTML less string
    func stringFromHTML(input: String) -> String {
        
        //We need to write Regular Expression to traverse string 
        
        var htmlLessString = ""

        do{
            let regex = try NSRegularExpression(pattern: Constants.kHTMLRegEx, options: .CaseInsensitive)
            
            htmlLessString = regex.stringByReplacingMatchesInString(input, options: .ReportCompletion, range: NSMakeRange(0,input.characters.count), withTemplate: "")
            
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        return htmlLessString
    }
    
    // Image URL is part of description HTML message, below method returns Image URL
    func getImageLinkFromImgTag(input:String) -> String {
        
        //First we need to get image tag
        do{
            let regex = try NSRegularExpression(pattern: Constants.kImageTagRegEx, options: .CaseInsensitive)
            let imgTagResults = regex.matchesInString(input, options: .ReportCompletion, range: NSMakeRange(0, input.characters.count))
            //First result will the img tag
            if let resultMatch = imgTagResults.first {
                let str = input as NSString
                let subString = str.substringWithRange(resultMatch.range)
                
                //Now we have Image tag we need to extract Image URL
                do{
                    // find our url, it is encapsulated like "//[url]"
                    let imageRegex = try NSRegularExpression(pattern: Constants.kImageURLRegEx, options: .CaseInsensitive)
                    
                    let imgURLResults = imageRegex.matchesInString(subString, options: .ReportCompletion, range: NSMakeRange(0, subString.characters.count))
                    
                    if let imgMatch = imgURLResults.first{
                         //creating imgURL 
                        let tempStr = subString as NSString
                        let imgURL = "http:"+tempStr.substringWithRange(imgMatch.range).stringByReplacingOccurrencesOfString("\"", withString: "")
                        
                        return imgURL
                        
                    }
                    
                }catch let error as NSError
                {
                    print("Error parsing URL : \(error.localizedDescription)")
                }
            }
        }catch let error as NSError{
            print(error.localizedDescription)
        }
        return ""
    }
    // Takes in a Article date string and returns an NSDate object
    // If the date cannot be parsed, returns the current date
    func dateFromString(input: String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = Constants.kGoogleNewsArticleDateFormat
        
        if let date = dateFormatter.dateFromString(input) {
            return date
        }
        
        return NSDate()
    }


}

//MARK: NSXMLParserDelegate Methods

extension XMLParser : NSXMLParserDelegate{
    // Document handling methods
    
    // sent when the parser finds an element start tag.
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String])
    {
            self.element = elementName
        
            // when it iterates and come with next element, making empty string to read next elements
        
            if elementName == "item"{
            self.articleTitle = ""
            self.articleDescription = ""
            self.articleImageURL = ""
            self.articleURL = ""
        }
    }
    
    // This returns the string of the characters encountered thus far. You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to -parser:foundCharacters:
    func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        switch self.element!{
            case "title":
                self.articleTitle += string
            case "description":
                self.articleDescription += string
            case "link":
                self.articleURL += string
            default:
                break
        }
    }

    // sent when an end tag is encountered. The various parameters are supplied as above.
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if elementName == "item"{
            if !(self.articleTitle.isEmpty) && !(self.articleDescription.isEmpty)
            {
                //create instance of article protoype and it to the list
                let article = ArticlePrototype(title: self.articleTitle, description: stringFromHTML(self.articleDescription), imageURL: getImageLinkFromImgTag(self.articleDescription), image: nil, articleURL: self.articleURL,articleDate: dateFromString(self.articleDate))
                self.articleList.append(article)
            }
        }

    }
}
