# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$ ->
  if typeof window["Annotator"] isnt "undefined"
    $("#content").annotator().annotator "addPlugin", "Store",
      urls:
        create: "/notebooks"
        read: "/notes"
        update: "/notesu"
        destroy: "/notesd"
        search: "/notess"

      annotationData:
        uri: window.location.pathname
        prefix: "/"

      loadFromSearch:
        limit: 20
        uri: window.location.pathname

$ ->
  $("#bk1").removeClass("collapsed");
  $("#collapse1").addClass("in");
  $("#collapse1").css("height","auto");

  $(".sectionlbl").show()
  
  if window.location.hash
    hashvalue = "p" + window.location.hash.split("#")[1]
    currentColor = jQuery.Color("#" + hashvalue)
    $("#" + hashvalue).animate
      backgroundColor: "#FDF1CA"
    , 1000
    $("#" + hashvalue).animate
      backgroundColor: currentColor
    , 3000

  setSpan = (window_width) ->
    if window_width >= 1200
      $("#read").removeClass().addClass("span6").addClass "offset1"
    else if window_width >= 980 and window_width < 1200
      $("#read").removeClass().addClass("span7").addClass "offset1"
    else if window_width > 767 and window_width < 980
      $("#read").removeClass().addClass("span10").addClass "offset1"
    else
      $("#read").removeClass().addClass "span6"

    if window_width > 611 && window_width < 768
      $("#read").addClass("read-margins")
    else
      $("#read").removeClass("read-margins")

  setSpan($(window).width())

  $(window).resize ->
    setSpan($(window).width())