//
//  NewsFeedCell.swift
//  LatvianNewsFeed
//
//  Created by Elīna Zekunde on 13/02/2021.
//

import UIKit

class NewsFeedCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    func setUI(with: Item) {
        titleLabel.text = with.title
       
        guard let url = URL(string: with.urlToImage) else { return }
        
        UIImage.loadFrom(url: url) { image in
            self.newsImage.image = image
        }
    }
}

extension UIImage {
    public static func loadFrom(url: URL, completion: @escaping (_ image: UIImage?) -> ()) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    completion(UIImage(data: data))
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
