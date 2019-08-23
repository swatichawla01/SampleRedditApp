//
//  RedditPostDetails.swift
//  RedditDemo
//
//  Created by Swati Chawla on 8/22/19.
//  Copyright © 2019 ABC. All rights reserved.
//

import Foundation
import UIKit

class RedditPostDetails {
    
    var authorName : String
    var title : String
    var thumbnail : UIImage
    
    init(authorName:String,title:String,thumbnail:UIImage)
    {
        self.authorName = authorName
        self.title = title
        self.thumbnail = thumbnail
    }
}
