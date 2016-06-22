/* =======================
 
 - Jiffy -
 
 made by Pawan Litt ©2016
 
 ==========================*/

import UIKit
import CloudKit


class Favorites: UITableViewController {


    /* Variables */
    var favoritesArray = NSMutableArray()
    

    

override func viewWillAppear(animated: Bool) {
    navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    if CurrentUser[USER_USERNAME] != nil {
        queryFavAds()
    } else {
        self.simpleAlert("You must login/signup into your Account to add Favorites")
    }
}
    
override func viewDidLoad() {
        super.viewDidLoad()

    
}

func queryFavAds()  {
    showHUD()
    
    let predicate = NSPredicate(format: "\(FAV_USER_POINTER) = %@", CurrentUser)
    let query = CKQuery(recordType: FAV_CLASS_NAME, predicate: predicate)
    let sort = NSSortDescriptor(key: "creationDate", ascending: false)
    query.sortDescriptors = [sort]
    
    publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {
            self.favoritesArray = NSMutableArray(array: results!)
            self.tableView.reloadData()
            self.hideHUD()
        
        // Error
        }} else { dispatch_async(dispatch_get_main_queue()) {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    } } }

}


// MARK: - TABLEVIEW DELEGATES */
override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
}
override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return favoritesArray.count
}
    
override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("FavoritesCell", forIndexPath: indexPath) as! FavoritesCell
        
    let favClass = favoritesArray[indexPath.row] as! CKRecord
    
    // Get Ads as a Pointer
    let adRef = favClass[FAV_AD_POINTER] as! CKReference
    publicDatabase.fetchRecordWithID(adRef.recordID) { (adPointer, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {
            cell.adTitleLabel.text = "\(adPointer![CLASSIF_TITLE]!)"
            cell.adDescrLabel.text = "\(adPointer![CLASSIF_DESCRIPTION]!)"
            
            // Get image
            let imageFile = adPointer![CLASSIF_IMAGE1] as? CKAsset
            if imageFile != nil { cell.adImage.image = UIImage(contentsOfFile: imageFile!.fileURL.path!) }
            
    } } }

        
return cell
}
    
    
// MARK: - SELECT AN AD -> SHOW IT
override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    let favClass = favoritesArray[indexPath.row] as! CKRecord
    // Get Ads as a Pointer
    let adRef = favClass[FAV_AD_POINTER] as! CKReference
    publicDatabase.fetchRecordWithID(adRef.recordID) { (adPointer, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {
    
            let showAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowSingleAd") as! ShowSingleAd
            // Pass the Ad ID to the Controller
            showAdVC.singleAdObj = adPointer!
            self.navigationController?.pushViewController(showAdVC, animated: true)
    } } }
    
}

    

// MARK: - REMOVE THIS AD FROM YOUR FAVORITES
override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
}
override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            // Delete selected Ad
            let favClass = favoritesArray[indexPath.row] as! CKRecord
            publicDatabase.deleteRecordWithID(favClass.recordID, completionHandler: { (recID, error) -> Void in
                if error == nil { dispatch_async(dispatch_get_main_queue()) {
                    
                    // Remove record in favoritesArray and the tableView's row
                    self.favoritesArray.removeObjectAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                    
                }} else { self.simpleAlert("\(error!.localizedDescription)") }
            })
    }
    
}

    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
