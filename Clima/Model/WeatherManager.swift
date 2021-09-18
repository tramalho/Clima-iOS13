//
//  WeatherManager.swift
//  Clima
//
//  Created by Thiago Antonio Ramalho on 17/09/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func success(model: WeatherModel)
    func error(message: String)
}

public struct WeatherManager {
    
    var delegate: WeatherManagerDelegate? = nil
    
    func searchBy(cityName: String) {
        execute(queryItems: [URLQueryItem(name: "q", value: cityName)])
    }
    
    func searchBy(lat: Double, long: Double) {
        execute(queryItems: [URLQueryItem(name: "lat", value: lat.description), URLQueryItem(name: "lon", value: long.description)])
    }
    
    private func execute(queryItems: [URLQueryItem]) {
        
        if let url = createURL(queryItems: queryItems) {
            print(url)
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, _, error in
                
                if data != nil, let safeData = data {
                    
                    if let model = parse(data: safeData) {
                        delegate?.success(model: model)
                    } else {
                        delegate?.error(message: "parse error")
                    }
                } else if error != nil {
                    delegate?.error(message: error?.localizedDescription ?? "response error")
                } else {
                    delegate?.error(message: "unknow Error")
                }
            }
            
            task.resume()
        }
    }
    
    private func createURL(queryItems: [URLQueryItem]) -> URL? {
        
        var finalQueries = [URLQueryItem(name: "appid", value: "<key from API>"), URLQueryItem(name: "units", value: "metric")]
        finalQueries.append(contentsOf: queryItems)
        
        var urlComponent = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        urlComponent?.queryItems = finalQueries
        
        return urlComponent?.url
    }
    
    private func parse(data: Data) ->  WeatherModel? {
        
        var model: WeatherModel? = nil
        
        let decoder = JSONDecoder()
        
        do {
            print(data)
            let r = try decoder.decode(WeatherData.self, from: data)
            model = WeatherModel(conditionID: r.weather[0].id, cityName: r.name, temperature: r.main.temp)
        } catch  {
            print("Error: \(error)")
        }
        
        return model
    }
}
