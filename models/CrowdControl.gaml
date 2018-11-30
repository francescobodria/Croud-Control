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
	int number_of_people <- 1000;//round(sqrt(grid_x_dimension*grid_y_dimension)/2);
	int number_of_initial_people <- number_of_people;
	//coeffieciente statico
	float ks <- 1.0;
	//coefficiente dinamico
	float kd <- 1.0;
	//coefficiente scommessa
	float k <- 1.0;
	//evaporazione per ciclo
	float evaporation_per_cycle <- 0.12;
	//seed lasciato dall'agente
	float ferormone <- 1.0;
	//valore massimo distanza sulla griglia
	int m <- int(max(matrix(file_distanza_uscita)));
	bool run <-false;
	bool force <- false;
	bool think <- true;
	int R <-0;
	int n<-10;
	float Fmax <- 0.7;
	float soglia <- 3.0;
	

	
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
      			color <- #green;
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

	// quando non ci sono più persone salva il numero di cicli effettuati fino ad ora in un file txt e termina la simulazione
	reflex save_result when: (number_of_people=0){
		save (string(cycle)+' '+string(evaporation_per_cycle)+' '+string(number_of_initial_people)) to: "tempo_di_uscita.txt" type:"text" rewrite: false;
		do die; 
	}
	//reflex save_result_2 when: (cycle = 2000 #cycles){
	//	save (string(cycle)+' '+string(evaporation_per_cycle)+' '+string(number_of_initial_people)) to: "tempo_di_uscita.txt" type:"text" rewrite: false;
	//	do die; 
	//}
}

// specie di agenti 

species people {
	rgb color <- #black;
	cell current_cell;
	cell possible_cell;
	bool panic;
	list<float> direzione <- [0.0,0.0,0.0,0.0];
	list<float> forza <-[0.0,0.0,0.0,0.0];
	float danno;
	float debug;
	bool force_driven <- false;
	aspect default {
		draw circle(0.4) color: color;
	}
	
	reflex move when: run = true{
		// setta le due variabili per il movimento
		
		//calcolo la somma delle forze verticali e orizzontali. N.B: se vertical>0 vuol dire che sono spinto più verso nord che verso sud.
		// se horizontal >0 vuol dire che sono spinto più verso est che verso ovest.
		
		let vertical <- self.forza[0]-self.forza[2];
		let horizontal <-self.forza[1]-self.forza[3];
		self.color <- #black;
		self.force_driven <- false;
		self.debug <- vertical;
		
		//se uno dei due supera la soglia valuto chi è il max e dal segno capisco se vengo spinto verso ovest, est, nord,sud. Imposto quindi possible cell sul valore nuovo.
		if (abs(vertical)> Fmax or abs(horizontal)> Fmax){
			self.color <- #red;
			self.force_driven <- true;
		
			if (abs(vertical)> abs(horizontal)){
				possible_cell <- cell({current_cell.grid_x,current_cell.grid_y-signum(vertical)});
			}
			if (abs(vertical)< abs(horizontal)){
				possible_cell <- cell({current_cell.grid_x+signum(horizontal),current_cell.grid_y});
			}
			if (abs(vertical)= abs(horizontal)){
				let r <- rnd(0.0,1.0);
				if (r<1/2){
				possible_cell <- cell({current_cell.grid_x+signum(horizontal),current_cell.grid_y});					
				}
				if (r>=1/2){
				possible_cell <- cell({current_cell.grid_x,current_cell.grid_y-signum(vertical)});
				}
	
			}
		
		// assegno il danno. potremmo pensare di assegnarlo solo nel caso in cui l'agente trovi la cella di arrivo occupata, ovvero non riesce a spostarsi.
		if (possible_cell.is_free = false or possible_cell.is_wall = true) {
		danno <- forza[0]+forza[1]+forza[2]+forza[3];
		}
		
		if danno >= soglia{
			
			if R= number_of_people-1 {		
				R<-0;
		
			if think = true {
			//write('think');
			force<-true;
			think <- false;
			}
			else if force = true {
				//write('force');
				run <-true;
				force<-false;
				}
			else if run = true {
				//write('run');
				run <-false;
				think <- true;
				}
		
			}
			
			number_of_people <- number_of_people-1;
			
			current_cell.is_free <- false;

			current_cell.color <- #red;
			
			do die;
		} 
		
		//se sono all'uscita imposto la cella libera e crepa
		
		}
		if (possible_cell.is_free = true and possible_cell.is_wall = false) {
			current_cell.dinamic <- current_cell.dinamic + ferormone;
			current_cell.is_free <- true;
			current_cell <- possible_cell; 
			location <- current_cell.location;
			current_cell.is_free <- false;
		}
		
		//manca morte
		//forze a zero per ciclo dopo
		self.forza <- [0.0,0.0,0.0,0.0];
		
		
	
	}	
	
	
	
	reflex push when: force = true{
		
		//aggiorno le forze da nord:
		
		loop i from: 1 to: n {
			
		//aggiorno le forze da nord::
		
		if (current_cell.grid_y-i>0){
			
			list<agent> nord <- agents_inside(cell({current_cell.grid_x,current_cell.grid_y-i}));
			 
			 if length(nord)!=0{
			  	let no <- attributes(nord[0])['direzione']; 			 	
			  	if no= [0.0,0.0,1.0,0.0]{
			  		self.forza[2] <- self.forza[2]+1/i;	 
			 	}
			 }
			 else {
			 	break;
			 }
			 
		}
		
		}
			
		loop i from: 1 to: n {
			
		//aggiorno le forze da sud:
		
		if (current_cell.grid_y+i<grid_y_dimension){
			
			list<agent> sud <- agents_inside(cell({current_cell.grid_x,current_cell.grid_y+i}));
			 
			 if length(sud)!=0{
			  	let su <- attributes(sud[0])['direzione']; 			 	
			  	if su= [1.0,0.0,0.0,0.0]{
			  		self.forza[0] <- self.forza[0]+1/i;	 
			 	}
			 }
			 else {
			 	break;
			 }
			 
		}
		
		}
		
		loop i from: 1 to: n {
			
		//aggiorno le forze da est:
		
		if (current_cell.grid_x+i<grid_x_dimension){
		
			list<agent> est <- agents_inside(cell({current_cell.grid_x+i,current_cell.grid_y}));
			 
			 if length(est)!=0{
			  	let es <- attributes(est[0])['direzione']; 			 	
			  	if es= [0.0,0.0,0.0,1.0]{
			  		self.forza[3] <- self.forza[3]+1/i;	 

			 	}
			 }
			 else {
			 	break;
			 }
			 
		}
		
		}
			
		loop i from: 1 to: n {	
		
		//aggiorno le forze da ovest:
		if (current_cell.grid_x-i>0){
		list<agent> ovest <- agents_inside(cell({current_cell.grid_x-i,current_cell.grid_y}));
			 
			 if length(ovest)!=0{
			  	let ov <- attributes(ovest[0])['direzione']; 			 	
			  	if ov= [0.0,1.0,0.0,0.0]{
			  		self.forza[1] <- self.forza[1]+1/i;	 
			 	}
			 }
			 else {
			 	break;
			 }
		
		}
	
		}
		
	}	
	
	reflex choose when: think = true {
		
		if current_cell.is_exit{
			current_cell.is_free <- true;
			
			if R= number_of_people-1 {		
				R<-0;
		
			if think = true {
			//write('think');
			force<-true;
			think <- false;
			}
			else if force = true {
				//write('force');
				run <-true;
				force<-false;
				}
			else if run = true {
				//write('run');
				run <-false;
				think <- true;
				}
		
			}
			
			number_of_people <- number_of_people-1;
			do die;
		}
		
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
		
		//associa vettore direzione alla scelta fatta
		// [N,E,S,W]
		if possible_cell.grid_x = current_cell.grid_x+1{
			self.direzione <- [0.0,1.0,0.0,0.0];
		}
		if possible_cell.grid_x  = current_cell.grid_x -1{
			self.direzione <- [0.0,0.0,0.0,1.0];
		}
		if possible_cell.grid_y  = current_cell.grid_y +1{
			self.direzione <- [0.0,0.0,1.0,0.0];
		}
		if possible_cell.grid_y  = current_cell.grid_y -1{
			self.direzione <- [1.0,0.0,0.0,0.0];
		}
	
	}
	
	
	reflex count {
		
		if R= number_of_people-1 {		
			R<-0;
		
			if think = true {
			//write('think');
			force<-true;
			think <- false;
			}
			else if force = true {
				//write('force');
				run <-true;
				force<-false;
				}
			else if run = true {
				//write('run');
				run <-false;
				think <- true;
				}
		
			}
		else{
			R <- R+1;
		
		}
	
	}
	
	}	


//specie cella
grid cell width: grid_x_dimension height: grid_y_dimension neighbors: 4 {
	rgb color <- #white;
	bool is_wall <- false;
	bool is_exit <- false;
	bool is_free <- true;
	float static <-  0.0;
	float dinamic <- 0.0 min: 0.0 update: dinamic-evaporation_per_cycle;
	//rgb color <- hsb(0.0,dinamic,1.0) update: hsb(0.0,dinamic,1.0);	
} 


//main loop che viene fatto girare ad ogni ciclo
experiment Main type: gui autorun:true{
	//scommentare in caso di salvataggio immagini
	//float minimum_cycle_duration <- 0.1;
	int number_of_simulations <- 1;
	//slider numero di persone
	parameter "numero di persone" var:number_of_people ;
	parameter "ks" var:ks; 
	parameter "kd" var:kd;
	parameter "ferormone" var:ferormone;
	parameter "evaporation" var:evaporation_per_cycle;
	parameter "k (scommessa)" var:k;
	parameter "F max" var:Fmax;
	parameter "n" var:n;
	parameter "soglia_morte" var:soglia;
	
	//crea multiple simulazioni con random seed differenti
	init {
		if number_of_simulations > 1{
			loop i from: 1 to: number_of_simulations-1{
				create simulation with:[evaporation_per_cycle::0.12+i/100];
			} 
		}
		
	}
	output {
		//scommentare autosave se si vogliono salvare le immagini ogni 3 cicli, scommentare anche poco più sopra minimum cycle duration per un salavataggio migliore
		display map refresh: every(3 #cycles){// autosave:every(3 #cycles){
			grid cell lines: #black;
			species people aspect: default ;
		}
	}
}


