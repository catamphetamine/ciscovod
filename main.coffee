require './files/offices.js'
require './files/date.js'

cisco_shell = require './../cisco_shell/cisco shell'

require './language'
Ssh = require './shell'
disk_tools = require './disk tools'

Backup_to = process.env.BACKUP_CISCO_CONFIGURATION_TO || 'c:/cisco/backup configs'

Ssh_options = 
	port: 22
	username: process.env.BACKUP_CISCO_CONFIGURATION_USERNAME
	password: process.env.BACKUP_CISCO_CONFIGURATION_PASSWORD

console.log(Ssh_options)

backup_configuration = (options) ->
	office = options.device.office
	device = options.device.device
	what = options.device.what

	name = office.title
	
	end = ->
		if options.end?
			options.end()
	
	if not device?
		console.log 'WARNING: ' + what + ' is not defined for office "' + name + '" in files/offices.js'
		return end()
	
	ip = device.ip
	
	if not ip?
		console.log 'WARNING: ' + what + ' IP is not set for office "' + name + '" in files/offices.js'
		return end()
	
	end = options.end
	
	options = Object.clone(Ssh_options)
	
	options.host = ip
	
	options.end = end
	
	options.failed = ->
		message = 'Error while backing up ' + name + ' (' + what + ', ' + ip + ')'
		console.log(message)
		throw message
	
	ip_parts = ip.split('.')
	ip_parts.shift()
	ip_parts.shift()
	
	file_name = ip_parts.join('.') + ' (' + name + ', ' + what + ') ' + new Date().toString('yyyy-MM-dd')
	
	console.log ''
	console.log 'Backing up ' + name + ' (' + what + ') configuration'
	console.log ''
	
	path = Backup_to + '/' + name + '/' + file_name + '.txt'
	
	new Ssh options, ->
		@command 'show startup-config', (output) ->
			#console.log(output)
			output = output.substring(output.indexOf('!'))
			disk_tools.создать_путь Backup_to + '/' + name, ->
				disk_tools.write(path, output)
				console.log ''
				console.log 'Configuration has been successfully backed up to ' + path
				console.log ''

process.argv.shift()
process.argv.shift()

action = process.argv.shift()

expand_devices = (office, what) ->
	switch what
		when 'router'
			if office[what]?
				return [office[what]]
			else if office.routers?
				return office.routers
				
		when 'switch'
			if office[what]?
				return [office[what]]
			else if office.switches?
				return office.switches

read_parameters = ->
	offices = []
		
	office = process.argv.shift()
	
	if office? && office != 'all'
		the_office = Offices[office]
		
		if not the_office?
			throw 'Office not found: ' + office
			
		offices.push(the_office)
	else
		for key, office of Offices
			offices.push(office)
		
	what = 'router'
	
	if office?
		what_parameter = process.argv.shift()
		
		if what_parameter?
		
			switch what_parameter
				when 'router'
					console
				when 'switch'
					console
				when 'everything'
					console
				else
					throw 'Invalid what parameter: ' + what_parameter
					
			what = what_parameter

	devices = []

	switch what
		when 'router'
			for office in offices
				for device in expand_devices(office, what)
					devices.push({ office: office, device: device, what: what })
					
		when 'switch'
			for office in offices
				for device in expand_devices(office, what)
					devices.push({ office: office, device: device, what: what })
					
		when 'everything'
			for office in offices
				for device in expand_devices(office, 'router')
					devices.push({ office: office, device: device, what: 'router' })
				for device in expand_devices(office, 'switch')
					devices.push({ office: office, device: device, what: 'switch' })
			
	parameters =
		offices: offices
		what: what
		devices: devices
		
	return parameters

parameters = read_parameters()
	
switch action
	when 'backup'
		next = ->
			device = parameters.devices.shift()
			
			if not device?
				return
			
			backup_configuration({ device: device, end: next })
		
		next()
		
	when 'configure'
		next = ->
			device = parameters.devices.shift()
			
			if not device?
				return
			
			shell_executor_options = 
				port: 22
				username: Ssh_options.username
				password: Ssh_options.password
				host: device.device.ip
				script_path: './../ciscovod/script'
				end: next
				parameters: device

			console.log '###################################################################'
			console.log 'Executing script for ' + device.office.title + ' on ' + device.what + ' ' + device.device.ip
			console.log '###################################################################'

			cisco_shell(shell_executor_options)

		next()
			
	else
		console.log('Unknown command: ' + action)
		console.log('Usage: "run backup \"название филиала\"" (конфиг будет записан в папку "' + Backup_to + '")')