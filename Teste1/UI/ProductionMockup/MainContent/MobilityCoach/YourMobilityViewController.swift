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

/**
* DEPRECATED This feature was removed at some point
*/
class YourMobilityViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //Header
    @IBOutlet weak var closeImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mobilityCollectionView: UICollectionView!
    
    // popOver
    @IBOutlet var popOver: UIView!
    @IBOutlet weak var popOverBeginButton: UIButton!
    var fadeView: UIView?
    
    @IBOutlet weak var popOverImage: UIImageView!
    @IBOutlet weak var popOverText: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let touch = UITapGestureRecognizer(target: self, action: #selector(dismissVC))
        self.closeImage.addGestureRecognizer(touch)
        
        self.titleLabel.text = "Your mobility"
        
        self.mobilityCollectionView.delegate = self
        self.mobilityCollectionView.dataSource = self
        self.mobilityCollectionView.collectionViewLayout = ZoomAndSnapResizableFlowLayout(cv: self.mobilityCollectionView)
        
        let frame = self.view.bounds
        self.popOver.bounds = CGRect(x: 0, y: 0, width: frame.width - 60, height: frame.height - 200)
        self.popOver.layer.cornerRadius = (self.popOver?.bounds.height ?? 0)/14
        self.popOverBeginButton?.layer.cornerRadius = (self.popOverBeginButton?.bounds.height ?? 0)/2
    }
    
    public func popUp(type: Int) {
        switch type {
        case 0:
            popOverText.text = "Done deal! We'll suggest trips to help you achieve your goal."
            popOverImage.image = UIImage(named: "ProductiveSquirelAccept")
            break
        case 1:
            popOverText.text = "I got the power! We'll suggest trips to help you achieve your goal."
            popOverImage.image = UIImage(named: "ActivitySquirelAccept")
            break
        case 2:
            popOverText.text = "Wax in wax out! We'll suggest trips to help you achieve your goal."
            popOverImage.image = UIImage(named: "RelaxingSquirelAccept")
            break
        default:
            break
        }
        popup()
    }
    
    @objc func popup(){
        closePopup()
        self.fadeView = UIView(frame: self.view.bounds)
        fadeView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(fadeView!)
        fadeView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closePopup)))
        
        self.view.addSubview(self.popOver)
        self.popOver.center = self.view.center
    }
    
    @objc func closePopup() {
        self.fadeView?.removeFromSuperview()
        self.popOver?.removeFromSuperview()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YourMobilityCollectionViewCell", for: indexPath) as! YourMobilityCollectionViewCell
        
        cell.setType(type: indexPath.item, vc: self)
        return cell
    }
    
    @IBAction func popOverClose(_ sender: Any) {
        if let user = MotivUser.getInstance() {
            user.hasSetGoal = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: MobilityCoachViewController.MobilityCoachRefresh), object: nil)
        
        self.closePopup()
        self.dismissVC()
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

class ZoomAndSnapResizableFlowLayout: UICollectionViewFlowLayout {
    
    var activeDistance: CGFloat = 300
    let zoomFactor: CGFloat = 0.25
    
    init(cv: UICollectionView) {
        super.init()
        
        scrollDirection = .horizontal
        minimumLineSpacing = 10
        
        itemSize = CGSize(width: cv.bounds.width * 0.7, height: cv.bounds.height)
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
        
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / activeDistance
            
            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attributes.zIndex = Int(zoom.rounded())
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
