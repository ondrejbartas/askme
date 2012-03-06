function render_geo_name(el) {
	var lat = parseFloat($(el).find('.lat').text());
	var lon = parseFloat($(el).find('.lon').text());
	console.log("getting for: "+lon+" , "+lat);
	var latlng = new google.maps.LatLng(lat, lon);
	geocoder = new google.maps.Geocoder();
	geocoder.geocode({'latLng': latlng}, function(results, status) {
		if (status == google.maps.GeocoderStatus.OK) {
			if (results[1]) {
				//find country name
				for (var i=0; i<results[0].address_components.length; i++) {
					for (var b=0;b<results[0].address_components[i].types.length;b++) {
						//there are different types that might hold a city admin_area_lvl_1 usually does in come cases looking for sublocality type will be more appropriate
						if (results[0].address_components[i].types[b] == "administrative_area_level_1") {
							//this is the object you are looking for
							city=results[0].address_components[i];
						}
						if (results[0].address_components[i].types[b] == "country") {
							country=results[0].address_components[i]
							break;
						}
					}
				}
				//city data
				$(el).append($('<span class="city">'+city.long_name+" ("+country.long_name+")</span>"));
				$(el).find(".lon").hide();
				$(el).find(".lat").hide();
			} else {
			}
		} else {
		}	
	});
	$(el).removeClass("geo");
}
	
function render_geo_names_one() {
	render_geo_name($('.geo:first'));
}
function render_geo_names() {
	count = 1;
	$('.geo').each(function(){
		window.setTimeout(function() { render_geo_names_one(); }, count*200);
		count = count + 1;
	})
}
