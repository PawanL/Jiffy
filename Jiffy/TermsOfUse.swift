/* =======================
 
 - Jiffy -
 
 made by Pawan Litt ©2016
 
 ==========================*/


import UIKit

class TermsOfUse: UIViewController {

    /* Views */
    @IBOutlet var webView: UIWebView!
    
    
   
override func viewDidLoad() {
        super.viewDidLoad()
    
    let url = NSBundle.mainBundle().URLForResource("tou", withExtension: "html")
    webView.loadRequest(NSURLRequest(URL: url!))

}

    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    }
    
    
// DISMISS BUTTON
@IBAction func dismissButt(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
