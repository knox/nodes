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
      #page << map.add_layer(Layer::Text.new("BassSlave", { :location => "/nodes.txt", :projection => OpenLayers::Projection.new("EPSG:4326"), :visibility => false }))
      page << map.add_layer(Layer::GML.new("Live (OLSR)", "/live.kml", { :format => JsExpr.new("OpenLayers.Format.KML"), :projection => OpenLayers::Projection.new("EPSG:4326"), :visibility => false }))
      page << map.add_layer(Layer::GML.new("Global (layereight.de)", "/freifunkmap.xml", { :format => JsExpr.new("OpenLayers.Format.KML"), :projection => OpenLayers::Projection.new("EPSG:4326"), :visibility => false }))
      
      page << map.set_center(OpenLayers::LonLat.new(@lon, @lat).transform(OpenLayers::Projection.new("EPSG:4326"), map.javascriptify_method_call("getProjectionObject")), @zoom)
      
    end
    
  end
  
end
