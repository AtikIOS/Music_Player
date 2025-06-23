//
//  MusicListCell.swift
//  Music_Player
//
//  Created by Atik Hasan on 10/14/24.
//

import UIKit

class MusicListCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblMusicTittle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
