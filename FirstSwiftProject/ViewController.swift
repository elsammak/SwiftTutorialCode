//
//  ViewController.swift
//  FirstSwiftProject
//
//  Created by Elsammak on 6/5/14.
//  Copyright (c) 2014 Byte Intellegence Systems. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,tableViewProtocol, UIAlertViewDelegate {

    //================================= IBOutlets ============================
    @IBOutlet var appsTableView : UITableView
    @IBOutlet var searchField : UITextField
    @IBOutlet var loadingWheel: UIActivityIndicatorView
    //================================= Vars ============================
    var tableData: NSArray = NSArray()
    var serverManager: ServerManager = ServerManager()
    var isReloadCompleted: Bool = false
    var imageCache = NSMutableDictionary()
    
    
//================================== Views Methods =======================================
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        serverManager.delegate = self;
        serverManager.searchItunesFor("Angry birds");
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

     override func prefersStatusBarHidden() -> Bool {
        
        return true;
    }
    
//===================================== Table View Delegate methods ==========================
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int{
        
        return tableData.count;
    
    }
    

    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!{
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
        
        if(isReloadCompleted){
           
            var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
            
            cell.text = rowData["trackName"] as String
            
            // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
            var urlString: NSString = rowData["artworkUrl60"] as NSString
            var imgURL: NSURL = NSURL(string: urlString)
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                // Jump in to a background thread to get the image for this item
                
                // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
                var urlString: NSString = rowData["artworkUrl60"] as NSString
                
                // Check our image cache for the existing key. This is just a dictionary of UIImages
                var image: UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
                
                if( !image? ) {
                    // If the image does not exist, we need to download it
                    var imgURL: NSURL = NSURL(string: urlString)
                    
                    // Download an NSData representation of the image at the URL
                    var request: NSURLRequest = NSURLRequest(URL: imgURL)
                    var urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                        if !error? {
                            //var imgData: NSData = NSData(contentsOfURL: imgURL)
                            image = UIImage(data: data)
                            
                            // Store the image in to our cache
                            self.imageCache.setValue(image, forKey: urlString)
                            cell.image = image
                            cell.setNeedsLayout()
                        }
                        else {
                            println("Error: \(error.localizedDescription)")
                        }
                        })
                    
                }
                else {
                    cell.image = image
                    cell.setNeedsLayout()
                }
                
                
                })
            
            // Get the formatted price string for display in the subtitle
            var formattedPrice: NSString = rowData["formattedPrice"] as NSString
            
            cell.detailTextLabel.text = formattedPrice
            
        }
        else{
            
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
        
        var rowData: NSDictionary = self.tableData[indexPath.row] as NSDictionary
        
        var alert: UIAlertView = UIAlertView()
        alert.title = rowData["trackName"] as NSString;
        alert.message = rowData["formattedPrice"] as NSString
        alert.addButtonWithTitle("Ok")
        alert.show()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int{
        
        return 1;
    }
    
    
//==================================== Delegeta Methods ====================================
    
    func reloadTableView(array: NSArray){
        
        println("Delegate called Successfully!!")
        
        //Stop loading wheel
        loadingWheel.stopAnimating()
        
        tableData = array;
        appsTableView.reloadData();
        isReloadCompleted = true;
    }
    
//===================================== IBAction methods ===================================
    
    @IBAction func searchButtonPressed(){
        
        //Check for string before searching
        if(!checkForString(searchField.text)){
            return
        }
        
        //Disable keyboard
        searchField.enabled = false;
        
        //Start search
        serverManager.searchItunesFor(searchField.text);
        
        //Start loading wheel animation
        loadingWheel.startAnimating()
        
    }
    
    func checkForString(searchItem: NSString) -> Bool{
        
        if searchItem.isEqualToString(""){
            return false;
        }
        return true;
    }
    
}

