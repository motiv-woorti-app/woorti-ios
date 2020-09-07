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

class DayTripsCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var DayTipsLabel: UILabel!
    //@IBOutlet weak var confirmTripsLAbel: UILabel!
    @IBOutlet weak var TripsCollectionView: UICollectionView!
    @IBOutlet weak var topViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    //    @IBOutlet weak var topViewWidthConstraint: NSLayoutConstraint!
//    @IBOutlet weak var ContainerCollectionViewHeight: NSLayoutConstraint!
//
//    @IBOutlet weak var CollectionViewHeight: NSLayoutConstraint!
    var parentContainer: MyTripsViewController?
    
    @IBOutlet weak var containertView: UIView!
    private var fts = [FullTrip]()
    private var key: TimeInterval = TimeInterval(0)
    
//    var cells = [SingleTripMyTripsCollectionViewCell]()
//    private var size = 2
//    let layoutLock = NSLock()
//    var currentLoaded = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.TripsCollectionView.delegate = self
        self.TripsCollectionView.dataSource = self
        self.containertView.translatesAutoresizingMaskIntoConstraints = false
        
        TripsCollectionView.register(UINib.init(nibName: "SingleTripMyTripsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "SingleTripMyTripsCollectionViewCell")
        if let flowLayout = TripsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            let width = self.TripsCollectionView.bounds.width - flowLayout.sectionInset.left - flowLayout.sectionInset.right - self.TripsCollectionView.contentInset.left - self.TripsCollectionView.contentInset.right
            let width = self.TripsCollectionView.bounds.width //- (13 * 2)
            flowLayout.estimatedItemSize = CGSize(width: width, height: 1)
        }
        
        MotivAuxiliaryFunctions.RoundView(view: containertView)
        containertView.backgroundColor = UIColor.clear
        
//        self.layer.borderColor = UIColor(displayP3Red: CGFloat(247)/CGFloat(255), green: CGFloat(230)/CGFloat(255), blue: CGFloat(208)/CGFloat(255), alpha: CGFloat(1)).cgColor
//        self.layer.borderWidth = CGFloat(5)
        // Initialization code
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionViewHeight.constant = CGFloat(fts.count * 109)
        return fts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SingleTripMyTripsCollectionViewCell", for: indexPath) as! SingleTripMyTripsCollectionViewCell
        
        let ft = fts[indexPath.row]
        cell.loadcell(width: self.TripsCollectionView.bounds.width, ft: ft)

        return cell
    }
    
    func loadcell(width: CGFloat, parent: MyTripsViewController,fts: [FullTrip], key: TimeInterval) {
        topViewWidth.constant = width - (13 * 2)
        self.parentContainer = parent
        self.key = key
        self.fts = fts
        
        let date = Date(timeIntervalSince1970: key)
        DayTipsLabel.text = dateTextViewConverter(date: date)
        
        /*self.confirmTripsLAbel.isHidden = true
        for ft in fts {
            if !ft.confirmed {
                self.confirmTripsLAbel.isHidden = false
                break
            }
        }*/
        
        TripsCollectionView.reloadData()
    }
    
    func dateTextViewConverter(date: Date) -> String {
        let today = self.parentContainer?.getDateFromDateTime(date: Date()) ?? Date()
        let yesterday = self.parentContainer?.getDateFromDateTime(date: Date(), dayDistance: -1) ?? Date()
        if today == date {
            return "Today"
        }
        if yesterday == date {
            return "Yesterday"
        }
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM dd"
        dateFormatterGet.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatterGet.locale = Locale.current
        let foundDate = dateFormatterGet.string(from:date)
        //print("found date: \(foundDate)")
        return foundDate
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ft = self.fts[indexPath.row]
//        if !ft.confirmed {
            parentContainer?.ftToGo = ft
            parentContainer?.performSegue(withIdentifier: MyTripsViewController.CHANGETOCONFIRMTRIP, sender: self)
//        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = containertView.systemLayoutSizeFitting(layoutAttributes.size)
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        frame.size.width = ceil(size.width - 20)
        print("DayTripsCollectionViewCell size: \(size.height) \(size.width) ceil: \(ceil(size.height)) \(ceil(size.width))")
        layoutAttributes.frame = frame
        self.parentContainer?.updateParent()
        return layoutAttributes
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        TripsCollectionView.collectionViewLayout.invalidateLayout()
    }
}
