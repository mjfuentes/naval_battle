$().ready(function(){
	var total_selected = 0;
	function createGrid(cell_amount, selectable_items) {
	    var ratioW = cell_amount,
	        ratioH = cell_amount,
	        cell_height = Math.floor(500/ratioH),
	        cell_width = Math.floor(500/ratioW);

	    var parent = $("#grid_container");

	    for (var i = 0; i < ratioH; i++) {
	        for(var p = 0; p < ratioW; p++){
	            var tile = $('<div />', {
	            	id: (i + 1)+"-"+(p +1),
	                width: cell_height - 1,
	                height: cell_width - 1
	            })
	            tile.click(function(){
	            	if(total_selected < selectable_items){
	            		$(this).css("background-color", "gray");
	            		total_selected++;
	            	}
	            })
	            tile.appendTo(parent);
	        }
	    }
	};
    createGrid(5,3);
});