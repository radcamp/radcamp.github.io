cd ~
git clone https://github.com/sanger-pathogens/assembly-stats.git
cd assembly-stats
mkdir build
cd build
cmake ..
make
make test
make install
