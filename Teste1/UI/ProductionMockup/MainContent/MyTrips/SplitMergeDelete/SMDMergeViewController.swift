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

class SMDMergeViewController: MTGenericViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let modesOfTransport = [Trip.modesOfTransport.walking,Trip.modesOfTransport.running,Trip.modesOfTransport.Bus,Trip.modesOfTransport.Train,Trip.modesOfTransport.Car,Trip.modesOfTransport.Tram, Trip.modesOfTransport.Subway, Trip.modesOfTransport.cycling, Trip.modesOfTransport.Ferry, Trip.modesOfTransport.Plane]
    
    var modesOfTRansportCells = [ChooseAmodeOfTransportCollectionViewCell]()
    @IBOutlet weak var carrouselCollectionView: UICollectionView!
    
    @IBOutlet weak var MergeTableView: UITableView!
    var listToLoad = [UITableViewCell]()
    @IBOutlet weak var carrouselView: UIView!
    
    var fadeView: UIView?
    @IBOutlet weak var MainView: UIView!
    
    @IBOutlet weak var MergeButton: UIButton!
    @IBOutlet weak var carousellButton: UIButton!
    
    enum callbacks: String {
        case SMDFadeOnMerge
        case SMDUnFadeOnMerge
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modesOfTransport.count
    }
    
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
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if modesOfTRansportCells.count > indexPath.item {
            let cell = modesOfTRansportCells[indexPath.item]
            return cell
        }
        
        let cell = self.carrouselCollectionView.dequeueReusableCell(withReuseIdentifier: "ChooseAmodeOfTransportCollectionViewCell", for: indexPath) as! ChooseAmodeOfTransportCollectionViewCell
//        LoadCell(indexPath, cell)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ChooseAmodeOfTransportCollectionViewCell {
            LoadCell(indexPath, cell)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        carrouselView.isHidden = true
        self.MergeTableView.delegate = self
        self.MergeTableView.dataSource = self
        self.carrouselCollectionView.delegate = self
        self.carrouselCollectionView.dataSource = self
        self.carrouselCollectionView.collectionViewLayout = ZoomAndSnapFlowLayout()
        // Do any additional setup after loading the view.
        self.MergeTableView.register( UINib(nibName: "SMDStartTableViewCell", bundle: nil), forCellReuseIdentifier: "SMDStartTableViewCell")
        self.MergeTableView.register( UINib(nibName: "SMDRadioButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "SMDRadioButtonTableViewCell")
        self.MergeTableView.register( UINib(nibName: "TubeTableViewCell", bundle: nil), forCellReuseIdentifier: "TubeTableViewCell")
        self.loadBottomButton(button: carousellButton)
        self.loadBottomButton(button: MergeButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(fadeTopViews), name: NSNotification.Name(rawValue: SMDMergeViewController.callbacks.SMDFadeOnMerge.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unfadeTopViews), name: NSNotification.Name(rawValue: SMDMergeViewController.callbacks.SMDUnFadeOnMerge.rawValue), object: nil)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.MergeButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Merge", comment: "", boldText: false, size: 15, disabled: false)
        
        MotivAuxiliaryFunctions.loadStandardButton(button: self.carousellButton, bColor: MotivColors.WoortiOrange, tColor: UIColor.white, key: "Save", comment: "", boldText: false, size: 15, disabled: false)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SplitMergeDeleteTopViewController.callbacks.SMDTopSetTitle.rawValue), object: nil, userInfo: ["title" : "Merge"])
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: SplitMergeDeleteTopViewController.callbacks.SMDTopHideButton.rawValue), object: nil)
        
//        self.loadCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadTable()
        DispatchQueue.main.async {
            self.MergeTableView.reloadData()
        }
    }
    
    func loadBottomButton(button: UIButton) {

    }
    
    func createTube() {
        let tube = (MergeTableView.dequeueReusableCell(withIdentifier: "TubeTableViewCell") as? TubeTableViewCell)!
        MotivAuxiliaryFunctions.RoundView(view: tube)
        self.listToLoad.append(tube)
    }
    
    func loadTable(){

        let list = (getFt()?.getTripPartsortedList() ?? [FullTripPart]()).filter { (part) -> Bool in
            if let leg = part as? Trip {
                return !leg.wrongLeg
            }
            return true
        }
        self.listToLoad.removeAll()
        
        self.createSTAcells(type: SMDStartTableViewCell.Images.Start, text: (getFt()?.getStartLocation() ?? "Start Location"), date: nil)
        createTube()
        for part in list {
            switch part {
            case let leg as Trip:
                if leg.wrongLeg {
                    continue
                }
                let cell = (MergeTableView.dequeueReusableCell(withIdentifier: "SMDRadioButtonTableViewCell") as? SMDRadioButtonTableViewCell)!
                cell.loadCell(part: leg)
                
                self.listToLoad.append(cell)
            case let we as WaitingEvent:

                let cell = (MergeTableView.dequeueReusableCell(withIdentifier: "SMDRadioButtonTableViewCell") as? SMDRadioButtonTableViewCell)!
                cell.loadCell(part: we)
                MotivAuxiliaryFunctions.RoundView(view: cell)
                self.listToLoad.append(cell)
            default:
                self.createSTAcells(type: SMDStartTableViewCell.Images.change, text: "Error!!", date: part.startDate)
            }
            createTube()
        }
        self.createSTAcells(type: SMDStartTableViewCell.Images.Arrival, text: (getFt()?.getEndLocation() ?? "End Location"), date: list.last?.startDate)
    }
    
    func createSTAcells(type: SMDStartTableViewCell.Images, text: String, date: Date?){
        let cell = (MergeTableView.dequeueReusableCell(withIdentifier: "SMDStartTableViewCell") as? SMDStartTableViewCell)!
        cell.loadCell(type: type, textLabel: text, date: date)
        MotivAuxiliaryFunctions.RoundView(view: cell)
        self.listToLoad.append(cell)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listToLoad.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return self.listToLoad[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? SMDRadioButtonTableViewCell {
            cell.toggleSelect()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch listToLoad[indexPath.row] {
        case let _ as TubeTableViewCell:
            return CGFloat(20)
        default:
            return CGFloat(50)
        }
    }

    @IBAction func mergeClick(_ sender: Any) {
        //check if possible and reveal
        var lastWasSelected = false
        var alreadyHasASelectionRange = false
        var selectedCount = 0
        var partsToMerge = [FullTripPart]()
        
        for cell in listToLoad {
            if let selectableCell = cell as? SMDRadioButtonTableViewCell {
                if selectableCell.isSelectedForMerge() {
                    if alreadyHasASelectionRange && !lastWasSelected {
                        return
                    }
                    lastWasSelected = true
                    alreadyHasASelectionRange = true
                    selectedCount += 1
                    if let part = selectableCell.part {
                        partsToMerge.append(part)
                    }
                } else {
                    lastWasSelected = false
                }
            }
        }
        
        if !alreadyHasASelectionRange || selectedCount < 2 {
            return
        }
        
        
        
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  GenericSplitMergeDeleteViewController.MTViews.SMDMyTripsSplitMap.rawValue), object: nil, userInfo: ["parts": partsToMerge, "type": SplitMapViewViewController.mapType.merge])
        
    }
    
    @IBAction func carrousellSaveClick(_ sender: Any) {
        //merge trips to this mode of transport
        DispatchQueue.global(qos: .background).sync {
            let legsToMerge = listToLoad.filter {
                (cell) -> Bool in
                if let Rcell = cell as? SMDRadioButtonTableViewCell {
                    return Rcell.isSelectedForMerge()
                }
                return false
            }
            for i in stride(from: legsToMerge.count - 2, through: 0, by: -1) {
                if let rb = legsToMerge[i] as? SMDRadioButtonTableViewCell {
                    if let part = rb.part {
                        self.getFt()?.joinWithnext(part: part, modeOfTRansport: self.getSelectedMOT(), fromInterface: true)
                    }
                }
            }
            loadTable()
            DispatchQueue.main.async {
                self.MergeTableView.reloadData()
            }
            notifyMOTEnd()
        }
    }
    
    func getSelectedMOT() -> String {
        for cell in modesOfTRansportCells {
            if cell.isSelectedForMerge() {
                return cell.getText()
            }
        }
        return ""
    }
    
    //fading top view
    @objc func fadeTopViews() {
        self.carrouselView.isHidden = false
        
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
        
        self.carrouselView.isHidden = true
        if fadeView != nil {
            fadeView?.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func notifyMOTEnd() {
        NotificationCenter.default.post(name:  NSNotification.Name(rawValue:  callbacks.SMDUnFadeOnMerge.rawValue), object: nil)
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


class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {
    
    var activeDistance: CGFloat = 300
    let zoomFactor: CGFloat = 0.5
    
    override init() {
        super.init()
        
        scrollDirection = .horizontal
        minimumLineSpacing = 10
        itemSize = CGSize(width: 50, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)
        
        self.activeDistance = collectionView.bounds.width / 2
        
        super.prepare()
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        
        var selectedCell: (CGFloat,ChooseAmodeOfTransportCollectionViewCell)?
        
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / activeDistance
            
            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attributes.zIndex = Int(zoom.rounded())
            }
            
            if let cell = collectionView.cellForItem(at: attributes.indexPath) as? ChooseAmodeOfTransportCollectionViewCell {

                cell.unselect()
                if distance.magnitude < selectedCell?.0 ?? (distance + 1) {
                    if selectedCell != nil {
                        selectedCell!.1.unselect()
                    }
                    cell.Select()
                    selectedCell = (distance.magnitude,cell)
                }
            }
        }
        
        return rectAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }

        // Add some snapping behaviour so that the zoomed cell is always centered
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
                

            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        return true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
    
}
