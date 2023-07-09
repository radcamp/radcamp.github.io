1. Install virtualbox for your OS: Virtualbox installers
2. Download the RADCamp virtualbox image
3. Start virtualbox and choose File->Import appliance, browse to the downloaded file, choose it and click 'Import'
4. The new image will appear in the left nav as RC-Kigali-server.
5. Right click, choose Run and wait for it to fire up (alternatively I prefer "Run headless" because it doesn't open the vm in a new window, as it is unnecessary)
6. Open a web browser on your computer and navigate to http://localhost:8800
7. This should present you with a jupyter notebook environment running inside the vm with all necessary packages installed (for the ipyrad/RADcamp part of the workshop)

If you want to actually log into the vm the username/password are:
uname: osboxes
passwd: osboxes.org
