/**
* Name: CrowdControl
* Authors: Bodria Francesco, Betti Lorenzo, Bruno ?
* Description: Agent Based model for modelling crowd behaviour
* Tags: 
*/

model CrowdControl

//variabili accessibili a tutti gli agenti durante la simulazione 
global {
	// init: viene fatto girare solo all'inizio del'programma
	init {
		list<cell> free_cells <- cell where (each.is_free);
		create people number: 95 {
			current_cell <- one_of(free_cells);
			location <- current_cell.location;
			current_cell.is_free <- false;
			remove current_cell from: free_cells;
		}		
	}
}

// specie di agenti 
species people skills: [moving] {
	cell current_cell;
	cell possible_cell;
	aspect default {
		draw circle(4.8) color: #black;
	}
	reflex move {
		//lista di vicini per debug
		possible_cell <- one_of(current_cell.neighbors);
		// il print in gama è write
		write possible_cell;
		// setta le due variabili per il movimento
		if (possible_cell.is_free = true) {
			current_cell.is_free <- true;
			current_cell <- possible_cell;
			location <- current_cell.location;
			current_cell.is_free <- false;
		}
		
	}

}

//specie cella
grid cell width: 10 height: 10 neighbors: 4 {
	rgb color <- #white;
	bool is_free <- true;
} 

//main loop che viene fatto girare ad ogni ciclo
experiment Main type: gui {
	output {
		display objects_display {
			grid cell lines: #black;
			species people aspect: default ;
		}
	}
}


