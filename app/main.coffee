require "babel-polyfill"

WS = require "./ws"
m  = require "mithril"

do ->
	ws = await new WS config.ws

	Main =
		oninit: ->
			@count = 0
			console.log await ws.get("get", start: 500, end: 600)

		view: ->
			m "h1", "sdsds"

	# mount
	root = document.getElementById "root"
	m.mount root, Main