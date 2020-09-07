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
import Firebase
import GoogleSignIn
import MapKit

class ConfrimScreenController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var ConfirmCollectionView: UICollectionView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var confirmButton: UIButton!
    var ft: FullTrip?
    private var lines = [MKPolyline]()
    private var colors = [UIColor]()
    private var currentAnnotations = [MKPointAnnotation]()
    private var annotationToSplit: startTripAnotation?
    private var waitForSplitRecognizer: Bool = false
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ft!.getTripOrderedList().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ConfirmScreenCollectionViewCell", for: indexPath) as! ConfirmScreenCollectionViewCell
        let trip = ft?.getTripOrderedList()[indexPath.row]
        return cell
    }
    
    @IBAction func confirmTripSendTrip(_ sender: Any) {
        if  let ft = self.ft {
            ft.confirmTrip()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let trip = ft {
            confirmButton.isHidden = trip.sentToServer
        }
        ConfirmCollectionView.delegate = self
        ConfirmCollectionView.dataSource = self
        TableView.delegate = self
        TableView.dataSource = self
        // Do any additional setup after loading the view.
        self.title = "Confirm Trip"
        map.delegate = self
        let waitForSplitRecognizer = UILongPressGestureRecognizer()
        waitForSplitRecognizer.addTarget(self, action: #selector(handleLongPress))
        map.addGestureRecognizer(waitForSplitRecognizer)
        printFullTripOnMap(ft: ft!)
    }
    
    public func refreshView() {
        removeAllAnnotations()
        ConfirmCollectionView.reloadData()
        TableView.reloadData()
        printFullTripOnMap(ft: ft!)
        if let trip = ft {
            confirmButton.isHidden = trip.sentToServer
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UiAlerts.getInstance().newView(view: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GoToMainMenuClick(_ sender: Any) {
        for controler in (navigationController?.viewControllers)! {
            if let MainMenuControler = controler as? MainMenuView {
                navigationController?.popToViewController(MainMenuControler, animated: true)
                break
            }
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
    
    //MAP
    //MARK: map delegate functions
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = colors.removeFirst()
            return lineView
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("select")
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("deselect")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("calloutAccessoryControlTapped")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let ann = annotation as? startTripAnotation {
            return ann.view
        }
        return nil
    }
    
    //MARK: map related functions
    private func printFullTripOnMap(ft: FullTrip){
        for line in self.lines {
            self.map.remove(line)
        }
        self.lines.removeAll()

        for part in ft.getTripPartsortedList(){
            var cords = [CLLocationCoordinate2D]()
            for loc in part.getLocationsortedList(){
                
                let cord = CLLocationCoordinate2D(latitude: (loc.location?.coordinate.latitude)!, longitude: (loc.location?.coordinate.longitude)!)
                cords.append(cord)
            }
            
            if cords.count > 0 {
                if let trip = part as? Trip {
                    let selectedAnnotationStartDate = self.annotationToSplit?.Leg.startDate ?? Date()
                    
                    if selectedAnnotationStartDate == trip.startDate {
                        colors.append(UIColor.cyan)
                    } else {
                        switch (trip.modeOfTransport ?? "") {
                        case "" :
                            colors.append(UIColor.white)
                        case ActivityClassfier.UNKNOWN :
                            colors.append(UIColor.black)
                        case ActivityClassfier.AUTOMOTIVE :
                            colors.append(UIColor.red)
                        case ActivityClassfier.CYCLING :
                            colors.append(UIColor.yellow)
                        case ActivityClassfier.WALKING :
                            colors.append(UIColor.purple)
                        case ActivityClassfier.RUNNING :
                            colors.append(UIColor.brown)
                        case ActivityClassfier.STATIONARY :
                            colors.append(UIColor.orange)
                        default:
                            colors.append(UIColor.white)
                        }
                    }
                } else {
                    colors.append(UIColor.blue)
                }
                self.lines.append(MKPolyline(coordinates: cords, count: cords.count))
                if let trip = part as? Trip {
                    if let last = cords.last {
                        addAnotation(coordinate: last, leg: trip)
                    }
                }
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
    }
    
    private func addAnotation(coordinate: CLLocationCoordinate2D,leg: Trip) {
        let annotation = startTripAnotation(location: coordinate, leg: leg, confirmView: self)
        currentAnnotations.append(annotation)
        map.addAnnotation(annotation)
    }
    
    private func removeAllAnnotations() {
        for anotation in currentAnnotations {
            map.removeAnnotation(anotation)
        }
        currentAnnotations.removeAll()
    }
    
    fileprivate func waitForSplit(annotation: startTripAnotation){

        //set Leg to split
        self.annotationToSplit = annotation
        waitForSplitRecognizer = true
        printFullTripOnMap(ft: ft!)
      
        
    }
    
    func finishWaitForSplit(){
       
        waitForSplitRecognizer = false
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        DispatchQueue.global(qos: .background).async {
            if gestureRecognizer.state == .began && self.waitForSplitRecognizer {
                let location = gestureRecognizer.location(in: self.map)
                let coordinate = self.map.convert(location,toCoordinateFrom: self.map)
                let pin = MKPointAnnotation()
                pin.coordinate=coordinate
                DispatchQueue.main.sync {
                    self.map.addAnnotation(pin)
                }
                print("got coordinate")
                if let Trip = self.ft {
                    if UiAlerts.getInstance().showSplitLegAlert() {
                        Trip.splitLeg(locations: coordinate, leg: self.annotationToSplit!.Leg, fromInterface: true)

                        print("refreshing")
                        self.finishWaitForSplit()
                        DispatchQueue.main.async {
                            self.refreshView()
                        }
                    }
                }
                DispatchQueue.main.sync {
                    self.map.removeAnnotation(pin)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ft!.getTripOrderedList().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "confirmViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? confirmViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let leg = self.ft!.getTripOrderedList()[indexPath.row]
        cell.leg = leg
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let cell = tableView.cellForRow(at: indexPath) as? confirmViewCell {
            if let leg = cell.leg {
                if let lastCoord = leg.getLocationsortedList().last?.location {
                    let coordinateRegion = MKCoordinateRegionMakeWithDistance(lastCoord.coordinate, 500, 500)
                    self.map.setRegion(coordinateRegion, animated: true)
                    if let annotation = startTripAnotation.getAnnotationFromMap(coordinate: lastCoord.coordinate, map: self.map) {
                        print("found annotation")
                        self.waitForSplit(annotation: annotation)
                    }
                }
            }
        }
    }
}


private class startTripAnotation: MKPointAnnotation {
    public var Leg: Trip
    public var view: startTripAnnotationView?
    
    
    public init(location: CLLocationCoordinate2D, leg: Trip, confirmView: ConfrimScreenController){
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
    public var confirmView: ConfrimScreenController?
    
    public init(annotation: startTripAnotation, confirmView: ConfrimScreenController){
        rec = UILongPressGestureRecognizer()
        self.confirmView = confirmView
        super.init(annotation: annotation, reuseIdentifier: nil)
        rec.addTarget(self, action: #selector(handleLongPress))
        self.isEnabled = false
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        self.addGestureRecognizer(rec)
        self.addGestureRecognizer(tapRec)
    }
    
    required init?(coder aDecoder: NSCoder) {
        rec = UILongPressGestureRecognizer()
        super.init(coder: aDecoder)
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        DispatchQueue.global(qos: .background).async {
            if gestureRecognizer.state == .began {
                print("Juntar com o próximo")
                if let ft = self.confirmView?.ft,
                    let annotation = self.annotation as? startTripAnotation{
                    if UiAlerts.getInstance().showJoinLegAlert() {
                        ft.joinWithnext(part: annotation.Leg, fromInterface: true)
                        DispatchQueue.main.sync {
                            self.confirmView!.refreshView()
                        }
                    }
                }
                print("finish")
            }
        }
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            print("Seleccionar Para dividir Leg")
            if let view = confirmView,
                let annotation = annotation as? startTripAnotation {
                
                view.waitForSplit(annotation: annotation)
            }
        }
    }
}

class confirmViewCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
    var leg: Trip? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
