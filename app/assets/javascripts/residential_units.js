function removeImage(id, unit_id) {
	// make a DELETE ajax request to delete the file
	$.ajax({
		type: 'DELETE',
		url: '/residential_units/' + unit_id + '/unit_images/' + id,
		success: function(data){
			console.log(data.message);
			$.getScript('/residential_units/' + unit_id + '/refresh_images')
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
	$("#unit-dropzone").dropzone({
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
			$(file.previewTemplate).find('.dz-remove').attr('unit_id', response.unitID);
			// add the dz-success class (the green tick sign)
			$(file.previewElement).addClass("dz-success");
			$.getScript('/residential_units/' + response.unitID + '/refresh_images')
			file.previewElement.remove();
		},
		//when the remove button is clicked
		removedfile: function(file){
			// grap the id of the uploaded file we set earlier
			var id = $(file.previewTemplate).find('.dz-remove').attr('id'); 
			var unit_id = $(file.previewTemplate).find('.dz-remove').attr('unit_id');
			removeImage(id, unit_id);
			file.previewElement.remove();
		}
	});

	$('.delete-unit-img').click(function(event) {
		event.preventDefault();
		var id = $(this).attr('data-id'); 
		var unit_id = $(this).attr('data-unit-id');
		console.log(id, unit_id);
		removeImage(id, unit_id);
		// TODO: WTF why is this breaking?
	});

	$('.carousel-indicators > li:first-child').addClass('active');
	$('.carousel-inner > .item:first-child').addClass('active')
	
});// end document ready