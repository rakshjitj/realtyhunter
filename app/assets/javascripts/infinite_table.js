if ($('.infinite-table').length) {
  $('.infinite-table').infinitePages({
    debug: true,
    buffer: 200,
    context: '.pane',
    loading: function() {
      // jQuery callback on the nav element
      console.log('loading');
      return $(this).text('Loading...');
    },
    success: function() {
      // called after successful ajax call
      console.log('ok');
    },
    error: function() {
      console.log('trouble');
      // called after failed ajax call
      return $(this).button('There was an error, please try again');
    }
  });
}
