//
//  Extensions.swift
//  Boost ctRL
//
//  Created by Zac Johnson on 3/11/19.
//  Copyright © 2019 Zac Johnson. All rights reserved.
//

import UIKit

extension UIColor {
	
	// MARK: - Initialization
	convenience init?(hex: String) {var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
		
		var rgb: UInt32 = 0
		
		var r: CGFloat = 0.0
		var g: CGFloat = 0.0
		var b: CGFloat = 0.0
		let a: CGFloat = 1.0
		
		guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }
		
		r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
		g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
		b = CGFloat(rgb & 0x0000FF) / 255.0
		
		self.init(red: r, green: g, blue: b, alpha: a)
	}
}

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
	func loadImageFromCacheWithUrlString(urlString: String) {
		
		self.image = UIImage(named: "logo-null")
		
		// Check cache for cached image first
		if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
			self.image = cachedImage
			return
		}
		
		// Otherwise, download image
		let url = URL(string: urlString)
		print(url!)
		URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
			if error != nil {
				print(error!)
				self.image = UIImage(named: "logo-null")
				return
			}
			
			DispatchQueue.main.async {
				if let downloadedImage = UIImage(data: data!) {
					imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
					
					self.image = downloadedImage
				}
			}
			
		}).resume()
	}
}

extension AppDelegate {
	func downloadDataFromFirebase() {
		let downloader = Downloader()
		if downloader.loadTeamsAndStandings() {
			print("Initial Team Download Complete: ✅")
		} else {
			print("Returned False ‼️")
		}
		
		if downloader.loadMatches() {
			print("Initial Matches Download ✅")
		} else {
			print("Initial Matches Download 🔴")
		}
	}
}