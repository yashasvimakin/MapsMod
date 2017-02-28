//
//  ViewController.swift
//  MapsMod
//
//  Created by Yashasvi Makin on 24/02/17.
//  Copyright © 2017 Yashasvi Makin. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps

class ViewController: UIViewController,UIGestureRecognizerDelegate {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var lastVelocity:CGFloat! = 0.0
    var lastTranslation:CGPoint!
    var controller : UIViewController! = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        self.showModal()
    }
    
    func showModal() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.controller = storyboard.instantiateViewController(withIdentifier: "listView")
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.view.frame = CGRect(x: self.view.frame.size.width - controller.view.frame.width, y: self.view.frame.size.height - 100, width: controller.view.frame.width, height: controller.view.frame.height)
        controller.didMove(toParentViewController: self)
        self.createPanGestureRecognizer(targetView: controller.view.viewWithTag(1)!)
    }
    
    func createPanGestureRecognizer( targetView: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(panGesture:)))
        targetView.addGestureRecognizer(panGesture)
        let tableView = controller.view.viewWithTag(2)! as! UITableView
        tableView.isScrollEnabled = false
        panGesture.delegate = self
    }
    func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        let velocity:CGPoint = panGesture.velocity(in: panGesture.view)
        let translation = panGesture.translation(in: self.view)
        var initialY:CGFloat = panGesture.view!.frame.origin.y
        switch panGesture.state {
        case UIGestureRecognizerState.began:
            initialY = panGesture.view!.frame.origin.y
            break
        case UIGestureRecognizerState.changed:
            if panGesture.view!.frame.origin.y + translation.y >  self.view.frame.size.height - 100 {
                panGesture.view!.frame.origin = CGPoint(x: panGesture.view!.frame.origin.x, y: self.view.frame.size.height - 100 )
                let tableView = controller.view.viewWithTag(2)! as! UITableView
                tableView.isScrollEnabled = false
            }
            else
                if panGesture.view!.frame.origin.y + translation.y < 50 {
                    panGesture.view!.frame.origin = CGPoint(x: panGesture.view!.frame.origin.x, y: 50 )
                    let tableView = controller.view.viewWithTag(2)! as! UITableView
                    tableView.isScrollEnabled = true
                }
                else
                {
                    panGesture.view!.center = CGPoint(x: panGesture.view!.center.x, y: panGesture.view!.center.y + translation.y)
                    let tableView = controller.view.viewWithTag(2)! as! UITableView
                    tableView.isScrollEnabled = false
            }
            self.lastVelocity = velocity.y
            lastTranslation = translation
            
            panGesture.setTranslation(CGPoint.zero, in: panGesture.view!)
        case UIGestureRecognizerState.cancelled: break
        case UIGestureRecognizerState.ended:
            
            let springVelocity:CGFloat = fabs(panGesture.view!.frame.origin.y + (self.lastVelocity / 5.0));
            UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
                if springVelocity < (self.view.frame.size.height * 1/2) {
                    panGesture.view!.frame.origin = CGPoint(x: panGesture.view!.frame.origin.x, y: 50 )
                }
                else
                    if springVelocity > (self.view.frame.size.height * 1/2) && springVelocity < self.view.frame.size.height - 100 {
                        panGesture.view!.frame.origin = CGPoint(x: panGesture.view!.frame.origin.x, y: self.view.frame.size.height - 300 )
                    }
                    else {
                        panGesture.view!.frame.origin = CGPoint(x: panGesture.view!.frame.origin.x, y: self.view.frame.size.height - 100 )
                }
                panGesture.setTranslation(CGPoint.zero, in: self.view)
            }, completion: nil)
        default: break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        currentLocation = location
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
            //self.showModal()
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

