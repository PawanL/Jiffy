

import UIKit
import CloudKit

class Login: UIViewController,
    UITextFieldDelegate,
    UIAlertViewDelegate
{
    
    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var usernameTxt: UITextField!
    @IBOutlet var passwordTxt: UITextField!
    
    @IBOutlet var loginButtons: [UIButton]!
    @IBOutlet var txtFieldViews: [UIView]!
    
    /* Variables */
    var userEmail = String()
    
    
    
    
override func viewWillAppear(animated: Bool) {
    userEmail = ""
    if currentUsername != nil { self.navigationController?.popViewControllerAnimated(true) }
        
}

override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup layouts
        containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 550)
        
        // Round views corners
    for butt in loginButtons { butt.layer.cornerRadius = 10 }
    for aView in txtFieldViews { aView.layer.cornerRadius = 8 }
    
}
    
    
    
// MARK: - LOGIN BUTTON
@IBAction func loginButt(sender: AnyObject) {
        dismissKeyboard()
        showHUD()
        
        let predicate = NSPredicate(format: "\(USER_USERNAME) = %@ AND \(USER_PASSWORD) = %@", usernameTxt.text!.lowercaseString, passwordTxt.text!)
        let query = CKQuery(recordType: USER_CLASS_NAME, predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error == nil {  dispatch_async(dispatch_get_main_queue()) {
                if results?.count > 0 {
                    currentUsername = self.usernameTxt.text!.lowercaseString
                    def.setObject(currentUsername, forKey: "currentUsername")
                    
                    self.navigationController?.popViewControllerAnimated(true)
                    self.hideHUD()
                } else {
                    let alert = UIAlertView(title: APP_NAME,
                        message: "No user found, try again!",
                        delegate: self,
                        cancelButtonTitle: "Retry",
                        otherButtonTitles: "Sign Up")
                    alert.show()
                    self.hideHUD()
                }
            
            }} else {  dispatch_async(dispatch_get_main_queue()) {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
            } } }
}
    
// AlertView delegate
func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
    if alertView.buttonTitleAtIndex(buttonIndex) == "Sign Up" {
            signupButt(self)
    }
        
        
        
    if alertView.buttonTitleAtIndex(buttonIndex) == "Next" {
            self.showHUD()
            print("\(alertView.textFieldAtIndex(0)!.text!)")
            
            let predicate = NSPredicate(format: "\(USER_EMAIL) = %@", (alertView.textFieldAtIndex(0)!.text)!)
            let query = CKQuery(recordType: USER_CLASS_NAME, predicate: predicate)
            publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
                if error == nil { dispatch_async(dispatch_get_main_queue()) {
                    
                    if results!.count == 1 {
                        self.userEmail = "\(results![0][USER_EMAIL]!)"
                        
                        let alert = UIAlertView(title: APP_NAME,
                            message: "Type a new password",
                            delegate: self,
                            cancelButtonTitle: "Cancel",
                            otherButtonTitles: "Change Password")
                        alert.alertViewStyle = .PlainTextInput
                        alert.textFieldAtIndex(0)?.keyboardAppearance = .Dark
                        alert.show()
                        self.hideHUD()
                        
                    } else {
                        self.simpleAlert("The email address you've entered is invalid, please try again!")
                        self.hideHUD()
                    }
                }} else { dispatch_async(dispatch_get_main_queue()) {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
            } } }
        }
        
        
        
        if alertView.buttonTitleAtIndex(buttonIndex) == "Change Password" {
            updateUserPassword(alertView.textFieldAtIndex(0)!.text!)
        }
    }
    
    
    
// MARK: - UPDATE CURRENT USER PASSWORD
func updateUserPassword(newPassword:String) {
        showHUD()
        
        let predicate = NSPredicate(format: "\(USER_EMAIL) = %@", userEmail)
        let query = CKQuery(recordType: USER_CLASS_NAME, predicate: predicate)
        publicDatabase.performQuery(query, inZoneWithID: nil) { (results, error) -> Void in
            if error == nil { dispatch_async(dispatch_get_main_queue()) {
                
                let theUser = results![0]
                theUser[USER_PASSWORD] = newPassword
                
                // Save new passowrd
                publicDatabase.saveRecord(theUser, completionHandler: { (record, error) -> Void in
                    if error == nil { dispatch_async(dispatch_get_main_queue()) {
                        print("NEW PASSWORD: \(theUser[USER_PASSWORD]!)")
                        self.hideHUD()
                        self.simpleAlert("Now you can login with your new password!")
                }} else { dispatch_async(dispatch_get_main_queue()) {
                        self.simpleAlert("\(error!.localizedDescription)")
                        self.hideHUD()
                } } })
       
            }} else { dispatch_async(dispatch_get_main_queue()) {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        } } }
        
    }
    
    
    
    
// MARK: - SIGNUP BUTTON
   @IBAction func signupButt(sender: AnyObject) {
        let signupVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignUp") as! SignUp
        self.navigationController?.pushViewController(signupVC, animated: true)
}
    
    
    
    // MARK: - TEXTFIELD DELEGATES
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTxt  {  passwordTxt.becomeFirstResponder() }
        if textField == passwordTxt  {  passwordTxt.resignFirstResponder() }
        return true
    }
    
    
    // MARK: - TAP TO DISMISS KEYBOARD
    @IBAction func tapToDismissKeyboard(sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
    func dismissKeyboard() {
        usernameTxt.resignFirstResponder()
        passwordTxt.resignFirstResponder()
    }
    
    
    
    // MARK: - FORGOT PASSWORD BUTTON
    @IBAction func forgotPasswButt(sender: AnyObject) {
        let alert = UIAlertView(title: APP_NAME,
            message: "Type the email address you used to register in \(APP_NAME)",
            delegate: self,
            cancelButtonTitle: "Cancel",
            otherButtonTitles: "Next")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.textFieldAtIndex(0)?.keyboardType = .EmailAddress
        alert.textFieldAtIndex(0)?.keyboardAppearance = .Dark
        alert.show()
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

