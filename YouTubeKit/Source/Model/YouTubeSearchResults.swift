//
//  YouTubeSearchResultsContainer.swift
//  YouTubeKit
//
//  Created by Simon Støvring on 08/11/2017.
//  Copyright © 2017 SimonBS. All rights reserved.
//

import Foundation

public class YouTubeSearchResultsContainer: Codable {
    public let items: [YouTubeSearchResultItem]
}

public class YouTubeSearchResultItem: Codable {
    public let id: YouTubeSearchResultId
    public let snippet: YouTubeSearchResultSnippet
}

public class YouTubeSearchResultId: Codable {
    public let videoId: String
}

public class YouTubeSearchResultSnippet: Codable {
    public let title: String
}
