
## Directories ##


code
  VHDL sources specific for TRB3sc

cores
  Ipexpress cores specific to TRB3sc

pinout
  Pinout for all design as well as basic constraints present in all designs

scripts
  E.g. the compile script to be used for all TRB3sc projects and configuratioon files for these scripts

template
  A basic design with all global features, should be used as template for own designs, but can be used as-is for tests
  

  
## Preparation ##
  - a config_compile_NAME.pl file is needed for each project and environment in the project directory
  - for multipar, add a nodelist to the scripts directory
  - link both the nodelist and the compile script to your project directory