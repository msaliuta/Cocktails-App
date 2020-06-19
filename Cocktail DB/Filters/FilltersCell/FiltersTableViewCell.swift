//
//  FiltersTableViewCell.swift
//  Cocktail DB
//
//  Created by Maksym Saliuta on 19.06.2020.
//  Copyright © 2020 Maksym Saliuta. All rights reserved.
//

import UIKit

class FiltersTableViewCell: UITableViewCell {

    @IBOutlet weak var filltersCellLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
        // Configure the view for the selected state
    }
    
}
