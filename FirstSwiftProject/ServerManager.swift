//
//  ServerManager.swift
//  FirstSwiftProject
//
//  Created by Elsammak on 6/5/14.
//  Copyright (c) 2014 Byte Intellegence Systems. All rights reserved.
//

import Foundation

protocol tableViewProtocol{

    func reloadTableView(array: NSArray)

}

class ServerManager: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate{

    //==================== Init ===================
    var data: NSMutableData = NSMutableData()
    var tableData: NSArray = NSArray()
    var delegate: tableViewProtocol! = nil
    
    
    func searchItunesFor(searchTerm: String) {
        
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        var itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        var escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        var urlPath = "https://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software"
        var url: NSURL = NSURL(string: urlPath)
        var request: NSURLRequest = NSURLRequest(URL: url)
        var connection: NSURLConnection = NSURLConnection(request: request, delegate: self, startImmediately: false)
        
        println("Search iTunes API at URL \(url)")
        
        connection.start()
    }

    
    //=============================== Delegate methods ============================
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!){
        
        println("Error occured!!")
    }


    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        // Append the recieved chunk of data to our data object
        self.data.appendData(data)
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!){
    
        data = NSMutableData()
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!) {
        // Request complete, self.data should now hold the resulting info
        // Convert the retrieved data in to an object through JSON deserialization
        var err: NSError
        var jsonResult: NSDictionary = NSJSONSerialization.JSONObjectWithData(data, options:    NSJSONReadingOptions.MutableContainers, error: nil) as NSDictionary
        
        if jsonResult.count>0 && jsonResult["results"].count>0 {
            var results: NSArray = jsonResult["results"] as NSArray
            self.tableData = results
            println("get data")
            delegate.reloadTableView(self.tableData);
        }
    }

}