//
//  CoreDataManager.swift
//  GoogleNewsFeed
//
//  Created by Harish Vitta on 5/6/16.
//  Copyright © 2016 Harish Vitta. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager : NSObject {
    func fetchRecords(articles : [ArticlePrototype])
    {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedObjectContext = appDelegate.managedObjectContext
        
        var articlesArray = [Article]()
        
        //First clear any previous data in core data
        
        let fetchRequest = NSFetchRequest(entityName: "Article")
        
        do{
            // returns the number of objects a fetch request would have returned if it had been passed to -executeFetchRequest:error:.   If an error occurred during the processing of the request, this method will return NSNotFound.
            let fetchResults = try managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            if articles .count > 0{
            if let managedObjects = fetchResults as [NSManagedObject]!{
                for managedObject in managedObjects{
                    managedObjectContext.deleteObject(managedObject)
                }
                
                try managedObjectContext.save()
                }
            }
        }catch {
            print("Error : \(error)")
        }
        
        //Saving articles 
        
        for article in articles{
            
            let managedArticle = Article(prototype: article, inManagedObjectContext: managedObjectContext)
            
            articlesArray.append(managedArticle)
        }
        
        //save in core data
        
        do{
            try managedObjectContext.save()
        }
        catch{
            print("Error : \(error)")
        }
    }
}
