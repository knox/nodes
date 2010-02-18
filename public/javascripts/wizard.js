if ($('subnet_ip_suggest')) {
	$('subnet_ip_suggest').setStyle( {
		display : 'block'
	});
	Event.addBehavior( {
		'#subnet_ip_suggest:click' : function(e) {
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
	$('node_ip_suggest').setStyle( {
		display : 'block'
	});
	Event.addBehavior( {
		'#node_ip_suggest:click' : function(e) {
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
