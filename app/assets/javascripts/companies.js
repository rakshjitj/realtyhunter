Companies = {};

(function() {
	
	Companies.initialize = function() {
		$('#company_privacy_policy').editable({inlineMode: false})
		$('#company_terms_conditions').editable({inlineMode: false})
	};

})();
$(document).ready(Companies.initialize);