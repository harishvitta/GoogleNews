//
//  Article.swift
//  GoogleNewsFeed
//
//  Created by Harish Vitta on 5/6/16.
//  Copyright © 2016 Harish Vitta. All rights reserved.
//

import UIKit
import CoreData

class Article : NSManagedObject{
    
    @NSManaged var articleTitle: String?
    @NSManaged var articleDescription: String?
    @NSManaged var imageURL: String?
    @NSManaged var image: NSObject?
    @NSManaged var articleURL: String?
    @NSManaged var articleDate : NSObject?
    
    convenience init(prototype: ArticlePrototype, inManagedObjectContext context: NSManagedObjectContext){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let entity = NSEntityDescription.entityForName("Article", inManagedObjectContext: context)!
        
        //init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?)
        self.init(entity : entity, insertIntoManagedObjectContext : appDelegate.managedObjectContext)
        
        self.articleTitle = prototype.title
        self.articleDescription = prototype.description
        self.articleURL = prototype.articleURL
        self.imageURL = prototype.imageURL
        self.articleDate = prototype.articleDate
        
        //optional image
        
        if (prototype.image as UIImage!) != nil
        {
            self.image = prototype.image
        }
    }

}
