// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require_tree .

$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
});



 // Place all the behaviors and hooks related to the matching controller here.
 // All this logic will automatically be available in application.js.
 // You can use CoffeeScript in this file: http://coffeescript.org/
 //
 // Change the src of the given image with an updated timestamp to get the latest version
 // @param node - DOM image tag object of the Ganglia image to update
var refreshImages, startRefresh;

startRefresh = function(node) {
  return node.src = URL(node.src).setQuery("timestamp", (new Date).getTime()).toString();
};
// anonymous function to update all visible Ganglia graphs every 5 seconds
(refreshImages = function() {
  var i, nodes;
  nodes = $('.updateable');
  i = 0;
  while (i < nodes.length) {
    if ($(nodes[i]).is(':visible')) {
      startRefresh(nodes[i]);
    }
    i++;
  }
  setTimeout(refreshImages, 5000);
})();
