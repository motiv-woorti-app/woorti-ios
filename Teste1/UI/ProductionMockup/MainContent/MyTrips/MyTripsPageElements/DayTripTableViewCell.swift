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

class DayTripTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var DayTipsLabel: UILabel!
    //@IBOutlet weak var confirmTripsLAbel: UILabel!
    @IBOutlet weak var TripsTableView: UITableView!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var parentContainer: MyTripsViewController?
    
    @IBOutlet weak var overlappingContainerView: UIView!
    @IBOutlet weak var containertView: UIView!
    private var fts = [FullTrip]()
    private var key: TimeInterval = TimeInterval(0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        TripsTableView.register(UINib.init(nibName: "SingleTripTableViewCell", bundle: nil), forCellWithReuseIdentifier: "SingleTripTableViewCell")
//        self.TripsTableView.separatorInset = UIEdgeInsets(top: CGFloat(0), left: CGFloat(0), bottom: CGFloat(10), right: CGFloat(0))
//        self.TripsTableView.separatorColor = MotivColors.WoortiOrangeT2
        TripsTableView.register(UINib(nibName: "SingleTripTableViewCell", bundle: nil), forCellReuseIdentifier: "SingleTripTableViewCell")
        
        self.TripsTableView.delegate = self
        self.TripsTableView.dataSource = self
        TripsTableView.backgroundColor = UIColor.clear
        MotivAuxiliaryFunctions.RoundView(view: containertView)
        MotivAuxiliaryFunctions.RoundView(view: overlappingContainerView)
        containertView.backgroundColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        collectionViewHeight.constant = CGFloat(fts.count * 119)
        return fts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SingleTripTableViewCell", for: indexPath) as! SingleTripTableViewCell
        
        let ft = fts[indexPath.row]
        cell.loadcell(ft: ft)
        
        return cell
    }
    
    func loadcell(parent: MyTripsViewController, fts: [FullTrip], key: TimeInterval) {
//        topViewWidth.constant = width - (13 * 2)
        self.parentContainer = parent
        self.key = key
        self.fts = fts
        
        let date = Date(timeIntervalSince1970: key)
        DayTipsLabel.text = dateTextViewConverter(date: date)
        
        /*
        self.confirmTripsLAbel.isHidden = true
        for ft in fts {
            if !ft.confirmed {
                self.confirmTripsLAbel.isHidden = false
                break
            }
        }*/
        
        TripsTableView.reloadData()
    }
    
    func dateTextViewConverter(date: Date) -> String {
        let today = self.parentContainer?.getDateFromDateTime(date: Date()) ?? Date()
        let yesterday = self.parentContainer?.getDateFromDateTime(date: Date(), dayDistance: -1) ?? Date()
        if today == date {
            return NSLocalizedString("Today", comment: "")
        }
        if yesterday == date {
            return NSLocalizedString("Yesterday", comment: "")
        }
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MMM dd"
        
        dateFormatterGet.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatterGet.locale = Locale.current
        let foundDate = dateFormatterGet.string(from:date)
        //print("found date: \(foundDate)")
        return foundDate
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ft = self.fts[indexPath.row]
        parentContainer?.ftToGo = ft
        parentContainer?.performSegue(withIdentifier: MyTripsViewController.CHANGETOCONFIRMTRIP, sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(119)
    }
    
}
