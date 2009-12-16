if defined? Geokit

  Geokit::default_units = APP_CONFIG['geokit']['default_units'].to_sym
  
  Geokit::Geocoders::google = APP_CONFIG['geokit']['google_key']
  Geokit::Geocoders::yahoo = APP_CONFIG['geokit']['yahoo_key']
  
  Geokit::Geocoders::provider_order = [ :google, :yahoo ]
  
end