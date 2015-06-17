// google map
function initializeMap() {
  $(".panel").geocomplete({
  	map: "#map_canvas",
  	location: "<%= @building.formatted_street_address %>" ,
  	details: ".details"
  }).bind("geocode:result", function(event, result){
      //console.log(result);
  }).bind("geocode:error", function(event, result){
      //console.log("[ERROR]: " + result);
  });
};

function removeImage(id, bldg_id) {
	console.log('/buildings/' + bldg_id + '/destroy_image/' + id);
	// make a DELETE ajax request to delete the file
	$.ajax({
		type: 'DELETE',
		url: '/buildings/' + bldg_id + '/images/' + id,
		success: function(data){
			console.log(data.message);
			$.getScript('/buildings/' + bldg_id + '/refresh_images')
		},
		error: function(data) {
			console.log('ERROR:', data);
		}
	});
};


$(document).ready(function(){
	// start up google maps
	initializeMap();
	// disable auto discover
	Dropzone.autoDiscover = false;
 
	// grap our upload form by its id
	$("#media-dropzone").dropzone({
		// restrict image size to a maximum 1MB
		//maxFilesize: 4,
		//paramName: "upload[image]",
		// show remove links on each image upload
		addRemoveLinks: true,
		// if the upload was successful
		success: function(file, response){
			// find the remove button link of the uploaded file and give it an id
			// based of the fileID response from the server
			$(file.previewTemplate).find('.dz-remove').attr('id', response.fileID);
			$(file.previewTemplate).find('.dz-remove').attr('bldg_id', response.bldgID);
			// add the dz-success class (the green tick sign)
			//console.log('/buildings/' + bldg_id + '/destroy_image/' + id);
			$(file.previewElement).addClass("dz-success");
			$.getScript('/buildings/' + response.bldgID + '/refresh_images')
			file.previewElement.remove();
		},
		//when the remove button is clicked
		removedfile: function(file){
			// grap the id of the uploaded file we set earlier
			var id = $(file.previewTemplate).find('.dz-remove').attr('id'); 
			var bldg_id = $(file.previewTemplate).find('.dz-remove').attr('bldg_id');
			removeImage(id, bldg_id);
			file.previewElement.remove();
		}
	});

	$('.delete-img').click(function(event) {
		event.preventDefault();
		var id = $(this).attr('data-id'); 
		var bldg_id = $(this).attr('data-bldg-id');
		console.log(id, bldg_id);
		removeImage(id, bldg_id);
		// TODO: WTF why is this breaking?
	});

}); // end document raedy
