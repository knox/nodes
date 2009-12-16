if defined? Geokit

  Geokit::default_units = :kms
  
  Geokit::Geocoders::google = 'ABQIAAAAJASmpFszQOsjK5L8rvGYDxTtQ2tT4vl28MJs0fc7NfWJJsJDXRQk27EQpwP5K-3Npf2DGdwiqCofsQ'
  Geokit::Geocoders::yahoo = 'PqF3LP3V34FA.K1dnwXxjM2AwIdOMqHiq_ezi7FVKNYCweyDQoUgP9eiJwlpXeXCjvDdsFRCsxYt'
  
  Geokit::Geocoders::provider_order = [ :google, :yahoo ]
  
end