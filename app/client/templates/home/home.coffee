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

Template.Home.onDestroyed ->
