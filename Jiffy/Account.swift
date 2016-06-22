/* =======================
 
 - Jiffy -
 
 made by Pawan Litt ©2016
 
 ==========================*/


import UIKit
import CloudKit

class Account: UIViewController,
UITextFieldDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var fullnameTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var phoneTxt: UITextField!
    @IBOutlet var websiteTxt: UITextField!
    @IBOutlet var saveProfileOutlet: UIButton!
    @IBOutlet var myAdsOutlet: UIButton!
    
    
    /* Variables */
    var userArray = NSMutableArray()
    var avatarURL = NSURL()
    var avatarPath = String()
    
    
    
// MARK: - CHECK IF USER IS LOGGED IN
override func viewWillAppear(animated: Bool) {
    print("reloadUser: \(reloadUser)")
    
    // Check current User
    if currentUsername == nil {
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        navigationController?.pushViewController(loginVC, animated: false)
    
    } else {
        showHUD()
        let predicate = NSPredicate(format: "\(USER_USERNAME) = %@", currentUsername!)
        let query = CKQuery(recordType: USER_CLASS_NAME, predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error == nil { dispatch_async(dispatch_get_main_queue()) {
                
                if results?.count == 1 {
                    CurrentUser = results![0]
                    print("CURRENT USER IN ACCOUNT: \(CurrentUser[USER_USERNAME]!) - usernameStr: \(currentUsername!)")
                    
                    if  !reloadUser {
                        reloadUser = true
                        self.showUserDetails()
                        reloadUser = false
                    }
                    self.hideHUD()
                    
                } else { self.viewWillAppear(true) }
                
            // Error
            }} else { dispatch_async(dispatch_get_main_queue()) {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        } } }
        
 
    }
}
  
override func viewDidDisappear(animated: Bool) {
    reloadUser = false
}
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    
    // Round views corners
    avatarImage.layer.cornerRadius = avatarImage.bounds.size.width/2
    saveProfileOutlet.layer.cornerRadius = 8
    myAdsOutlet.layer.cornerRadius = 8

    
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 550)
}
    
override func viewDidAppear(animated: Bool) {
    navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 1.0)
}
    

// MARK: - SHOW CURRENT USER'S DETAIULS
func showUserDetails() {
    
    usernameLabel.text = "\(CurrentUser[USER_USERNAME]!)"
    emailTxt.text = "\(CurrentUser[USER_EMAIL]!)"
    
    if CurrentUser[USER_FULLNAME] != nil { fullnameTxt.text = "\(CurrentUser[USER_FULLNAME]!)"
    } else { fullnameTxt.text = "" }
    
    if CurrentUser[USER_PHONE] != nil { phoneTxt.text = "\(CurrentUser[USER_PHONE]!)"
    } else { phoneTxt.text = "" }
    
    if CurrentUser[USER_WEBSITE] != nil { websiteTxt.text = "\(CurrentUser[USER_WEBSITE]!)"
    } else { websiteTxt.text = "N/A" }
    
     // Get Avatar image
    let imageFile = CurrentUser[USER_AVATAR] as? CKAsset
    if imageFile != nil { avatarImage.image = UIImage(contentsOfFile: imageFile!.fileURL.path!) }
    
}
    
    
    
// MARK: - TEXTFIELD DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == fullnameTxt {  emailTxt.becomeFirstResponder()  }
    if textField == emailTxt {  phoneTxt.becomeFirstResponder()  }
    if textField == phoneTxt {  websiteTxt.becomeFirstResponder()  }
    if textField == websiteTxt {  websiteTxt.resignFirstResponder()  }

return true
}

    
// MARK: - CHANGE IMAGE BUTTON
@IBAction func changeImageButt(sender: AnyObject) {
    
    let alert = UIAlertView(title: APP_NAME,
    message: "Add a Photo",
    delegate: self,
    cancelButtonTitle: "Cancel",
    otherButtonTitles:
            "Take a picture",
            "Choose from Library"
    )
    alert.show()
    
}
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "Take a picture" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
            
        } else if alertView.buttonTitleAtIndex(buttonIndex) == "Choose from Library" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = true
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }
}
// ImagePicker delegate
func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    avatarImage.image = image

    let dirPaths = NSSearchPathForDirectoriesInDomains( .DocumentDirectory, .UserDomainMask, true)
    let docsDir: AnyObject = dirPaths[0]
    avatarPath = docsDir.stringByAppendingPathComponent("image.png")
    UIImageJPEGRepresentation(image, 0.5)!.writeToFile(avatarPath, atomically: true)
    avatarURL = NSURL(fileURLWithPath: avatarPath)
    print("\(avatarURL)")
    
    reloadUser = true
    
    dismissViewControllerAnimated(true, completion: nil)
}

    
    

// MARK: - SAVE PROFILE BUTTON
@IBAction func saveProfileButt(sender: AnyObject) {
    showHUD()
    
    CurrentUser[USER_FULLNAME] = fullnameTxt.text
    CurrentUser[USER_EMAIL] = emailTxt.text
    CurrentUser[USER_PHONE] = phoneTxt.text
    CurrentUser[USER_WEBSITE] = websiteTxt.text

    // Save Image (if exists)
    if avatarPath != "" {
        let imageFile = CKAsset(fileURL: avatarURL)
        CurrentUser[USER_AVATAR] = imageFile
    }
    
    publicDatabase.saveRecord(CurrentUser) { (user, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {
            self.simpleAlert("Your Profile has been updated!")
            self.hideHUD()
            
        }} else {
            self.simpleAlert("\(error!.localizedDescription)")
            self.hideHUD()
    }}
    
}

    
    
// MARK: - POST A NEW AD BUTTON
@IBAction func postAdButt(sender: AnyObject) {
    let postVC = self.storyboard?.instantiateViewControllerWithIdentifier("Post") as! Post
    presentViewController(postVC, animated: true, completion: nil)
}
    
    
    
// MARK: - MY ADS BUTTON
@IBAction func myAdsButt(sender: AnyObject) {
    let myAdsVC = self.storyboard?.instantiateViewControllerWithIdentifier("MyAds") as! MyAds
    self.navigationController?.pushViewController(myAdsVC, animated: true)
}
    
    
    
// MARK: - LOGOUT BUTTON
@IBAction func logoutButt(sender: AnyObject) {
    let alert = UIAlertController(title: APP_NAME,
        message: "Are you sure you want to logout?",
        preferredStyle: UIAlertControllerStyle.Alert)
    let ok = UIAlertAction(title: "Logout", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        self.showHUD()
        
        currentUsername = nil
        def.setObject(currentUsername, forKey: "currentUsername")
        CurrentUser = CKRecord(recordType: USER_CLASS_NAME)
        
        // Show the Login screen
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("Login") as! Login
        self.navigationController?.pushViewController(loginVC, animated: true)
        self.hideHUD()
    })
    
    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in })
    
    alert.addAction(ok); alert.addAction(cancel)
    presentViewController(alert, animated: true, completion: nil)
}

    

    
// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
    fullnameTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
    phoneTxt.resignFirstResponder()
    websiteTxt.resignFirstResponder()
}
    

    
    
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
