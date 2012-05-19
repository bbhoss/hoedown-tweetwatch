$( function() {
    var geojsonLayer = new L.GeoJSON();
    geojsonLayer.on("featureparse", function (e) {
        if (e.properties && e.properties.name){
            e.layer.bindPopup(e.properties.name);
        }
    });
    map.addLayer(geojsonLayer);
    client = Stomp.client( "ws://localhost:8675/" )

    client.connect( null, null, function() {
        $(window).unload(function() { client.disconnect() });
        
        client.subscribe( '/stomplet/messages', function(message) {
            var msg = $.parseJSON( message.body )
            geojsonLayer.addGeoJSON(msg.geojson);
        } )
    } )

} )
