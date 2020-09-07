// (C) 2017-2020 - The Woorti app is a research (non-commercial) application that was
// developed in the context of the European research project MoTiV (motivproject.eu). The
// code was developed by partner INESC-ID with contributions in graphics design by partner
// TIS. The Woorti app development was one of the outcomes of a Work Package of the MoTiV
// project.
 
// The Woorti app was originally intended as a tool to support data collection regarding
// mobility patterns from city and country-wide campaigns and provide the data and user
// management to campaign managers.
 
// The Woorti app development followed an agile approach taking into account ongoing
// feedback of partners and testing users while continuing under development. This has
// been carried out as an iterative process deploying new app versions. Along the 
// timeline, various previously unforeseen requirements were identified, some requirements
// Were revised, there were requests for modifications, extensions, or new aspects in
// functionality or interaction as found useful or interesting to campaign managers and
// other project partners. Most stemmed naturally from the very usage and ongoing testing
// of the Woorti app. Hence, code and data structures were successively revised in a
// way not only to accommodate this but, also importantly, to maintain compatibility with
// the functionality, data and data structures of previous versions of the app, as new
// version roll-out was never done from scratch.

// The code developed for the Woorti app is made available as open source, namely to
// contribute to further research in the area of the MoTiV project, and the app also makes
// use of open source components as detailed in the Woorti app license. 
 
// This project has received funding from the European Union’s Horizon 2020 research and
// innovation programme under grant agreement No. 770145.
 
// This file is part of the Woorti app referred to as SOFTWARE.
import UIKit
import CoreLocation

/*
 * Onboarding view to request Location and Notifications permissions.
 */
class OnboardingPermissionsViewController: GenericViewController, CLLocationManagerDelegate {

    @IBOutlet weak var PermissionTextLabel: UITextView!
    @IBOutlet weak var NextButton: UIButton!
    
    @IBOutlet weak var imageOfPermission: UIImageView!
    
    @IBOutlet weak var contentPage: UIView!
    private var type = permissionType.location
    private var man: CLLocationManager?
    
    enum permissionType {
        case location
        case locationNecessary
        case notification
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadContent()
        // Do any additional setup after loading the view.
    }
    
    func LoadContent(){
        
        MotivAuxiliaryFunctions.RoundView(view: contentPage)
        self.view.backgroundColor = UIColor.clear
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.NextButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Ok_Cool", comment: "message: Ok cool", boldText: true, size: 17, disabled: false, CompleteRoundCorners: true)
        
        MotivFont.motivRegularFontFor(key: "Ask_location_permission_String", comment: "message: Thanks! To record your trips we need your permission to let Woorti access to your location at all times.\n\nIt should not excessively consume your battery.", tv: PermissionTextLabel, size: 15)
        
        switch type {
        case .location:
            MotivFont.motivRegularFontFor(key: "Ask_location_permission_String", comment: "message: Thanks! To record your trips we need your permission to let Woorti access to your location at all times.\n\nIt should not excessively consume your battery.", tv: PermissionTextLabel, size: 15)
            self.imageOfPermission.image = UIImage(named: "Location_permission")
        case .notification:
            
            MotivFont.motivRegularFontFor(key: "Ask_notification_permission_String", comment: "message: Lastly, we will be asking you questions regarding your experiences as you travel. Your opinion really matters to us! \n\n To do this we need to be able to send you notifications", tv: PermissionTextLabel, size: 15)
            self.imageOfPermission.image = UIImage(named: "Notification_Permission")
        case .locationNecessary:
            
            MotivFont.motivRegularFontFor(key: "Ask_location_permission_String_when_user_has_denied", comment: "message: Sorry! For Woorti to function properly we really need that you allow it to access your location at all times.", tv: PermissionTextLabel, size: 15)
            self.imageOfPermission.image = UIImage(named: "Location_permission")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            type = .notification
            self.LoadContent()
        case .notDetermined:
            return
        default:
            type = .locationNecessary
            self.LoadContent()
        }
        self.man = nil
    }
    
    fileprivate func requestLocalization() {
        if Thread.isMainThread {
            self.man = CLLocationManager()
            self.man!.delegate = self
            self.man!.requestAlwaysAuthorization()
        } else {
            DispatchQueue.main.async {
                self.requestLocalization()
            }
        }
    }
    
    @IBAction func NextButtonClick(_ sender: Any) {
        
        let alertController = UIAlertController(title: "GPS", message: NSLocalizedString("Ask_location_permission_String_when_user_has_denied", comment: ""), preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: NSLocalizedString("GPS_Link_Phone_Settings", comment: ""), style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
            
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("GPS_Go_Back", comment: ""), style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        switch CLLocationManager.authorizationStatus() {
        case .denied, .restricted, .authorizedWhenInUse:
            self.present(alertController, animated: true, completion: nil)
        case .notDetermined:
            requestLocalization()
        default:
                UserInfo.appDelegate?.requestAuthorization()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: OnboardingTopAndContentViewController.OboardViews.OBVGOTOchangeToWYName.rawValue), object: nil)
        }
        
        
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
