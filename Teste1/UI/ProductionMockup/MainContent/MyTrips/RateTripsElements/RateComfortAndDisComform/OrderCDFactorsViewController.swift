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
//import MobileCoreServices
//, UITableViewDragDelegate, UITableViewDropDelegate
class OrderCDFactorsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var values = ["Cleanliness inside","Seating availability (onboard)","Air quality","Temperature","Personal space (crowd level)","Provacy","Jerkiness/Motion Sickness","Design/Arquitecture","Maintenance (upkeep/repair)","Cleanliness Outside","Air Polution","Noise","Traffic (congestion)","Pleasentness (ambience)","Smoothness (pavement/floors)","Accessibility (ease to get to or through)"]
    
    @IBOutlet weak var orderTableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var ContainedIn: ComfortAndDiscomfortFactorsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderTableView.delegate = self
        orderTableView.dataSource = self
//        orderTableView.dragDelegate = self
//        orderTableView.dropDelegate = self
        orderTableView.setEditing(true, animated: true)
        view.translatesAutoresizingMaskIntoConstraints = false
        // Do any additional setup after loading the view.
        tableViewHeightConstraint.constant = CGFloat(50 * values.count)
    }
    
    func reloadView(){
        if Thread.isMainThread {
            tableViewHeightConstraint.constant = CGFloat(50 * values.count)
            orderTableView.reloadData()
        } else {
            DispatchQueue.main.async {
                self.reloadView()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCDTableViewCell") as! OrderCDTableViewCell
        let value = values[indexPath.row]
        cell.loadCell(Text: value)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! chooseCDTableViewCell
//        cell.toggleCell()
//        let (selected, text) = cell.getCellSelected()
//        if selected {
//            selectedValues.append(text)
//        } else if let ind = selectedValues.index(of: text) {
//            selectedValues.remove(at: ind)
//        }
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
//    //Drag
//    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//
//        let value = values[indexPath.row]
//
//        let data = value.data(using: .utf8)
//        let itemProvider = NSItemProvider()
//
//        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
//            completion(data, nil)
//            return nil
//        }
//
//        return [
//            UIDragItem(itemProvider: itemProvider)
//        ]
//
//    }
//
//    //Drop
//    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
//        return session.canLoadObjects(ofClass: NSString.self)
//    }
//
//    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
//        // The .move operation is available only for dragging within a single app.
//        if tableView.hasActiveDrag {
//            if session.items.count > 1 {
//                return UITableViewDropProposal(operation: .cancel)
//            } else {
//                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
//            }
//        } else {
//            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
//        }
//    }
//
//    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
//        let destinationIndexPath: IndexPath
//
//        if let indexPath = coordinator.destinationIndexPath {
//            destinationIndexPath = indexPath
//        } else {
//            // Get last index path of table view.
//            let section = tableView.numberOfSections - 1
//            let row = tableView.numberOfRows(inSection: section)
//            destinationIndexPath = IndexPath(row: row, section: section)
//        }
//
//        coordinator.session.loadObjects(ofClass: NSString.self) { items in
//            // Consume drag items.
//            let stringItems = items as! [String]
//
//            var indexPaths = [IndexPath]()
//            for (index, item) in stringItems.enumerated() {
//                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
////                self.model.addItem(item, at: indexPath.row)
//                self.values.insert(item, at: indexPath.row)
//                indexPaths.append(indexPath)
//            }
//
//            tableView.insertRows(at: indexPaths, with: .automatic)
//        }
//    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let value = self.values[sourceIndexPath.row]
        print("start: \(sourceIndexPath.row) dest: \(destinationIndexPath.row)")
        print("start: \(self.values[sourceIndexPath.row]) dest: \(self.values[destinationIndexPath.row])")
        
        if destinationIndexPath.row > sourceIndexPath.row {
            self.values.insert(value, at: destinationIndexPath.row + 1)
            print("remove\(self.values[sourceIndexPath.row])")
            self.values.remove(at: sourceIndexPath.row)
        } else {
            self.values.insert(value, at: destinationIndexPath.row)
            print("remove\(self.values[sourceIndexPath.row + 1])")
            self.values.remove(at: sourceIndexPath.row + 1)
        }
        
//        if let idx = self.values.index(of: value) {
//            self.values.remove(at: idx)
//        }
        print(values)
        reloadView()
    }
    
    @IBAction func clickDone(_ sender: Any) {
        if let parent = self.ContainedIn {
            parent.processDone(vc: self)
        }
    }
}

