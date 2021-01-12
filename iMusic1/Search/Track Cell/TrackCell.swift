//
//  TrackCell.swift
//  iMusic1
//
//  Created by Тимур Мусаханов on 8/17/20.
//  Copyright © 2020 Тимур Мусаханов. All rights reserved.
//

import UIKit
import SDWebImage

class TrackCell: UITableViewCell {
    
    static let reuseId = "trackCell"
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var imageTrack: UIImageView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var collectionName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageTrack.contentMode = .scaleAspectFill
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTrack.image = nil
    }

    func set(viewModel: Track) {
        trackNameLabel.text = viewModel.trackName
        artistName.text = viewModel.artistName
        collectionName.text = viewModel.collectionName
        
        guard let stringImage = viewModel.artworkUrl100 else { return }
        guard let urlImage = URL(string: stringImage) else { return }
        imageTrack.sd_setImage(with: urlImage, completed: nil)
    }
}
