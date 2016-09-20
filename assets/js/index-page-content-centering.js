(function(){
  var CONTENT_BLOCK_SELECTOR = '.js-index-content-container';

  $(document).ready(function(){
    var hViewport = $(window).height();
    var hHeader = $('header').height();
    var hFooter = $('footer').height();
    var hContent = $(CONTENT_BLOCK_SELECTOR).height();

    var calculatedMargin = (hViewport - hHeader - hFooter - hContent) / 2;
    $(CONTENT_BLOCK_SELECTOR).css({marginTop: calculatedMargin, marginBottom: calculatedMargin});
  });

}());
