//
//  CountryListViewController.swift
//  OmiseSDK
//
//  Created by Andrei Solovev on 8/6/23.
//  Copyright © 2023 Omise. All rights reserved.
//

import UIKit

class CountryListViewController: UIViewController {
    typealias ViewModel = CountryListViewModelProtocol

    private struct Style {
        let countryCellIdentifier = "CountryCell"
    }

    private var style = Style()
    var viewModel: ViewModel? {
        didSet {
            if let newViewModel = viewModel {
                bind(to: newViewModel)
            }
        }
    }

    var preferredPrimaryColor: UIColor? {
        didSet {
            applyPrimaryColor()
        }
    }

    var preferredSecondaryColor: UIColor? {
        didSet {
            applySecondaryColor()
        }
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: style.countryCellIdentifier)
        return tableView
    }()

    init(viewModel: ViewModel? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        if let viewModel = viewModel {
            bind(to: viewModel)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
        DispatchQueue.main.async {
            self.scrollToSelectedRow(animated: false)
        }
    }
}

extension CountryListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.countries.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: style.countryCellIdentifier, for: indexPath)
        let country = viewModel?.countries.at(indexPath.row)

        cell.textLabel?.text = country?.name ?? ""
        cell.textLabel?.textColor = UIStyle.Color.primary.uiColor
        cell.accessoryType = (viewModel?.selectedCountry == country) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = viewModel?.countries.at(indexPath.row)
        viewModel?.selectedCountry = country
    }
}

// MARK: Setups
private extension CountryListViewController {
    func setupViews() {
        if #available(iOS 11, *) {
            navigationItem.largeTitleDisplayMode = .never
        }

        view.backgroundColor = .background
        view.addSubviewAndFit(tableView)
        tableView.reloadData()
    }

    func bind(to viewModel: ViewModel) {
        guard isViewLoaded else { return }
        tableView.reloadData()
    }

    func applyPrimaryColor() {
        guard isViewLoaded else {
            return
        }
        tableView.reloadData()
    }

    func applySecondaryColor() {
        guard isViewLoaded else {
            return
        }
        tableView.reloadData()
    }

    func scrollToSelectedRow(animated: Bool) {
        if let viewModel = viewModel,
           let selectedCountry = viewModel.selectedCountry,
           let index = viewModel.countries.firstIndex(of: selectedCountry) {
            let indexPath = IndexPath(row: index, section: 0)
            tableView.scrollToRow(at: indexPath, at: .middle, animated: animated)
        }
    }

}

#if SWIFTUI_ENABLED
import SwiftUI

// MARK: Preview
struct CountryListViewController_Previews: PreviewProvider {
    static var previews: some View {
        UIKitViewControllerPresentable(
            viewController:
                CountryListViewController(
                    viewModel: CountryListViewModelMockup()
                )
        )
    }
}
#endif
