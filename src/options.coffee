#
# helpers
#
$ = document.querySelector.bind document
$$ = document.querySelectorAll.bind document
val = (obj) -> obj.value
last = (arr) -> arr[arr.length-1] if arr.length > 0

M = require './models.coffee'
S = require './sun_altitude.coffee'
C = require './canvas.coffee'

class Options
    constructor: (@parent, @models=[], @views=[]) ->
        @prio =
            temperature: 2,
            color: 1,
            opacity: 0

        chrome.storage.local
            .get ['keyframes', 'latitude', 'longitude'], (items) =>
                @canvas = new C.OptionsAltitudeGraph $('#graph'), items.latitude, items.longitude

                # sort by option first, key_value for same option
                items.keyframes
                    .sort (a, b) =>
                        if a.option isnt b.option
                            @prio[b.option] - @prio[a.option] 
                        else
                            a.key_value - b.key_value
                            
                @add kf for kf in items.keyframes

        $ '#add'
            .addEventListener 'click', (event) =>
                event.preventDefault()
                @add()
        
        $ '#save'
            .addEventListener 'click', (event) =>
                event.preventDefault()
                chrome.storage.local
                    .set 'keyframes': @models, ->

    add: (model) ->
        model = new M.Keyframe() if not model?
        @models.push model
        @views.push new M.KeyframeView model, @parent

        last @views
            .create()
            .render()
            .delete.addEventListener 'click', (event) =>
                event.preventDefault()
                index = @models.indexOf model
                @models.splice index, 1
                last @views.splice index, 1
                    .erase()


app = new Options $ '#keyframes'
