function removeImage(id, bldg_id) {
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
		
	// disable auto discover
	Dropzone.autoDiscover = false;
 
	// grap our upload form by its id
	$("#building-dropzone").dropzone({
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

	$('.delete-bldg-img').click(function(event) {
		event.preventDefault();
		var id = $(this).attr('data-id'); 
		var bldg_id = $(this).attr('data-bldg-id');
		console.log(id, bldg_id);
		removeImage(id, bldg_id);
	});

	$('.carousel-indicators > li:first-child').addClass('active');
	$('.carousel-inner > .item:first-child').addClass('active')
	
});// end document ready