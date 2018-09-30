/**
* Name: CrowdControl
* Authors: Bodria Francesco, Betti Lorenzo, Bruno ?
* Description: Agent Based model for modelling crowd behaviour
* Tags: 
*/

model CrowdControl

//variabili accessibili a tutti gli agenti durante la simulazione 
global {
	// carico gli shape file per il perimetro della piazza e le uscite
	file wall_shapefile <- shape_file("../includes/wall_2.shp");
	file exit_shapefile <- shape_file("../includes/exit_2.shp");
	geometry shape <- envelope(wall_shapefile);	
	
	// init: viene fatto girare solo all'inizio del'programma
	init {
		//Creation of the wall and initialization of the cell is_wall attribute
		create wall from: wall_shapefile {
			ask cell overlapping self {
				is_wall <- true;
			}
		}
		//Creation of the exit and initialization of the cell is_exit attribute
		create exit from: exit_shapefile {
			ask (cell overlapping self) where not each.is_wall{
				is_exit <- true;
			}	
		}
		
		list<cell> free_cells <- cell where ((each.is_free) and not (each.is_wall));
		
		create people number: 2300 {
			current_cell <- one_of(free_cells);
			location <- current_cell.location;
			current_cell.is_free <- false;
			remove current_cell from: free_cells;
		}		
	
	}

}

// specie di agenti 
species people {
	cell current_cell;
	cell possible_cell;
	aspect default {
		draw circle(0.8) color: #black;
	}
	reflex move {
		//lista di vicini per debug
		possible_cell <- one_of(current_cell.neighbors);
		// il print in gama è write
		write possible_cell;
		// setta le due variabili per il movimento
		if (possible_cell.is_free = true and possible_cell.is_wall = false) {
			current_cell.is_free <- true;
			current_cell <- possible_cell;
			location <- current_cell.location;
			current_cell.is_free <- false;
		}	
	}
}
//specie cella
grid cell width: 50 height: 50 neighbors: 4 {
	rgb color <- #white;
	bool is_wall <- false;
	bool is_exit <- false;
	bool is_free <- true;
} 

//Species exit which represent the exit
species exit{
	aspect default {
		draw shape color: #blue;
	}
}
//Species which represent the wall
species wall{
	aspect default {
		draw shape color: #black depth: 1;
	}
}
//main loop che viene fatto girare ad ogni ciclo
experiment Main type: gui {
	
	output {
		display map type: opengl{
			grid cell lines: #black;
			species wall refresh: false;
			species exit refresh: false;			
			species people aspect: default ;
		}
	}
}


