//
//  HTLocationPickerView.swift
//  Pods
//
//  Created by Ravi Jain on 05/07/17.
//
//

import UIKit
import MapKit

@objc public protocol  HTPlacePickerViewDelegate : class {
    func didSelectPlace(place : HyperTrackPlace, pickerView:HTPlacePickerView)
    func didCancelPlaceSelection(pickerView:HTPlacePickerView)
}

@objc public class HTPlacePickerView: UIView,MKMapViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var searchActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchResultTableView: UITableView!
    var searchResults : [HyperTrackPlace]? = []
    var selectedLocation : HyperTrackPlace?
    var isShowingSearchResults = false
    var isShowingSavedResults = true
    var pinnedImageView : UIImageView? = nil
    var destinationAnnotation : HTMapAnnotation? = nil
    var shouldStartTrackingRegion  = false
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var destinationView: UIView!
    @IBOutlet weak var confirmButton: UIButton!
    
    open var longitudinalDistance: Double!
    open var isMapViewCenterChanged = false
    
    open var startLocation : HyperTrackPlace?
    
    weak var pickerViewDelegate : HTPlacePickerViewDelegate?
    
    override public func awakeFromNib() {
        
        self.mapView.delegate = self
        self.mapView.showsPointsOfInterest = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.delegate = self
        self.searchResultTableView.dataSource = self
        self.searchResultTableView.delegate = self
        
      // self.confirmButton.shadow()
        
        setUpSearchResultTableView()
        setUpPinnedImageView()
        self.reloadSearchResults()
    }
    
    
    func setUpView(){
        self.mapView.isHidden = true
        var region : MKCoordinateRegion?
        
        if let degrees = startLocation?.location?.coordinates {
            let destination = CLLocationCoordinate2DMake((degrees.last)!, (degrees.first)!)
            region =    MKCoordinateRegionMake(
                (destination),
                MKCoordinateSpanMake(0.005, 0.005))
            self.searchText.text = HTGenericUtils.getPlaceName(place: self.startLocation)
        }
        else if let location = Transmitter.sharedInstance.locationManager.getLastKnownLocation(){
            region =    MKCoordinateRegionMake(
                (location.coordinate),
                MKCoordinateSpanMake(0.005, 0.005))
        }
        else{
            region =    MKCoordinateRegionMake(
                CLLocationCoordinate2DMake(28.5621352, 77.1604902),
                MKCoordinateSpanMake(0.05, 0.05))
        }
        self.mapView.setRegion(region!, animated: true)
    }
    
    func setUpPinnedImageView(){
        let image = UIImage.init(named: "square", in: Settings.getBundle(), compatibleWith: nil)
        self.pinnedImageView = UIImageView.init(image: image, highlightedImage: image)
        self.pinnedImageView?.frame = CGRect(x:0,y:0,width:29,height:29)
        self.pinnedImageView?.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    func setUpSearchResultTableView(){
        self.searchText.delegate = self
        self.destinationView.layer.cornerRadius = self.searchText.frame.width/10.0
        self.destinationView.layer.masksToBounds = true
        self.searchText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.searchResultTableView.delegate = self
        self.searchResultTableView.dataSource = self
        self.searchResultTableView.backgroundColor = UIColor.clear
        
        self.searchResultTableView.register(UINib(nibName: "SearchCellView", bundle: Settings.getBundle()), forCellReuseIdentifier: "SearchCell")
        self.searchResultTableView.isHidden = false
        
        self.searchText.becomeFirstResponder()
        self.mapView.bringSubview(toFront: self.confirmButton)
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if let searchText = textField.text{
            if(textField.text != ""){
                self.isShowingSearchResults = true
                self.reloadSearchTableView()
                self.searchActivityIndicator.startAnimating()
                getSearchResultsForText(searchText: searchText, completionHandler: { places, error in
                    self.searchActivityIndicator.stopAnimating()
                    if(self.isShowingSearchResults){
                        self.searchResultTableView.isHidden = false
                        self.isShowingSavedResults = false
                        
                        if(error == nil){
                            self.searchResults = places
                            self.reloadSearchTableView()
                        }else{
                            //log error
                            self.searchResults = []
                            self.reloadSearchTableView()
                        }
                    }else{
                        self.searchResults = []
                        self.reloadSearchTableView()
                    }
                })
            }else{
                self.isShowingSearchResults = false
                searchResults = []
                self.reloadSearchTableView()
            }
            
        }else{
            self.isShowingSearchResults = false
            searchResults = []
            self.reloadSearchTableView()
        }
    }
    
    func getSearchResultsForText(searchText : String,completionHandler: ((_ places: [HyperTrackPlace]?, _ error: HyperTrackError?) -> Void)?) {
        
        if let location = Transmitter.sharedInstance.locationManager.getLastKnownLocation() {
            var coordinate : CLLocationCoordinate2D? = nil
            coordinate = location.coordinate
            HypertrackService.sharedInstance.findPlaces(searchText: searchText, cordinate: coordinate, completionHandler: completionHandler)
            return
        }
        
    }
    
    func reloadSearchTableView(){
        self.searchResultTableView.reloadData()
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        self.removeFromSuperview()
        self.pickerViewDelegate?.didCancelPlaceSelection(pickerView: self)
    }
    
    @IBAction func onConfirmLocationButtonClick(_ sender: Any) {
        if self.selectedLocation != nil {
            self.pickerViewDelegate?.didSelectPlace(place: self.selectedLocation!, pickerView: self)
            self.confirmButton.isHidden = true
        }
    }
    
    public func setUp (){
        self.reloadSearchResults()
    }
    
    @IBAction func onBackPressed(sender: UIButton) {
        self.removeSearchView()
    }
    
    private func reloadSearchResults(){
        searchResultTableView.reloadData()
    }
    
    
    func removeSearchView(){
        self.removeFromSuperview()
        self.searchResults = []
        self.reloadSearchResults()
    }
    
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        //removeSearchView()
        self.searchResults = []
        self.reloadSearchResults()
    }
}



class HTSearchViewCell : UITableViewCell {
    
    @IBOutlet weak var mainLabel : UILabel?
    @IBOutlet weak var subtitleLabel : UILabel?
    @IBOutlet weak var iconView : UIImageView?
    @IBOutlet weak var centreLabel : UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: "SearchCell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}

extension HTPlacePickerView : UITableViewDelegate{
    
    func didSelectedLocation(place : HyperTrackPlace, selectOnMap:Bool){
        self.searchText.resignFirstResponder()
        self.searchResultTableView.isHidden = true
        self.mapView.isHidden = false
        isShowingSearchResults = false
        self.selectedLocation = place
        self.searchText.text = HTGenericUtils.getPlaceName(place: place)
        self.shouldStartTrackingRegion = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // in half a second...
            self.shouldStartTrackingRegion = true
        }
        
        if self.destinationAnnotation != nil {
            self.mapView.removeAnnotation(self.destinationAnnotation!)
        }
        
        let mapAnnotation = HTMapAnnotation()
        mapAnnotation.coordinate = CLLocationCoordinate2DMake((selectedLocation?.location?.coordinates.last)! , (selectedLocation?.location?.coordinates.first)!)
        mapAnnotation.title = HTGenericUtils.getPlaceName(place: place)
        mapAnnotation.type = MarkerType.DESTINATION_MARKER
        self.mapView.addAnnotation(mapAnnotation)
        self.destinationAnnotation = mapAnnotation
        
        let region = MKCoordinateRegionMake(mapAnnotation.coordinate,MKCoordinateSpanMake(0.01, 0.01))
        self.mapView.setRegion(region, animated: true)
        
    }
    
    func getSearchResultsForCoordinate(cordinate: CLLocationCoordinate2D?, completionHandler: ((HyperTrackPlace?, HyperTrackError?) -> Void)?) {
        let geoJsonLocation = HTGeoJSONLocation.init(type: "Point", coordinates: cordinate!)
        HypertrackService.sharedInstance.createPlace(geoJson:geoJsonLocation, completionHandler: completionHandler)
        return
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        self.confirmButton.isHidden = false
        tableView.deselectRow(at: indexPath, animated: true)
        if(indexPath.section == 0 && !isShowingSearchResults){
            self.mapView.isHidden = false
            self.searchResultTableView.isHidden = true
            self.searchText.resignFirstResponder()

            if (indexPath.row == 1){
                if (startLocation?.location?.coordinates) != nil {
                    self.didSelectedLocation(place: self.startLocation!,selectOnMap : true)
                }else if let location = Transmitter.sharedInstance.locationManager.getLastKnownLocation() {
                    getSearchResultsForCoordinate(cordinate: location.coordinate, completionHandler: { place, error in
                        if(error == nil && place != nil){
                            self.didSelectedLocation(place: place!,selectOnMap : true)
                        }else{
                            //log error
                        }
                    })
                }
            }else if (indexPath.row == 0){
                if let location = Transmitter.sharedInstance.locationManager.getLastKnownLocation() {
                    getSearchResultsForCoordinate(cordinate: location.coordinate, completionHandler: { place, error in
                        if(error == nil && place != nil){
                            self.didSelectedLocation(place: place!,selectOnMap : true)
                        }else{
                            //log error
                        }
                    })
                }
            }
            else if (indexPath.row == 1){
                
            }
            return
        }
        
        let location : HyperTrackPlace
        if(isShowingSavedResults){
            location = (getSavedPlaces()![indexPath.row])
        }else{
            location = (searchResults?[indexPath.row])!
        }
        
        didSelectedLocation(place: location,selectOnMap : false)
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{
        if(section == 1 ){
            return 20
        }
        return 10
    }
    
}

extension HTPlacePickerView : UITableViewDataSource{
    
    public func numberOfSections(in tableView: UITableView) -> Int{
        if(!self.isShowingSearchResults){
            return 2
        }
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if(section == 0 && !isShowingSearchResults){
            return 2
        }
        
        if(isShowingSavedResults){
            return (getSavedPlaces()!.count)
        }else{
            if searchResults != nil{
                return (searchResults?.count)!
            }
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! HTSearchViewCell
        
        let bundle = Bundle(for: HTLiveLocationView.self)
        cell.backgroundColor = UIColor.white
        cell.centreLabel?.text = ""
        cell.mainLabel?.text = ""
        cell.subtitleLabel?.text = ""
        
        if(indexPath.section == 0 && !isShowingSearchResults){
            if( indexPath.row == 0){
                cell.centreLabel?.text = "My location"
                cell.mainLabel?.text = ""
                cell.subtitleLabel?.text = ""
                cell.iconView?.image = UIImage.init(named: "myLocation", in: bundle, compatibleWith: nil)
            }else if (indexPath.row == 1){
                cell.centreLabel?.text = "Choose on map"
                cell.mainLabel?.text = ""
                cell.subtitleLabel?.text = ""
                cell.iconView?.image = UIImage.init(named: "chooseOnMap", in: bundle, compatibleWith: nil)
            }
            return cell
        }
        
        let location : HyperTrackPlace
        if(isShowingSavedResults){
            location = (getSavedPlaces()![indexPath.row])
            cell.iconView?.image = UIImage.init(named: "recentlyVisited", in: bundle, compatibleWith: nil)
            
        }else{
            location = (searchResults?[indexPath.row])!
            cell.iconView?.image = UIImage.init(named: "searchResult", in: bundle, compatibleWith: nil)
        }
        if(location.name == nil || location.name == ""){
            if(location.address != nil){
                location.name = location.address?.components(separatedBy: ",").first
            }
        }
        cell.mainLabel?.text = location.name
        cell.subtitleLabel?.text = location.address
        
        return cell
    }
    
    
    func getSavedPlaces() -> [HyperTrackPlace]?{
        return Settings.getAllSavedPlaces()
    }
    
    
}


extension HTPlacePickerView : UITextFieldDelegate{
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        return true
    }
}


extension HTPlacePickerView : MapCustomizationDelegate{
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        if(shouldStartTrackingRegion){
            self.pinnedImageView?.center = mapView.center
            self.pinnedImageView?.removeFromSuperview()
            mapView.addSubview(self.pinnedImageView!)
            if let annotation =  self.destinationAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    
    func confirmLocation(_ sender: Any){
        
    }
    
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if(shouldStartTrackingRegion){
            
            if let annotation = self.destinationAnnotation {
                
                DispatchQueue.main.async {
                    
                    annotation.coordinate = mapView.region.center
                    let view = mapView.view(for: annotation)
                    var markerView : HTMarkerWithTitle? = nil
                    
                    if let view = view {
                        markerView = view.subviews.first as? HTMarkerWithTitle
                        markerView?.titleLabel?.text = ""
                        markerView?.activityIndicator.startAnimating()
                    }
                    self.searchActivityIndicator.startAnimating()
                    
                    self.getSearchResultsForCoordinate(cordinate: annotation.coordinate, completionHandler: { place, error in
                        
                        self.searchActivityIndicator.isHidden = true
                        if(markerView != nil){
                            markerView?.activityIndicator.stopAnimating()
                        }
                        if(error == nil){
                            annotation.title = HTGenericUtils.getPlaceName(place: place)
                            annotation.place = place
                            if(markerView != nil){
                                markerView?.titleLabel?.text = HTGenericUtils.getPlaceName(place: place)
                            }
                            self.searchText.text = HTGenericUtils.getPlaceName(place: place)
                            self.selectedLocation = place
                        }
                        
                        self.pinnedImageView?.removeFromSuperview()
                        self.mapView.addAnnotation(annotation)
                        
                    })
                }
            }
        }
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if(annotation is HTMapAnnotation){
            return annotationView(mapView, annotation: (annotation as? HTMapAnnotation)!)
        }
        
        return nil
    }
    
    public func annotationView(_ mapView: MKMapView, annotation: HTMapAnnotation) -> MKAnnotationView?{
        if(annotation.type == MarkerType.DESTINATION_MARKER){
            return mapMarkerForDestination(annotation: annotation)
        }
        else{
            return mapMarkerForHero(annotation: annotation)
        }
    }
    
    func mapMarkerForDestination(annotation : HTMapAnnotation) -> MKAnnotationView {
        let bundle = Settings.getBundle()!
        let markerView: HTMarkerWithTitle = bundle.loadNibNamed("MarkerTitleView", owner: self, options: nil)?.first as! HTMarkerWithTitle
        if let title = annotation.title{
            markerView.setTitle(title: title)
        }
        return mapMarkerForView(markerView: markerView)
    }
    
    func mapMarkerForHero(annotation : HTMapAnnotation) -> MKAnnotationView {
        let bundle = Settings.getBundle()!
        let markerView: HTMarkerWithTitle = bundle.loadNibNamed("MarkerTitleView", owner: self, options: nil)?.first as! HTMarkerWithTitle
        markerView.radiate()
        if let title = annotation.title{
            markerView.setTitle(title: title)
        }else{
            if let action = annotation.action{
                if(HTGenericUtils.isCurrentUser(userId: action.user?.id)){
                    markerView.setTitle(title: "You")
                }else{
                    if let name = action.user?.name {
                        markerView.setTitle(title: name)
                    }else{
                        markerView.setTitle(title: "")
                        
                    }
                }
            }
        }
        markerView.markerImage.image =  UIImage.init(named: "triangle", in: bundle, compatibleWith: nil)
        
        
        if(annotation.image != nil){
            markerView.markerImage.image =  annotation.image
            
            
        }
        else{
            if let action = annotation.action{
                if(HTGenericUtils.isCurrentUser(userId: action.user?.id)){
                    markerView.markerImage.image =  UIImage.init(named: "purpleArrow", in: bundle, compatibleWith: nil)
                }
            }
        }
        
        if let user = annotation.action?.user {
            if(HTGenericUtils.isCurrentUser(userId: user.id) ) {
            }
        }
        
        let view =  mapMarkerForView(markerView: markerView)
        if(annotation.location != nil){
            let headingDirection =  annotation.location?.course
            if( Double((headingDirection)!) > 0){
                let rotation = CGFloat(headingDirection!/180 * Double.pi)
                markerView.markerImage.transform = CGAffineTransform(rotationAngle: rotation)
            }
        }
        return view
    }

    func mapMarkerForView(markerView: UIView) -> MKAnnotationView {
        let marker = MKAnnotationView()
        let adjustedOrigin = CGPoint(x: -markerView.frame.size.width / 2, y: -markerView.frame.size.height / 2)
        markerView.frame = CGRect(origin: adjustedOrigin, size: markerView.frame.size)
        
        marker.addSubview(markerView)
        marker.bringSubview(toFront: markerView)
        return marker
    }
}



