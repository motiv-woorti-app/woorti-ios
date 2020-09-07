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

class LessonViewController: UIViewController {

    @IBOutlet weak var lessonTitle: UILabel!
    @IBOutlet weak var dismissButton: UIImageView!
    @IBOutlet weak var lessonImage: UIImageView!
    @IBOutlet weak var LessonDescription: UILabel!
    @IBOutlet weak var LessonText: UITextView!
    
    @IBOutlet weak var messageView: UIView!
    
    @IBOutlet weak var shareImage: UIImageView!
    var lesson: Lesson?
    var viewHasBeenLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        self.dismissButton.addGestureRecognizer(touch)
        viewHasBeenLoaded = true
        loadLessonIntoView()
        
        //UI
        self.lessonImage?.layer.cornerRadius = (self.lessonImage?.bounds.height ?? 0)/14
        self.lessonImage?.clipsToBounds = true
        
        self.messageView?.layer.cornerRadius = (self.messageView?.bounds.height ?? 0)/14
        self.messageView?.clipsToBounds = true
        
        
//        self.dismissButton.tintColor = UIColor.white
//        self.dismissButton.image = self.dismissButton.image?.withRenderingMode(.alwaysTemplate)
        self.dismissButton.tintColor = UIColor(displayP3Red: 236, green: 192, blue: 137, alpha: 1)
        
//        self.shareImage.tintColor = UIColor.white
//        self.shareImage.image = self.shareImage.image?.withRenderingMode(.alwaysTemplate)
        self.shareImage.tintColor = UIColor(displayP3Red: 236, green: 192, blue: 137, alpha: 1)
        
        
        self.lessonImage?.layer.shadowOffset = CGSize(width: 10, height: 30)
        self.lessonImage?.layer.shadowColor = UIColor.black.cgColor
        self.lessonImage?.layer.shadowOpacity = 1
        self.lessonImage?.layer.shadowRadius = 50
        
        self.messageView?.layer.shadowOffset = CGSize(width: 10, height: 30)
        self.messageView?.layer.shadowColor = UIColor.black.cgColor
        self.messageView?.layer.shadowOpacity = 1
        self.messageView?.layer.shadowRadius = 50
    }
    
    @objc func dismissVC() {
        if let presenting = self.presentingViewController as? MainViewController {
            for child in presenting.childViewControllers {
                if let prev = child as? MobilityCoachViewController {
                    prev.loadLessons()
                }
            }
        }
        self.dismiss(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadLesson(lesson: Lesson){
        self.lesson = lesson
        if viewHasBeenLoaded {
            loadLessonIntoView()
        }
        lesson.readLesson()
    }
    
    func loadLessonIntoView() {
        if let lesson = self.lesson {
            self.lessonTitle.text = lesson.title
            self.lessonImage.image = lesson.getImage()
            self.LessonDescription.text = lesson.subTitle
            self.LessonText.text = lesson.text
        }
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
