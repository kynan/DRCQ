Meteor.subscribe 'markers'

categories =
  resource:
    shelter:
      category: 'shelter'
      iconUrl: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_shelter_32px_icon_bluebox.png'
    wash:
      category: 'wash'
      iconUrl: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_WASH_32px_icon_bluebox.png'
  need:
    shelter:
      category: 'shelter'
      iconUrl: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_shelter_32px_icon.png'
    wash:
      category: 'wash'
      iconUrl: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_WASH_32px_icon.png'

Template.Home.events
  'click img.marker': (event, tmpl) ->
    category = event.target.attributes.category.value
    type = event.target.attributes.type.value
    Markers.insert
      latlng: tmpl.addMarker.get(),
      category: category
      type: type
      icon: categories[type][category]
    tmpl.addMarker.set null

Template.Home.helpers
  resource: ->
    (val for key, val of categories.resource)
  need: ->
    (val for key, val of categories.need)
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

  groups = {}
  for c of categories.resource
    groups[c] = L.layerGroup().addTo map

  L.tileLayer.provider('Thunderforest.Outdoors').addTo map
  L.control.layers({}, groups).addTo map

  # Double click to add markers
  map.on 'dblclick', (event) ->
    self.addMarker.set event.latlng

  query = Markers.find()
  query.observe
    added: (document) ->
      marker = L.marker(document.latlng, icon: L.icon document.icon).bindPopup "#{document.category} #{document.type} at #{document.latlng.lat}, #{document.latlng.lng}"
      groups[document.category].addLayer marker

    removed: (oldDocument) ->
      layers = map._layers
      key = undefined
      val = undefined
      for key of layers
        val = layers[key]
        map.removeLayer val if val._latlng?.lat is oldDocument.latlng.lat and val._latlng?.lng is oldDocument.latlng.lng
      return

Template.Home.onDestroyed ->
