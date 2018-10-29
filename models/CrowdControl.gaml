/**
* Name: CrowdControl
* Authors: Bodria Francesco, Betti Lorenzo, Chicci Lorenzo
* Description: Agent Based model for modelling crowd behaviour
* Tags: 
*/

model CrowdControl

//variabili accessibili a tutti gli agenti durante la simulazione 
global {
	//file csv della mappa
	file file_mappa <- csv_file("../includes/mappa.csv",",");
	//file csv contenente il gradiente  
	file file_distanza_uscita <- csv_file("../includes/distanza_uscita.csv",",");
	
	//calcolo dimensioni griglia
	int grid_x_dimension <- matrix(file_mappa).columns;
    int grid_y_dimension <- matrix(file_mappa).rows;
    //creazione geometria rettangolo con le dimensioni della griglia
	geometry shape <- envelope(rectangle(grid_x_dimension,grid_y_dimension));
	
	//variabile per il numero di persone settata inizialmente a meta della sqrt dell'area
	int number_of_people <- 1;//round(sqrt(grid_x_dimension*grid_y_dimension)/2);
	//coeffieciente statico
	float ks <- 1.0;
	//coefficiente dinamico
	float kd <- 1.0;
	//coefficiente scommessa
	float k <- 1.0;
	//evaporazione per ciclo
	float evaporation_per_cycle <- 0.1;
	//seed lasciato dall'agente
	float ferormone <- 1.0;
	//valore massimo distanza sulla griglia
	int m <- int(max(matrix(file_distanza_uscita)));
	
	// init: viene fatto girare solo all'inizio del'programma
	init {
		//write m;
		// loading dei dati nella matrice per uscite e muri
		matrix data <- matrix(file_mappa);
		matrix data1 <- matrix(file_distanza_uscita);
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
      		//imposta il campo scalare
      		static <- float(data1[grid_x,grid_y]);
      		
      			}
		// lista delle celle libere che non sono muri su cui metteremo gli agenti
		list<cell> free_cells <- cell where ((each.is_free) and not (each.is_wall));
		
		//creazione specie people
		create people number: number_of_people {
			panic <- true;
			current_cell <- one_of(free_cells);
			location <- current_cell.location;
			current_cell.is_free <- false;
			remove current_cell from: free_cells;
			
		}		
	
	}
	
	reflex diffuse{
		diffuse var:dinamic on:cell proportion:1 radius:1 propagation:gradient ;		
	}	

}

// specie di agenti 
species people {
	cell current_cell;
	cell possible_cell;
	bool panic;
	aspect default {
		draw circle(0.4) color: #black;
	}
	
	reflex move when: panic = true{
		//lista contenente tutti i vicini
		list<cell> neigh <- current_cell.neighbors;
		//lista delle probabilità da calcolare
		list<float> probability <- list_with(length(neigh),0.0);
		//ciclo for per il calcolo delle probabilità
		loop i from: 0 to: length(neigh)-1 {
			//lista vuota se non c'è agente nel vicino o con un elemento se c'è qualcuno
			list<agent> neigh_in_cell <- agents_inside(neigh[i]);
			float epsilon <- 1.0;
			if length(neigh_in_cell) = 1{
				epsilon <- k;
			}
			//se non è un muro calcola la probabilità
			if not neigh[i].is_wall {
				probability[i] <- exp(-(1-current_cell.static/(2*m))*ks*(neigh[i].static))*exp(current_cell.static/(2*m)*kd*neigh[i].dinamic)*epsilon;
			}
		}
		//normalizzazione della probabilità
		float norm <- sum(probability);
		
		loop i from: 0 to: length(neigh)-1{
			probability[i] <- probability[i]/norm;
			
		}
		//scelta della cella su cui voglio andare
		int cell_choosen <- rnd_choice(probability);
		possible_cell <- neigh[cell_choosen];
		//lista di vicini per debug
		// il print in gama è write
		//write possible_cell;
		// setta le due variabili per il movimento
		if (possible_cell.is_free = true and possible_cell.is_wall = false) {
			current_cell.dinamic <- current_cell.dinamic + ferormone;
			current_cell.is_free <- true;
			current_cell <- possible_cell; 
			location <- current_cell.location;
			current_cell.is_free <- false;
		}
		//se sono all'uscita imposto la cella libera e crepa
		if current_cell.is_exit{
			current_cell.is_free <- true;
			do die;
		}	
	}
}

//specie cella
grid cell width: grid_x_dimension height: grid_y_dimension neighbors: 4 {
	bool is_wall <- false;
	bool is_exit <- false;
	bool is_free <- true;
	float static <-  0.0;
	float dinamic <- 0.0 min: 0.0 update: dinamic-evaporation_per_cycle;
	rgb color <- hsb(0.0,dinamic,1.0) update: hsb(0.0,dinamic,1.0);	
} 


//main loop che viene fatto girare ad ogni ciclo
experiment Main type: gui {
	//slider numero di persone
	parameter "numero di persone" var:number_of_people ;
	parameter "ks" var:ks; 
	parameter "kd" var:kd;
	parameter "ferormone" var:ferormone;
	parameter "evaporation" var:evaporation_per_cycle min:0.0 max:1.0 step:0.02;
	parameter "k (scommessa)" var:k;
	output {
		display map {
			grid cell lines: #black;
			species people aspect: default ;
		}
	}
}


