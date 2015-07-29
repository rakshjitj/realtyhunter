$(document).ready(function(){
  $('.auth-token-toggle').click(function (event) {
    $('.auth-token').toggleClass('hidden');
    event.preventDefault();
  });
});
