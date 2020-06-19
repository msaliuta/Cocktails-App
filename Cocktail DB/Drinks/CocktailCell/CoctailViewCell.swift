//
//  CoctailViewCell.swift
//  Cocktail DB
//
//  Created by Maksym Saliuta on 19.06.2020.
//  Copyright © 2020 Maksym Saliuta. All rights reserved.
//

import UIKit

class CoctailViewCell: UITableViewCell {

    @IBOutlet weak var coctailImageView: UIImageView!
    @IBOutlet weak var coctailNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with drink: Drink){
        coctailNameLabel.text = drink.name
        coctailImageView.downloaded(from: drink.imageURL , contentMode: .scaleToFill)
    }
}
