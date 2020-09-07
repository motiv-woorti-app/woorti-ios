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

class MTTopBarViewController: UIViewController {

    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var MapImage: UIImageView!
    @IBOutlet weak var ProgressBar: UIProgressView!
    
    @IBOutlet weak var PointsToAward: UILabel!
    @IBOutlet weak var pointsAwarded: UILabel!
    @IBOutlet weak var backButton: UIButton!
    private var MyTripsFillInStage = Float(0)
    private let MyTripsStageCount = Float(4)
    public var ft: FullTrip?
    var points = 0.0
    var pointsToShow = 0
    
    var pointsReceived = [Int]()
    
    public static var disableButtons = "MTTopBarViewControllerDisableButtons"
    public static var updateTopBarPoints = "UpdateTopBarPoints"
    
    @IBAction func clickBack(_ sender: Any) {
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsBack.rawValue), object: nil)
    }
    
    func loadProgressBar(newIndex: Float) {
        if newIndex < self.MyTripsFillInStage || newIndex > MyTripsStageCount {
            return
        }
        self.MyTripsFillInStage = newIndex
        self.ProgressBar.progress = MyTripsFillInStage.divided(by: MyTripsStageCount)
        
        MotivFont.motivRegularFontFor(text: "\(pointsToShow) pts", label: pointsAwarded, size: 11)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.pointsAwarded, color: UIColor.white)
    }
    
    // function to show the points to add
    func pointsToAdd(points: Double) {
        self.points = points
        if PointsToAward != nil {
            MotivFont.motivRegularFontFor(text: "+ \(points) /", label: PointsToAward, size: 11)
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: PointsToAward, color: MotivColors.WoortiOrangeT1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editFT)))
        MapImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mapFT)))
        NotificationCenter.default.addObserver(self, selector: #selector(disable), name:  NSNotification.Name(rawValue:  MTTopBarViewController.disableButtons), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePoints(_:)), name:  NSNotification.Name(rawValue:  MTTopBarViewController.updateTopBarPoints), object: nil)
       
        // Do any additional setup after loading the view.
        loadImage(image: editImage)
        loadImage(image: MapImage)
        
        self.loadProgressBar(newIndex: self.MyTripsFillInStage)
        self.ProgressBar.transform = self.ProgressBar.transform.scaledBy(x: 1, y: 5)
        
        backButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        
        MapImage.image = MapImage.image?.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
        editImage.image = editImage.image?.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
        pointsToAdd(points: self.points)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func editFT(){
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsEditTrip.rawValue), object: nil)
    }
    
    @objc func mapFT(){
        NotificationCenter.default.post( name: NSNotification.Name(rawValue: MyTripsGenericViewController.MTViews.MyTripsMapTrip.rawValue), object: nil)
    }
    
    @objc func disable(){
        editImage.isUserInteractionEnabled = false
        MapImage.isUserInteractionEnabled = false
    }
    
    @objc func updatePoints(_ notification: Notification) {
            
            // process info
        if let newPoints = notification.userInfo?["addPoints"] as? Int {
            pointsToShow += newPoints
        }
    }
    

    
    func loadImage(image: UIImageView) {
        image.tintColor = UIColor(displayP3Red: CGFloat(237)/CGFloat(255), green: CGFloat(192)/CGFloat(255), blue: CGFloat(137)/CGFloat(255), alpha: CGFloat(1))
        image.image = image.image?.withRenderingMode(.alwaysTemplate)
        image.tintColor = UIColor(displayP3Red: CGFloat(237)/CGFloat(255), green: CGFloat(192)/CGFloat(255), blue: CGFloat(137)/CGFloat(255), alpha: CGFloat(1))
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
