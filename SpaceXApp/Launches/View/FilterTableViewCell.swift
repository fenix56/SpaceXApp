//
//  FilterTableViewCell.swift
//  SpaceXApp
//
//  Created by Przemek on 29/08/22.
//

import UIKit

class FilterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var yearLabel: UILabel!
    
    @IBOutlet weak var yearImageView: UIImageView!
    var filterCriteria: FilterCriteria?
    
    func updateUI(filterCriteria: FilterCriteria) {
        self.filterCriteria = filterCriteria
        
        updateYearUI()
        addActions()
    }
    
    private func updateYearUI() {
        
        if let filterCriteria = filterCriteria as? FilterByYears {
            yearLabel.text = filterCriteria.year
            
            let imageName = filterCriteria.isSelected ? "Selected" : "DeSelected"
            
            yearImageView.image = UIImage(named: imageName)
        }
        
        if let filterCriteria = filterCriteria as? FilterByLaunchType {
            
            switch filterCriteria.launchType {
            case LaunchType.success:
                yearLabel.text = "Launch Success"
            case LaunchType.failure:
                yearLabel.text = "Launch Failure"
            }
            
            let imageName = filterCriteria.isSelected ? "Selected" : "DeSelected"
            
            yearImageView.image = UIImage(named: imageName)
        }
        if let filterCriteria = filterCriteria as? Sorting {
            yearLabel.text = "Sort Decnding"
            
            let imageName = filterCriteria.isSelected ? "Selected" : "DeSelected"
            
            yearImageView.image = UIImage(named: imageName)
        }
    }
    
    func addActions() {
        let stgr1 = UITapGestureRecognizer(target: self, action: #selector(yearTapped))
        stgr1.numberOfTouchesRequired = 1
        stackView.addGestureRecognizer( stgr1)
    }
    
    @objc func yearTapped() {
        if var filterCriteria = filterCriteria {
            filterCriteria.isSelected = !filterCriteria.isSelected
            updateYearUI()
        }
    }
    
}
