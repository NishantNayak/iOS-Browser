//
//  SeachEagineTableViewCell.swift
//  iOSBrowser
//
//  Created by NINAYA-BLRM20 on 20/09/20.
//  Copyright © 2020 NINAYA-BLRM20. All rights reserved.
//

import UIKit

class SeachEngineTableViewCell: UITableViewCell {

    @IBOutlet weak var searchImageView: UIImageView!
    @IBOutlet weak var searchEngine: UILabel!
    @IBOutlet weak var checkboxImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
