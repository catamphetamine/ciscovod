disk = require 'fs'

disk_tools = {}

remove_empty_objects = (map) ->
	for key, value of map
		if typeof map[key] == 'object'
			if Object.пусто(map[key])
				delete map[key]
				continue
			remove_empty_objects(map[key])

file_map = (path, options) ->
	if typeof path == 'object'
		options = path
		path = options.path

	map = {}

	for entry in disk.readdirSync(path)
		if options.exclude? && options.exclude.has((path + '/' + entry).after(options.path).substring(1))
			continue

		if disk.statSync(path + '/' + entry).isDirectory()
			map[entry] = file_map(path + '/' + entry, options)
		else
			dot_position = entry.lastIndexOf('.')

			if dot_position < 0
				continue

			title = entry.substring(0, dot_position)
			extension = entry.substring(dot_position + 1)

			if extension + '' == options.type + ''
				map[title] = yes

	remove_empty_objects(map)

	return map

flatten = (map) ->	
	flat = []

	flatten_recursive = (map, path) ->
		path_to = (file) ->
			if not path?
				return file
			return path + '/' + file

		for key, value of map
			if typeof map[key] == 'object'
				flatten_recursive(map[key], path_to(key))
			else
				flat.add(path_to(key))

	flatten_recursive(map)

	flat

disk_tools.list_files = (path, options) ->
	if not disk.existsSync(path)
		return []

	options.path = path
	flatten(file_map(options))

map_to_array_map = (map) ->
	array = []

	for key, value of map
		if typeof value == 'object'
			array.add({ key: map_to_array_map(value) })
		else if value == yes
			array.add(key)

	return array

disk_tools.map_files = (path, options) ->
	if not disk.existsSync(path)
		return []

	options.path = path
	map_to_array_map(file_map(options))

disk_tools.read = (file) ->
	disk.readFileSync(file, 'utf8')

disk_tools.создать_путь = (path, callback) ->
	file_system = disk

	# default foder mode
	mode = 0o777

	# change windows slashes to unix
	path =  path.replace(/\\/g, '/')

	# remove trailing slash
	if path.substring(path.length - 1) == '/'
		path = path.substring(0, path.length - 1)

	check_folder = (path, callback) ->
		file_system.stat(path, (error, info) ->
			if not error?
				# folder exists, no need to check previous folders
				if info.isDirectory()
					return callback()

				# file exists at location, cannot make folder
				#return callback(new Error('exists'))

			if error?
				# if it is unkown error
				if error.errno != 2 && error.errno != 32 && error.code != 'ENOENT'
					console.error(require('util').inspect(error, true))
					return callback(error)

			# the folder doesn't exist, try one stage earlier then create

			# if only slash remaining is initial slash, then there is no where to go back
			if path.lastIndexOf('/') == path.indexOf('/')
				# should only be triggered when path is '/' in Unix, or 'C:/' in Windows
				# (which must exist)
				return callback(new Error('Not found'))

			# try one stage earlier
			check_folder(path.substring(0, path.lastIndexOf('/')), (error) ->
				if error?
					return callback(error)

				# make this directory
				file_system.mkdir(path, mode, (error) ->
					if error && error.errno != 17
						error = "Failed to create folder #{path}"
						console.error(error)
						return callback(new Error(error))

					callback()
				)
			)
		)

	check_folder(path, callback)
	
disk_tools.write = (path, what) ->
	disk.writeFileSync(path, what, 'utf8')
	
module.exports = disk_tools