//
//  WeatherManager.swift
//  Clima
//
//  Created by Joqtan on 19/12/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(_ weatherManager: WeatherManager, error: Error)
}

struct WeatherManager {
    
    var delegate: WeatherManagerDelegate?

    let weatherURL =
        "https://api.openweathermap.org/data/2.5/weather?&units=metric&appid=7dbedf27a67dfc9e19dbc397dfb1e77d"

    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: Double, longitude: Double) {
        let urlString = "\(weatherURL)&lat=\(String(latitude))&lon=\(String(longitude))"
        
        performRequest(with: urlString)
    }

    func performRequest(with urlString: String) {

        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)

            let task = session.dataTask(with: url) { (data, response, error) in
                if let responseError = error {
                    delegate?.didFailWithError(self, error: responseError)
                    return
                }

                if let responseData = data {
                    if let weather = parseJSON(responseData){
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }

            task.resume()
        }

    }

    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)

            return weather

        } catch {
            delegate?.didFailWithError(self, error: error)
            return nil
        }

    }

    

}
