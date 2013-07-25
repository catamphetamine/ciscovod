Object.clone = (obj) ->
	if not obj? or typeof obj isnt 'object'
		return obj

	if obj instanceof Date
		return new Date(obj.getTime()) 

	if obj instanceof RegExp
		flags = ''
		flags += 'g' if obj.global?
		flags += 'i' if obj.ignoreCase?
		flags += 'm' if obj.multiline?
		flags += 'y' if obj.sticky?
		return new RegExp(obj.source, flags) 

	newInstance = new obj.constructor()

	for key of obj
		newInstance[key] = Object.clone obj[key]

	return newInstance

Object.merge_recursive = (obj1, obj2) ->
	for ключ, значение of obj2
		#if obj2.hasOwnProperty(ключ)
		if typeof obj2[ключ] == 'object' && obj1[ключ]?
			obj1[ключ] = Object.merge_recursive(obj1[ключ], obj2[ключ])
		else
			obj1[ключ] = obj2[ключ]

	return obj1

Object.x_over_y = (obj1, obj2) ->
	if not obj1?
		return obj2
	Object.merge_recursive(obj2, obj1)
	
String.prototype.starts_with = (substring) ->
	@indexOf(substring) == 0

String.prototype.ends_with = (substring) ->
	index = @lastIndexOf(substring)
	index >= 0 && index == @length - substring.length
	
RegExp.escape = (string) ->
	specials = new RegExp("[.*+?|()\\[\\]{}\\\\]", "g")
	return string.replace(specials, "\\$&")

String.prototype.replace_all = (what, with_what) ->
	regexp = new RegExp(RegExp.escape(what), "g")
	return @replace(regexp, with_what)
	
Array.prototype.is_empty = ->
	return @length == 0
	
String.prototype.has = (what) ->
	return @indexOf(what) >= 0