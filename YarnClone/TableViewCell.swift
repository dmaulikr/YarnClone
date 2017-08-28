//
//  TableViewCell.swift
//  YarnClone
//  Created by Ольга Клюшкина on 22.08.17.
//  Copyright © 2017 klyushkina. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var storyName: UILabel!
    @IBOutlet weak var storyImage: UIImageView!
    @IBOutlet weak var shortDescription: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    

override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    }

override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
