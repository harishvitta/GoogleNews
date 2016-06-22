//
//  GoogleNewsFeedTests.swift
//  GoogleNewsFeedTests
//
//  Created by Harish Vitta on 31/5/16.
//  Copyright © 2016 Harish Vitta. All rights reserved.
//

import XCTest
import CoreData

@testable import GoogleNewsFeed

class GoogleNewsFeedTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func testGetArticles() {
        let expectation : XCTestExpectation = self.expectationWithDescription("Get Articles should return as NSData")
        INetConnector().getArticlesWithCompletion{
            (data , error) -> Void in
            XCTAssertNotNil(data)
            expectation.fulfill()
            
            if error != nil {
                XCTFail("Get Articles should return error")
            }
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testFetchAllArticlesWithBadURL(){
        let expectation = self.expectationWithDescription("fetchAllArticles should return eror, provided invalid Feed URL")
        let inValidURL = NSURL(string: "http://news.googleere.com/?output=rss")
        
        NSURLSession.sharedSession().dataTaskWithURL(inValidURL!){
            (data , response , error) -> Void in
            
            if error != nil{
                XCTAssertNil(data, "failed to get articles from RSS Feed")
                expectation.fulfill()
            }
            else{
                XCTFail("Should Return unknown error")
            }
            
            }.resume()
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testFetclAllArticlesWithNoConnectivity()
    {
        let expectation = self.expectationWithDescription("fetchAllArticles should return error, when no internet connectivity")
        let inValidURL = NSURL(string: "http://news.google.com/?output=rss")
        
        NSURLSession.sharedSession().dataTaskWithURL(inValidURL!){
            (data , response , error) -> Void in
            
            if error?.code == NSURLErrorNotConnectedToInternet{
                expectation.fulfill()
            }
            else{
                XCTFail("Should Return NSURLErrorNotConnectedToInternet error")
            }
            
            }.resume()
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    //func parseAllArticleData(data: NSData, completion: (content: [ArticlePrototype]?, error: ErrorType?) -> Void){
    
    func testParseWithValidData(){
        
        let expectation : XCTestExpectation = self.expectationWithDescription("ParseAllArticleData method takes in an NSData object and runs it through my parser class to parse the XML It returns an array of ArticlePrototype structs, the prototype object is used to create my Article NSManagedObject, and/or a ParsingError")
        INetConnector().getArticlesWithCompletion{
            (data , error) -> Void in
            XCTAssertNotNil(data)
            guard let parsedData = data as? NSData else {
                XCTFail()
                return
            }
            
            INetConnector().parseAllArticleData(parsedData, completion: {
                (data , error) -> Void in
                if error != nil{
                    XCTFail("Parsing failed")
                }
                
                if let unwrappedData = data as [ArticlePrototype]! {
                    if unwrappedData.isEmpty{
                        XCTFail("parseAllArticleData should return non-empty array of Article Prototype")
                    }
                    else{
                        //unwrappedData returned meaning data
                        expectation.fulfill()
                    }
                }
            })
        }
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testParseWithInvalidData(){
        
        let expectation : XCTestExpectation = self.expectationWithDescription("Parse invalid data and return parsing error")
        INetConnector().parseAllArticleData(NSData(), completion: {
            (data , error) -> Void in
            if error != nil{
                expectation.fulfill()
            }
            else{
                XCTFail("parseAllArticleData should fail to parse invalid data")
                
            }
        })
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testDownloadImagesForArticles(){
        
        let expectation : XCTestExpectation = self.expectationWithDescription("Download Images for articles from Article list")
        INetConnector().getArticlesWithCompletion{
            (data , error) -> Void in
            XCTAssertNotNil(data)
            guard let parsedData = data as? NSData else {
                XCTFail()
                return
            }
            
            INetConnector().parseAllArticleData(parsedData, completion: {
                (data , error) -> Void in
                if error != nil{
                    XCTFail("Parsing failed")
                }
                
                if let unwrappedData = data as [ArticlePrototype]! {
                    if unwrappedData.isEmpty{
                        XCTFail("parseAllArticleData should return non-empty array of Article Prototype")
                    }
                    else{
                        INetConnector().downloadImagesForArticles(unwrappedData, completion:{
                            (articles: [ArticlePrototype]) -> Void in
                            if let article = articles.first as ArticlePrototype!{
                                if article.image != nil {
                                    expectation.fulfill()
                                }
                            }
                        })
                    }
                }
            })
        }
        self.waitForExpectationsWithTimeout(15.0, handler: nil)
    }
    func testDownloadImagesForArticlesWithEmptyList() {
        
        let expectation = self.expectationWithDescription("downloadImagesForArticles should return an empty output on an empty input")
        
        INetConnector().downloadImagesForArticles([]) { (articles) -> Void in
            if !articles.isEmpty {
                XCTFail("Output should be empty with an empty imput")
            } else {
                expectation.fulfill()
            }
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    func testFetchImageFromURL() {
        
        let expectation = self.expectationWithDescription("fetchImageFromURL should return an image from a valid url")
        
        let testImageStr = "http://t0.gstatic.com/images?q=tbn:ANd9GcSv02Cgoq6jsfwHQZKWJMDn9scgGI-rvH4LhFMbwchZtNAbn_afhtpGOz8WYIrE8L1e-VtWh2-C"
        
        INetConnector().fetchImageFromURL(testImageStr) { (image) -> Void in
            XCTAssertNotNil(image, "Image returned from sample URL should not be nil")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    func testFetchImageWithBadUrl() {
        
        let expectation = self.expectationWithDescription("fetchImageFromURL should return nil from a non-image url")
        
        let testImageStr = "http://t0.gstatic.com/images?q=tbn:ANd9GcSv02Cgoq6jsfwHQZKWJMDn9scgGI-rvH4LhFMbwchZtNAbn_afhtpGOz8WYIrE8L1"
        
        INetConnector().fetchImageFromURL(testImageStr) { (image) -> Void in
            XCTAssertNotNil(image, "Image returned from non-image URL should be nil")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    func testFetchImageWithEmptyUrl() {
        
        let expectation = self.expectationWithDescription("fetchImageFromURL should return nil from a non-image url")
        
        INetConnector().fetchImageFromURL("") { (image) -> Void in
            XCTAssertNil(image, "Image returned from empty URL should be nil")
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    
    
}
