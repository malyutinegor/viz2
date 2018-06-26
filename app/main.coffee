require "babel-polyfill"

WS       = require "./ws"

m    = require "mithril"
papa = require "papaparse"

# todo: calculate line size
# todo: resize
# todo: parse time
# todo: watch

LINE_SIZE  = 20 
CHUNK_SIZE = 100
FAULT      = LINE_SIZE / 5
VISIBLE    = 300

isVisible = (e) ->
	return !!(e.offsetWidth || e.offsetHeight || e.getClientRects().length)

mapObj = (obj, f) ->
	ret = []
	for name, prop of obj
		ret.push f prop, name
	return ret

i = 0

headers = [
	"lol",
	"kek",
	"cheburek"
]

do ->
	ws = await new WS config.ws

	class Main
		constructor: ->
			@count = 0
			@start = 0
			@lines = []

			@loadLinesCount().then (@count) =>
				console.log "Lines count:", @count
				m.redraw()

		loadLines: (start, end) ->
			return new Promise (resolve) =>
				ws.get("get", { start, end }).then (lines) =>
					{ data } = papa.parse lines
					resolve data

		loadLinesCount: ->
			return new Promise (resolve) =>
				ws.get("lines").then (lines) =>
					resolve lines

		scroll: (event) ->
			@updating = false
			# console.log ++i
			dom = event.target
			scrollTop    = dom.scrollY or dom.scrollTop
			scrollBottom = dom.clientHeight + scrollTop

			@scrollTop = scrollTop

			topLine    = Math.min(Math.max(Math.floor(scrollTop / LINE_SIZE), 0), @count)
			bottomLine = Math.max(Math.min(Math.floor(scrollBottom / LINE_SIZE), @count), 0) 

			@start = topLine
			@lines = await @loadLines topLine, bottomLine

			m.redraw()

		view: ->
			m "div.table-root", { 
				onscroll: (event) => await @scroll event
				oncreate: (vnode) =>
					@updateInterval = setInterval =>
						await @scroll { target: vnode.dom }
						m.redraw()
					, 500
				onremove: (vnode) =>
					clearInterval @updateInterval
			},
				if @lines
					m "div.table", { style: height: (@count * LINE_SIZE) + "px" },
						m "table", { style: top: (@start * LINE_SIZE) + "px" }, [
							m "thead", [
								headers.map (header) =>
									m "th", { style: top: (@scrollTop - (@start * LINE_SIZE)) + "px" }, header
							]
							m "tbody", [
								@lines.map (line) =>
									m "tr", line.map (cell) =>
										m "td", cell
							]
						]

	# mount
	root = document.getElementById "root"
	m.mount root, Main
