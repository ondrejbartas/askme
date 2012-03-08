function geo_success(position) {
  var s = document.querySelector('#status');
  
  if (s.className == 'success') {
    // not sure why we're hitting this twice in FF, I think it's to do with a cached result coming back    
    return;
  }
  s.innerHTML = "lat: "+position.coords.latitude+", lon:"+position.coords.longitude;
	$('#geo_lon').val(position.coords.longitude);
	$('#geo_lat').val(position.coords.latitude);
}

function geo_by_ip() {
	if(geoip_longitude() && geoip_latitude()) {
	  var s = document.querySelector('#status');
		s.innerHTML = "lat: "+geoip_latitude()+", lon:"+geoip_longitude();
		$('#geo_lon').val(geoip_longitude());
		$('#geo_lat').val(geoip_latitude());
	} else {
		geo_error("failed")
	}
}

function geo_error(msg) {
  var s = document.querySelector('#status');
  s.innerHTML = typeof msg == 'string' ? msg : "failed";
  s.className = 'fail';
  // console.log(arguments);
}

$(function(){

	geo_by_ip();

	if (navigator.geolocation) {
	  navigator.geolocation.getCurrentPosition(geo_success, geo_by_ip);
	} else {
	  geo_by_ip();
	}

});