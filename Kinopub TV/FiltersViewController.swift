//
//  FiltersViewController.swift
//  Kinopub TV
//
//  Created by Peter on 23/03/16.
//  Copyright © 2016 Peter Tikhomirov. All rights reserved.
//

import UIKit

protocol FilterViewDelegate {
	func didSelectSortOption(sortOption: SortOption)
}

protocol FiltersViewControllerDelegate: class {
    func filtersDidSelectFilter(filter: Filter)
    func filtersDidDisappear()
}

class FiltersViewController: UIViewController, FilterViewDelegate, KinoSortable {
	
	@IBOutlet var singleYearButton: CheckButton!
	@IBOutlet var toYearUpButton: LightButton!
	@IBOutlet var toYearDownButton: LightButton!
	@IBOutlet var fromYearUpButton: LightButton!
	@IBOutlet var fromYearDownButton: LightButton!
	@IBOutlet var fromYear: UILabel!
	@IBOutlet var toYear: UILabel!
	@IBOutlet var sortTable: UITableView!
	@IBOutlet var genreTable: UITableView!
	@IBOutlet var applyButton: LightButton!
	
    weak var delegate: FiltersViewControllerDelegate?
    
	var sortTableSource = SortTableDataSource()
	var genres = [Genre]()
	var genreSelectedIndexSelected = IndexPath()
	var currentView = ItemType()
	let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
	
	var checkmark = UIImage(named: "icon-checkbox")
	var underView: UIImage?
	let calendarComponents = NSCalendar.current.dateComponents([.day, .month, .year], from: Date())
	
	var selectedGenre: Genre? = nil
	var selectedYearRange: String? = nil
    var selectedSortOption: SortOption?
	
	// MARK: - Delegate methods 
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		visualEffectView.removeFromSuperview()

	}
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.filtersDidDisappear()
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
		view.isOpaque = false
		genreTable.remembersLastFocusedIndexPath = true
		sortTableSource.parent = self
		sortTable.dataSource = sortTableSource
		sortTable.delegate = sortTableSource
		fetchGenres()
    }
	
	// MARK: - Methods
	
	func didSelectSortOption(sortOption: SortOption) {
		selectedSortOption = sortOption
	}
	
	func didSelectYearRange() {
		var yearString = ""
		if singleYearButton.toggled {
			yearString = "\(toYear.text!)-\(toYear.text!)"
		} else {
			yearString = "\(fromYear.text!)-\(toYear.text!)"
		}
		selectedYearRange = yearString
	}
	
    func configure(with filter: Filter) {
        toYear.text = String(filter.toYear!)
        fromYear.text = String(filter.fromYear!)
		if let sortBy = filter.sortBy {
			let index = SortOption.all.index(of: sortBy)
			let selectedRow = IndexPath(row: index ?? 0, section: 0)
			sortTable.selectRow(at: selectedRow, animated: false, scrollPosition: .none)
		}
    }
    
	func fetchGenres() {
		let genreType = currentView.genre()
		getGenres(for: genreType) { genres in
			var all = Genre()
			all.title = "Все жанры"
			self.genres.append(all)
			self.genres.append(contentsOf: genres)
			self.genreTable.reloadData()
		}
	}
	
	// MARK: - Actions

	@IBAction func toggleYear(_ sender: CheckButton) {
		if sender.toggled {
			sender.setBackgroundImage(nil, for: .normal)
			sender.setBackgroundImage(nil, for: .focused)
			sender.setBackgroundImage(nil, for: .highlighted)
		} else {
			sender.setBackgroundImage(checkmark, for: .normal)
			sender.setBackgroundImage(checkmark, for: .focused)
			sender.setBackgroundImage(checkmark, for: .highlighted)
		}
		sender.toggled = !sender.toggled
		didSelectYearRange()
	}
	
	@IBAction func closeFilters(_ sender: UIButton) {
        var filter = Filter()
        if singleYearButton.toggled {
            filter.fromYear = Int(toYear.text!)
            filter.toYear = Int(toYear.text!)
        } else {
            filter.fromYear = Int(fromYear.text!)
            filter.toYear = Int(toYear.text!)
        }
        filter.genre = selectedGenre
        filter.sortBy = selectedSortOption
        
        delegate?.filtersDidSelectFilter(filter: filter)
		self.dismiss(animated: true, completion: nil)
	}
	

	@IBAction func increaseFrom(_ sender: LightButton) {
		var intValue = Int(fromYear.text!)!
		if intValue >= 1912 && intValue < calendarComponents.year! {
			intValue = intValue+1
			fromYear.text = String(intValue)
			didSelectYearRange()
		}
	}
	
	@IBAction func decreaseFrom(_ sender: LightButton) {
		var intValue = Int(fromYear.text!)!
		if intValue > 1912 && intValue <= calendarComponents.year! {
			intValue = intValue-1
			fromYear.text = String(intValue)
			didSelectYearRange()
		}
	}
	
	@IBAction func increaseTo(_ sender: LightButton) {
		var intValue = Int(toYear.text!)!
		if intValue >= 1912 && intValue < calendarComponents.year! {
			intValue = intValue+1
			toYear.text = String(intValue)
			didSelectYearRange()
		}
	}
	
	@IBAction func decreaseTo(_ sender: LightButton) {
		var intValue = Int(toYear.text!)!
		if intValue > 1912 && intValue <= calendarComponents.year! {
			intValue = intValue-1
			toYear.text = String(intValue)
			didSelectYearRange()
		}
	}

}


extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return genres.count
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "genreCell") as! FilterTableViewCell
		let genre = genres[indexPath.row]
		cell.genre = genre
		if genreSelectedIndexSelected == indexPath {
			cell.status = .checked
		} else {
			cell.status = .unchecked
		}
		cell.filter.text = genre.title
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		genreSelectedIndexSelected = indexPath
		let cell = tableView.cellForRow(at: indexPath) as! FilterTableViewCell
		//cell.toggleCheckMark() // This causes a bug. We would rather select one single genre at a time.
		if let genre = cell.genre {
			selectedGenre = genre
		}
		tableView.deselectRow(at: indexPath, animated: true)
		tableView.reloadData()
		// TODO: gather all the checked indexPaths together so we can save them
	}

}

class SortTableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
	
	var parent: FiltersViewController?
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return SortOption.all.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "sortCell") as! SortingTableViewCell
		let sortOption = SortOption.all[indexPath.row]
		cell.name.text = sortOption.name()
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedRow = SortOption.all[indexPath.row]
		parent?.didSelectSortOption(sortOption: selectedRow)
	}
}







