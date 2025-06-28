import Foundation
import CoreLocation

class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    private init() {}
    
    // MARK: - Weather Data Models
    struct WeatherData: Codable {
        let temperature: Double
        let condition: String
        let humidity: Int
        let windSpeed: Double
        let description: String
    }
    
    struct WeatherResponse: Codable {
        let main: Main
        let weather: [Weather]
        let wind: Wind
        
        struct Main: Codable {
            let temp: Double
            let humidity: Int
        }
        
        struct Weather: Codable {
            let main: String
            let description: String
        }
        
        struct Wind: Codable {
            let speed: Double
        }
    }
    
    // MARK: - Weather Fetching
    func fetchWeather(for location: CLLocationCoordinate2D) async throws -> WeatherData {
        // Note: In a real app, you would use a weather API like OpenWeatherMap
        // For this example, we'll simulate weather data
        
        let simulatedWeather = WeatherData(
            temperature: Double.random(in: 15...25),
            condition: ["Sunny", "Cloudy", "Rainy", "Windy"].randomElement() ?? "Sunny",
            humidity: Int.random(in: 40...80),
            windSpeed: Double.random(in: 5...20),
            description: "Perfect weather for football"
        )
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        return simulatedWeather
    }
    
    func fetchWeatherForStadium() async throws -> WeatherData {
        // Default stadium location (you can customize this)
        let stadiumLocation = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        return try await fetchWeather(for: stadiumLocation)
    }
    
    // MARK: - Weather Condition Mapping
    func mapToWeatherCondition(_ weatherString: String) -> WeatherCondition {
        switch weatherString.lowercased() {
        case "sunny", "clear":
            return .sunny
        case "cloudy", "overcast":
            return .cloudy
        case "rainy", "rain":
            return .rainy
        case "snowy", "snow":
            return .snowy
        case "windy":
            return .windy
        default:
            return .sunny
        }
    }
    
    // MARK: - Weather Recommendations
    func getTrainingRecommendation(for weather: WeatherData) -> String {
        switch weather.condition.lowercased() {
        case "sunny":
            if weather.temperature > 30 {
                return "Hot weather - ensure players stay hydrated and take frequent breaks"
            } else {
                return "Perfect weather for outdoor training"
            }
        case "rainy":
            return "Consider indoor training or postpone session"
        case "windy":
            if weather.windSpeed > 15 {
                return "Strong winds - avoid aerial training drills"
            } else {
                return "Light winds - good for training"
            }
        case "cloudy":
            return "Good conditions for intensive training"
        default:
            return "Check current conditions before training"
        }
    }
    
    func getMatchDayRecommendation(for weather: WeatherData) -> String {
        switch weather.condition.lowercased() {
        case "sunny":
            return "Great weather for football - expect fast-paced game"
        case "rainy":
            return "Wet conditions - focus on ball control and careful passing"
        case "windy":
            return "Windy conditions - adjust long passes and set pieces"
        case "cloudy":
            return "Overcast conditions - good visibility for players"
        default:
            return "Monitor weather conditions closely"
        }
    }
}

// MARK: - Location Manager for Weather
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}