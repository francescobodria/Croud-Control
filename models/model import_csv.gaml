model import_csv

global {
  file my_csv_file <- csv_file("../includes/test.csv",",");
  
  
  int grid_x_dimension <- matrix(my_csv_file).columns;
  int grid_y_dimension <- matrix(my_csv_file).rows;
  init {
    matrix data <- matrix(my_csv_file);
    ask my_gama_grid {
      grid_value <- float(data[grid_x,grid_y]);
      if (grid_value = 1){
      	color <- #blue;
      }
      if (grid_value = 2){
      	color <- #red;
      }
    }
  }
}

grid my_gama_grid width: 100 height: 100 {
}

experiment main type: gui{
  output {
    display map{
      grid my_gama_grid lines: #black;
    }
  }
}