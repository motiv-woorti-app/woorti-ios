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

class OptionsMenuViewController: MTGenericViewController {

    @IBOutlet weak var SplitButton: UIButton!
    @IBOutlet weak var MergeButton: UIButton!
    @IBOutlet weak var DeleteButton: UIButton!
    @IBOutlet var topView: UIView!
    
    var option = GenericSplitMergeDeleteViewController.Option.split
    var Trip = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SplitButton.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        SplitButton.layer.cornerRadius = 14
        MergeButton.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        MergeButton.layer.cornerRadius = 14
        DeleteButton.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        DeleteButton.layer.cornerRadius = 14
        
        MotivFont.motivRegularFontFor(key: "Split", comment: "", button: self.SplitButton, size: 15)
        MotivFont.motivRegularFontFor(key: "Merge", comment: "", button: self.MergeButton, size: 15)
        MotivFont.motivRegularFontFor(key: "Delete", comment: "", button: self.DeleteButton, size: 15)
        
        loadImageForButton(btn: SplitButton)
        loadImageForButton(btn: MergeButton)
        loadImageForButton(btn: DeleteButton)
        
        // Do any additional setup after loading the view.
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backOnMenu)))
    }
    
    func loadImageForButton(btn: UIButton) {
        let bounds = btn.imageView?.bounds
        let heightBound =  (bounds?.height)! - 20
        let widthBound = (bounds?.width)! - 20
        
        btn.contentMode = .scaleAspectFit
        btn.imageEdgeInsets = UIEdgeInsets(top: heightBound/2, left: widthBound/2, bottom: heightBound/2, right: widthBound/2)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func splitClick(_ sender: Any) {
        self.option = .split
        if self.Trip {
            self.performSegue(withIdentifier: "ShowMergeSplitDeleteTrip",sender: self)
        } else {
            self.performSegue(withIdentifier: "SplitDeleteMergeSegue", sender: self)
        }
        
    }
    
    @IBAction func mergeClick(_ sender: Any) {
        self.option = .merge
        if self.Trip {
            self.performSegue(withIdentifier: "ShowMergeSplitDeleteTrip",sender: self)
        } else {
            self.performSegue(withIdentifier: "SplitDeleteMergeSegue", sender: self)
        }
    }
    
    @IBAction func deleteClick(_ sender: Any) {
        self.option = .delete
        if self.Trip {
            self.performSegue(withIdentifier: "ShowMergeSplitDeleteTrip",sender: self)
        } else {
            self.performSegue(withIdentifier: "SplitDeleteMergeSegue", sender: self)
        }
    }
    
    @objc func backOnMenu(){
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyTripsViewController.StartedOrFinishedTrip), object: nil)
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.destination {
        case let genericSplitMergeDelete as GenericSplitMergeDeleteViewController:
            genericSplitMergeDelete.setFT(ft: self.getFt()!)
            genericSplitMergeDelete.setOptionToShow(option: self.option)
        case let genericSplitMergeDelete as SplitMergeDeleteTripsViewController:
//            genericSplitMergeDelete.setFT(ft: self.getFt()!)
            switch self.option {
                case .merge:
                genericSplitMergeDelete.option = SplitMergeDeleteTripsViewController.optionsEnum.merge
                case .split:
                    genericSplitMergeDelete.option = SplitMergeDeleteTripsViewController.optionsEnum.split
                case .delete:
                    genericSplitMergeDelete.option = SplitMergeDeleteTripsViewController.optionsEnum.delete
            }
//            genericSplitMergeDelete.setOptionToShow(option: self.option)
        default:
            break
        }
    }

}
