//
//  ViewController.swift
//  ARObject
//
//  Created by Bogdan Petkanych on 27.07.2024.
//

import UIKit

class ViewController: UIViewController {
  
  var objectView: ObjectView = {
    let view = ObjectView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    return view
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(objectView)
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: objectView.leadingAnchor),
      view.topAnchor.constraint(equalTo: objectView.topAnchor),
      view.trailingAnchor.constraint(equalTo: objectView.trailingAnchor),
      view.bottomAnchor.constraint(equalTo: objectView.bottomAnchor),
    ])
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    runObjectView()
  }
  
  func runObjectView() {
    objectView.loadObject(by: Bundle.main.url(forResource: "toy", withExtension: "usdz")!) { [weak self] result in
      switch result {
      case .success:
        self?.objectView.runSession()
      case .failure(let failure):
        self?.showAlert(title: "Error", message: failure.localizedDescription)
      }
    }
    objectView.runSession()
  }
  
  func showAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    present(alert, animated: true)
  }
}

