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
		create people number: 1 {
			current_cell <- one_of(cell);
			location <- current_cell.location;
		}		
	}
}

// specie di agenti 
species people skills: [moving] {
	cell current_cell;
	aspect default {
		draw circle(4.8) color: #black;
	}
	reflex move {
		//lista di vicini per debug
		list<cell> possible_cells <- current_cell.neighbors ;
		// il print in gama è write
		write possible_cells;
		// setta le due variabili per il movimento
		current_cell <- one_of(shuffle(current_cell.neighbors));
		location <- current_cell.location;
	}

}

//specie cella
grid cell width: 10 height: 10 neighbors: 4 {
	rgb color <- #white;
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


