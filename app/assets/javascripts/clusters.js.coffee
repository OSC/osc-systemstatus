# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

startRefresh = (node) ->
  address = undefined
  if node.src.indexOf('timestamp=') > -1
    address = node.src.split('timestamp=')[0]
  else
    address = node.src
  node.src = address + 'timestamp=' + (new Date).getTime()
  return

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
