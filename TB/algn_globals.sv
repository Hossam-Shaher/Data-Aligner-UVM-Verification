`ifndef ALGN_GLOBALS_SV
  `define ALGN_GLOBALS_SV

  //Enumerations

  typedef enum bit 		{APB_READ = 0, 	APB_WRITE = 1} 	apb_dir_t;
  typedef enum bit 		{APB_OKAY = 0, 	APB_ERR = 1} 	apb_response_t;
  typedef enum bit 		{MD_OKAY = 0, 	MD_ERR = 1} 	md_response_t;


`endif	//ALGN_GLOBALS_SV