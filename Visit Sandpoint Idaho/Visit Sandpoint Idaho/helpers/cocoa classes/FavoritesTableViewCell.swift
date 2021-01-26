//
//  FavoritesTableViewCell.swift
//  Visit Sandpoint Idaho
//
//  Created by Mitchell Rust on 12/6/20.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var sub1Label: UILabel!
    @IBOutlet weak var sub2Label: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
