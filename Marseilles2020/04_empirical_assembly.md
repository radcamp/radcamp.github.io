
pinch from NYC2018

## Form small groups and assemble practice data
* `cd fastq_out`
* Run fastqc on on the real data, passing in the directory of the 3RAD data
for your group, which will be of the form `/media/RADCamp/<username>/raws/*R1*`
and `/media/RADCamp/<username>/raws/*R2*` replacing the username with the last
name of the participant in your group who generated 3RAD data (should take
5-10 minutes per file).
* Examine the results of fastqc by opening the
`~/ipyrad-workshop/<assembly-name>/fastqc_out/\*.html` files in the jupyter
notebook browser.
* Go back to the terminal and `cd ~/ipyrad-workshop/<assembly_name>`.
* Create a params file for the real data (`ipyrad -n <assembly_name>`).
* Update your params file as necessary including the correct
[overhang sequences](PartII-Overhangs.txt) and read trimming and adapter
filtering settings based on the results from fastqc.
* Also, based on preliminary anaylsis, set `max_barcodes_mismatch`
to 2.
* Launch ipyrad steps 1-7
