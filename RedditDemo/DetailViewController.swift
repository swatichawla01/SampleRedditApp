//
//  DetailViewController.swift
//  RedditDemo
//
//  Created by Swati Chawla on 8/22/19.
//  Copyright © 2019 ABC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UITextView!
    @IBOutlet weak var postImageView: UIImageView!


    func configureView() {
        // Update the user interface for the detail item.
        if let detailItem = detailItem {
            if let detailDescriptionLabel = detailDescriptionLabel, let _ = postImageView {
                self.navigationItem.title = detailItem.authorName
                detailDescriptionLabel.text = detailItem.title
                postImageView.image = detailItem.thumbnail
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: RedditPostDetails? {
        didSet {
            configureView()
        }
    }
}

