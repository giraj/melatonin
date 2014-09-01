'use strict'

H = require './helpers.coffee'
A = require './altitude.coffee'
C = require './color_helpers.coffee'

class Storage
    constructor: (config) ->
        @get null, (it) =>
            if not it.version? or it.version < '0.3.0'
                @clear =>
                    @set config, =>
                        @print()
                        @bind_events()
            else
                obj = {}
                for own k, v of config
                    do ->
                        obj[k] = v if not it[k]?
                @set obj, =>
                    @print()
                    @bind_events()

    set: (obj, cb) ->
        if H.contains 'altitude', (k for own k, _ of obj)
            obj.last_update = Date.now()
        chrome.storage.local.set obj, cb

    get: (arr, cb) ->
        chrome.storage.local.get arr, cb

    clear: (cb) ->
        chrome.storage.local.clear cb

    print: ->
        @get null, (it) ->
            console.log 'in storage:'
            for own k, v of it
                do ->
                    console.log k + " : " + v

    bind_events: ->
        chrome.storage.onChanged.addListener (changes, namespace) =>
            for own k, v of changes
                do (k, v) ->
                    if k is 'altitude'
                        chrome.runtime.sendMessage type: 'new_altitude',
                                                   value: v.newValue

module.exports = Storage
