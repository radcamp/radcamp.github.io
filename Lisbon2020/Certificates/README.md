# Creating certificates from this template

In order to create participants' certificates from this template you need some chell magic:

```bash
IFS=$'\n'       # make newlines the only separator

mkdir Certs
mkdir PDF_certs

for i in $(cat name_list.txt)                                           130
do
sed "s/NAME_HERE/${i}/" Certificate_template.svg > Certs/${i}_Certificate.svg
done

cd Certs

for i in *.svg                                                          130
do
convert ${i} ../PDF_certs/${i:0:-3}.pdf
done
```

Where `name_list.txt` is a file with participants' names, one per line.
