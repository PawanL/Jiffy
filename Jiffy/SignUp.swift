/* =======================
 
 - Jiffy -
 
 made by Pawan Litt ©2016
 
 ==========================*/


import UIKit
import CloudKit


class SignUp: UIViewController,
UITextFieldDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var signupOutlet: UIButton!
    @IBOutlet weak var touOutlet: UIButton!
    
    @IBOutlet var bkgViews: [UIView]!
    
    
   

override func viewDidLoad() {
        super.viewDidLoad()
    
    self.title = "SIGN UP"
    
    // Round views corners
    signupOutlet.layer.cornerRadius = 5
    touOutlet.layer.cornerRadius = 5
    for view in bkgViews { view.layer.cornerRadius = 8 }
    
    
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 300)
}
    

// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
    dismissKeyboard()
}
 
    
    
// MARK: - SIGNUP BUTTON
@IBAction func signupButt(sender: AnyObject) {
        dismissKeyboard()
        showHUD()
        
        // Check if your choose username already exists in the database
        let predicate = NSPredicate(format: "\(USER_USERNAME) = %@", usernameTxt.text!.lowercaseString)
        let query = CKQuery(recordType: USER_CLASS_NAME, predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error == nil { dispatch_async(dispatch_get_main_queue()) {
                if results?.count > 0 {
                    self.simpleAlert("A user with this email already exists, please choose another email.")
                    self.hideHUD()
                    
                // Username doesn't exists, so register a new User
                } else {
                    let userForSignUp = CKRecord(recordType: USER_CLASS_NAME)
                    userForSignUp[USER_USERNAME] = self.usernameTxt.text!.lowercaseString
                    userForSignUp[USER_EMAIL] = self.emailTxt.text!.lowercaseString
                    userForSignUp[USER_PASSWORD] = self.passwordTxt.text
                    
            // Empty field -> No sign Up
            if self.usernameTxt.text == "" || self.passwordTxt.text == "" || self.emailTxt.text == "" {
                    self.simpleAlert("You must fill all fields to sign up!")
                    self.hideHUD()
                        
            // Sign up block
            } else {
                publicDatabase.saveRecord(userForSignUp, completionHandler: { (record, error) -> Void in
                    if error == nil { dispatch_async(dispatch_get_main_queue()) {
                        currentUsername = self.usernameTxt.text!.lowercaseString
                        def.setObject(currentUsername, forKey: "currentUsername")
                        
                        reloadUser = true
                        self.navigationController?.popViewControllerAnimated(true)
                        self.hideHUD()
                    
                    }} else { dispatch_async(dispatch_get_main_queue()) {
                            self.simpleAlert("\(error!.localizedDescription)")
                            self.hideHUD()
                }} })
            }
            
                }
             
                
            // Error in query
            }} else { dispatch_async(dispatch_get_main_queue()) {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        } } }
    
}

    
   
    
    
// MARK: - TEXTFIELD DELEGATES
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTxt {   passwordTxt.becomeFirstResponder()  }
    if textField == passwordTxt {  emailTxt.becomeFirstResponder()  }
    if textField == emailTxt {   emailTxt.resignFirstResponder()   }
        
return true
}


func dismissKeyboard() {
    usernameTxt.resignFirstResponder()
    passwordTxt.resignFirstResponder()
    emailTxt.resignFirstResponder()
}

    
// MARK: - TERMS OF USE BUTTON
@IBAction func touButt(sender: AnyObject) {
    let touVC = self.storyboard?.instantiateViewControllerWithIdentifier("TermsOfUse") as! TermsOfUse
    presentViewController(touVC, animated: true, completion: nil)
}
    
    
    

    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
