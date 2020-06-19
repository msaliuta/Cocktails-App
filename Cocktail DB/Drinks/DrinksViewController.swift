//
//  DrinksViewController.swift
//  Cocktail DB
//
//  Created by Maksym Saliuta on 18.06.2020.
//  Copyright © 2020 Maksym Saliuta. All rights reserved.
//

import Foundation
import UIKit

class DrinksViewController: UIViewController{
    
    private var drinks: [String: [Drink]] = [:]
    private var filters = [Constants.defaultFilter]
    private var index = 0
    private var cocktailCellID = "\(CoctailViewCell.self)"
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var drinksTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drinksTableView.dataSource = self
        drinksTableView.delegate = self
        drinksTableView.register(UINib(nibName: "CoctailViewCell", bundle: nil), forCellReuseIdentifier: cocktailCellID)
        drinksTableView.separatorStyle = .none
        updateList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        configureNavigationBar()
    }
    
    private func configureNavigationBar(){
        
        let height: CGFloat = 70
        let bounds = self.navigationController!.navigationBar.bounds
        
        filterButton.setImage(UIImage(named: "Vector.png"), for: .normal)
        filterButton.setTitle(.none, for: .normal)
        
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(CGFloat(7), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.topItem?.title = "Drinks"
        self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + height)
    }
    
    private func updateList() {
        if 0..<filters.count ~= index {
            CocktailDB.shared.fetchCocktails(filter: filters[index]) { (result) in
                switch result {
                case .success(let response):
                    if self.index == 0 {
                        self.drinks = [:]
                    }
                    let filters = self.filters
                    let index = self.index
                    let key = filters[index]
                    self.drinks[key] = response.drinks
                    DispatchQueue.main.async {
                        self.drinksTableView.reloadData()
                    }
                case .failure(let error):
                    print("\(error)")
                }
            }
        }
    }
}

extension DrinksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionDrinks = drinks[filters[section]]
        return sectionDrinks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cocktailCellID, for: indexPath) as? CoctailViewCell else {
            return UITableViewCell()
        }
        
        let drink = drinks[filters[indexPath.section]]?[indexPath.row]
        cell.configure(with: drink!)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filters.count
    }
    
}

extension DrinksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        filters[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == index && indexPath.row == tableView.numberOfRows(inSection: index) - 1 && filters.count - 1 > index {
            index += 1
            updateList()
        }
    }
}

extension UIImageView {
    
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: UIView.ContentMode) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

extension DrinksViewController: FiltersViewControllerDelegate {
    func applyFilters(filters: [String]) {
        self.filters = filters
    }
}
