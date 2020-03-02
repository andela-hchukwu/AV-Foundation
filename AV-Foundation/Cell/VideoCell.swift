//
//  VideoCell.swift
//  AV-Foundation
//
//  Created by Henry Chukwu on 3/2/20.
//  Copyright © 2020 Henry Chukwu. All rights reserved.
//

import UIKit

class VideoCell: UITableViewCell {

    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

}
