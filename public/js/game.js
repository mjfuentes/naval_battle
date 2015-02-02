$().ready(function(){
	var total_selected = 0;
	var selected_items = []
	var selectable_items;
	var game_started = false;
	var game_size = $("#my_board").data("size");
	var game_id = $("#my_board").data("id");
	var player_id = $("#my_board").data("player");
	var rival_id = $("#my_board").data("rival");
	var game_status = $("#my_board").data("status");

	function createGrids() {
		if (game_size == "small") {
			cell_amount = 5;
			selectable_items = 7
		}
		else if (game_size == "medium") {
			cell_amount = 10;
			selectable_items = 15;
		}
		else {
			cell_amount = 15;
			selectable_items = 20;
		}
		
		parent = $("#rival_board_container");

	    var ratioW = cell_amount,
	        ratioH = cell_amount,
	        cell_height = Math.floor(500/ratioH),
	        cell_width = Math.floor(500/ratioW);


	    for (var i = 0; i < ratioH; i++) {
	        for(var p = 0; p < ratioW; p++){
	            var tile = $('<div />', {
	            	id: (i + 1)+"-"+(p +1),
	            	class: "grid_cell_rival",
	                width: cell_height - 1,
	                height: cell_width - 1
	            })
	        		tile.click(function(){
	            	$(".grid_cell_rival").css("background-color", "white");
	            	var indexes = $(this).attr('id').split('-');
	            	selected_items[0] = indexes;
            		$(this).css("background-color", "gray");
         			$("#attack").prop('disabled',false)
	            })
	            tile.appendTo(parent);
	        }
	    }

		parent = $("#my_board_container");
		var selected_positions = []
		if (game_started){
			$.ajax({
			   url: '/players/' + player_id + '/games/' + game_id + '/positions',
			   type: 'GET',
			   async: false,
			   success: function(data) {
					selected_positions = data.positions
				},
				error: function(data) {
					alert("Hubo un error al cargar la partida");
				}
			});
		}
	    for (var i = 0; i < ratioH; i++) {
	        for(var p = 0; p < ratioW; p++){
	            var tile = $('<div />', {
	            	id: (i + 1)+"-"+(p +1),
	            	class: "grid_cell",
	                width: cell_height - 1,
	                height: cell_width - 1
	            })
	            if (is_selected(selected_positions,[String(i+1),String(p+1)])){
	            	tile.css("background-color", "gray");
	            }
	            tile.click(function(){
	            	if (!game_started){
		            	var indexes = $(this).attr('id').split('-');
		            	if((total_selected < selectable_items) && ($(this).data("selected") == null)){
		            		$(this).data("selected",true);
			            	selected_items.push(indexes);
		            		$(this).css("background-color", "gray");
		            		total_selected++;
		            		if (total_selected == selectable_items){
		            			$("#start_game").prop('disabled',false)
		            		}
		            	}
		            }
	            })
	            tile.appendTo(parent);
	        }
	    }
	};

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
	});

	$("#attack").click(function(){
			$.ajax({
			   url: '/players/' + player_id + '/games/' + game_id + '/move',
			   type: 'POST',
			   data: {"position" : selected_items[0], "rival" : rival_id },
			   success: function(data) {
			   		if (data["code"] == 3) {
			   			alert("You win!");
			   			window.location.href = window.location.origin + '/index'
			   		}
			   		else if (data["code"] == 2){
			   			alert("You hit a ship!");
			   			location.reload();
			   		}
			   		else if (data["code"] == 1){
						alert("Water.");
			   			location.reload();
					}
				},
				error: function(data) {
					alert(data.responseJSON.message);
					if (data.responseJSON.code > 0) {
						window.location.href = window.location.origin + '/index'
					}
					else{
	   				start_game();
					}
				}
			});
	});

	function is_selected(all_pos, pos){
		for (key in all_pos) {
			if (all_pos.hasOwnProperty(key)){
					if ((all_pos[key][0] == pos[0]) && (all_pos[key][1] == pos[1])){
						return true
					}
			}
    	}
    	return false;
	}

	function end_game(){
		game_ended = true;
		game_started = false;
		$("#start_game").text("Volver al menu principal!");
	}

    function start_game(){
    	selected_items = [];
    	total_selected = 0;
    	$("#start_game").prop('disabled',true)
    	// $("#start_game").text("Atacar!");
    	$("#titulo").text("Choose a target:")
    	// $("#start_game").hide();
    	// $(".grid_cell").css("background-color", "white");
    	// $(".grid_cell").data("selected", null);
    }

   $("#start_game").prop('disabled',true)
   $("#attack").prop('disabled',true)

   if (game_status == "1"){
    	game_started = true;
    	start_game();
   }

	createGrids();

});