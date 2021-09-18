//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    private lazy var weatherManager: WeatherManager = {
        var manager = WeatherManager()
        manager.delegate = self
        return manager
    }()
    
    private lazy var coreLocation: CLLocationManager = {
       var coreLocation = CLLocationManager()
        coreLocation.delegate = self
        return coreLocation
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        coreLocation.requestWhenInUseAuthorization()
        coreLocation.requestLocation()
    }
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        print("locationPressed")
        coreLocation.requestLocation()
    }
}

extension WeatherViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if (textField.text == "") {
            textField.placeholder = "Search"
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let cityName = textField.text {
            weatherManager.searchBy(cityName: cityName)
        }
        
        textField.text = ""
    }
}

extension WeatherViewController: WeatherManagerDelegate {
    
    private func populate(model: WeatherModel) {
        DispatchQueue.main.async {
            self.cityLabel.text = model.cityName
            self.temperatureLabel.text = String(format: "%.0f", arguments: [model.temperature])
            self.conditionImageView.image = UIImage(systemName: model.conditionName)
        }
    }
    
    func success(model: WeatherModel) {
        populate(model: model)
    }
    
    func error(message: String) {
        print(message)
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            let coord = location.coordinate
            weatherManager.searchBy(lat: coord.latitude, long: coord.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.denied {
            coreLocation.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
