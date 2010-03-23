class MapController < ApplicationController

  after_filter :store_location, :only => [:index]

  def index
    
    @lon = params[:lon] || APP_CONFIG['map']['lon']
    @lat = params[:lat] || APP_CONFIG['map']['lat']
    @zoom = params[:zoom] || APP_CONFIG['map']['zoom'] 

    @map = MapLayers::Map.new("map", 
      :projection => OpenLayers::Projection.new("EPSG:900913"), 
      :displayProjection => OpenLayers::Projection.new("EPSG:4326"),
      :units => 'km', 
      :controls => []
      ) do |map, page|
      
      page << map.add_control(Control::Navigation.new())
      page << map.add_control(Control::PanZoomBar.new())
      page << map.add_control(Control::LayerSwitcher.new)
      page << map.add_control(Control::Attribution.new())
      page << map.add_control(Control::Permalink.new('permalink'))
      page << map.add_control(Control::MousePosition.new())

      page << map.add_control(Control::OverviewMap.new({ :layers => [ MapLayers::OSM_MAPNIK ]}))
      
      page << map.add_layer(MapLayers::OSM_MAPNIK) 
      
      page << map.add_layer(Layer::GeoRSS.new("Nodes", "/nodes/georss", { :projection => OpenLayers::Projection.new("EPSG:4326") }))
      #page << map.add_layer(Layer::GML.new("Nodes KML", "/nodes/kml", { :format => JsExpr.new("OpenLayers.Format.KML"), :projection => OpenLayers::Projection.new("EPSG:4326"), :visibility => false }))
      #page << map.add_layer(Layer::WFS.new("Nodes WFS", "/nodes/wfs", { :typename => "nodes" }, { :featureClass => JsExpr.new("OpenLayers.Feature.WFS"), :projection => OpenLayers::Projection.new("EPSG:4326"), :visibility => false }))
      
      page << map.add_layer(Layer::GML.new("Live (OLSR)", 
        RAILS_ENV == 'production' ? '/cgi-bin/cgi-bin-map.kml' : '/mirror/cgi-bin-map.kml', 
        { :format => JsExpr.new("OpenLayers.Format.KML"), :projection => OpenLayers::Projection.new("EPSG:4326"), :visibility => false }))

      if RAILS_ENV == 'development'
        page << map.add_layer(Layer::GML.new("Global (layereight.de)", '/mirror/freifunkmap.xml', { :format => JsExpr.new("OpenLayers.Format.KML"), :projection => OpenLayers::Projection.new("EPSG:4326"), :visibility => false }))
      end
    
      page << map.set_center(OpenLayers::LonLat.new(@lon, @lat).transform(OpenLayers::Projection.new("EPSG:4326"), map.javascriptify_method_call("getProjectionObject")), @zoom)
      
    end
    
  end

  def geocode

    street = params[:street].blank? ? nil : params[:street]
    zip = params[:zip].blank? ? nil : params[:zip]
    city = params[:city].blank? ? APP_CONFIG['geokit']['city'] : params[:city]
    
    address = [ street, [ zip, city ].compact.join(" ") ].compact.join(", ")

    respond_to do |format|
      format.js {
        render :update do |page|

          logger.debug "Map::geocode Looking up geo location for '#{address}'"
          @location = Geokit::Geocoders::MultiGeocoder.geocode(address, :bias => 'de', :lang => 'de')
  
          page.assign "$('node_geocoder').disabled", false
          page.toggle 'node_geocoder_spinner'

          if !@location.success
            page.alert 'Couldn\'t find geo location for this address'
          else
            if @location.all.size > 1
              page.alert 'Couldn\'t find unambiguous geo location for this address'
            else
              page.assign "$('node_lat').value", @location.lat
              page.assign "$('node_lng').value", @location.lng
            end
          end
          
        end
      }
    end

  end
  
end
