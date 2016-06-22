/* =======================
 
 - Jiffy -
 
 made by Pawan Litt ©2016
 
 ==========================*/


import UIKit
import CloudKit
import MapKit
import CoreLocation
import AddressBook


class Post: UIViewController,
UIPickerViewDataSource,
UIPickerViewDelegate,
UITextFieldDelegate,
UITextViewDelegate,
CLLocationManagerDelegate,
UIAlertViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
{

    /* Views */
    @IBOutlet var categoryContainer: UIView!
    @IBOutlet var categoryPickerView: UIPickerView!
    
    @IBOutlet var titlelabel: UILabel!
    @IBOutlet var containerScrollView: UIScrollView!
    @IBOutlet var titleTxt: UITextField!
    @IBOutlet var categoryTxt: UITextField!
    @IBOutlet var priceTxt: UITextField!
    @IBOutlet var addressTxt: UITextField!
    @IBOutlet var descrTxt: UITextView!
    
    @IBOutlet var mapView: MKMapView!

    @IBOutlet var buttonsImage: [UIButton]!
    var buttTAG = Int()
    @IBOutlet var image1: UIImageView!
    @IBOutlet var image2: UIImageView!
    @IBOutlet var image3: UIImageView!

    @IBOutlet var postAdOutlet: UIButton!
    
    @IBOutlet var deleteAdOutlet: UIButton!
    
    
    
    /* Variables */
    var classifArray = NSMutableArray()
    var favoritesArray = NSMutableArray()
    var locationManager: CLLocationManager!
    
    var annotation:MKAnnotation!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinView:MKPinAnnotationView!
    var region: MKCoordinateRegion!
    var coordinates: CLLocationCoordinate2D!
    
    
    var postObj = CKRecord(recordType: CLASSIF_CLASS_NAME)
    var image1URL = NSURL()
    var image2URL = NSURL()
    var image3URL = NSURL()
    var image1Path = String()
    var image2Path = String()
    var image3Path = String()
    

    
    
override func viewDidLoad() {
        super.viewDidLoad()
    
    navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 199.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    
    let postAlert = UIAlertView(title: APP_NAME,
                                 message: "By posting you are agreeing to the terms of use of Jiffy",
                                 delegate: nil,
                                 cancelButtonTitle: "OK")
    postAlert.show()
    
    // Round views corners
    deleteAdOutlet.layer.cornerRadius = 8
    
    print("POST OBJ: \(postObj[CLASSIF_TITLE])")
    
    image1Path = ""
    image2Path = ""
    image3Path = ""
    
    
    // Check if you are about to update an Ad
    if postObj[CLASSIF_TITLE] != nil {
        titlelabel.text = "Edit your Ad"
        print("postObj: \(postObj[CLASSIF_TITLE]!)")
        postAdOutlet.setTitle("Update", forState: UIControlState.Normal)
        deleteAdOutlet.hidden = false
        showAdDetails()
    } else {
        deleteAdOutlet.hidden = true
    }

    
    // Setup views
    categoryContainer.frame.origin.y = view.frame.size.height
    containerScrollView.contentSize = CGSizeMake(containerScrollView.frame.size.width, 800)
    view.bringSubviewToFront(categoryContainer)

    
    // Setup buttons to load Ad images
    for button in buttonsImage {
        button.addTarget(self, action: #selector(buttImageTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
}
    

// MARK: - SHOW YOUR AD'S DETAILS
func showAdDetails() {
    
    titleTxt.text = "\(postObj[CLASSIF_TITLE]!)"
    categoryTxt.text = "\(postObj[CLASSIF_CATEGORY]!)"
    priceTxt.text = "\(postObj[CLASSIF_PRICE]!)"
    descrTxt.text = "\(postObj[CLASSIF_DESCRIPTION]!)"
    addressTxt.text = "\(postObj[CLASSIF_ADDRESS_STRING]!)"
    
    addPinOnMap(addressTxt.text!)
    
    // Get image1
    let imageFile1 = postObj[CLASSIF_IMAGE1] as? CKAsset
    if imageFile1 != nil { image1.image = UIImage(contentsOfFile: imageFile1!.fileURL.path!) }
    
    // Get image2
    let imageFile2 = postObj[CLASSIF_IMAGE2] as? CKAsset
    if imageFile2 != nil { image2.image = UIImage(contentsOfFile: imageFile2!.fileURL.path!) }
    
    // Get image3
    let imageFile3 = postObj[CLASSIF_IMAGE3] as? CKAsset
    if imageFile3 != nil { image3.image = UIImage(contentsOfFile: imageFile3!.fileURL.path!) }
    
}

    
// MARK: - BUTTON FOR IMAGES
func buttImageTapped(sender: UIButton) {
    let button = sender as UIButton
    buttTAG = button.tag
    
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
    
    // OPEN DEVICE'S CAMERA
    if alertView.buttonTitleAtIndex(buttonIndex) == "Take a picture" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
            
        
    // PICK A PHOTO FROM LIBRARY
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Choose from Library" {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
                imagePicker.allowsEditing = false
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        
        
        
    // DELETE AD
    } else if alertView.buttonTitleAtIndex(buttonIndex) == "Delete Ad" {
        publicDatabase.deleteRecordWithID(postObj.recordID, completionHandler: { (recID, error) -> Void in
            if error == nil { dispatch_async(dispatch_get_main_queue()) {

                    let predicate = NSPredicate(format: "\(FAV_AD_POINTER) = %@", self.postObj)
                    let query = CKQuery(recordType: FAV_CLASS_NAME, predicate: predicate)
            
                    publicDatabase.performQuery(query, inZoneWithID: nil) { (favorites, error) -> Void in
                            if error == nil { dispatch_async(dispatch_get_main_queue()) {
                                
                                if favorites!.count != 0 {
                                    for i in 0..<favorites!.count {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            let favClass = favorites![i] 
                                            
                                            publicDatabase.deleteRecordWithID(favClass.recordID, completionHandler: { (recID, error) -> Void in
                                                if error == nil { dispatch_async(dispatch_get_main_queue()) {
                                                    
                                                }} else { self.simpleAlert("\(error!.localizedDescription)")
                                            }})
                                }}}
                                self.dismissViewControllerAnimated(true, completion: nil)
                                
                                
                            }} else { dispatch_async(dispatch_get_main_queue()) {
                                self.simpleAlert("\(error!.localizedDescription)")
                                self.hideHUD()
                    } } }
                        
            }} else { self.simpleAlert("\(error!.localizedDescription)") }
        })
     
        
                        
    }
}
    
// MARK: -  ImagePicker delegate
func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    let image = info[UIImagePickerControllerOriginalImage] as! UIImage
    
    // Assign Images
    switch buttTAG {
    case 0:
        image1.image = image
        
        let dirPaths = NSSearchPathForDirectoriesInDomains( .DocumentDirectory, .UserDomainMask, true)
        let docsDir: AnyObject = dirPaths[0]
        image1Path = docsDir.stringByAppendingPathComponent("image1.jpg")
        UIImageJPEGRepresentation(image1.image!, 0.5)!.writeToFile(image1Path, atomically: true)
        image1URL = NSURL(fileURLWithPath: image1Path)
        print("image1URL: \(image1URL)")
        
    case 1:
        image2.image = image
        
        let dirPaths = NSSearchPathForDirectoriesInDomains( .DocumentDirectory, .UserDomainMask, true)
        let docsDir: AnyObject = dirPaths[0]
        image2Path = docsDir.stringByAppendingPathComponent("image2.jpg")
        UIImageJPEGRepresentation(image2.image!, 0.5)!.writeToFile(image2Path, atomically: true)
        image2URL = NSURL(fileURLWithPath: image2Path)
        print("image2URL: \(image2URL)")
        
    case 2:
        image3.image = image
        
        let dirPaths = NSSearchPathForDirectoriesInDomains( .DocumentDirectory, .UserDomainMask, true)
        let docsDir: AnyObject = dirPaths[0]
        image3Path = docsDir.stringByAppendingPathComponent("image3.jpg")
        UIImageJPEGRepresentation(image3.image!, 0.5)!.writeToFile(image3Path, atomically: true)
        image3URL = NSURL(fileURLWithPath: image3Path)
        print("image3URL: \(image3URL)")
        
    default: break }
        
   
        
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
    
    
    
// MARK: - SET CURRENT LOCATION BUTTON
@IBAction func setCurrentLocationButt(sender: AnyObject) {
    // Init LocationManager
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
   
    if locationManager.respondsToSelector(#selector(CLLocationManager.requestWhenInUseAuthorization)) {
        locationManager.requestAlwaysAuthorization()
     }
    
    
    locationManager.startUpdatingLocation()
}
    
    
    
// MARK: - CORE LOCATION MANAGER -> GET CURRENT LOCATION OF THE USER
func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("didFailWithError: %@", error)
    
    let errorAlert = UIAlertView(title: APP_NAME,
        message: "Failed to Get Your Location",
        delegate: nil,
        cancelButtonTitle: "OK")
    errorAlert.show()
}
func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {

    locationManager.stopUpdatingLocation()
    
    let geoCoder = CLGeocoder()
    geoCoder.reverseGeocodeLocation(newLocation, completionHandler: { (placemarks, error) -> Void in
        
        let placeArray:[CLPlacemark] = placemarks!
        var placemark: CLPlacemark!
        placemark = placeArray[0]
        
        // Street
        let street = placemark.addressDictionary?["Street"] as? String ?? ""
        // City
        let city = placemark.addressDictionary?["City"] as? String ?? ""
        // Zip code
        let zip = placemark.addressDictionary?["ZIP"] as? String ?? ""
        // State
        let state = placemark.addressDictionary?["State"] as? String ?? ""
        // Country
        let country = placemark.addressDictionary?["Country"] as? String ?? ""

        // Show address on addressTxt
        self.addressTxt.text = "\(street), \(zip), \(city), \(state), \(country)"
        // Add a Pin to the Map
        if self.addressTxt!.text! != "" {  self.addPinOnMap(self.addressTxt.text!)  }
        
    })
    
}

    
// MARK: - ADD A PIN ON THE MAP
func addPinOnMap(address: String) {

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
  
    } else {
        // Add PointAnnonation text and a Pin to the Map
        self.pointAnnotation = MKPointAnnotation()
        self.pointAnnotation.title = self.titleTxt.text
        self.pointAnnotation.subtitle = self.addressTxt.text
        self.pointAnnotation.coordinate = CLLocationCoordinate2D( latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:localSearchResponse!.boundingRegion.center.longitude)
        
        // Store coordinates (to use later while posting the Ad)
        self.coordinates = self.pointAnnotation.coordinate
        
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
}
    
    
    
// MARK: -  TEXTFIELD DELEGATE
func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
    if textField == categoryTxt {
        showCatPickerView()
        titleTxt.resignFirstResponder()
        priceTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
    
return true
}
    
func textFieldDidBeginEditing(textField: UITextField) {
    if textField == categoryTxt {
        showCatPickerView()
        titleTxt.resignFirstResponder()
        priceTxt.resignFirstResponder()
        categoryTxt.resignFirstResponder()
    }
    
}
func textFieldDidEndEditing(textField: UITextField) {
    // Get address for the Map
    if textField == addressTxt {
        if addressTxt.text != "" {  addPinOnMap(addressTxt.text!)  }
    }
}
    
func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == titleTxt {  categoryTxt.becomeFirstResponder(); hideCatPickerView()  }
    if textField == priceTxt {  descrTxt.becomeFirstResponder()  }
    
    if textField == addressTxt {  addressTxt.resignFirstResponder()  }
    
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
    
   
    
    
    
    
// MARK: - POST NEW AD / UPDATE AD BUTTON
@IBAction func postAdButt(sender: AnyObject) {
    showHUD()

    
    // POST A NEW AD -----------------------------------------------------------------------
    if postObj[CLASSIF_TITLE] == nil {
        
        // Save the ad if there's a Title
        if titleTxt.text == "" || addressTxt.text == "" {
            simpleAlert("You have to insert a Title and a Location for this Ad!")
            self.hideHUD()
            
        } else {

            // Save userPointer
            let currUserRef = CKReference(record: CurrentUser, action: .None)
            postObj[CLASSIF_USER_POINTER] = currUserRef
    
            // Save other data
            postObj[CLASSIF_TITLE] = titleTxt.text
            postObj[CLASSIF_TITLE_LOWERCASE] = titleTxt.text!.lowercaseString
            postObj[CLASSIF_CATEGORY] = categoryTxt.text
            postObj[CLASSIF_PRICE] = priceTxt.text
        	postObj[CLASSIF_DESCRIPTION] = descrTxt.text
            postObj[CLASSIF_ADDRESS_STRING] = addressTxt.text!.lowercaseString
        
            if coordinates != nil {
                let geoPoint = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
                postObj[CLASSIF_ADDRESS] = geoPoint
            }
        
            // Save Image1
            if image1Path != "" {
                let imageFile = CKAsset(fileURL: image1URL)
                postObj[CLASSIF_IMAGE1] = imageFile
            }
    
            // Save Image2
            if image2Path != "" {
                let imageFile = CKAsset(fileURL: image2URL)
                postObj[CLASSIF_IMAGE2] = imageFile
            }
    
            // Save Image3
            if image3Path != "" {
                let imageFile = CKAsset(fileURL: image3URL)
                postObj[CLASSIF_IMAGE3] = imageFile
            }

            print("\(image1Path) - \(image2Path) - \(image3Path)")
        
            publicDatabase.saveRecord(postObj, completionHandler: { (record, error) -> Void in
                if error == nil { dispatch_async(dispatch_get_main_queue()) {
                    self.simpleAlert("Your Ad has been successfully post!")
                    self.hideHUD()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }} else {
                    self.simpleAlert("\(error!.localizedDescription)")
                    self.hideHUD()
                }})
        }
        
        
        
        
    // UPDATE SELECTED AD ----------------------------------------------------------------------
    } else {
        
        // Save userPointer
        let currUserRef = CKReference(record: CurrentUser, action: .None)
        postObj[CLASSIF_USER_POINTER] = currUserRef
                
        // Save other data
        postObj[CLASSIF_TITLE] = self.titleTxt.text
        postObj[CLASSIF_TITLE_LOWERCASE] = self.titleTxt.text!.lowercaseString
        postObj[CLASSIF_CATEGORY] = self.categoryTxt.text
        postObj[CLASSIF_PRICE] = self.priceTxt.text
        postObj[CLASSIF_DESCRIPTION] = self.descrTxt.text
        postObj[CLASSIF_ADDRESS_STRING] = self.addressTxt.text!.lowercaseString
                
        if self.coordinates != nil {
            let geoPoint = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            postObj[CLASSIF_ADDRESS] = geoPoint
        }
                
        // Save Image1
        if image1Path != "" {
            let imageFile = CKAsset(fileURL: image1URL)
            postObj[CLASSIF_IMAGE1] = imageFile
        }
        
        // Save Image2
        if image2Path != "" {
            let imageFile = CKAsset(fileURL: image2URL)
            postObj[CLASSIF_IMAGE2] = imageFile
        }
        
        // Save Image3
        if image3Path != "" {
            let imageFile = CKAsset(fileURL: image3URL)
            postObj[CLASSIF_IMAGE3] = imageFile
        }
        
        
        // Saving block
        publicDatabase.saveRecord(postObj, completionHandler: { (record, error) -> Void in
            if error == nil { dispatch_async(dispatch_get_main_queue()) {
                self.simpleAlert("Your Ad has been successfully updated!")
                self.hideHUD()
                self.dismissViewControllerAnimated(true, completion: nil)
            }} else {
                self.simpleAlert("\(error!.localizedDescription)")
                self.hideHUD()
        }})
        
    }
    
}
    
    
// MARK: - DELETE AD BUTTON
@IBAction func deleteAdButt(sender: AnyObject) {
    let alert = UIAlertView(title: APP_NAME,
    message: "Are you sure you want to delete this Ad?",
    delegate: self,
    cancelButtonTitle: "No",
    otherButtonTitles: "Delete Ad")
    alert.show()
}
 
    
    
// MARK: - CANCEL BUTTON
@IBAction func cancelButt(sender: AnyObject) {
    dismissViewControllerAnimated(true, completion: nil)
}
    
    
    
// MARK: - PICKERVIEW DONE BUTTON
@IBAction func doneButt(sender: AnyObject) {
    hideCatPickerView()
}
    

// MARK: - TAP TO DISMISS KEYBOARD
@IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
    titleTxt.resignFirstResponder()
    categoryTxt.resignFirstResponder()
    priceTxt.resignFirstResponder()
    addressTxt.resignFirstResponder()
    descrTxt.resignFirstResponder()
}
    
    
// MARK: - SHOW/HIDE CATEGORY PICKERVIEW
func showCatPickerView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.view.frame.size.height - self.categoryContainer.frame.size.height
        }, completion: { (finished: Bool) in  });
}
func hideCatPickerView() {
    UIView.animateWithDuration(0.1, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: {
        self.categoryContainer.frame.origin.y = self.view.frame.size.height
    }, completion: { (finished: Bool) in  });
}
    
    
    


    

    
override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
}
}
