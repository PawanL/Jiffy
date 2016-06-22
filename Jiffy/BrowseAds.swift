/* =======================
 
 - Jiffy -
 
 made by Pawan Litt ©2016
 
 ==========================*/

import UIKit
import CloudKit

var searchedAdsArray = NSMutableArray()


class BrowseAds: UITableViewController {
    
    
    /* Variables */
    var callTAG = 0
    

    
    
    
override func viewDidLoad() {
        super.viewDidLoad()

     self.title = " Browse Ads"
    
}
    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    }

 
// MARK: - TABLEVIEW DELEGATES
override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
}
override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return searchedAdsArray.count
}
    
override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("AdCell", forIndexPath: indexPath) as! AdCell
    
    let classifClass = searchedAdsArray[indexPath.row] as! CKRecord
    
    cell.adTitleLabel.text = "\(classifClass[CLASSIF_TITLE]!)"
    cell.adDescrLabel.text = "\(classifClass[CLASSIF_DESCRIPTION]!)"
    cell.addToFavOutlet.tag = indexPath.row
    
    // Get date
    let adDate = classifClass[CLASSIF_CREATION_DATE] as! NSDate
    let dateFormat = NSDateFormatter()
    dateFormat.dateFormat = "MMM/dd/yyyy"
    cell.dateLabel.text = dateFormat.stringFromDate(adDate)
    
    // Get image
    let imageFile = classifClass[CLASSIF_IMAGE1] as? CKAsset
    if imageFile != nil { cell.adImage.image = UIImage(contentsOfFile: imageFile!.fileURL.path!) }

    
return cell
}
 
// MARK: - SELECTED AN AD -> SHOW IT
override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let classifClass = searchedAdsArray[indexPath.row] as! CKRecord
    
    let showAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("ShowSingleAd") as! ShowSingleAd
    showAdVC.singleAdObj = classifClass
    self.navigationController?.pushViewController(showAdVC, animated: true)
}


    
    
    
    
// MARK: - ADD AD TO FAVORITES BUTTON
@IBAction func addToFavButt(sender: AnyObject) {
    let button = sender as! UIButton
    
    // CURRENT USER IS LOGGED IN
    if CurrentUser[USER_USERNAME] != nil {
        let adRecord = searchedAdsArray[button.tag] as! CKRecord
        let favClass = CKRecord(recordType: FAV_CLASS_NAME)
    
        // Prepare References
        let currUserRef = CKReference(record: CurrentUser, action: .None)
        favClass[FAV_USER_POINTER] = currUserRef
        let adRef = CKReference(record: adRecord, action: .None)
        favClass[FAV_AD_POINTER] = adRef
    
        showHUD()
        let predicate = NSPredicate(format: "\(FAV_USER_POINTER) = %@ AND \(FAV_AD_POINTER) = %@", CurrentUser, adRecord)
        let query = CKQuery(recordType: FAV_CLASS_NAME, predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error == nil { dispatch_async(dispatch_get_main_queue()) {
                
                // You've already favorited this ad!
                if results!.count != 0 {
                    self.simpleAlert("You've already added this Ad to your Favorites! Check it out on Favorites tab.")
                    self.hideHUD()
                    
                // Favorite this ad!
                } else {
                    publicDatabase.saveRecord(favClass, completionHandler: { (record, error) -> Void in
                        if error == nil { dispatch_async(dispatch_get_main_queue()) {
                            self.simpleAlert("This Ad has been added to your Favorites!")
                            self.hideHUD()
                        }} else { dispatch_async(dispatch_get_main_queue()) {
                            self.simpleAlert("\(error!.localizedDescription)")
                            self.hideHUD()
                    }}})
                }
        
            // Error
            }} else { dispatch_async(dispatch_get_main_queue()) {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }}}
        

        
    // CURRENT USER IS NOT LOGGED IN, CANNOT FAVORITE!
    } else { simpleAlert("You must first login/signup to save Favorites. You can do that in the Account screen") }
}
 
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
