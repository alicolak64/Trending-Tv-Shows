//
//  TvImage.swift
//  Trending Tv Shows
//
//  Created by Alex Paul on 1/9/21.
//

import UIKit
import Kingfisher

class TvImage: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        set()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func set() {
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        contentMode = .scaleAspectFill
        backgroundColor = .systemBackground
    }
    
    func downloadTVImage(_ url: String) {
        guard let imageUrl = URL(string: url), !url.isEmpty else {
            print("Non Valid Url")
            return
        }
        
        self.kf.setImage(
            with: imageUrl,
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        )
    }

}
