# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Change the src of the given image with an updated timestamp to get the latest version
# @param node - DOM image tag object of the Ganglia image to update
startRefresh = (node) ->
  if node.src.indexOf('timestamp=') > -1
    node.src = node.src.split('timestamp=')[0] + 'timestamp=' + (new Date).getTime()
  return

# anonymous function to update all visible Ganglia graphs every 5 seconds
(refreshImages = ->
  nodes = $('.updateable')
  i = 0
  while i < nodes.length
    if $(nodes[i]).is(':visible')
      startRefresh nodes[i]
    i++
  setTimeout refreshImages, 5000
  return
)()
