//
//  ViewController.swift
//  SpaceXApp
//
//  Created by Przemek on 29/08/22.
//

import UIKit
import Combine
import SwiftUI

final class LaunchViewController: UIViewController {
    
    @IBOutlet weak var activityIndecator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    
    var anyCancellable: AnyCancellable?
    
    let viewModel: LaunchesViewModelType = LaunchesViewModel(repository: LaunchRepository())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        
        self.tableView.contentInsetAdjustmentBehavior = .never
        let companyApiRequest = ApiRequest(baseUrl: EndPoint.baseUrl, path: Path.company, params: [:])
        
        let launchApiRequest = ApiRequest(baseUrl: EndPoint.baseUrl, path: Path.launches, params: [:])
        
        bindData()
        viewModel.fetchCompanyAndLaunchInfo(companyApiRequest: companyApiRequest, launchApiRequest: launchApiRequest)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "filterScreen" {
            if  let destination = segue.destination as? FilterSelectionViewController {
                            
                destination.viewModel = viewModel
            }
        }
    }
    
    private func bindData() {
        anyCancellable =  viewModel.stateBinding.sink { _ in
            
        } receiveValue: { [weak self] launchState in
            DispatchQueue.main.async {
                self?.updateUI(state: launchState)
            }
        }
        
    }
    
    private func updateUI(state: LaunchsState) {
        switch state {
        case .none:
            tableView.isHidden = true
        case .loading:
            tableView.isHidden = true
            activityIndecator.startAnimating()
        case .finishedLoading:
            tableView.isHidden = false
            activityIndecator.stopAnimating()
            tableView.reloadData()
        case .error(let error):
            print(error)
            activityIndecator.stopAnimating()
            tableView.reloadData()
        case .filterSelection:
            tableView.reloadData()
        }
    }
    
    private func showActionSheet(for index: Int) {
        
        let items = viewModel.getLaunchClickDetails(for: index)
        
        let alert = UIAlertController(title: "SpaceX", message: "Please Select an Option", preferredStyle: .actionSheet)
        
        items.forEach { item in
            alert.addAction(UIAlertAction(title: item.name, style: .default, handler: { _ in
                if let url = URL(string: item.navigationUrl), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, completionHandler: nil)
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    @IBAction func filterButtonAction(_ sender: Any) {

    }
    
    deinit {
        anyCancellable?.cancel()
    }
    
}

extension LaunchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return viewModel.launchesCount
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "companyInfoCell") as? CompanyInfoTableViewCell else {
                return UITableViewCell()
            }
            cell.setData(companyInfo: viewModel.getCompanyInfo())
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "launchInfoCell") as? LaunchInfoTableViewCell else {
                return UITableViewCell()
            }
            
            cell.accessibilityValue = ""
            
            if let launchDetails = viewModel.getLaunchInfo(for: indexPath.row) {
                cell.setData(launchDetails: launchDetails)
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension LaunchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
        
        view.backgroundColor = UIColor.black
        
        let label = UILabel(frame: view.bounds)
        label.textColor = UIColor.white
        view.addSubview(label)
        
        switch section {
        case 0:
            label.text =  "Company"
        case 1:
            label.text = "LAUNCHES"
        default:
            label.text = ""
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showActionSheet(for: indexPath.row)
    }
}
