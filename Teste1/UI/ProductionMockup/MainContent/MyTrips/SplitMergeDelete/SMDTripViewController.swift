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

class SMDTripViewController: UIViewController, MKMapViewDelegate {

    var option = optionEnum.merge
    var fts = [FullTrip]()
    var parentVC: SplitMergeDeleteTripsViewController?
    
    var even = false
    
    enum optionEnum {
        case merge, split, delete
    }
    
    //outlets
    @IBOutlet weak var SplitButton: UIButton!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var closeImage: UIImageView!
    @IBOutlet weak var headerTitle: UILabel!
    
    //MAP
    private var lines = [MKPolyline]()
    private var color = UIColor.orange
    var annotations = [MKAnnotation]()
    private var currentAnnotations = [MKPointAnnotation]()
    private var hasloaded = false
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            if even {
                lineView.strokeColor = color
            } else {
                lineView.strokeColor = MotivColors.WoortiBlack
            }
            even = !even
            return lineView
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let ann = annotation as? GenericAnotation {
            ann.view?.frame = CGRect(x: (ann.view?.frame.minX)!, y: (ann.view?.frame.minY)!, width: CGFloat(40), height: CGFloat(40))
            return ann.view
        } else if let ann = annotation as? startTripAnotation {
            ann.view?.frame = CGRect(x: (ann.view?.frame.minX)!, y: (ann.view?.frame.minY)!, width: CGFloat(40), height: CGFloat(40))
            return ann.view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let ann = view as? startTripAnnotationView {
            if let leg = ann.Leg {
                splitTrip(part: leg)
            }
            
        } else if let ann = view as? GenericAnnotationView {
            if let leg = ann.Leg {
                splitTrip(part: leg)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MapView.delegate = self
        self.MapView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
        let gr = UITapGestureRecognizer(target: self, action: #selector(close))
        self.closeImage.addGestureRecognizer(gr)
        closeImage.image = closeImage.image?.withAlignmentRectInsets(UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10))
        UiAlerts.getInstance().newView(view: self)
        
        switch self.option {
        case .delete:
            MotivAuxiliaryFunctions.loadStandardButton(button: SplitButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Delete", comment: "", boldText: true, size: 15, disabled: false)
            SplitButton.isHidden = false
            SplitButton.isUserInteractionEnabled = true
            MotivFont.motivRegularFontFor(key: "Confirm_The_Legs_To_delete", comment: "", label: self.headerTitle, size: 15)
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.headerTitle, color: MotivColors.WoortiOrangeT1)
        case .merge:
            MotivAuxiliaryFunctions.loadStandardButton(button: SplitButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Merge", comment: "", boldText: true, size: 15, disabled: false)
            SplitButton.isHidden = false
            SplitButton.isUserInteractionEnabled = true
            MotivFont.motivRegularFontFor(key: "Confirm_Trips_To_Merge", comment: "message: Confirm the selected trips to merge", label: self.headerTitle, size: 15)
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.headerTitle, color: MotivColors.WoortiOrangeT1)
        case .split:
            MotivAuxiliaryFunctions.loadStandardButton(button: SplitButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Split", comment: "", boldText: true, size: 15, disabled: false)
            SplitButton.isHidden = true
            MotivFont.motivRegularFontFor(key: "Move_The_Map_To_Split_The_Leg", comment: "", label: self.headerTitle, size: 15)
            MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.headerTitle, color: MotivColors.WoortiOrangeT1)
        }
        self.refreshView()
        
        hasloaded = true
    }
    
    func splitTrip(part: FullTripPart) {
        DispatchQueue.global(qos: .userInitiated).async {
            UiAlerts.getInstance().newView(view: self)
            if self.option == .split,
                let ft = self.fts.first,
                (ft.getTripPartsortedList().index(of: part) ?? 0) > 0,
                UiAlerts.getInstance().showSplitTripAlert() {
                
                UserInfo.splitTrip(ft: self.fts.first!, part: part)
                self.parentVC!.reloadView()
                self.dismiss(animated: true, completion: nil)
                self.parentVC!.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func mergeDeleteButton(_ sender: Any) {
        switch self.option {
        case .delete:
            UserInfo.DeleteTrips(fts: self.fts)
        case .merge:
            UserInfo.mergeTrips(fts: self.fts)
        default:
            break
        }
        self.parentVC!.reloadView()
        self.dismiss(animated: true, completion: nil)
        self.parentVC!.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func close() {
        self.parentVC!.reloadView()
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadViewController(option: optionEnum, fts: [FullTrip]) {
        self.option = option
        self.fts = fts
    }
    
    public func refreshView() {
        removeAllAnnotations()
        for line in self.lines {
            self.MapView.remove(line)
        }
        self.lines.removeAll()
        
        for ft in fts {
            printParts(ft: ft)
            
        }
        loadAnnotations()
    }
    
    func loadAnnotations() {
        
        self.MapView.removeAnnotations(annotations)
        annotations = [MKAnnotation]()
        for ft in self.fts {
            loadAnnotations(ft: ft)
        }
    }
    
    func loadAnnotations(ft: FullTrip){

        let list = ft.getTripPartsortedList()
        for part in list {
            if let middleLocation = part.getLocationsortedList()[part.getLocationsortedList().count/2].location?.coordinate {
                
                switch part {
                case let leg as Trip:
                    if leg.wrongLeg {
                        continue
                    }
                    let image = leg.getImageModeToShow()
                    
                    let cFirst = UtilityFunctions.getHourMinuteFromDate(date: part.getLocationsortedList().first!.location!.timestamp)
                    let cLast = UtilityFunctions.getHourMinuteFromDate(date: part.getLocationsortedList().last!.location!.timestamp)
                    
                    annotations.append(GenericAnotation(location: middleLocation, leg: leg, image: image, confirmView: self))
                case _ as WaitingEvent:
                    if (list.index(of: part) ?? 0) != 0,
                        let firstlocation = part.getLocationsortedList().first?.location?.coordinate {
                        annotations.append(GenericAnotation(location: middleLocation, leg: part, icon: TripMapViewController.motIcons.baseline_shuffle_white.rawValue, confirmView: self))
                    }
                default:
                    break
                }
            }
        }
        
        //end annotation
        if let firstCoordinate = ft.getLastLocation()?.coordinate,
            self.option != .split {
            annotations.append(GenericAnotation(location: firstCoordinate, icon: TripMapViewController.motIcons.baseline_place_black.rawValue, text: "Trip ended"))
        }
        self.MapView.addAnnotations(annotations)
    }
    
    private func removeAllAnnotations() {
        for anotation in currentAnnotations {
            MapView.removeAnnotation(anotation)
        }
        currentAnnotations.removeAll()
    }
    
    private func printParts(ft: FullTrip) {
        printLegsOnMap(parts: ft.getTripPartsortedList())
        //        }
        
        if self.lines.count < 1 { //Nothing to draw
            return
        }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance((self.lines.last?.coordinate)!, 5000, 5000)
        self.MapView.setRegion(coordinateRegion, animated: false)
        
        for line in self.lines {
            self.MapView.add(line)
        }
    }
    
    func printLegsOnMap(parts: [FullTripPart]) {
        var i = 0
        for part in parts {
            printLegOnMap(part: part)
        }
    }
    
    
    func printLegOnMap(part: FullTripPart) {
        var cords = [CLLocationCoordinate2D]()
        for loc in part.getLocationsortedList(){
            let cord = CLLocationCoordinate2D(latitude: (loc.location?.coordinate.latitude)!, longitude: (loc.location?.coordinate.longitude)!)
            cords.append(cord)
        }
        
        if cords.count > 0 {
            self.lines.append(MKPolyline(coordinates: cords, count: cords.count))
        }
    }
}

private class startTripAnotation: MKPointAnnotation {
    public var Leg: FullTripPart
    public var view: startTripAnnotationView?
    
    public init(location: CLLocationCoordinate2D, leg: FullTripPart, icon: TripMapViewController.motIcons, confirmView: SMDTripViewController){
        Leg = leg
        super.init()
        view = startTripAnnotationView(annotation: self, leg: leg, icon: icon, confirmView: confirmView)
        coordinate = location
        title = "\(leg.startDate)"
    }
    
    public static func getAnnotationFromMap(coordinate: CLLocationCoordinate2D, map: MKMapView) -> startTripAnotation? {
        for ann in map.annotations {
            if let tripAnn = ann as? startTripAnotation{
                let coord = tripAnn.coordinate
                if coordinate.latitude == coord.latitude && coordinate.longitude == coord.longitude {
                    return tripAnn
                }
            }
        }
        return nil
    }
}

private class startTripAnnotationView: MKPinAnnotationView  {
    public var rec: UIGestureRecognizer
    public var confirmView: SMDTripViewController?
    public var Leg: FullTripPart?
//    var gr = UITapGestureRecognizer(target: self, action: #selector(split))
    
    @objc func split() {
        if let part = Leg {
            confirmView?.splitTrip(part: part)
        }
    }
    
    public init(annotation: startTripAnotation, leg: FullTripPart, icon: TripMapViewController.motIcons, confirmView: SMDTripViewController){
        Leg = leg
        rec = UITapGestureRecognizer()
        self.confirmView = confirmView
        super.init(annotation: annotation, reuseIdentifier: nil)
        self.tintColor = UIColor.black
        self.image = UIImage(named: icon.rawValue)?.withRenderingMode(.alwaysTemplate)
        self.tintColor = UIColor.black
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: CGFloat(40), height: CGFloat(40))
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
    }
    
    required init?(coder aDecoder: NSCoder) {
        rec = UITapGestureRecognizer()
        super.init(coder: aDecoder)
    }
}
