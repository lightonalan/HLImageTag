//
//  TaggableUser.swift
//  HLImageTag
//
//  Created by Nguyen Xuan Hieu on 6/12/18.
//  Copyright © 2018 Nguyen Xuan Hieu. All rights reserved.
//

import UIKit

class TaggableUser: Decodable {
    /// The user identifier.
    var id: String!
    
    /// The user's address.
    var address: String!
    
    /// The URL of the user's profile picture.
    var profilePicture: URL!
    
    /// The user's full name.
    var fullName: String!
}
