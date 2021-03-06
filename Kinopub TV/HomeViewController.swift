//
//  NewViewController.swift
//  Kinopub TV
//
//  Created by Peter on 17/09/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, KinoListable, MenuRetractable, SegueHandlerType {
	
	enum SegueIdentifier: String {
		case TVShowsSegue
	}

	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var topConstraint: NSLayoutConstraint!
	
	var popularController: PopularTVShowsController? {
		didSet { if authState == .authorized { loadFeaturedShows() } }
	}
	
	var bannerSource = [Item]() {
		didSet { collectionView.fadeCells() }
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		collectionView.remembersLastFocusedIndexPath = true
//		if authState == .authorized {
//			loadFeaturedMovies()
//		}
    }
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		retractMenu(for: topConstraint, and: context)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		switch segueIdentifier(for: segue) {
		case .TVShowsSegue:
			if let controller = segue.destination as? PopularTVShowsController {
				popularController = controller
			}
			break
		}
	}
	
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func loadFeaturedShows() {
		if let controller = popularController {
			controller.loadPopularTVShows()
		}
	}
	
	func loadFeaturedMovies() {
		getFeaturedMovies { response in
			switch response {
			case .success(let items, _):
				guard let items = items else { return }
				self.bannerSource = items
				break
			case .error(let error):
				log.error("Error getting items: \(error)")
				break
			}
		}
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return bannerSource.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let item = bannerSource[indexPath.row]
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath as IndexPath) as? BannerCollectionViewCell {
			cell.prepareCell(item: item)
			return cell
		}
		return UICollectionViewCell()
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = bannerSource[indexPath.row]
		let controller = ItemViewController(nibName: "ItemViewController", bundle: nil)
		let subtype = item.subtype != "" ? ItemSubType(rawValue: item.subtype!) : nil
		controller.kinoItem = KinoItem(id: item.id, type: ItemType(rawValue: item.type!), subtype: subtype)
		self.present(controller, animated: true, completion: nil)
	}
}


