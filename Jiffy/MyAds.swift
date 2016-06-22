/* =======================
 
 - Jiffy -
 
 made by Pawan Litt ©2016
 
 ==========================*/

import UIKit
import CloudKit


class MyAds: UITableViewController {

    
    /* Variables */
    var myAdsArray = NSMutableArray()
    

    
override func viewDidAppear(animated: Bool) {
    showHUD()
    navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    let predicate = NSPredicate(format: "\(CLASSIF_USER_POINTER) = %@", CurrentUser)
    let query = CKQuery(recordType: CLASSIF_CLASS_NAME, predicate: predicate)
    let sort = NSSortDescriptor(key: "creationDate", ascending: false)
    query.sortDescriptors = [sort]
    
    publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {
            self.myAdsArray = NSMutableArray(array: results!)
            self.tableView.reloadData()
            self.hideHUD()
        // Error
        }} else { dispatch_async(dispatch_get_main_queue()) {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    } } }

}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    self.title = "My Ads"
   
}

    
    
    
    
// MARK: - TABLE VIEW DELEGATES
override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
}

override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myAdsArray.count
}

override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MyAdCell", forIndexPath: indexPath) as! MyAdCell

    let classifClass = myAdsArray[indexPath.row] as! CKRecord
    
    // Get image
    let imageFile = classifClass[CLASSIF_IMAGE1] as? CKAsset
    if imageFile != nil { cell.adImage.image = UIImage(contentsOfFile: imageFile!.fileURL.path!) }
    
    cell.adTitleLabel.text = "\(classifClass[CLASSIF_TITLE]!)"
    cell.adDescrLabel.text = "\(classifClass[CLASSIF_DESCRIPTION]!)"
    

return cell
}

override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let classifClass = myAdsArray[indexPath.row] as! CKRecord
    
    // Open to Post Controller
    let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("Post") as! Post
    postVC.postObj = classifClass
    presentViewController(postVC, animated: true, completion: nil)

}

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
}
}
