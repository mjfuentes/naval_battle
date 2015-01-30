$().ready(function(){
	var total_selected = 0;
	var selected_items = []
	var selectable_items;
	var game_started = false;
	var game_size = $("#game").data("size");
	var game_id = $("#game").data("id");
	var player_id = $("#game").data("player");
	var rival_id = $("#game").data("rival");
	var game_status = $("#game").data("status");
	function createGrid() {
		if (game_size == "small") {
			cell_amount = 5;
			selectable_items = 7
		}
		else if (game_size == "medium") {
			cell_amount = 10;
			selectable_items = 15;
		}
		else if (game_size == "large") {
			cell_amount = 15;
			selectable_items = 20;
		}
	    var ratioW = cell_amount,
	        ratioH = cell_amount,
	        cell_height = Math.floor(500/ratioH),
	        cell_width = Math.floor(500/ratioW);

	    var parent = $("#grid_container");

	    for (var i = 0; i < ratioH; i++) {
	        for(var p = 0; p < ratioW; p++){
	            var tile = $('<div />', {
	            	id: (i + 1)+"-"+(p +1),
	            	class: "grid_cell",
	                width: cell_height - 1,
	                height: cell_width - 1
	            })
	            tile.click(function(){
	            	var indexes = $(this).attr('id').split('-');
	            	if((total_selected < selectable_items) && ($(this).data("selected") == null)){
	            		$(this).data("selected",true);
		            	selected_items.push(indexes);
	            		$(this).css("background-color", "gray");
	            		total_selected++;
	            		if (total_selected == selectable_items){
	            			$("#start_game").show();
	            		}
	            	}
	            })
	            tile.appendTo(parent);
	        }
	    }
	};
    createGrid(5,3);

	$("#start_game").click(function(){
		if (!game_started) {
			$.ajax({
			   url: '/players/' + player_id + '/games/' + game_id,
			   type: 'PUT',
			   data: {"positions" : selected_items },
			   success: function(data) {
					start_game()
				},
				error: function(data) {
					alert("Hubo un error con el pedido");
				}
			});
		}
		else {
			$.ajax({
			   url: '/players/' + player_id + '/games/' + game_id + '/move',
			   type: 'POST',
			   data: {"position" : selected_items[0], "rival" : rival_id },
			   success: function(data) {
			   		if (data["code"] == 3) {
			   			alert("Ganaste!");
			   			window.location.href = window.location.origin + '/index'
			   		}
			   		else if (data["code"] == 2){
			   			alert("Le diste a un barco!");
			   			start_game();
			   		}
			   		else if (data["code"] == 1){
						alert("Agua.");
			   			start_game();
					}
				},
				error: function(data) {
					alert(data.responseJSON.message);
		   			start_game();
				}
			});
		}
	});

	function end_game(){
		game_ended = true;
		game_started = false;
		$("#start_game").text("Volver al menu principal!");
	}

    function start_game(){
    	game_started = true;
    	selected_items = [];
    	total_selected = 0;
    	selectable_items = 1;
    	$("#start_game").text("Atacar!");
    	$("#title").text("Selecciona un objetivo:")
    	$("#start_game").hide();
    	$(".grid_cell").css("background-color", "white");
    	$(".grid_cell").data("selected", null);
    }

    if (game_status == "1"){
    	game_started = true;
    	start_game();
    }
});