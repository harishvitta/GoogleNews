//
//  Commons.swift
//  GoogleNewsFeed
//
//  Created by Harish Vitta on 3/6/16.
//  Copyright © 2016 Harish Vitta. All rights reserved.
//

import Foundation



struct Constants
{
    static let kGoogleNewsURL = "https://news.google.com/?output=rss"
    static let kHTTPSuccessStatusCode = 200
    static let kImageTagRegEx = "<img src=[^>]+>"
    static let kHTMLRegEx = "<[^>]+>"
    static let kImageURLRegEx = "\"//(.*?)\""
    static let kGoogleNewsArticleDateFormat = "EEE, d MMM yyyy HH:mm:ss Z"

    static let kNetworkFailureMessage = "There was a problem while downloading articles. Please check your network connetion and try again"
    static let kParsingErrorMessage = "The was a problem parsing downloaded articles. Please try again."
    static let kUnknownErrorMessage = "There was a problem downloading articles. Please try again later."

}