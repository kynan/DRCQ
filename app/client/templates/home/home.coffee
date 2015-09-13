Meteor.subscribe 'markers'

categories =
  shelter:
    category: 'shelter'
    resource: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_shelter_32px_icon_bluebox.png'
    need: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_shelter_32px_icon.png'
  wash:
    category: 'wash'
    resource: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_WASH_32px_icon_bluebox.png'
    need: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_WASH_32px_icon.png'
  food:
    category: 'food'
    resource: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_food_security_32px_icon_bluebox.png'
    need: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_food_security_32px_icon.png'
  health:
    category: 'health'
    resource: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_health_32px_icon_bluebox.png'
    need: 'http://mw1.google.com/crisisresponse/icons/un-ocha/cluster_health_32px_icon.png'

Template.Home.events
  'click img.marker': (event, tmpl) ->
    category = event.target.attributes.category.value
    type = event.target.attributes.type.value
    Markers.insert
      latlng: tmpl.addMarker.get(),
      category: category
      type: type
    tmpl.addMarker.set null

  'click a.removeMarker': (event) ->
    Markers.remove event.target.id

Template.Home.helpers
  categories: ->
    (val for key, val of categories)
  addMarker: ->
    Template.instance().addMarker.get()
  round: (val) ->
    return val.toFixed 4

Template.Home.onCreated ->
  this.addMarker = new ReactiveVar null

Template.Home.onRendered ->
  self = this

  L.Icon.Default.imagePath = 'packages/bevanhunt_leaflet/images'

  harwell = [51.5645499, -1.3229768]
  map = L.map 'map', doubleClickZoom: false
  map.setView harwell, 13

  groups = {}
  for c of categories
    groups[c] = L.layerGroup().addTo map

  L.tileLayer.provider('Thunderforest.Outdoors').addTo map
  L.control.layers({}, groups).addTo map

  # Double click to add markers
  map.on 'dblclick', (event) ->
    self.addMarker.set event.latlng

  query = Markers.find()
  query.observe
    added: (document) ->
      text = "#{document.category} #{document.type} at #{document.latlng.lat.toFixed 4}, #{document.latlng.lng.toFixed 4} | <a class='removeMarker' id='#{document._id}' href='#'>remove</a>"
      icon = L.icon
        iconUrl: categories[document.category][document.type]
        iconSize: [32, 32]
        iconAnchor: [16, 0]
      marker = L.marker(document.latlng, icon: icon).bindPopup text
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
