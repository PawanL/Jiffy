/* =======================
 
 - Jiffy -
 
 made by Pawan Litt ©2016
 
 ==========================*/


import UIKit
import CloudKit
import GoogleMobileAds
import AudioToolbox


class Home: UIViewController,
UITextFieldDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
GADInterstitialDelegate
{

    /* Views */
    @IBOutlet var searchOutlet: UIButton!
    @IBOutlet var termsOfUseOutlet: UIButton!
    
    @IBOutlet var fieldsView: UIView!
    @IBOutlet var keywordsTxt: UITextField!
    @IBOutlet var categoryTxt: UITextField!
    
    @IBOutlet var categoryContainer: UIView!
    @IBOutlet var categoryPickerView: UIPickerView!
    
    @IBOutlet var categoriesScrollView: UIScrollView!
    
    var adMobInterstitial: GADInterstitial!

    
    /* Variables */
    var classifArray = NSMutableArray()
    var catButton = UIButton()
    
    
override func viewWillAppear(animated: Bool) {
    
    navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 0.0)
    
    searchedAdsArray.removeAllObjects()
    
    // YOU'RE NOT LOGGED IN ICLOUD
    CKContainer.defaultContainer().accountStatusWithCompletionHandler { (accountStatus, error) -> Void in
        if accountStatus == CKAccountStatus.NoAccount {
            let alert = UIAlertController(title: APP_NAME,
                message: "Sign in to your iCloud account to add Favorites. On the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on.\nIf you don't have an iCloud account, tap Create a new Apple ID.",
                    preferredStyle: UIAlertControllerStyle.Alert)
            let cancel = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) -> Void in })
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: nil)
    } }
        
        
    // Check current User (as Record Type)
    if currentUsername != nil {
            let predicate = NSPredicate(format: "\(USER_USERNAME) = %@", currentUsername!)
            let query = CKQuery(recordType: USER_CLASS_NAME, predicate: predicate)
            publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
                if error == nil { dispatch_async(dispatch_get_main_queue()) {
                    
                    if results?.count == 1 {
                        CurrentUser = results![0]
                        print("CURRENT USER LOGGED: \(CurrentUser[USER_USERNAME]!) - usernameStr: \(currentUsername!)")
                    } else { self.viewWillAppear(true) }
                    
                // Error
                }} else { dispatch_async(dispatch_get_main_queue()) {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
            } } }
        }
}
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Init AdMob interstitial
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(120 * Double(NSEC_PER_MSEC)))
    adMobInterstitial = GADInterstitial(adUnitID: ADMOB_UNIT_ID)
    adMobInterstitial.loadRequest(GADRequest())
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        self.showInterstitial()
    }
    
    
    // Round views corners
    searchOutlet.layer.cornerRadius = 8
    //searchOutlet.layer.shadowColor = UIColor.blackColor().CGColor
    //searchOutlet.layer.shadowOffset = CGSizeMake(0, 1.5)
    //searchOutlet.layer.shadowOpacity = 0.8

    termsOfUseOutlet.layer.cornerRadius = 8
    
    
    // Put fieldsView in the center of the screen
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
        fieldsView.center = CGPointMake(view.frame.size.width/2, 300 )
    }
    
    // Hide the Categ. PickerView
    categoryContainer.frame.origin.y = view.frame.size.height
    view.bringSubviewToFront(categoryContainer)
    
    setupCategoriesScrollView()
    
}

    
// MARK: - SETUP CATEGORIES SCROLL VIEW
func setupCategoriesScrollView() {
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 0
        let buttonWidth:CGFloat = 90
        let buttonHeight: CGFloat = 90
        let gapBetweenButtons: CGFloat = 5
        
        var itemCount = 0
        
        // Loop for creating buttons ========
        for i in 0..<categoriesArray.count {
            itemCount = i

            // Create a Button
            catButton = UIButton(type: UIButtonType.Custom)
            catButton.frame = CGRectMake(xCoord, yCoord, buttonWidth, buttonHeight)
            catButton.tag = i
            catButton.showsTouchWhenHighlighted = true
            catButton.setTitle("\(categoriesArray[itemCount])", forState: UIControlState.Normal)
            catButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 12)
            catButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            catButton.setBackgroundImage(UIImage(named: "\(categoriesArray[itemCount])"), forState: UIControlState.Normal)
            catButton.contentVerticalAlignment = UIControlContentVerticalAlignment.Bottom
            catButton.layer.cornerRadius = 5
            catButton.clipsToBounds = true
            catButton.addTarget(self, action: #selector(catButtTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            // Add Buttons & Labels based on xCood
            xCoord +=  buttonWidth + gapBetweenButtons
            categoriesScrollView.addSubview(catButton)
        
    } // END LOOP ================================
    
        // Place Buttons into the ScrollView =====
        categoriesScrollView.contentSize = CGSizeMake(buttonWidth * CGFloat(itemCount+2), yCoord)
}

    
    
    
// MARK: - ADMOB INTESRSTITIAL
func showInterstitial() {
    // Show AdMob interstitial
    if adMobInterstitial.isReady {
        adMobInterstitial.presentFromRootViewController(self)
        print("Present AdMob Interstitial")
    }
}
    
    
    
    
// MARK: - CATEGORY BUTTON TAPPED
func catButtTapped(sender: UIButton) {
    let button = sender as UIButton
    let categoryStr = "\(button.titleForState(UIControlState.Normal)!)"
    searchedAdsArray.removeAllObjects()
    showHUD()
    
    showHUD()
    
    let predicate = NSPredicate(format: "\(CLASSIF_CATEGORY) = %@", categoryStr)
    let query = CKQuery(recordType: CLASSIF_CLASS_NAME, predicate: predicate)
    let sort = NSSortDescriptor(key: "modificationDate", ascending: false)
    query.sortDescriptors = [sort]
    
    publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {
            searchedAdsArray = NSMutableArray(array: results!)
            
            // Go to Browse Ads VC
            let baVC = self.storyboard?.instantiateViewControllerWithIdentifier("BrowseAds") as! BrowseAds
            self.navigationController?.pushViewController(baVC, animated: true)
            self.hideHUD()
        
        }} else { dispatch_async(dispatch_get_main_queue()) {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    } } }
    
}
    
    
    
    
// MARK: - SEARCH BUTTON
@IBAction func searchButt(sender: AnyObject) {
    searchedAdsArray.removeAllObjects()
    showHUD()
    
    let keywordsArray = keywordsTxt.text!.lowercaseString.componentsSeparatedByString(" ") as NSArray
    
    let predicate = NSPredicate(format: "\(CLASSIF_TITLE_LOWERCASE) BEGINSWITH %@ AND \(CLASSIF_CATEGORY) = %@", "\(keywordsArray[0])", categoryTxt.text!)
    let query = CKQuery(recordType: CLASSIF_CLASS_NAME, predicate: predicate)
    let sort = NSSortDescriptor(key: "creationDate", ascending: false)
    query.sortDescriptors = [sort]
    
    publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {
            searchedAdsArray = NSMutableArray(array: results!)
            
            if searchedAdsArray.count != 0 {
                // Go to Browse Ads VC
                let baVC = self.storyboard?.instantiateViewControllerWithIdentifier("BrowseAds") as! BrowseAds
                self.navigationController?.pushViewController(baVC, animated: true)
                self.hideHUD()
                
            } else {
                self.simpleAlert("Nothing found with your search keywords, try different keywords, location or category")
                self.hideHUD()
            }
            
        // Error
        }} else { dispatch_async(dispatch_get_main_queue()) {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    } } }

}

    
    
    
// MARK: -  TEXTFIELD DELEGATE
func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == categoryTxt {
        showCatPickerView()
        keywordsTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
        
return true
}
    
func textFieldDidBeginEditing(textField: UITextField) {
    if textField == categoryTxt {
        showCatPickerView()
        keywordsTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
}
    
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == keywordsTxt {  categoryTxt.becomeFirstResponder(); hideCatPickerView()  }
    if textField == categoryTxt {  categoryTxt.resignFirstResponder()  }

return true
}
    
    
    
    
// MARK: - PICKERVIEW DELEGATES
func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1;
}

func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return categoriesArray.count
}
    
func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
    return categoriesArray[row]
}

func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    categoryTxt.text = "\(categoriesArray[row])"
}

    
// PICKERVIEW DONE BUTTON
@IBAction func doneButt(sender: AnyObject) {
    hideCatPickerView()
}

    
    
    
    
// MARK: - POST A NEW AD BUTTON
@IBAction func postAdButt(sender: AnyObject) {
    // USER IS NOT LOGGED IN
    if CurrentUser[USER_USERNAME] == nil {
        self.simpleAlert("You must first login/signup to Post an Ad. You can do that in the Account screen")
        
    // USER IS LOGGED IN
    } else {
        let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("Post") as! Post
        presentViewController(postVC, animated: true, completion: nil)
    }
}

    
    
    
// MARK: - DISMISS KEYBOARD ON TAP
@IBAction func dismissKeyboardOnTap(sender: UITapGestureRecognizer) {
    keywordsTxt.resignFirstResponder()
    categoryTxt.resignFirstResponder()
    hideCatPickerView()
}
    
    
    
// MARK: - SHOW/HIDE CATEGORY PICKERVIEW
func showCatPickerView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.view.frame.size.height - self.categoryContainer.frame.size.height-44
    }, completion: { (finished: Bool) in  });
}
func hideCatPickerView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in  });
}
    
    
    
    
// MARK: - SHOW TERMS OF USE
@IBAction func termsOfUseButt(sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUse") as! TermsOfUse
    presentViewController(touVC, animated: true, completion: nil)
}
    
    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
