# Notes about automating FFT output of sleepsign. 
## Written by A. Fisk 2018-11  

**Problem:** As I'm sure everyone who has used sleepsign is 
aware, it's an absolute pain to sit there and
ask it to ouput each channel as an continuous 
FFT to analyse in the usual way the lab does.  
Therefore I managed to automate this process, 
it has many problems but I hope that it is a good 
start and it can be improved. 

Here follows a rough explanation/user guide for 
using the same implementation.  

### Instructions  

1. Download SikuliX (http://sikulix.com/). 
Follow their instructions to install.  
2. Get the script from github 
(https://github.com/A-Fisk/VVlab_Scripts)  
3. open SikuliX, open the scripts "FFT_output_create"  
4. Run the script!. It is buggy and can crash 
sometimes and if it's running for over 12 hours 
it crashes for me too.  
5. If it crashes just close SikuliX and sleepsign, 
figure out where in the file list you got to, set the 
file list index to start there and restart everything.


### Overview of implementation. 

I use an automating program called "SikuliX" which
allows me to write the script in python. 
The main steps are as follows:  
1. Define the directory to find the .raf files in  
2. Create a list with all those file names in it  
3. Open sleepsign.  
4. Go through the list of raf files and for 
each file:  
5. Open the file  
6. Select continuous FFT output  
7. Create a list of output channels and 
for each channel:  
8. Select just that channel  
9. Create the name of the output file from 
the name of the input file  
10. Save that channel for that animal  
11. Wait 15 minutes and go on to next channel/
animal. 

I hope that makes sense and the code seems obvious.

### Current problems.  
1. Creates single text file for each channel.  
	I know some of you have updated the script to 
work with all channels in a single file but I haven't 
done that yet. This means the script takes longer to 
process as it waits 15 minutes for each channel rather 
than 15 minutes per animal.  
2. SikuliX appears unstable. I built this script using 
v.1.1.3, which has since been updated to v1.1.4 and fixes 
some critical erros. The main error I saw was that the 
screenshots I had saved to define where to click 
sometimes disappeared from the folder.  
