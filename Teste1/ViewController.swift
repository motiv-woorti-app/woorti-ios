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
import CoreMotion
import CoreLocation
import CoreData
import MapKit

/*
 * Testing view controller. used for development.
 */
class ViewController: UIViewController, MKMapViewDelegate {
    
    //MARK:properties
    @IBOutlet weak var EditText: UITextView!
    @IBOutlet weak var map: MKMapView!
    public static var updateInterval = 15 //seconds
    public var updateTimer: Timer?
    public var fullTripToShow: FullTrip?
    private var lines = [MKPolyline]()
    private var color = UIColor.blue
    private var colors = [UIColor]()
    @IBOutlet weak var confirmTripButton: UIButton!
    
    
    @objc func UpdateActivity() -> Void {
        DispatchQueue.main.async{
            if self.fullTripToShow != nil {
                self.EditText.text? = (self.fullTripToShow?.printFinalData())!
                self.printFullTripOnMap(ft: self.fullTripToShow!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DetectActivityModule.viewControllerSnapped=self
        self.title = "Trip View"
        if let trip = self.fullTripToShow {
            confirmTripButton.isHidden = trip.sentToServer
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UpdateActivity()
        if let ft = fullTripToShow {
            if !ft.closed {
                updateTimer=Timer.scheduledTimer(timeInterval: TimeInterval(ViewController.updateInterval), target: self, selector: #selector(UpdateActivity), userInfo: nil, repeats: true)
            }
        }
        UiAlerts.getInstance().newView(view: self)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        
        updateTimer?.invalidate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                } else {
                    colors.append(UIColor.blue)
                }
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
    }
    
    @IBAction func ConfirmTripClick(_ sender: Any) {
        if  let ft = self.fullTripToShow {
            ft.confirmTrip()
        }
    }
    
    
    //MARK: map delegate functions
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let lineView = MKPolylineRenderer(overlay: overlay)
            lineView.strokeColor = colors.removeFirst()
            //self.color=UIColor.green
            return lineView
        }
        return MKOverlayRenderer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ConfrimScreenController {
            vc.ft = self.fullTripToShow
        }
    }
}

