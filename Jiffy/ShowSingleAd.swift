/* =======================
 
 - Jiffy -
 
 made by Pawan Litt ©2016
 
 ==========================*/

import UIKit
import CloudKit
import MapKit
import GoogleMobileAds
import AudioToolbox
import MessageUI


class ShowSingleAd: UIViewController,
UIAlertViewDelegate,
UIScrollViewDelegate,
UITextFieldDelegate,
GADInterstitialDelegate,
MFMailComposeViewControllerDelegate,
MKMapViewDelegate
{

    /* Views */
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var adTitleLabel: UILabel!
    
    @IBOutlet var imagesScrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!
    @IBOutlet var imageButtons: [UIButton]!
    
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet var adDescrTxt: UITextView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet weak var websiteOutlet: UIButton!
    
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var messageTxt: UITextView!
    @IBOutlet var nameTxt: UITextField!
    @IBOutlet var emailTxt: UITextField!
    @IBOutlet var phoneTxt: UITextField!
    
    @IBOutlet var sendOutlet: UIButton!
    @IBOutlet weak var phoneCallOutlet: UIButton!
    @IBOutlet weak var reportUserButton: UIButton!
    
    @IBOutlet var imagePreviewView: UIView!
    @IBOutlet var imgScrollView: UIScrollView!
    @IBOutlet var imgPrev: UIImageView!
    
    
    var adMobInterstitial: GADInterstitial!
    
    
    
    /* Variables */
    var singleAdArray = NSMutableArray()
    var singleAdObj = CKRecord(recordType: CLASSIF_CLASS_NAME)
    
    var dataURL = NSData()
    var reqURL = NSURL()
    var request = NSMutableURLRequest()
    var receiverEmail = ""
    var postTitle = ""
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!
    var reportButt = UIButton()
    

    
    
    override func viewDidAppear(animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    }
    
    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    // Initialize a Report Button
    reportButt = UIButton(type: UIButtonType.Custom)
    reportButt.adjustsImageWhenHighlighted = false
    reportButt.frame = CGRectMake(0, 0, 22,22)
    reportButt.setBackgroundImage(UIImage(named: "flag"), forState: UIControlState.Normal)
    reportButt.addTarget(self, action: #selector(reportButt(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButt)
    
    
    // Init AdMob interstitial
    // Call AdMob Interstitial
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(60 * Double(NSEC_PER_SEC)))
    adMobInterstitial = GADInterstitial(adUnitID: ADMOB_UNIT_ID)
    adMobInterstitial.loadRequest(GADRequest())
    dispatch_after(delayTime, dispatch_get_main_queue()) {
        self.showInterstitial()
    }
    
    
    // Reset variables for Reply
    receiverEmail = ""
    postTitle = ""
    
    
    // Setup container ScrollView
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 1500)
    
    
    // Setup images ScrollView and their buttons
    image1.frame.origin.x = 0
    image2.frame.origin.x = imagesScrollView.frame.size.width
    image3.frame.origin.x = imagesScrollView.frame.size.width*2
    
    imageButtons[0].frame.origin.x = 0
    imageButtons[1].frame.origin.x = imagesScrollView.frame.size.width
    imageButtons[2].frame.origin.x = imagesScrollView.frame.size.width*2
    
    
    // Round views corners
    sendOutlet.layer.cornerRadius = 8
    phoneCallOutlet.layer.cornerRadius = 8

    
    imagePreviewView.frame = CGRectMake(0, 0, 0, 0)

    
    // Show Ad's details
    showAdDetails()
}


func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
    return imgPrev
}

    
func showAdDetails() {
    print("SINGLE AD: \(singleAdObj[CLASSIF_TITLE]!)")

    // Get Ad Title
    adTitleLabel.text = "\(singleAdObj[CLASSIF_TITLE]!)"
    self.title = "\(singleAdObj[CLASSIF_TITLE]!)"
    
     // Get image1
    let imageFile1 = singleAdObj[CLASSIF_IMAGE1] as? CKAsset
    if imageFile1 != nil {
        image1.image = UIImage(contentsOfFile: imageFile1!.fileURL.path!)
        pageControl.numberOfPages = 1
    }
    
    // Get image2
    let imageFile2 = singleAdObj[CLASSIF_IMAGE2] as? CKAsset
    if imageFile2 != nil {
        image2.image = UIImage(contentsOfFile: imageFile2!.fileURL.path!)
        pageControl.numberOfPages = 2
    }
    
    // Get image3
    let imageFile3 = singleAdObj[CLASSIF_IMAGE3] as? CKAsset
    if imageFile3 != nil {
        image3.image = UIImage(contentsOfFile: imageFile3!.fileURL.path!)
        pageControl.numberOfPages = 3
    }
    

    print("\(pageControl.numberOfPages)")
    imagesScrollView.contentSize = CGSizeMake(imagesScrollView.frame.size.width * CGFloat(pageControl.numberOfPages), imagesScrollView.frame.size.height)

    
    // Get Ad Price
    priceLabel.text = "\(singleAdObj[CLASSIF_PRICE]!)"
    
    // Get Ad Date
    let adDate = singleAdObj[CLASSIF_CREATION_DATE] as! NSDate
    let dateFormat = NSDateFormatter()
    dateFormat.dateFormat = "MMM/dd/yyyy"
    dateLabel.text = dateFormat.stringFromDate(adDate)
    
    
    // Get Ad Description
    adDescrTxt.text = "\(singleAdObj[CLASSIF_DESCRIPTION]!)"
    
    // Get Ad Address
    addressLabel.text = "\(singleAdObj[CLASSIF_ADDRESS_STRING]!)"
    addPinOnMap(addressLabel.text!)

    
    // Get userPointer
    let userRef = singleAdObj[CLASSIF_USER_POINTER] as! CKReference
    publicDatabase.fetchRecordWithID(userRef.recordID) { (userPointer, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {
            self.usernameLabel.text = "\(userPointer![USER_USERNAME]!)"
    
            // Check if user has provided a website
            if userPointer![USER_WEBSITE] != nil { self.websiteOutlet.setTitle("\(userPointer![USER_WEBSITE]!)", forState: .Normal)
            } else { self.websiteOutlet.setTitle("N/D", forState: .Normal) }
            
            
            // Check if the user has provided a phone number
            if userPointer![USER_PHONE] == nil { self.phoneCallOutlet.hidden = true
            } else { self.phoneCallOutlet.hidden = false }
        
    } } }

    
    
}
    
    
    
// OPEN SELLER'S WEBSITE (IF IT EXISTS)
@IBAction func websiteButt(sender: AnyObject) {
    let butt = sender as! UIButton
    let webStr = "\(butt.titleLabel!.text!)"
    if webStr != "N/D" {
        let webURL = NSURL(string: webStr)
        UIApplication.sharedApplication().openURL(webURL!)
    }
}
 
    
    
    
// MARK: - ADMOB INTERSTITIAL DELEGATES
func showInterstitial() {
    // Show AdMob interstitial
    if adMobInterstitial.isReady {
        adMobInterstitial.presentFromRootViewController(self)
        print("present Interstitial")
    }
}

    
    
//MARK: - ADD A PIN ON THE MAP
func addPinOnMap(address: String) {
    mapView.delegate = self
    
    if mapView.annotations.count != 0 {
            annotation = mapView.annotations[0] 
            mapView.removeAnnotation(annotation)
    }
        // Make a search on the Map
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = address
        localSearch = MKLocalSearch(request: localSearchRequest)
            
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            // Place not found or GPS not available
            if localSearchResponse == nil  {
                let alert = UIAlertView(title: APP_NAME,
                message: "Place not found, or GPS not available",
                delegate: nil,
                cancelButtonTitle: "Try again" )
                alert.show()
            }
                
            // Add PointAnnonation text and a Pin to the Map
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.adTitleLabel.text
            self.pointAnnotation.subtitle = self.addressLabel.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
                
            self.pinView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
                self.mapView.addAnnotation(self.pinView.annotation!)
                
            // Zoom the Map to the location
            self.region = MKCoordinateRegionMakeWithDistance(self.pointAnnotation.coordinate, 1000, 1000);
            self.mapView.setRegion(self.region, animated: true)
            self.mapView.regionThatFits(self.region)
            self.mapView.reloadInputViews()
        }
}

 
    
// MARK: - ADD RIGHT CALLOUT TO OPEN IN IOS MAPS APP
func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Handle custom annotations.
        if annotation.isKindOfClass(MKPointAnnotation) {
            
            // Try to dequeue an existing pin view first.
            let reuseID = "CustomPinAnnotationView"
            var annotView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseID)
            
            if annotView == nil {
                annotView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
                annotView!.canShowCallout = true
                
                // Custom Pin image
                let imageView = UIImageView(frame: CGRectMake(0, 0, 32, 32))
                imageView.image =  UIImage(named: "locationButt")
                imageView.center = annotView!.center
                imageView.contentMode = UIViewContentMode.ScaleAspectFill
                annotView!.addSubview(imageView)
                
                // Add a RIGHT CALLOUT Accessory
                let rightButton = UIButton(type: UIButtonType.Custom)
                rightButton.frame = CGRectMake(0, 0, 32, 32)
                rightButton.layer.cornerRadius = rightButton.bounds.size.width/2
                rightButton.clipsToBounds = true
                rightButton.setImage(UIImage(named: "openInMaps"), forState: UIControlState.Normal)
                annotView!.rightCalloutAccessoryView = rightButton
            }
    return annotView
    }
        
return nil
}
    
    
    
// MARK: - OPEN THE NATIVE iOS MAPS APP
func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    annotation = view.annotation
    let coordinate = annotation.coordinate
    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
    let mapitem = MKMapItem(placemark: placemark)
    mapitem.name = annotation.title!
    mapitem.openInMapsWithLaunchOptions(nil)
}
    

    
    
    
// MARK: - SCROLLVIEW DELEGATE
func scrollViewDidScroll(scrollView: UIScrollView) {
    // switch pageControl to current page
    let pageWidth = imagesScrollView.frame.size.width
    let page = Int(floor((imagesScrollView.contentOffset.x * 2 + pageWidth) / (pageWidth * 2)))
    pageControl.currentPage = page
}
    
    
// MARK: - TEXTFIELD DELEGATE
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == nameTxt { emailTxt.becomeFirstResponder() }
    if textField == emailTxt { phoneTxt.becomeFirstResponder() }
    if textField == phoneTxt { phoneTxt.resignFirstResponder() }
        
return true
}
    
    
    
    
// MARK: - SEND REPLY BUTTON
@IBAction func sendReplyButt(sender: AnyObject) {
    
    // Get userPointer
    let userRef = singleAdObj[CLASSIF_USER_POINTER] as! CKReference
    publicDatabase.fetchRecordWithID(userRef.recordID) { (userPointer, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {
            
            self.receiverEmail = "\(userPointer![USER_EMAIL]!)"
            self.postTitle = self.adTitleLabel.text!
            print("RECEIVER EMAIL: \(self.receiverEmail)")
            
            if self.messageTxt.text != "" &&  self.emailTxt.text != ""  &&  self.nameTxt.text != "" {
   
                let strURL = "\(PATH_TO_PHP_FILE)sendReply.php?name=\(self.nameTxt.text!)&fromEmail=\(self.emailTxt.text!)&tel=\(self.phoneTxt.text!)&messageBody=\(self.messageTxt.text!)&receiverEmail=\(self.receiverEmail)&postTitle=\(self.postTitle)"
                self.reqURL = NSURL(string: strURL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())! )!
                self.request = NSMutableURLRequest()
                self.request.URL = self.reqURL
                self.request.HTTPMethod = "GET"
                let connection = NSURLConnection(request: self.request, delegate: self, startImmediately: true)
                print("REQUEST URL: \(self.reqURL) - \(connection!.description)")
                
                self.simpleAlert("Thanks, You're reply has been sent!")
                
                
            // SOME REQUIRED FIELD IS EMPTY...
            } else { self.simpleAlert("Please fill all the required fields.") }
    } } }

}
    
 
    
    
// MARK: - PHONE CALL BUTTON
@IBAction func phoneCallButt(sender: AnyObject) {
    
    // Get userPointer
    let userRef = singleAdObj[CLASSIF_USER_POINTER] as! CKReference
    publicDatabase.fetchRecordWithID(userRef.recordID) { (userPointer, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {
    
        let aURL = NSURL(string: "telprompt://\(userPointer![USER_PHONE]!)")!
        if UIApplication.sharedApplication().canOpenURL(aURL) {
            UIApplication.sharedApplication().openURL(aURL)
        } else { dispatch_async(dispatch_get_main_queue()) {
            self.simpleAlert("This device can't make phone calls")
        }}
    }}}
}
    
    
    
 
// MARK: - REPORT INAPPROPRIATE AD BUTTON
func reportButt(sender:UIButton) {
   
    let mailComposer = MFMailComposeViewController()
    mailComposer.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    mailComposer.mailComposeDelegate = self
    mailComposer.setToRecipients([MY_REPORT_EMAIL_ADDRESS])
    mailComposer.setSubject("Reporting Inappropriate Ad")
    
    mailComposer.setMessageBody("Hello,<br>I am reporting an ad with ID: <strong>\(singleAdObj.recordID.recordName)</strong><br> and Title: <strong>\(singleAdObj[CLASSIF_TITLE]!)</strong><br>since it contains inappropriate contents and violates the Terms of Use of this App.<br><br>Please moderate this post.<br><br>Thank you very much,<br>Regards.", isHTML: true)
    
    if MFMailComposeViewController.canSendMail() {
        presentViewController(mailComposer, animated: true, completion: nil)
    } else {
        let alert = UIAlertView(title: APP_NAME,
        message: "Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.",
        delegate: nil,
        cancelButtonTitle: "OK")
        alert.show()
    }
}
    
// Email delegate
func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
        var outputMessage = ""
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:  outputMessage = "Mail cancelled"
        case MFMailComposeResultSaved.rawValue:  outputMessage = "Mail saved"
        case MFMailComposeResultSent.rawValue:  outputMessage = "Thanks for reporting this post. We will check it out asap and moderate it"
        case MFMailComposeResultFailed.rawValue:  outputMessage = "Something went wrong with sending Mail, try again later."
        default: break
        }
    let alert = UIAlertView(title: APP_NAME,
    message: outputMessage,
    delegate: nil,
    cancelButtonTitle: "Ok" )
    alert.show()
        
    dismissViewControllerAnimated(false, completion: nil)
}

// MARK: - REPORT INAPPROPRIATE USER BUTTON
@IBAction func reportUser(sender: AnyObject) {
    
    
    // Get userPointer
    let userRef = singleAdObj[CLASSIF_USER_POINTER] as! CKReference
    publicDatabase.fetchRecordWithID(userRef.recordID) { (userPointer, error) -> Void in
        if error == nil { dispatch_async(dispatch_get_main_queue()) {

            let mailComposer = MFMailComposeViewController()
            mailComposer.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 1.0)
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients([MY_REPORT_EMAIL_ADDRESS])
            mailComposer.setSubject("Reporting Inappropriate Ad")
            
            mailComposer.setMessageBody("Hello,<br>I am reporting user with ID: <strong>\("\(userPointer![USER_USERNAME]!)")</strong><br>since the user violates the Terms of Use of this App.<br><br>Please moderate this user.<br><br>Thank you very much,<br>Regards.", isHTML: true)
            
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposer, animated: true, completion: nil)
            } else {
                let alert = UIAlertView(title: APP_NAME,
                                        message: "Your device cannot send emails. Please configure an email address into Settings -> Mail, Contacts, Calendars.",
                                        delegate: nil,
                                        cancelButtonTitle: "OK")
                alert.show()
            }
            }
        }
    }
}


    
    
// MARK: - SHOW IMAGE PREVIEW BUTTON
@IBAction func showImagePreviewButt(sender: AnyObject) {
    let butt = sender as! UIButton
    
    var imageFile:CKAsset?
    
    switch butt.tag {
        case 0: imageFile = singleAdObj[CLASSIF_IMAGE1] as? CKAsset
        case 1: imageFile = singleAdObj[CLASSIF_IMAGE2] as? CKAsset
        case 2: imageFile = singleAdObj[CLASSIF_IMAGE3] as? CKAsset
    default:break }
    
    
    if imageFile != nil {
        imgPrev.image = UIImage(contentsOfFile: imageFile!.fileURL.path!)
        showImagePrevView()
    }
}
  
    
// MARK: - TAP ON IMAGE TO CLOSE PREVIEW
@IBAction func tapToClosePreview(sender: UITapGestureRecognizer) {
    hideImagePrevView()
}
    
    
// MARK: - SHOW/HIDE PREVIEW IMAGE VIEW
func showImagePrevView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.imagePreviewView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
    }, completion: { (finished: Bool) in  })
}
func hideImagePrevView() {
    imgPrev.image = nil
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.imagePreviewView.frame = CGRectMake(0, 0, 0, 0)
    }, completion: { (finished: Bool) in  })
}
    
    


    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
