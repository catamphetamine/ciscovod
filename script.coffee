module.exports = (data) ->
	$$ [
		'configure terminal',
		
		'voice service voip',
		'ip address trusted list',
		'ipv4 10.101.0.1',
		'ipv4 10.101.0.3',
		'allow-connections h323 to h323',
 		'allow-connections h323 to sip',
 		'allow-connections sip to h323',
 		'supplementary-service h450.12',
 		'redirect ip2ip',

		'do write'
	]
	

