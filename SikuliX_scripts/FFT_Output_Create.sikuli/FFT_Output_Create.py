# Look through all the files and import into list
import glob 
import os

dir_name = "C:/P3_LLEEG_Chapter3"

dir_path = os.path.normpath(dir_name)

#find the files 
files_list = sorted(glob.glob(dir_path + '\\*\\*.raf'))

print (files_list)

#set the output channels
output_channels = ['-fro.txt',
                   '-occ.txt',
                   '-foc.txt']

output_dir = 'C:/P3_LLEEG_Chapter3/6_FFT'

output_path = os.path.normpath(output_dir)

# Open the SleepSign program
#define and open app
SleepSign_app = App(r'C:\Program Files (x86)\KISSEI COMTEC\SleepSign for Animal\SleepSign.exe')

SleepSign_app.open()


# open the correct file

for file in files_list[2:]:

    click("RAF.png")
    
    paste("file_name_box.png", 
            file)

    click("open_file_box.png")

    wait(5)

    # save the continuous FFT

    click("analysis_box.png")

    click("fft_output_box.png")
    click("continuous_fft_box.png")

    # create the output names 

    file_name = file[-22:-4]

    output_names = [(output_path + os.sep +  file_name + x) for x in output_channels]

    output_signals = ["signal_0.png",
                      "signal_1.png",
                      "signal_2.png"]

    # loop through and save the txt files in the right places
    for signal, file_name in zip(output_signals, output_names):

        click("select_channel_box.png")

        click("clear_signal_box.png")

        click(signal)

        click("signal_ok_box.png")

        click("path_box.png")

        click("output_path_box.png") 

        type("a", KEY_CTRL)
        
        type(Key.BACKSPACE)

        paste(file_name)

        click("output_save_box.png")

        click("start_output_box.png")

        wait(900)

        type(Key.ENTER)

    click("close_post_output.png")

    type("w", KEY_CTRL)
        
# create output, save
# create output file names
# loop through output file names and save 

