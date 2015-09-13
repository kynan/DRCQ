Meteor.subscribe 'markers'

Template.Home.events
  'click img.marker': (event, tmpl) ->
    Markers.insert
      latlng: tmpl.addMarker.get(),
      icon: {iconUrl: event.target.attributes.src.value}
    tmpl.addMarker.set null

Template.Home.helpers
  addMarker: ->
    Template.instance().addMarker.get()

Template.Home.onCreated ->
  this.addMarker = new ReactiveVar null

Template.Home.onRendered ->
  self = this

  L.Icon.Default.imagePath = 'packages/bevanhunt_leaflet/images'

  harwell = [51.5645499, -1.3229768]
  map = L.map 'map', doubleClickZoom: false
  map.setView harwell, 13

  L.tileLayer.provider('Thunderforest.Outdoors').addTo map

  # Double click to add markers
  map.on 'dblclick', (event) ->
    self.addMarker.set event.latlng

  query = Markers.find()
  query.observe
    added: (document) ->
      console.log document
      marker = L.marker(document.latlng, icon: L.icon document.icon).addTo(map).on "click", (event) ->
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
