EventEmitter = require "events"

symbols = "1234567890qwertyuiopasdfghjklzxcvbnm"

class WS extends EventEmitter
	constructor: (@address) ->
		super()
		return new Promise (resolve, reject) =>
			@ws = new WebSocket @address

			@ws.onopen = =>
				console.log "Connection opened on " + @address
				resolve @

			@ws.onclose = =>
				console.log "Connection closed"

			@ws.onerror = (err) =>
				reject err

			@ws.onmessage = (event) =>
				data = JSON.parse event.data

				unless data.type?
					throw new Error "Invalid message: no \"type\" field:", event

				unless data.data?
					throw new Error "Invalid message: no \"data\" field: ", event

				@emit data.type, JSON.parse(data.data)

	receive: (type) ->
		return new Promise (resolve) =>
			@once type, resolve

	get: (type, data) ->
		reply = "reply-"

		for i in [0...20]
			num = Math.floor Math.random() * symbols.length
			reply += symbols[num]

		@send type, data, reply
		return await @receive reply

	send: (type, data, reply = type) ->
		@ws.send JSON.stringify { type, reply, data: JSON.stringify(data) }

module.exports = WS
