if ($('subnet_ip_suggest')) {
	$('subnet_ip_suggest').toggle();
	Event.addBehavior( {
		'#subnet_ip_suggest:click' : function(e) {
			$('subnet_ip_suggest').disabled = true;
			$('subnet_ip_suggest_spinner').toggle();
			new Ajax.Request('/subnets/suggest_ip', {
				asynchronous : true,
				evalScripts : true,
				method : 'post'
			});
			return false;
		}
	});
}

if ($('node_ip_suggest')) {
	$('node_ip_suggest').toggle();
	Event.addBehavior( {
		'#node_ip_suggest:click' : function(e) {
			$('node_ip_suggest').disabled = true;
			$('node_ip_suggest_spinner').toggle();
			new Ajax.Request('/nodes/suggest_ip', {
				asynchronous : true,
				evalScripts : true,
				method : 'post',
				parameters : $H( {
					subnet_id : $F('node_subnet_id')
				})
			});
			return false;
		}
	});
}

if ($('node_geocoder')) {
	$('node_geocoder').toggle();
	Event.addBehavior( {
		'#node_geocoder:click' : function(e) {
			$('node_geocoder').disabled = true;
			$('node_geocoder_spinner').toggle();
			new Ajax.Request('/map/geocode', {
				asynchronous : true,
				evalScripts : true,
				method : 'post',
				parameters : $H( {
					street : $F('node_street'),
					zip : $F('node_zip'),
					city : $F('node_city')
				})
			});
			return false;
		}
	});
}
