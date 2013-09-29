Simulate & Analyse Toolkit (SAT)
================================

COMPILATION
-----------

The code runs from the source directory. The compilation is a two step process.
First, you need to compile libraries using standard:

./configure
make

To explore the list of compilation options we recommend running "./configure
--help" first.  Second, you choose what simulation you want to work with in the
sat/simul directory and compile the the simulation executable using:

make NAME_OF_EXECUTABLE

where NAME_OF_EXECUTABLE is a binary name. You can find the name of execublaes
in the Makefile.am file (e.g. inst1d, inst2d, herm, khbox, ...).
