//
//  FiltersViewController.swift
//  Cocktail DB
//
//  Created by Maksym Saliuta on 19.06.2020.
//  Copyright © 2020 Maksym Saliuta. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate: class {
    func applyFilters(filters: [String])
}

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var filterTableView: UITableView!
    @IBOutlet weak var applyButton: UIButton!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    @IBAction func applyButtonPrassed(_ sender: UIButton) {
        let filters = selectedFilters.map{ $0.name }
        delegate?.applyFilters(filters: filters)
        navigationController?.popViewController(animated: true)
    }
    
    private var filtersCellId = "\(FiltersTableViewCell.self)"
    private var filters = [Filter]()
    private var selectedFilters: [Filter] {
        filters.filter { $0.isSelected }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterTableView.dataSource = self
        filterTableView.delegate = self
        filterTableView.register(UINib(nibName: "FiltersTableViewCell", bundle: nil), forCellReuseIdentifier: filtersCellId)
        filterTableView.separatorStyle = .none
        
        updateFilters()
        // Do any additional setup after loading the view.
    }
    
    
    private func updateFilters() {
        CocktailDB.shared.fetchFilters { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                let filters = response.drinks
                self.filters = filters
                DispatchQueue.main.async {
                    self.filterTableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print(error)
                }
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension FiltersViewController: UITableViewDelegate {
    
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = filterTableView.dequeueReusableCell(withIdentifier: filtersCellId, for: indexPath) as? FiltersTableViewCell {
            let filter = filters[indexPath.row]
            cell.filltersCellLabel.text = filter.name
            if filter.isSelected {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: true)
            }
            return cell
        }
        return UITableViewCell()
    }
    
    
}
