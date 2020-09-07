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

class TripDayTableViewCell: UITableViewCell, UITableViewDelegate, UITableViewDataSource {

    static let SingleTripCellTableViewCell = "SingleTripCellTableViewCell"
    
    var fts = [FullTrip]()
    var timeString: String = ""
    var selectedCells = [Int]()
    var selectable = false
    
    var startDay = Date()
    var parent: SplitMergeDeleteTripsViewController?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tv: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tv.dataSource = self
        self.tv.delegate = self
        self.tv.backgroundColor = MotivColors.WoortiOrangeT3
        self.backgroundColor = MotivColors.WoortiOrangeT3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    func setTripsToShow(fts: [FullTrip], date: Date, selectable: Bool, parent: SplitMergeDeleteTripsViewController) {
        if Thread.isMainThread {
            self.parent = parent
            self.fts = fts
            self.startDay = date
            self.selectable = selectable
            self.timeString = dateTextViewConverter(date: date)
            MotivFont.motivBoldFontFor(text: timeString, label: self.titleLabel, size: 15)
            self.titleLabel.textColor = MotivColors.WoortiOrange
            self.tv.register(UINib(nibName: TripDayTableViewCell.SingleTripCellTableViewCell, bundle: nil), forCellReuseIdentifier: TripDayTableViewCell.SingleTripCellTableViewCell)
            self.tv.reloadData()
        } else {
            DispatchQueue.main.async {
                self.setTripsToShow(fts: fts, date: self.startDay, selectable: selectable, parent: parent)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fts.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TripDayTableViewCell.SingleTripCellTableViewCell) as! SingleTripCellTableViewCell
        
        let selected = selectedCells.contains(indexPath.row)
        cell.loadcell(ft: fts[indexPath.row], selectable: selectable, selected: selected)
//        cell.setTripsToShow(fts: ftsOrdered[indexPath.row].1, timeString: dateTextViewConverter(date: ftsOrdered[indexPath.row].0))
        
        return cell
    }
    
    func ReloadCellView() {
        if Thread.isMainThread {
            self.tv.reloadData()
        } else {
            DispatchQueue.main.async {
                self.ReloadCellView()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ind = selectedCells.index(of: indexPath.row) {
           selectedCells.remove(at: ind)
        } else {
            selectedCells.append(indexPath.row)
        }
        parent?.selectTrip(ft: fts[indexPath.row])
        ReloadCellView()
    }
    
    func dateTextViewConverter(date: Date) -> String {
        let today = UserInfo.getDateFromDateTime(date: Date()) ?? Date()
        let yesterday = UserInfo.getDateFromDateTime(date: Date(), dayDistance: -1) ?? Date()
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(109)
    }
    
}
