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

class ProfileAppLanguageViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var languageTableView: UITableView!
    @IBOutlet weak var tableviewHeight: NSLayoutConstraint!
    let itemSize = CGFloat(50)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.languageTableView.delegate = self
        self.languageTableView.dataSource = self
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        makeViewRound(view: languageTableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UiAlerts.getInstance().newView(view: self)
    }
    
    //TV
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableviewHeight.constant = itemSize * CGFloat(Languages.getLanguages().count)
//        return Bundle.main.localizations.count
        return Languages.getLanguages().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguagesTableViewCell") as! LanguagesTableViewCell
        
//        let current = Locale.preferredLanguages.first!
//        let cellsSelected = Bundle.main.localizations[indexPath.row]
        let current = MotivUser.getInstance()?.language ?? Languages.getLanguages().first?.smartphoneID ?? "eng"
        let cellsSelected = Languages.getLanguages()[indexPath.row]
        
        cell.loadCell(isLanguageSelected: current == cellsSelected.smartphoneID, text: cellsSelected.name)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cellsSelected = Bundle.main.localizations[indexPath.row]
        
        let cellsSelected = Languages.getLanguages()[indexPath.row].smartphoneID
        let prev = MotivUser.getInstance()?.language
        if prev != cellsSelected {
            MotivUser.getInstance()?.language = cellsSelected
            UserDefaults.standard.set([cellsSelected], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            
            DispatchQueue.main.async {
                self.languageTableView.reloadData()
            }
            UiAlerts.getInstance().showRestartAppAfterLanguageChange()
        }
    }
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return itemSize
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
