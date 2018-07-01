# Some util functions, some converted by js2coffee.

debounce = (func, wait, immediate) ->
	timeout = undefined
	->
		context = this
		args = arguments

		later = ->
			timeout = null
			if !immediate
				func.apply context, args
			return

		callNow = immediate and !timeout
		clearTimeout timeout
		timeout = setTimeout(later, wait)
		if callNow
			func.apply context, args
		return

module.exports = { debounce }
