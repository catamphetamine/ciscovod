module.exports = (data, end) ->
	###
	$ 'show run | sec ephone', (ephones) ->

		the_phones = []
		
		ephone = null
		
		for line in ephones.split('\r\n')
			if line.starts_with('ephone  ')
				ephone = line
			if line.starts_with(' type 6911')
				the_phones.push(ephone)
				ephone = null

		commands = [
			'configure terminal',
			
			'ephone-template 2',
			'feature-button 1 GPickUp'
		]
		
		for phone in the_phones
			commands.push(phone)
			commands.push('ephone-template 2')
			
		commands.push('do write')
			
		console.log(commands)
		
		$$ commands
	###

	$$ [
		'configure terminal'
	]