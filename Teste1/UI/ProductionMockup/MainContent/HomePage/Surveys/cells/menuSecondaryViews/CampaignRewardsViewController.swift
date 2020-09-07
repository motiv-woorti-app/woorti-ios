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

class CampaignRewardsViewController: GenericViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var rewards = [Reward]()
    var rewardStatus = [RewardStatus]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = MotivUser.getInstance() {
            rewards = user.getRewards()
            rewardStatus = user.getRewardStatus()
            
            rewards = rewards.filter({$0.isRewardActive(date: Date())})
        }
        print("RewardsViewController got \(rewards.count) rewards")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "RewardTableViewCell", bundle: nil), forCellReuseIdentifier: "RewardTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor.clear
        tableView.backgroundColor = UIColor.clear
    
        
        self.view.backgroundColor = MotivColors.WoortiOrangeT3
        
        tableView.tableFooterView = UIView()
        MotivAuxiliaryFunctions.RoundView(view: tableView)
        
        //MotivRequestManager.getInstance().syncRewardStatusWithServer()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
    }
    
    //TV
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return rewards.count
        
    }
    
    func getRewardStatusString(targetType: Double, targetPoints: Double, id: String) -> String{
        var string = ""
        var currentPoints = 0.0
        var type : String
        switch(targetType){
            case 1.0: type = NSLocalizedString("Points", comment: "")
            case 2.0: type = NSLocalizedString("Days", comment: "")
            case 3.0: type = NSLocalizedString("Trips", comment: "")
            case 4.0: type = NSLocalizedString("Points", comment: "")
            case 5.0: type = NSLocalizedString("Days", comment: "")
            case 6.0: type = NSLocalizedString("Trips", comment: "")
            default: type = ""
        }
        
        for reward in rewardStatus {
            if reward.rewardID == id {
                currentPoints = reward.currentValue
            }
        }
        
        return "\(Int(currentPoints))/\(Int(targetPoints)) " + type
    }
    
    func getDescriptions(reward: Reward) -> (String, String) {
        var rewardLanguage = ""
        
        if let lang = MotivUser.getInstance()?.language {
            rewardLanguage = (Languages.getLanguageForSMCode(smartphoneID: lang ?? "") ?? Languages.getLanguages().first)!.woortiID
        }
        
        let defaultLanguage = reward.defaultLanguage
        
        var defaultShortDescription = ""
        var defaultLongDescription = ""
   
        let descriptions = reward.allDescriptions.allObjects as? [Description] ?? [Description]()
       
        for description in descriptions {
            if description.lang == defaultLanguage {
                defaultShortDescription = description.myShortDescription
                defaultLongDescription = description.longDescription
            }
            else if description.lang == rewardLanguage{
                return (description.myShortDescription, description.longDescription)
            }
        }
        
        return (defaultShortDescription, defaultLongDescription)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RewardTableViewCell") as! RewardTableViewCell
        
        let reward = rewards[indexPath.row]
        let campaignName = MotivUser.getInstance()!.getCampaignName(id: reward.targetCampaignId)
        
        MotivFont.motivBoldFontFor(text: reward.rewardName, label: cell.RewardName, size: 16)
        MotivFont.motivBoldFontFor(text: campaignName, label: cell.CampaignName, size: 14)
        
        MotivFont.motivBoldFontFor(key: getRewardStatusString(targetType: reward.targetType,targetPoints: reward.targetValue,id: reward.rewardId), comment: "", label: cell.RewardScore, size: 16)
        MotivFont.ChangeColorOnAttributedStringFromLabel(label: cell.RewardScore, color: MotivColors.WoortiOrange)
        
        MotivFont.motivRegularFontFor(key: reward.organizerName, comment: "", label: cell.OrganizerName, size: 14)
        
       var descriptions = getDescriptions(reward: reward)
        
        MotivFont.motivRegularFontFor(key: descriptions.0, comment: "", label: cell.ShortDescription, size: 14)
        
        MotivFont.motivRegularFontFor(key: descriptions.1, comment: "", label: cell.LongDescription, size: 14)
        
        if reward.linkToContact.count > 0 {
            MotivFont.motivRegularFontFor(key: reward.linkToContact, comment: "", label: cell.Link, size: 14)
        } else {
            cell.Link.isHidden = true
        }
        

        
        cell.makeViewRound()
        cell.loadShadow()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
    }
    
    
    
    
    func makeViewRound(view :UIView){
        view.layer.masksToBounds = true
        view.layer.cornerRadius = view.bounds.width * 0.05
    }
    
    
}
