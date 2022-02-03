
var Airtable = require('airtable');
var base = new Airtable({apiKey: 'keyZ5ixWh8VGnbyu6'}).base('appnrXsE25ls6TAY1'); //don't hack me bro

//on load, grab entries from base

base('Table 1').select({
	//only pull cards that the team has seen, based on the "Visible" column in the base
	filterByFormula: "NOT({Visible}='')",
    view: "Grid view",
	sort: [{field: "Index", direction: "asc"}]
}).firstPage(function page(err, records) {
	if (err) { console.error(err); return; }

    records.forEach(function(record) {
		//set variables for each card returned
		var name = record.get('Name');
		var boxname = record.get('Box Name');
		var possessed = record.get('In Possession');
		var suit = record.get('Suit');
		var pic = record.get('Attachments');
		var cardnumber = record.get("Index");
		var imageFull = pic[0].thumbnails.full.url;
		var imageLg = pic[0].thumbnails.large.url;
		var imageSm = pic[0].thumbnails.small.url;
		var picxl = record.get('XL');
		var imageXL = picxl[0].thumbnails.full.url;
		var owned = '';
		var ownedicon = '';
		
		//check to see if the card is owned: if so, write a class and html element
		if(possessed === true) { ownedicon='<i class="far fa-check-square"></i>'; owned='owned'; }
		
		//write html with the card's info into the main grid
		$('#cardgrid').append('<div id="' + cardnumber + '" class="col-md-3 display-container ' + suit + ' ' + owned +'"><a data-toggle="modal" href="#' + boxname + '"><img class="img-fluid img-thumbnail" alt="' + name + '" src="' + imageLg + '" /></a><div><p class="text-center text-white bg-dark"><strong>' + name + '</strong><span class="text-success"> ' + ownedicon + '</span></p></div></div>');
		
		//write html with the full size image into the hidden lightbox modal
		$('#lightboxes').append('<div class="modal" id="' + boxname + '" tabindex="-1" role="dialog" airalabelledby="' + name + '" aria-hidden="true"><div class="modal-dialog modal-lg" role="document"><div class="modal-content"><div class="modal-header"><h5 class="modal-title">' + name + '</h5><button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button></div><div class="modal-body text-center"><p><img src="' + imageFull + '"></p><p><button onclick="newtab(\'' + imageXL + '\')">Open in New Tab</button></p></div></div></div></div>');
		
    });
});

//navbar functions: each navbar button hides non-matching grid cards, and sets the nav-link to active
function showAll() {
	$('Major, .Batons, .Blades, .Coins, .Cups').show();
	$(".nav").find(".active").removeClass("active");
	$('.active').removeClass("active");
	$('#showall').addClass("active");
}

function newtab(url) {
	var win = window.open(url, '_blank');
	win.focus();
}

function onlyMajor() {
	$('.Major').show();
	$('.Batons, .Blades, .Coins, .Cups').hide();
	$('.active').removeClass("active");
	$('#onlymajor').addClass("active");

}

function onlyBatons() {
	$('.Batons').show();
	$('.Major, .Blades, .Coins, .Cups').hide();
	$('.active').removeClass("active");
	$('#onlybatons').addClass("active");
}

function onlyBlades() {
	$('.Blades').show();
	$('.Major, .Batons, .Coins, .Cups').hide();
	$('.active').removeClass("active");
	$('#onlyblades').addClass("active");
}

function onlyCoins() {
	$('.Coins').show();
	$('.Major, .Batons, .Blades, .Cups').hide();
	$('.active').removeClass("active");
	$('#onlycoins').addClass("active");
}

function onlyCups() {
	$('.Cups').show();
	$('.Major, .Batons, .Blades, .Coins').hide();
	$('.active').removeClass("active");
	$('#onlycups').addClass("active");
}

function onlyOwned() {
	$('.Major, .Batons, .Blades, .Cups, .Coins').hide();
	$('.owned').show();
	$('.active').removeClass("active");
	$('#onlyowned').addClass("active");
}

function random() {
	$('.Major, .Batons, .Blades, .Cups, .Coins').hide();
	$('.active').removeClass("active");
	$('#drawacard').addClass("active");
	
	var len = $(".owned").length;
	console.log('len: ', len);
	var randomcard = Math.floor(Math.random() * len );
	$('.owned').eq(randomcard).show();
	console.log('random: ', randomcard)
	
	
}