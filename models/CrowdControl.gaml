/**
* Name: CrowdControl
* Authors: Bodria Francesco, Betti Lorenzo, Bruno ?
* Description: Agent Based model for modelling crowd behaviour
* Tags: 
*/

model CrowdControl

//variabili accessibili a tutti gli agenti durante la simulazione 
global {
	//definizione del file da importare
	file my_csv_file <- csv_file("../includes/test.csv",",");
	//calcolo dimensioni griglia
	int grid_x_dimension <- matrix(my_csv_file).columns;
    int grid_y_dimension <- matrix(my_csv_file).rows;
    //creazione geometria rettangolo con le dimensioni della griglia
	geometry shape <- envelope(rectangle(grid_x_dimension,grid_y_dimension));
	
	//variabile per il numero di persone settata inizialmente a meta della sqrt dell'area
	int number_of_people <- round(sqrt(grid_x_dimension*grid_y_dimension)/2);
	
	// init: viene fatto girare solo all'inizio del'programma
	init {
		write number_of_people;
		// loading dei dati nella matrice per uscite e muri
		matrix data <- matrix(my_csv_file);
		//Creation of the wall and initialization of the cell is_wall and is_exit attributes
    		ask cell {
    			//carico il valore
    			grid_value <- float(data[grid_x,grid_y]);
    			//se è 1 è un muro 
      		if (grid_value = 1){
      			color <- #blue;
      			is_wall <- true;
      			}
      		// se è 2 è un uscita
      		if (grid_value = 2){
      			color <- #red;
      			is_exit <- true;
      			}
      			}
		// lista delle celle libere che non sono muri su cui metteremo gli agenti
		list<cell> free_cells <- cell where ((each.is_free) and not (each.is_wall));
		
		//creazione specie people
		create people number: number_of_people {
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
		draw circle(0.4) color: #black;
	}
	reflex move {
		//lista di vicini per debug
		possible_cell <- one_of(current_cell.neighbors where (not (each.is_wall)));
		// il print in gama è write
		//write possible_cell;
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
grid cell width: grid_x_dimension height: grid_y_dimension neighbors: 4 {
	rgb color <- #white;
	bool is_wall <- false;
	bool is_exit <- false;
	bool is_free <- true;
} 


//main loop che viene fatto girare ad ogni ciclo
experiment Main type: gui {
	//slider numero di persone
	parameter "numero di persone" var:number_of_people;
	output {
		display map {
			grid cell lines: #black;	
			species people aspect: default ;
		}
	}
}


