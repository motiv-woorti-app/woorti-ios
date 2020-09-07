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

class SplitMapViewViewController: MTGenericViewController, MKMapViewDelegate, MotGetter {
    
//    var leg: Trip?
    var min = -1
    var max = 0
//    var trip: FullTrip?
    var type = mapType.split

    var even = false
    //outlets
    @IBOutlet weak var SplitButton: UIButton!
    @IBOutlet weak var MapView: MKMapView!
    
    @IBOutlet weak var splitMapLabel: UILabel!
    
    @IBOutlet weak var progressBar: CircularProgressBar!
    
    //MAP
    private var lines = [MKPolyline]()
//    private var colors = [UIColor]()
    private var color = UIColor.orange
    var annotations = [MKAnnotation]()
    private var currentAnnotations = [MKPointAnnotation]()
    private var annotationToSplit: startTripAnotation?
//    private var waitForSplitRecognizer: Bool = false
    private var hasloaded = false
    private var pin: MKPointAnnotation?
    
    var horizontalLayer: CAShapeLayer?
    var verticalLayer: CAShapeLayer?
    
    enum mapType {
        case split
        case merge
        case delete
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.MapView.delegate = self
        self.progressBar.isHidden = true
//        let waitForSplitRecognizer = UILongPressGestureRecognizer()
//        waitForSplitRecognizer.addTarget(self, action: #selector(handleLongPress))
//        MapView.addGestureRecognizer(waitForSplitRecognizer)
        if min > -1 {
            switch self.type {
            case .delete:
                LoadBottomButton(text: "Delete")
                splitMapLabel.isHidden = true
            case .merge:
                LoadBottomButton(text: "Merge")
                splitMapLabel.isHidden = true
            case .split:
                LoadBottomButton(text: "Split")
                splitMapLabel.isHidden = false
                loadSplitDashedLines()
            }
            self.refreshView()
        }
        
        hasloaded = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadSplitDashedLines()
    }
    
    func loadSplitDashedLines(){
        let bounds = self.MapView.bounds
        let center = self.MapView.center
        //vertical line
        self.loadDashedLine(origin: CGPoint.init(x: center.x, y: bounds.minY), size: CGSize.init(width: 0, height: bounds.height), horizontal: false)
        //horizontal line
        self.loadDashedLine(origin: CGPoint.init(x: bounds.minX, y: center.y), size: CGSize.init(width: bounds.width, height: 0), horizontal: true)
    }
    
    func loadDashedLine(origin: CGPoint, size: CGSize, horizontal: Bool){
        let rect = CGRect.init(origin: origin, size: size)//Set Height width as you want
        print("values: \(origin), \(size)")
        
        let layer = CAShapeLayer.init()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
        layer.path = path.cgPath;
        layer.strokeColor = UIColor.gray.cgColor
        layer.lineDashPattern = [2,2]; // Here you set line length
        layer.backgroundColor = UIColor.clear.cgColor;
        layer.fillColor = UIColor.clear.cgColor;
        self.MapView.layer.addSublayer(layer);
        if horizontal {
          self.horizontalLayer?.removeFromSuperlayer()
            self.horizontalLayer = layer
        } else {
            self.verticalLayer?.removeFromSuperlayer()
            self.verticalLayer = layer
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func LoadBottomButton(text: String) {
        MotivAuxiliaryFunctions.loadStandardButton(button: self.SplitButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: text, comment: "", boldText: false, size: 15, disabled: false)
    }
    
    
    func loadAnnotations(){
        self.MapView.removeAnnotations(annotations)
        annotations = [MKAnnotation]()
        
        if let ft = self.getFt() {

            let list = ft.getTripPartsortedList()
            var i = 0
            var max = self.max
            
            if self.type == .split {
                max += 1
            }
        
            for part in list {
                if let startLocation = part.getLocationsortedList().first?.location?.coordinate,
                    i >= self.min && i <= max {
                    
                    switch part {
                    case let leg as Trip:
                        if leg.wrongLeg {
                            continue
                        }
//                        let icon = leg.getIconFromModeOfTRansport()
                        let image = leg.getImageModeToShow()
                        
                        let cFirst = UtilityFunctions.getHourMinuteFromDate(date: part.getLocationsortedList().first!.location!.timestamp)
                        let cLast = UtilityFunctions.getHourMinuteFromDate(date: part.getLocationsortedList().last!.location!.timestamp)
                        annotations.append(GenericAnotation(location: startLocation, image: image, text: "\(cFirst) > \(cLast)"))
                    case let _ as WaitingEvent:
                        if (list.index(of: part) ?? 0) != 0,
                            let firstlocation = part.getLocationsortedList().first?.location?.coordinate {
                            annotations.append(GenericAnotation(location: firstlocation, icon: TripMapViewController.motIcons.baseline_shuffle_white.rawValue, text: ""))
                        }
                    default:
                        break
                    }
                }
                i+=1
            }
            
            //end annotation
            if let firstCoordinate = ft.getLastLocation()?.coordinate,
                max == list.count {
                annotations.append(GenericAnotation(location: firstCoordinate, icon: TripMapViewController.motIcons.baseline_place_black.rawValue, text: ""))
            }
        }
        
        self.MapView.addAnnotations(annotations)
    }
    
    
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
            return ann.view
        }
        return nil
    }
    
    func SetUp( start: Int, end: Int, type: mapType){
        self.min = start
        self.max = end
        self.type = type
        if hasloaded {
            switch self.type {
            case .delete:
                LoadBottomButton(text: "Delete")
                splitMapLabel.isHidden = true
            case .merge:
                LoadBottomButton(text: "Merge")
                splitMapLabel.isHidden = true
            case .split:
                LoadBottomButton(text: "Split")
                splitMapLabel.isHidden = false
                loadSplitDashedLines()
            }
            self.refreshView()
        }
        switch self.type {
        case .delete:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SplitMergeDeleteTopViewController.callbacks.SMDTopSetTitle.rawValue), object: nil, userInfo: ["title" : "Confirm_The_Legs_To_delete"])
        case .merge:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SplitMergeDeleteTopViewController.callbacks.SMDTopSetTitle.rawValue), object: nil, userInfo: ["title" : "Confirm_The_Legs_To_Merge"])
        case .split:
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SplitMergeDeleteTopViewController.callbacks.SMDTopSetTitle.rawValue), object: nil, userInfo: ["title" : "Move_The_Map_To_Split"])
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SplitMergeDeleteTopViewController.callbacks.SMDTopHideButton.rawValue), object: nil)
    }
    
    @IBAction func ClickBottomButton(_ sender: Any) {
        switch self.type {
        case .delete:
            
            let legsToDelete = self.getFt()?.getTripPartsortedList().filter {
                (part) -> Bool in
                if let idx = self.getFt()?.getTripPartsortedList().index(of: part) {
                    print("idx: \(idx), \(self.min), \(self.max), \(self.getFt()?.getTripPartsortedList().count)")
                    return idx >= self.min && idx <= self.max
                }
                return false
            }
            
            
            for part in legsToDelete ?? [FullTripPart]() {
                if let leg = part as? Trip {
                    leg.wrongLeg = true
                } else {
                    self.getFt()?.removeFromTrips(part)
                }
            }
            
            self.getFt()?.numDeletes = (self.getFt()?.numDeletes ?? 0) + 1
            self.getFt()?.cleanTrip()
            
            
            
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  GenericSplitMergeDeleteViewController.MTViews.SMDMyTripsBackEnd.rawValue), object: nil)
        case .merge:
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  GenericSplitMergeDeleteViewController.MOTNotifs.SMDFadeTOMOTView.rawValue), object: nil, userInfo: ["getter": self])
        case .split:
            
            self.getFt()?.numSplits = (self.getFt()?.numSplits ?? 0) + 1
            if let pin = self.pin {
                self.SplitOnSelectedPin(pin.coordinate)
            }
        }
    }
    
    func printLegsOnMap(parts: [FullTripPart]) {
        var i = 0
        for part in parts {
            if i >= self.min && i <= self.max {
                printLegOnMap(part: part)
            }
            i+=1
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
    
    private func printParts() {
        for line in self.lines {
            self.MapView.remove(line)
        }
        self.lines.removeAll()
        printLegsOnMap(parts: self.getFt()!.getTripPartsortedList())
        
        if self.lines.count < 1 { //Nothing to draw
            return
        }
        let coordinateRegion = MKCoordinateRegionMakeWithDistance((self.lines.last?.coordinate)!, 5000, 5000)
        self.MapView.setRegion(coordinateRegion, animated: false)
        
        for line in self.lines {
            self.MapView.add(line)
        }
    }
    
    
    private func addAnotation(coordinate: CLLocationCoordinate2D,leg: Trip) {
        let annotation = startTripAnotation(location: coordinate, leg: leg, confirmView: self)
        currentAnnotations.append(annotation)
        MapView.addAnnotation(annotation)
    }
    
    private func removeAllAnnotations() {
        for anotation in currentAnnotations {
            MapView.removeAnnotation(anotation)
        }
        currentAnnotations.removeAll()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if self.type == .split {
            updateSplitPin()
            loadSplitDashedLines()
        }
    }
    
    func updateSplitPin() {
        DispatchQueue.global(qos: .background).async {
            let leg = self.getFt()?.getTripPartsortedList()[self.max] as! Trip
            if let coordinate = leg.getMostProbableCoordinate(location: self.MapView.centerCoordinate) {
                if let pin = self.pin {
                    DispatchQueue.main.sync {
                        self.MapView.removeAnnotation(pin)
                    }
                }
                self.pin = MKPointAnnotation()
                self.pin!.coordinate = coordinate.coordinate
                DispatchQueue.main.sync {
                    self.MapView.addAnnotation(self.pin!)
                }
                print("got coordinate")
            }
        }
    }
    
    
    fileprivate func SplitOnSelectedPin(_ coordinate: CLLocationCoordinate2D) {
        
        DispatchQueue.global(qos: .background).async {
            
            
            if let Trip = self.getFt() {
                
                if UiAlerts.getInstance().showSplitLegAlert() {
                    
                    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
                    
                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                    loadingIndicator.hidesWhenStopped = true
                    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
                    loadingIndicator.startAnimating()
                    
                    alert.view.addSubview(loadingIndicator)
                    self.present(alert, animated: true, completion: nil)
                
                    let leg = self.getFt()?.getTripPartsortedList()[self.max] as! Trip
                    Trip.splitLeg(locations: coordinate, leg: leg, fromInterface: true)

                    
                    self.dismiss(animated: false, completion: nil)
                    
                    NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  GenericSplitMergeDeleteViewController.MTViews.SMDMyTripsBackEnd.rawValue), object: nil)
                }
            }
        }
    }
    
    
    public func refreshView() {
        removeAllAnnotations()
        printParts()
        loadAnnotations()
        loadSplitDashedLines()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func gotModeOftransport(mot: motToCell) {
        DispatchQueue.global(qos: .background).async {
            
            let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
            
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating()
            
            alert.view.addSubview(loadingIndicator)
            print("Presenting dialog")
            self.present(alert, animated: true, completion: nil)
            
            let legsToMerge = self.getFt()?.getTripPartsortedList().filter {
                (part) -> Bool in
                if let idx = self.getFt()?.getTripPartsortedList().index(of: part) {
                    print("idx: \(idx), \(self.min), \(self.max), \(self.getFt()?.getTripPartsortedList().count)")
                    return idx >= self.min && idx <= self.max
                }
                return false
            }
            print("count: \(legsToMerge?.count ?? 0), \(self.min), \(self.max), \(self.getFt()?.getTripPartsortedList().count)")
            if legsToMerge?.count ?? 0 > 1  {
                for i in stride(from: (legsToMerge?.count ?? 0) - 2, through: 0, by: -1) {
                    //                if let leg = (legsToMerge[i] as? SMDRadioButtonTableViewCell)?.part as? Trip {
                    //                    self.getFt()?.joinWithnext(leg: leg, modeOfTRansport: self.getSelectedMOT())
                    //
                    
                    print("i: \(i), \((legsToMerge?.count ?? 0) - 2)")
                    if i <= (legsToMerge?.count ?? 0 - 2) {
                        let part = legsToMerge![i]
                        self.getFt()?.joinWithnext(part: part, modeOfTRansport: mot.strMode, fromInterface: true)
                    }
                }
            }
            
            if let minPart = self.getFt()?.getTripPartsortedList()[self.min] as? Trip,
                let user = MotivUser.getInstance() {
                let mot = user.getMotFromText(text: mot.strMode)?.motCode ?? Double(mot.mode)
                minPart.realMot = mot
//                user.setSecondaryasMain(mainCode: mot.motCode)
            }
            
            print("Dismissing dialog")
            alert.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  GenericSplitMergeDeleteViewController.MTViews.SMDMyTripsBackEnd.rawValue), object: nil)

        }
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  GenericSplitMergeDeleteViewController.MOTNotifs.SMDunFadeTOMOTView.rawValue), object: nil)
    }
}



private class startTripAnotation: MKPointAnnotation {
    public var Leg: Trip
    public var view: startTripAnnotationView?
    
    public init(location: CLLocationCoordinate2D, leg: Trip, confirmView: SplitMapViewViewController){
        Leg = leg
        super.init()
        view = startTripAnnotationView(annotation: self, confirmView: confirmView)
        coordinate = location
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
    public var confirmView: SplitMapViewViewController?
    
    public init(annotation: startTripAnotation, confirmView: SplitMapViewViewController){
        rec = UILongPressGestureRecognizer()
        self.confirmView = confirmView
        super.init(annotation: annotation, reuseIdentifier: nil)
//        rec.addTarget(self, action: #selector(handleLongPress))
        self.isEnabled = false
//        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap))
//
//        self.addGestureRecognizer(rec)
//        self.addGestureRecognizer(tapRec)
    }
    
    required init?(coder aDecoder: NSCoder) {
        rec = UILongPressGestureRecognizer()
        super.init(coder: aDecoder)
    }
    
}
