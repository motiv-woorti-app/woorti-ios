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
import MapKit

class TripMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var backimage: UIImageView!
    
    public var fullTripToShow: FullTrip?
    private var lines = [MKPolyline]()
    private var color = UIColor.orange
    var annotations = [MKAnnotation]()
    var even = false
    
    @IBOutlet weak var splitImage: UIImageView!
    @IBOutlet weak var deleteIamge: UIImageView!
    @IBOutlet weak var mergeImage: UIImageView!
    
    @IBOutlet weak var splitButton: UILabel!
    @IBOutlet weak var mergeButton: UILabel!
    @IBOutlet weak var deleteButton: UILabel!
    
    @IBOutlet weak var splitView: UIView!
    @IBOutlet weak var mergeView: UIView!
    @IBOutlet weak var deleteView: UIView!
    
    
    @IBOutlet var RoundedImages: [UIView]!
    private let GoToSplitMergeDeleteView = "ShowSplitMergeDelete"
    
    var option = GenericSplitMergeDeleteViewController.Option.split
    
    enum motIcons: String {
//        case directions_bike_black
//        case directions_boat_black
//        case directions_bus_black
//        case directions_car_black
//        case directions_railway_black
//        case directions_walk_black
        case baseline_shuffle_white = "Transfer"
//        case baseline_subway_black_18dp
//        case baseline_airplanemode_active_black_18dp
        case baseline_adjust_white = "Starting_Point"
        case baseline_place_black = "Arrival_Point"
        
        case Icon_Airplane, Icon_Bicycle, Icon_Bike_Sharing, Icon_Bus, Icon_Car_Sharing_Driver, Icon_Car_Sharing_Passenger, Icon_Cargo_Bike, Icon_Coach, Icon_Electric_Bike, Icon_Electric_Wheelchair, Icon_Ferry_Boat, Icon_High_Speed_Train, Icon_Jogging, Icon_Metro, Icon_Micro_Scooter, Icon_Moped, Icon_Motorcycle, Icon_Other, Icon_Private_Car_Driver, Icon_Private_Car_Passenger, Icon_Regional_Intercity_Train, Icon_Skateboard, Icon_Taxi, Icon_Tram, Icon_Urban_Train, Icon_Walking, Icon_Wheelchair
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.map.delegate = self
        
        let backrecognizer = UITapGestureRecognizer(target: self, action: #selector(back))
        self.backimage.addGestureRecognizer(backrecognizer)
        
        let splitrecognizer = UITapGestureRecognizer(target: self, action: #selector(showSplit))
        self.splitView.addGestureRecognizer(splitrecognizer)
        let mergerecognizer = UITapGestureRecognizer(target: self, action: #selector(showMerge))
        self.mergeView.addGestureRecognizer(mergerecognizer)
        let deleterecognizer = UITapGestureRecognizer(target: self, action: #selector(showDelete))
        self.deleteView.addGestureRecognizer(deleterecognizer)
        
        // Do any additional setup after loading the view.
        for view in RoundedImages {
            MotivAuxiliaryFunctions.RoundView(view: self.splitImage)
        }
        
        MotivFont.motivRegularFontFor(key: "Split", comment: "", label: self.splitButton, size: 13)
        MotivFont.motivRegularFontFor(key: "Merge", comment: "", label: self.mergeButton, size: 13)
        MotivFont.motivRegularFontFor(key: "Delete", comment: "", label: self.deleteButton, size: 13)
        
    }
    
    @objc func showSplit() {
        option = GenericSplitMergeDeleteViewController.Option.split
        self.performSegue(withIdentifier: self.GoToSplitMergeDeleteView, sender: self)
    }
    
    @objc func showMerge() {
        option = GenericSplitMergeDeleteViewController.Option.merge
        self.performSegue(withIdentifier: self.GoToSplitMergeDeleteView, sender: self)
    }
    
    @objc func showDelete() {
        option = GenericSplitMergeDeleteViewController.Option.delete
        self.performSegue(withIdentifier: self.GoToSplitMergeDeleteView, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        switch segue.destination {
        case let vc as GenericSplitMergeDeleteViewController:
            vc.setOptionToShow(option: self.option)
            vc.setFT(ft: self.fullTripToShow!)
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func UpdateActivity() -> Void {
        DispatchQueue.main.async{
            if self.fullTripToShow != nil {
//                self.EditText.text? = (self.fullTripToShow?.printFinalData())!
                //            self.EditText.text? = UserInfo.printInfo()
                self.printFullTripOnMap(ft: self.fullTripToShow!)
            }
        }
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UpdateActivity()
    }
    
    private func printFullTripOnMap(ft: FullTrip){
        // remove all lines
        for line in self.lines {
            self.map.remove(line)
        }
        self.lines.removeAll()
        
        //Draw new lines
        //        var prevLocation: UserLocation?
        for part in ft.getTripPartsortedList(){
            var cords = [CLLocationCoordinate2D]()
            for loc in part.getLocationsortedList(){
                //                if prevLocation != nil {
                //                    if (prevLocation?.location?.timestamp)! < (loc.location?.timestamp)! {
                //                        let cord = CLLocationCoordinate2D(latitude: (loc.location?.coordinate.latitude)!, longitude: (loc.location?.coordinate.longitude)!)
                //                        cords.append(cord)
                //                    }
                //                } else {
                let cord = CLLocationCoordinate2D(latitude: (loc.location?.coordinate.latitude)!, longitude: (loc.location?.coordinate.longitude)!)
                cords.append(cord)
                //                }
                //                prevLocation=loc
            }

            if cords.count > 0 {
//                if let trip = part as? Trip {
//                    switch (trip.modeOfTransport ?? "") {
//                    case "" :
//                        colors.append(UIColor.white)
//                    case ActivityClassfier.UNKNOWN :
//                        colors.append(UIColor.black)
//                    case ActivityClassfier.AUTOMOTIVE :
//                        colors.append(UIColor.red)
//                    case ActivityClassfier.CYCLING :
//                        colors.append(UIColor.yellow)
//                    case ActivityClassfier.WALKING :
//                        colors.append(UIColor.purple)
//                    case ActivityClassfier.RUNNING :
//                        colors.append(UIColor.brown)
//                    case ActivityClassfier.STATIONARY :
//                        colors.append(UIColor.orange)
//                    default:
//                        colors.append(UIColor.white)
//                    }
//                } else {
//                    colors.append(UIColor.blue)
//                }
                self.lines.append(MKPolyline(coordinates: cords, count: cords.count))
            }
        }

        if self.lines.count < 1 { //Nothing to draw
            return
        }

        let coordinateRegion = MKCoordinateRegionMakeWithDistance((self.lines.last?.coordinate)!, 5000, 5000)
        self.map.setRegion(coordinateRegion, animated: false)

        for line in self.lines {
            self.map.add(line)
        }
        loadAnnotations()
    }
    
    func loadAnnotations(){
        self.map.removeAnnotations(annotations)
        annotations = [MKAnnotation]()
        
        if let ft = self.fullTripToShow {
            //start annotation
            if let firstCoordinate = ft.getFirstLocation()?.coordinate {
                annotations.append(GenericAnotation(location: firstCoordinate, icon: motIcons.baseline_adjust_white.rawValue, text: ""))
            }
            
            let list = ft.getTripOrderedList()
            
            for part in list {
                if part.getLocationsortedList().count > 0 {
                    if part.wrongLeg {
                        continue
                    }
                    
                    if let middleLocation = part.getLocationsortedList()[part.getLocationsortedList().count/2].location?.coordinate {
//                        let icon = part.getIconFromModeOfTRansport()
                        let image = part.getImageModeToShow()
                        
                        
                        let cFirst = UtilityFunctions.getHourMinuteFromDate(date: part.getLocationsortedList().first!.location!.timestamp)
                        let cLast = UtilityFunctions.getHourMinuteFromDate(date: part.getLocationsortedList().last!.location!.timestamp)
                        annotations.append(GenericAnotation(location: middleLocation, image: image, text: "\(cFirst) > \(cLast)"))
                        
                        if (list.index(of: part) ?? 0) != 0,
                            let firstlocation = part.getLocationsortedList().first?.location?.coordinate {
                            annotations.append(GenericAnotation(location: firstlocation, icon: motIcons.baseline_shuffle_white.rawValue, text: ""))
                        }
                    }
                }
            }
            
            //end annotation
            if let firstCoordinate = ft.getLastLocation()?.coordinate {
                annotations.append(GenericAnotation(location: firstCoordinate, icon: motIcons.baseline_place_black.rawValue, text: ""))
            }
        }
        
        self.map.addAnnotations(annotations)
    }
    
    //MARK: map delegate functions
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
//            lineView.strokeColor = colors.removeFirst()
            if even {
                lineView.strokeColor = color
            } else {
                lineView.strokeColor = MotivColors.WoortiBlack
            }
            even = !even
            //self.color=UIColor.green
            return lineView
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let ann = annotation as? GenericAnotation {
            return ann.view
        }
        return nil
    }
}


class GenericAnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    public var Leg: FullTripPart?
    
//    public var Leg: Trip
    public var view: GenericAnnotationView?
    
    public init(location: CLLocationCoordinate2D, image: UIImage, text: String){
//        Leg = leg
        coordinate = location
        title = text
        super.init()
        view = GenericAnnotationView(annotation: self, image: image)
    }
    
    public init(location: CLLocationCoordinate2D, icon: String, text: String){
        //        Leg = leg
        coordinate = location
        title = text
        super.init()
        view = GenericAnnotationView(annotation: self, icon: icon)
    }
    
    public init(location: CLLocationCoordinate2D, leg: FullTripPart, icon: String, confirmView: SMDTripViewController){
        //        Leg = leg
        coordinate = location
        Leg = leg
        super.init()
//        view = GenericAnnotationView(annotation: self, icon: icon)
        view = GenericAnnotationView(annotation: self, icon: icon, leg: leg, confirmView: confirmView)
    }
    
    public init(location: CLLocationCoordinate2D, leg: FullTripPart, image: UIImage, confirmView: SMDTripViewController){
        //        Leg = leg
        coordinate = location
        Leg = leg
        super.init()
        //        view = GenericAnnotationView(annotation: self, icon: icon)
        view = GenericAnnotationView(annotation: self, image: image, leg: leg, confirmView: confirmView)
    }
    
    public static func getAnnotationFromMap(coordinate: CLLocationCoordinate2D, map: MKMapView) -> GenericAnotation? {
        for ann in map.annotations {
            if let tripAnn = ann as? GenericAnotation{
                let coord = tripAnn.coordinate
                if coordinate.latitude == coord.latitude && coordinate.longitude == coord.longitude {
                    return tripAnn
                }
            }
        }
        return nil
    }
}

class GenericAnnotationView: MKAnnotationView  {
//    public var rec: UIGestureRecognizer
//    public var confirmView: ConfrimScreenController?
    public var confirmView: SMDTripViewController?
    public var Leg: FullTripPart?
    
    let selectedLabel: UILabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 90, height: 38))
    var textToShow: String
    
    public init(annotation: GenericAnotation, image: UIImage, leg: FullTripPart? = nil, confirmView: SMDTripViewController? = nil){
        self.textToShow = annotation.title ?? ""
        self.Leg = leg
        
        super.init(annotation: annotation, reuseIdentifier: nil);
        
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: CGFloat(20), height: CGFloat(20))
        self.center = CGPoint(x: self.bounds.minX + 10, y: self.bounds.minY + 10)
        self.contentMode = .scaleAspectFit
        self.tintColor = UIColor.black
//        self.image = UIImage(named: icon.rawValue)?.withRenderingMode(.alwaysTemplate)
//        self.image = image.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
//        self.backgroundColor = UIColor.white
//        MotivAuxiliaryFunctions.RoundView(view: self, CompleteRoundCorners: true)
        self.loadView(image: image)
        self.tintColor = UIColor.black
        self.isUserInteractionEnabled = true
//        self.canShowCallout = true
    }
    
    public init(annotation: GenericAnotation, icon: String, leg: FullTripPart? = nil, confirmView: SMDTripViewController? = nil){
        self.textToShow = annotation.title ?? ""
        self.Leg = leg
        
        super.init(annotation: annotation, reuseIdentifier: nil);
        
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.frame = CGRect(x: self.bounds.minX, y: self.bounds.minY, width: CGFloat(20), height: CGFloat(20))
        self.center = CGPoint(x: self.bounds.minX + 10, y: self.bounds.minY + 10)
        
        self.contentMode = .scaleAspectFit
        self.tintColor = UIColor.black
//        self.image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate).withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
//
//        self.backgroundColor = UIColor.white
//        MotivAuxiliaryFunctions.RoundView(view: self, CompleteRoundCorners: true)
        self.loadView(image: UIImage(named: icon)!)
        self.tintColor = UIColor.black
        self.isUserInteractionEnabled = true
        //        self.canShowCallout = true
    }
    
    func loadView(image: UIImage) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: CGFloat(40), height: CGFloat(40)))
        MotivAuxiliaryFunctions.RoundView(view: view, CompleteRoundCorners: true)
        MotivAuxiliaryFunctions.BorerOnView(uiview: view)
        view.backgroundColor = UIColor.white
        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: CGFloat(20), height: CGFloat(20)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = image

        view.addSubview(imageView)
        self.addSubview(view)
    }
    
//    func split() {
//        if let leg = Leg {
//            confirmView?.splitTrip(part: leg)
//        }
//    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(false, animated: animated)
        if (self.textToShow ?? "") != "" {
            if(selected)
            {
                
                MotivFont.motivBoldFontFor(text: self.textToShow, label: selectedLabel, size: 13) //UIFont.init(name: "HelveticaBold", size: 15)
                selectedLabel.textColor = MotivColors.WoortiOrange
                selectedLabel.textAlignment = .center
                selectedLabel.backgroundColor = UIColor.white
                selectedLabel.layer.cornerRadius = self.selectedLabel.bounds.height / 2
                selectedLabel.layer.masksToBounds = true
                
                selectedLabel.center.x = 0.5 * self.frame.size.width;
                selectedLabel.center.y = -0.5 * selectedLabel.frame.height;
                self.addSubview(selectedLabel)
            }
            else
            {
                selectedLabel.removeFromSuperview()
            }
        } else if let part = Leg {
            confirmView?.splitTrip(part: part)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
//        rec = UILongPressGestureRecognizer()
        self.textToShow = ""
        super.init(coder: aDecoder)
    }
//
//    func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
//
////        DispatchQueue.global(qos: .background).async {
////            if gestureRecognizer.state == .began {
////                print("Juntar com o próximo")
////                if let ft = self.confirmView?.ft,
////                    let annotation = self.annotation as? startTripAnotation{
////                    if UiAlerts.getInstance().showJoinLegAlert() {
////                        ft.joinWithnext(part: annotation.Leg)
////                        DispatchQueue.main.sync {
////                            self.confirmView!.refreshView()
////                        }
////                    }
////                }
////                print("finish")
////            }
////        }
//    }
//
//    func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
////        if gestureRecognizer.state == .ended {
////            print("Seleccionar Para dividir Leg")
////            if let view = confirmView,
////                let annotation = annotation as? startTripAnotation {
////
////                view.waitForSplit(annotation: annotation)
////            }
////        }
//    }
}
