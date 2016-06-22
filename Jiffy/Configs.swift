/* =======================
 
 - Jiffy -
 
 made by Pawan Litt ©2016
 
 ==========================*/


import Foundation
import UIKit
import CloudKit



// CHANGE THE RED STRING BELOW ACCORDINGLY TO THE NAME YOU'LL GIVE TO YOUR OWN VERISON OF THIS APP
var APP_NAME = "Jiffy"


var categoriesArray = [
    "Jobs",
    "Real Estate",
    "Services",
    "Electronics",
    "Vehicles",
    "Shopping",
    "Community",
    "Pets",
    "Free stuff"
    
    // You can add more Categories here....
]



// IMPORTANT: Change the red string below with the path where you've stored the sendReply.php file (in this case we've stored it into a directory in our website called "Jiffy")
var PATH_TO_PHP_FILE = "http://www.jiffyClassifieds.com/jiffy/"

// IMPORTANT: You must replace the red email address below with the one you'll dedicate to Report emails from Users, in order to also agree with EULA Terms (Required by Apple)
let MY_REPORT_EMAIL_ADDRESS = "pawan.litt27@gmail.com"

// IMPORTANT: Replace the red string below with your own AdMob INTERSTITIAL's Unit ID
var ADMOB_UNIT_ID = "ca-app-pub-3011193616117520/4110419697"


// HUD View
let hudView = UIView(frame: CGRectMake(0, 0, 80, 80))
let indicatorView = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
extension UIViewController {
    func showHUD() {
        hudView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2)
        hudView.backgroundColor = UIColor(red: 250.0/255.0, green: 110.0/255.0, blue: 82.0/255.0, alpha: 1.0)
        hudView.alpha = 0.9
        hudView.layer.cornerRadius = hudView.bounds.size.width/2
        
        indicatorView.center = CGPointMake(hudView.frame.size.width/2, hudView.frame.size.height/2)
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        hudView.addSubview(indicatorView)
        indicatorView.startAnimating()
        view.addSubview(hudView)
    }
    func hideHUD() {
        hudView.removeFromSuperview()
    }
    
    func simpleAlert(mess:String) {
        UIAlertView(title: APP_NAME, message: mess, delegate: nil, cancelButtonTitle: "OK").show()
    }
}




let publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
let def = NSUserDefaults.standardUserDefaults()
var currentUsername = def.stringForKey("currentUsername")
var CurrentUser = CKRecord(recordType: USER_CLASS_NAME)
var reloadUser = Bool()



/* USER CLASS */
var USER_CLASS_NAME = "USERS_"
var USER_ID = "objectId"
var USER_USERNAME = "username"
var USER_PASSWORD = "password"
var USER_FULLNAME = "fullName"
var USER_PHONE = "phone"
var USER_EMAIL = "email"
var USER_WEBSITE = "website"
var USER_AVATAR = "avatar"

/* CLASSIFIEDS CLASS */
var CLASSIF_CLASS_NAME = "Classifieds"
var CLASSIF_ID = "objectId"
var CLASSIF_USER_POINTER = "userPointer" // User Pointer
var CLASSIF_TITLE = "title"
var CLASSIF_TITLE_LOWERCASE = "titleLowercase"
var CLASSIF_CATEGORY = "category"
var CLASSIF_ADDRESS = "address" // GeoPoint
var CLASSIF_ADDRESS_STRING = "addressString"
var CLASSIF_PRICE = "price"
var CLASSIF_DESCRIPTION = "description"
var CLASSIF_IMAGE1 = "image1" // File
var CLASSIF_IMAGE2 = "image2" // File
var CLASSIF_IMAGE3 = "image3" // File
var CLASSIF_CREATION_DATE = "creationDate"
var CLASSIF_MODIFICATION_DATE = "modificationDate"

/* FAVORITES CLASS */
var FAV_CLASS_NAME = "Favorites"
var FAV_USER_POINTER = "userPointer"
var FAV_AD_POINTER = "adPointer"






