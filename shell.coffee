ssh2 = require 'ssh2'

class Ssh
	commands: []
	
	constructor: (@options, @ready) ->
		shell = @
		
		@ssh = new ssh2()
		
		@ssh.on 'connect', ->
			console.log('Connection :: connect')
		  
		@ssh.on 'ready', ->
			console.log('Connection :: ready')
			shell.ready.bind(shell)()
			shell.next()
			
		@ssh.on 'banner', (message, language) ->
			console.log('Connection :: banner')
			console.log(message)
			
		@ssh.on 'tcp connection', ->
			console.log('Connection :: tcp connection')
			
		@ssh.on 'keyboard-interactive', (name, instructions) ->
			console.log('Connection :: keyboard-interactive')
			console.log(name)
			
		@ssh.on 'change password', (message, language) ->
			console.log('Connection :: change password')
			console.log(message)
			
		@ssh.on 'error', (error) ->
			console.error('Connection :: error :: ' + error)

		@ssh.on 'end', ->
			console.log('Connection :: end')

		@ssh.on 'close', (had_error) ->
			console.log('Connection :: close')
			
			if not shell.succeeded?
				if shell.options.failed?
					shell.options.failed()
			else
				if shell.options.done?
					shell.options.done()
			
			if shell.options.end?
				shell.options.end()
			
		#@options.debug = console.log 
			
		@ssh.connect(@options)
			
	command: (command, output) ->
		@commands.push({ 'command': command, 'output': output })
	
	next: ->
		if @commands.length == 0
			@succeeded = yes
			return @end()
			
		@execute_command(@commands.shift())
	
	execute_command: (options) ->
		console.log('executing command: ' + options.command)
		
		shell = this
		
		command = options.command
		output = options.output.bind(@)
		
		output_data = ''
		
		@ssh.exec command, (error, stream) ->
			if error?
				throw error
				
			stream.on 'data', (data, extended) ->
				if extended == 'stderr'
					throw data
					
				output_data += data
			
			stream.on 'end', ->
				console.log('Stream :: EOF')
			
			stream.on 'close', ->
				console.log('Stream :: close')
			
			stream.on 'exit', (code, signal) ->
				console.log('Stream :: exit :: code: ' + code + ', signal: ' + signal)
				
				output(output_data)
				shell.next()
	
	end: ->
		@ssh.end()
		
module.exports = Ssh