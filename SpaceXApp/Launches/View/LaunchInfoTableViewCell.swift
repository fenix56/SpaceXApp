//
//  LaunchInfoTableViewCell.swift
//  SpaceXApp
//
//  Created by Przemek on 29/08/22.
//

import UIKit
import SDWebImage

final class LaunchInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var missionSinceDaysValueLbl: UILabel!
    @IBOutlet weak var missionSinceDaysLbl: UILabel!
    @IBOutlet weak var rocketNameValueLbl: UILabel!
    @IBOutlet weak var rocketNameLbl: UILabel!
    @IBOutlet weak var missonDateValueLbl: UILabel!
    @IBOutlet weak var missionDateLbl: UILabel!
    @IBOutlet weak var missonNameValueLbl: UILabel!
    @IBOutlet weak var misisonNameLbl: UILabel!
    
    @IBOutlet weak var missionStatusImageView: UIImageView!
    @IBOutlet weak var launchPatchImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(launchDetails: LaunchDetails) {
        
        misisonNameLbl.accessibilityLabel = ""
        misisonNameLbl.text = "Mission:"
        missonNameValueLbl.text = launchDetails.missionName
        
        missionDateLbl.text = "Date/Time:"
        missonDateValueLbl.text = launchDetails.missionLaunchDate
        
        rocketNameLbl.text = "Rocket:"
        rocketNameValueLbl.text = launchDetails.rocketType
        
        missionSinceDaysLbl.text =  launchDetails.daysSinceFrom.0
        missionSinceDaysValueLbl.text = "\(launchDetails.daysSinceFrom.1)"
        
        let imageName = launchDetails.isMissonSuccessFull ? "success" : "failure"
        missionStatusImageView.image = UIImage(named: imageName)
                if let url = URL(string: launchDetails.patchImage) {
            
            launchPatchImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder.png"))

        }
    }

}
