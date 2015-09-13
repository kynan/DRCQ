Meteor.subscribe 'markers'

Template.Home.events {}

Template.Home.helpers {}

# Home: Lifecycle Hooks
Template.Home.onCreated ->

Template.Home.onRendered ->
  # on startup run resizing event
  $(window).resize ->
    $('#map').css 'height', window.innerHeight
  $(window).resize() # trigger resize event

  L.Icon.Default.imagePath = 'packages/bevanhunt_leaflet/images'

  harwell = [51.5645499, -1.3229768]
  map = L.map 'map', doubleClickZoom: false
  map.setView harwell, 13

  L.tileLayer.provider('Thunderforest.Outdoors').addTo map

  # Double click to add markers
  map.on 'dblclick', (event) ->
    Markers.insert {latlng: event.latlng}

  query = Markers.find()
  query.observe
    added: (document) ->
      marker = L.marker(document.latlng).addTo(map).on "click", (event) ->
        map.removeLayer marker
        Markers.remove _id: document._id

    removed: (oldDocument) ->
      layers = map._layers
      key = undefined
      val = undefined
      for key of layers
        val = layers[key]
        map.removeLayer val if val._latlng?.lat is oldDocument.latlng.lat and val._latlng?.lng is oldDocument.latlng.lng
      return


Template.Home.onDestroyed ->
