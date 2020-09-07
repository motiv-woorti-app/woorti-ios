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

class MTConfirmModesViewController: MTGenericViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, MotGetter, MKMapViewDelegate {
    
    let modesOfTransport = [Trip.modesOfTransport.walking,Trip.modesOfTransport.running,Trip.modesOfTransport.Bus,Trip.modesOfTransport.Train,Trip.modesOfTransport.Car,Trip.modesOfTransport.Tram, Trip.modesOfTransport.Subway, Trip.modesOfTransport.cycling, Trip.modesOfTransport.Ferry, Trip.modesOfTransport.Plane]
    
    var modesOfTRansportCells = [ChooseAmodeOfTransportCollectionViewCell]()
    
    var even = false
    
    @IBOutlet weak var confirmModesLabel: UILabel!
    @IBOutlet weak var TableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var map: MKMapView!
    
    private var lines = [MKPolyline]()
    private var color = UIColor.orange
    var annotations = [MKAnnotation]()
    var disabled = false
    
    enum cells: String {
        case Start
        case Tube
        case Arrival
        case Transfer
        case Option
    }
    var rated = false
    
    var printingCells = [String]()
    
    @IBOutlet weak var ConfimrTableView: UITableView!

//    @IBOutlet weak var carrousellSaveButton: UIButton!
    @IBOutlet weak var confirmAllButton: UIButton!
    
    @IBOutlet weak var ChooseModeOfTRansportView: UIView!
    var fadeView: UIView?
    @IBOutlet weak var MainView: UIView!
//    @IBOutlet weak var carrouselCollectionView: UICollectionView!
    
    var viewHasLoaded = false
    
    enum callbacks: String {
        case MTChooseConfirmModeStartCarrousell
        case MTChooseConfirmModeEndCarrousell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modesOfTransport.count
    }
    
    var MotSelectionView: GenericModeOfTransportPicker?
    
    var partsForPrinting = [FullTripPart?]()
    
    func LoadCell(_ indexPath: IndexPath, _ cell: ChooseAmodeOfTransportCollectionViewCell) {
        let (label, image) = Trip.getLabelAndPictureFromModeOfTRansport(mot: modesOfTransport[indexPath.item])
        print("\(label), \(image)")
        cell.cellLoad(actimage: image, text: label)
        if modesOfTRansportCells.count > indexPath.item {
            modesOfTRansportCells.remove(at: indexPath.item)
            modesOfTRansportCells.insert(cell, at: indexPath.item)
        } else {
            modesOfTRansportCells.append(cell)
        }
        viewHasLoaded = true
        willDisableFunctionality()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseAmodeOfTransportCollectionViewCell", for: indexPath) as! ChooseAmodeOfTransportCollectionViewCell
        //        let (label, image) = Trip.getLabelAndPictureFromModeOfTRansport(mot: modesOfTransport[indexPath.item])
        //        cell.cellLoad(image: image, text: label)
        
        if modesOfTRansportCells.count > indexPath.item {
            let cell = modesOfTRansportCells[indexPath.item]
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseAmodeOfTransportCollectionViewCell", for: indexPath) as! ChooseAmodeOfTransportCollectionViewCell
        //        LoadCell(indexPath, cell)
        return cell
    }
    
    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //        for cell in modesOfTRansportCells {
    //            cell.unselect()
    //        }
    //        let selectedCell = collectionView.cellForItem(at: indexPath) as! ChooseAmodeOfTransportCollectionViewCell
    //        selectedCell.Select()
    //    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ChooseAmodeOfTransportCollectionViewCell {
            LoadCell(indexPath, cell)
        }
    }
    
    func InitPrintingCells() {
        printingCells.removeAll()
        partsForPrinting.removeAll()
        if let parts = getFt()?.getTripPartsortedList() {
            let size = parts.count
            printingCells = [String]()
            if size > 0 {
                printingCells.append(cells.Start.rawValue)
                partsForPrinting.append(parts[0])
                printingCells.append(cells.Tube.rawValue)
                partsForPrinting.append(parts[0])
                var i = 0
                while i < size {
                    if parts[i].isKind(of: Trip.self) {
                        if (parts[i] as! Trip).wrongLeg {
                            i = i + 1
                            continue
                        }
                        printingCells.append("\(cells.Option.rawValue)\(i)")
                        partsForPrinting.append(parts[i])
                        printingCells.append(cells.Tube.rawValue)
                        partsForPrinting.append(nil)
                    } else if parts[i].isKind(of: WaitingEvent.self) {
                        printingCells.append(cells.Transfer.rawValue)
                        partsForPrinting.append(parts[i])
                        printingCells.append(cells.Tube.rawValue)
                        partsForPrinting.append(nil)
                    }
//                    }
                    i = i + 1
                }
                printingCells.append(cells.Arrival.rawValue)
                partsForPrinting.append(parts[i-1])
            }
        }
        if self.ConfimrTableView != nil {
            self.TableViewHeight.constant = self.getFullSize()
            self.ConfimrTableView.reloadData()
            self.UpdateActivity()
        }
    }
    
    fileprivate func willDisableFunctionality() {
        if let ft = self.getFt() {
            if !ft.closed {
                disabledFullTrip()
            }
        }
    }
    
    override func setFT(ft: FullTrip) {
        super.setFT(ft: ft)
        if self.ConfimrTableView != nil {
            InitPrintingCells()
            self.TableViewHeight.constant = self.getFullSize()
            self.ConfimrTableView.reloadData()
            self.UpdateActivity()
        }
        willDisableFunctionality()
    }
    
    func disabledFullTrip() {
        if self.viewHasLoaded {
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTTopBarViewController.disableButtons), object: nil)
            disabled = true
            confirmAllButton.isUserInteractionEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.loadButton()
        return printingCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let returnCell: UITableViewCell
        switch printingCells[indexPath.row] {
        case cells.Start.rawValue:
            let cell = (ConfimrTableView.dequeueReusableCell(withIdentifier: "GenericLocationTableViewCell") as? GenericLocationTableViewCell)!
//            cell.setImage(value: GenericLocationTableViewCell.Images.Start)
            let tryGetStartLocation = getFt()?.getStartLocation() ?? ""
            var startLocation = tryGetStartLocation
            if tryGetStartLocation == "" {
                startLocation = "Unknown Address"
            }
            
            
            cell.loadCell(image: GenericLocationTableViewCell.Images.Start,text: "Start: \(startLocation)", time: nil)
            returnCell = cell
        case cells.Tube.rawValue:
            let cell = (ConfimrTableView.dequeueReusableCell(withIdentifier: "TubeTableViewCell") as? TubeTableViewCell)!
            returnCell = cell
        case cells.Arrival.rawValue:
            let cell = (ConfimrTableView.dequeueReusableCell(withIdentifier: "GenericLocationTableViewCell") as? GenericLocationTableViewCell)!
            cell.setImage(value: GenericLocationTableViewCell.Images.Arrival)
            let tryGetEndLocation = getFt()?.getEndLocation() ?? ""
            var endLocation = tryGetEndLocation
            if endLocation == "" {
                endLocation = "Unknown Address"
            }
            cell.loadCell(image: GenericLocationTableViewCell.Images.Arrival,text: "End: \(endLocation)", time: partsForPrinting[indexPath.row]?.getEndDate() ?? nil)
            returnCell = cell
            
        case cells.Transfer.rawValue:
            let cell = (ConfimrTableView.dequeueReusableCell(withIdentifier: "GenericLocationTableViewCell") as? GenericLocationTableViewCell)!
            cell.setImage(value: GenericLocationTableViewCell.Images.change)
            cell.loadCell(image: GenericLocationTableViewCell.Images.change,text: NSLocalizedString("Transfer", comment: "message: Transfer"), time: partsForPrinting[indexPath.row]?.startDate ?? nil)
            returnCell = cell
            
        default:
            let row = printingCells[indexPath.row]
            let rowChanged = row.replacingOccurrences(of: cells.Option.rawValue, with: "")
            
            let partIdx = Int(rowChanged) ?? 0
            let part = getFt()?.getTripPartsortedList()[partIdx] as! Trip
            print("index \(partIdx)")
            
            if part.modeConfirmed {
                let cell = (ConfimrTableView.dequeueReusableCell(withIdentifier: "ValidatedConfirmModeTableViewCell") as? ValidatedConfirmModeTableViewCell)!
                cell.loadCell(leg: part, disabled: self.disabled)
                returnCell = cell
            } else {
                let cell = (ConfimrTableView.dequeueReusableCell(withIdentifier: "UnvalidatedConfirmModeTableViewCell") as? UnvalidatedConfirmModeTableViewCell)!
                cell.loadCell(leg: part, parentTableView: self, disabled: self.disabled)
                returnCell = cell
            }
        }
        return returnCell
    }
    
    func updateValidated() {
        DispatchQueue.main.async {
            self.TableViewHeight.constant = self.getFullSize()
            self.ConfimrTableView.reloadData()
            self.UpdateActivity()
            self.loadButton()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        self.ChooseModeOfTRansportView.isHidden = true
        MotivFont.motivBoldFontFor(key: "Confirm_Modes_Of_Your_Trips", comment: "message: Confirm the modes of your trip", label: confirmModesLabel, size: 17)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: self.confirmModesLabel, color: MotivColors.WoortiOrange)
        self.ConfimrTableView.delegate = self
        self.ConfimrTableView.dataSource = self
        self.ConfimrTableView.register( UINib(nibName: "TubeTableViewCell", bundle: nil), forCellReuseIdentifier: "TubeTableViewCell")
        self.ConfimrTableView.register( UINib(nibName: "GenericLocationTableViewCell", bundle: nil), forCellReuseIdentifier: "GenericLocationTableViewCell")
        confirmAllButton.backgroundColor = UIColor(red: 0.88, green: 0.94, blue: 0.99, alpha: 1)
        confirmAllButton.layer.cornerRadius = 9
        confirmAllButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        confirmAllButton.layer.shadowColor = UIColor(red: 0, green: 0.03, blue: 0, alpha: 0.18).cgColor
        confirmAllButton.layer.shadowOpacity = 1
        confirmAllButton.layer.shadowRadius = 4
//        InitPrintingCells()
        self.map.delegate = self
        self.view.backgroundColor = MotivColors.WoortiOrangeT2
//        self.carrouselCollectionView.collectionViewLayout = ZoomAndSnapFlowLayout()
//        self.carrouselCollectionView.delegate = self
//        self.carrouselCollectionView.dataSource = self
//        self.loadBottomButton(button: self.carrousellSaveButton)
        
//        GenericQuestionTableViewCell.loadStandardButton(button: self.confirmAllButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "Confirm_All", disabled: false)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.confirmAllButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Confirm_All", comment: "message: CONFIRM ALL", boldText: true, size: 15, disabled: false)
        
//        GenericQuestionTableViewCell.loadStandardButton(button: self.carrousellSaveButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "SAVE", disabled: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fadeTopViews), name: NSNotification.Name(rawValue: callbacks.MTChooseConfirmModeStartCarrousell.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unfadeTopViews), name: NSNotification.Name(rawValue: callbacks.MTChooseConfirmModeEndCarrousell.rawValue), object: nil)
        
        var userInfo = [String: Int]()
        userInfo["addPoints"] = 0
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTTopBarViewController.updateTopBarPoints), object: nil, userInfo: userInfo)
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "GenericModeOfTransportPickerView", bundle: bundle)
        //        if let productiveStarView = Bundle.main.loadNibNamed("StarRatingView", owner: self, options: nil)?.first as? StarRatingView {
        MotSelectionView = nib.instantiate(withOwner: self, options: nil).first as! GenericModeOfTransportPicker
            
//        self.ChooseModeOfTRansportView.isHidden = true
//        let motview = productiveStarView
        MotSelectionView?.setMotGetter(getter: self)
        loadButton()
    }
    
    func loadBottomButton(button: UIButton) {
        button.backgroundColor = UIColor(red: 0.88, green: 0.94, blue: 0.99, alpha: 1)
        button.layer.cornerRadius = 9
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowColor = UIColor(red: 0, green: 0.03, blue: 0, alpha: 0.18).cgColor
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 4
    }
    
    override func viewDidAppear(_ animated: Bool) {
        InitPrintingCells()
//        DispatchQueue.main.async {
//            self.SplitTableView.reloadData()
//        }
        UpdateActivity()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func getSizeForRow(index: Int) -> CGFloat {
        switch printingCells[index] {
        case cells.Start.rawValue, cells.Arrival.rawValue:
            return CGFloat(44)
        case cells.Tube.rawValue:
            return CGFloat(22)
        default:
            if printingCells[index].contains(cells.Transfer.rawValue) {
                return CGFloat(44)
            }
            if printingCells[index].contains(cells.Option.rawValue) {
                let row = printingCells[index]
                let rowChanged = row.replacingOccurrences(of: cells.Option.rawValue, with: "")
                let legIdx = Int(rowChanged) ?? 0
                if let leg = getFt()?.getTripPartsortedList()[legIdx] as? Trip {
                    if leg.modeConfirmed {
//                        return CGFloat(82)
                        return CGFloat(44)
                    } else {
                        return CGFloat(121)
                    }
                }
            }
            return CGFloat(121)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getSizeForRow(index: indexPath.row)
    }
    
    func getFullSize() -> CGFloat {
        var size = CGFloat(0)
        for cell in self.printingCells {
            size += getSizeForRow(index: self.printingCells.index(of: cell)!)
        }
        return size
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.ConfimrTableView.cellForRow(at: indexPath) as? ValidatedConfirmModeTableViewCell {
            cell.leg?.modeConfirmed = false
            
            DispatchQueue.main.async {
                self.TableViewHeight.constant = self.getFullSize()
                self.ConfimrTableView.reloadData()
//                self.UpdateActivity()
                self.loadButton()
            }
        }
    }
    
    func loadButton() {
        rated = true
        for leg in getFt()!.getTripOrderedList(){
            if !leg.modeConfirmed {
//                leg.correctedModeOfTransport = leg.modeOfTransport
                rated = false
            }
        }
        if rated {
            DispatchQueue.main.async {
//                GenericQuestionTableViewCell.loadStandardButton(button: self.confirmAllButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "Next", disabled: false)
//                self.ConfimrTableView.reloadData()
//                MotivAuxiliaryFunctions.loadStandardButton(button: self.confirmAllButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white,  key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 15, disabled: false, CompleteRoundCorners: true)
                MotivAuxiliaryFunctions.loadStandardButton(button: self.confirmAllButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white,  key: "Next" , comment: "message text of \"Next\" button message: Next", boldText: true, size: 15, disabled: false, border: false, borderColor: UIColor.clear, CompleteRoundCorners: true)
            }
        } else {
            DispatchQueue.main.async {
//                GenericQuestionTableViewCell.loadStandardButton(button: self.confirmAllButton, color: GenericQuestionTableViewCell.GreenButtonColor, text: "CONFIRM ALL", disabled: false)
                
//                MotivAuxiliaryFunctions.loadStandardButton(button: self.confirmAllButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Confirm_All", comment: "message: CONFIRM ALL", boldText: true, size: 15, disabled: false)
                MotivAuxiliaryFunctions.loadStandardButton(button: self.confirmAllButton, bColor: MotivColors.WoortiGreen, tColor: UIColor.white, key: "Confirm_All", comment: "message: CONFIRM ALL", boldText: true, size: 15, disabled: false, border: false, borderColor: UIColor.clear, CompleteRoundCorners: true)
//                self.ConfimrTableView.reloadData()
            }
        }
    }
    
    @IBAction func confirmAllButtonClick(_ sender: Any) {
        rated = true
        for leg in getFt()!.getTripOrderedList(){
            if !leg.modeConfirmed {
                leg.correctedModeOfTransport = leg.modeOfTransport
                leg.answerMode()
                leg.modeConfirmed = true
                rated = false
            }
        }
        if rated {
            var userInfo = [String: Int]()
            userInfo["addPoints"] = Int(Scored.getPossibleModePoints()) * getFt()!.getTripOrderedList().count
            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MTTopBarViewController.updateTopBarPoints), object: nil, userInfo: userInfo)
//            NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  MyTripsGenericViewController.MTViews.MyTripsObjective.rawValue), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsGenericViewController.MTViews.MyTripsTripWorthness.rawValue), object: nil)
        } else {
            rated = true
            DispatchQueue.main.async {
                self.confirmAllButton.setTitle(NSLocalizedString( "Next" , comment: "message text of \"Next\" button message: Next"), for: .normal)
                self.TableViewHeight.constant = self.getFullSize()
                self.ConfimrTableView.reloadData()
                self.UpdateActivity()
            }
        }
    }
    
    @IBAction func saveClick(_ sender: Any) {
        for cell in modesOfTRansportCells {
            if cell.isSelectedForMerge() {
                 NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  callbacks.MTChooseConfirmModeEndCarrousell.rawValue), object: nil, userInfo: ["mot": cell.getText()])
                break
            }
        }
    }
    
    func gotModeOftransport(mot: motToCell) {
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  callbacks.MTChooseConfirmModeEndCarrousell.rawValue), object: nil, userInfo: ["mot": mot])
    }
    
    //fading top view
    @objc func fadeTopViews() {
//        self.ChooseModeOfTRansportView.isHidden = false
        self.ChooseModeOfTRansportView.bounds = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.view.bounds.width - 20 , height: self.view.bounds.height - 20 )
        self.view.addSubview(self.ChooseModeOfTRansportView)

        self.ChooseModeOfTRansportView.layer.cornerRadius = self.ChooseModeOfTRansportView.bounds.width * 0.05
        self.ChooseModeOfTRansportView.layer.masksToBounds = true
        
        MotSelectionView?.frame = ChooseModeOfTRansportView.bounds
        ChooseModeOfTRansportView.addSubview(MotSelectionView!)
        self.ChooseModeOfTRansportView.center = self.view.center
        
        self.view.bringSubview(toFront: self.ChooseModeOfTRansportView)
        if let firstFrame = MainView?.bounds {
            fadeView = UIView(frame: firstFrame)
            fadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            MainView?.addSubview(fadeView!)
            fadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notifyMOTEnd)))
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func unfadeTopViews() {
        
//        self.ChooseModeOfTRansportView.isHidden = true
//        self.fadeView?.removeFromSuperview()
        MotSelectionView?.backOnMOTGetter()
        self.ChooseModeOfTRansportView?.removeFromSuperview()
        
        if fadeView != nil {
            fadeView?.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        UpdateActivity()
    }
    
    @objc func notifyMOTEnd() {
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  callbacks.MTChooseConfirmModeEndCarrousell.rawValue), object: nil)
    }
    
    /****** MAP ******/
    
    func UpdateActivity() -> Void {
        DispatchQueue.main.async {
            if self.getFt() != nil {
                self.printFullTripOnMap(ft: self.getFt()!)
            }
        }
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
    
    func loadAnnotations() {
        self.map.removeAnnotations(annotations)
        annotations = [MKAnnotation]()
        
        if let ft = self.getFt() {
            //start annotation
            if let firstCoordinate = ft.getFirstLocation()?.coordinate {
                annotations.append(GenericAnotation(location: firstCoordinate, icon: TripMapViewController.motIcons.baseline_adjust_white.rawValue, text: ""))
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
                            annotations.append(GenericAnotation(location: firstlocation, icon: TripMapViewController.motIcons.baseline_shuffle_white.rawValue, text: ""))
                        }
                    }
                }
            }
            
            //end annotation
            if let firstCoordinate = ft.getLastLocation()?.coordinate {
                annotations.append(GenericAnotation(location: firstCoordinate, icon: TripMapViewController.motIcons.baseline_place_black.rawValue, text: ""))
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
