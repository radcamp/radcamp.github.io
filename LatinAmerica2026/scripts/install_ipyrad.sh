#!/bin/bash

echo "**************************"
echo "Installing conda miniforge"
echo "**************************"

cd ~
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh -b -u -p ./miniconda3

echo "***************************"
echo "Creating ipyrad environment"
echo "***************************"

source ~/miniconda3/bin/activate
conda create -n ipyrad -c conda-forge -y
conda activate ipyrad

conda env list

echo "*****************"
echo "Installing ipyrad"
echo "*****************"

conda install -c conda-forge -c bioconda numpy ipyrad fastqc scikit-learn toytree raxml -y

echo "*************************"
echo "Installing jupyter kernel"
echo "*************************"

python -m ipykernel install --user --name=ipyrad

echo "conda activate ipyrad" >> ~/.bashrc