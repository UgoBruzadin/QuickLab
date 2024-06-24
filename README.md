This is an EEGLAB plugin. 

I dreamed of a day when I did not have to interact with prompts while using EEGLAB. As I created newer and newer functions, and modified EEGLAB original scripts, I made this dream come true! This plugin is a love letter to EEGLAB, and what EEGLAB UI could be. 

The original idea was to run EEGLAB functions quickly, without having to interact with prompts. It turnout to be much more. It contains an extremely modified version of EEG scroll plot + and TBT plugins. I recreated an UI were one can perform most EEGLAB functions at an EEG data without leaving the data scroll, and without having to interact with prompts!

The Data Scroll Pro is primarily useful for people with small datasets with low channels and low epochs, that need desperate cleaning hat can't be done automatically. This allows you to clean each file meticulosuly, removing any and all artifacts.
It can also help you learn about your dataset, and teach students how to clean and dataset and what a clean and dirty dataset look like.

Here's an example:

![image](https://github.com/UgoBruzadin/QuickLab/assets/25592470/3580f188-1f37-42ba-952c-fe187d63b558)

Here’s a short list of functionalities added compared to Scrollplot and Scrollplot+

- Toggle between channel and component data (keyboard: W)
- Toggle between rejection and interpolation (keyboard: S)
- Scroll in data right or left (keyboard right: D, left A)
- Go to the beginning and ending of the data (Kb: Q start E: end)
- Normalize data (Kb: R)
- Left click selects an epoch for rejection (red) or interpolation (green)
- Right click selects a channel for interpolation (no channel rejection in this mode)
  - For full interpolation: right click channel outside of any selected epoch.
  - For partial interpolation: right click inside green selected epochs.
  - Kb: Z on a channel select mouse-hovered channel for rejection, regardless or whether there are epochs selected or not.
  - IMPORTANT: One can perform partial of COMPONENTS. This is extremely useful for components with unique spikes and data with small ranks (low number of components). It allows one to keep the max data rank while removing artifacts identified by the components.
  - It's quite simple: I reject the components, but just for that selected epoch. This way, the rank is mostly untouched and the data is cleaner. Sometimes you can even GAIN rank, depending on how many components you have below the true data rank.
- Middle click: display the headmodel at the clicked time on the right panel.
  - Kb: V, B, N, M, H, G: display various headmodel based on V: epoch Variance, B: epoch Std, N:Mean, M: MeanLog10, H: Variance difference from the rest of the data, G: Variance of the whole data.
  - These options will help you see if this epoch is trouble or not, and what channels are creating the trouble.
  - Headmodel and Data Matrix will trade with each other without any hiccups. 
- Right panel: 
1. All data information displayed on top: Channel - Reference, Frames - Frame-Rate, Epochs - Events, Start and end of epoch, ICA (Number of Components) - Max Rank
1. Added Arrows to advance to start and end of file
1. Added Quick way to change the number of channels to display
1. Select Library of Functions to perform
   1. TBT
      1. A library of functions that select, trial by trial, based on Abnormal values (and all other EEGLAB trial rejection options) and based on given attributes, to reject or interpolate channels and epochs.
      1. You can change the percentage of trials that require a Channel to be fully interpolated
      1. You can change the number of channels on an epoch that selects that epoch for rejection (instead of interpolating the channels)
      1. Detect flat line, a function from Cleanline, selects channels that are flat.
      1. Detect channel pops is a function that I made. It allows you to run a moving window and detect changes in data variation, based on mean, std, etc. It’s very simple, very weird, but may be useful to detect channel spikes. Here are the variables:

         0. Size of window in bins/pnts
         0. Number of standard deviations from that epoch (is it weird IN this epoch?)
         0. Max Rej. window: A maximum size of change window. Helps reduce rejection of slow channels or Alpha/Theta waves. If the “spike” change is larger than 100 bins (default) it will consider it a normal change, not a spike.
         0. Select specific channel or components . [] = all chans/comps
         0. Options: select between mean, median, std. dev, and a few more options. 
         0. In conclusion, it identifies channels that have high mean (or median) velocity/acceleration of change that surpass a number of standard deviations based on that window, based on that epoch. I.e. spike detection.
   1. QuickLab
      1. ICA

         0. Number of components, [] for max rank
         0. Icatype
         0. Display components with viewprops+: 0 or 1
      1. BSS EMG (from AAR library)

         0. Window size and window shift
      1. Re-reference (beta)

         0. Select a channel to reference to, or select AVG LE or Original (beta)
      1. Re-epoch (beta)

         0. Time 1 and time 2
      1. DipFit(par)

         0. Number of components, number of dipoles (1 or 2)
      1. Any script

         0. This is marvelous: run ANY SCRIPT on the current data. Have a function that you want to run? Copy, paste, and run. As long as it outputs EEG, it will work.
   1. IClabel
      1. Runs all IClabel functions for component rejection. The best one is all but brain at 80% or more. This can be used for a quick and dirty cleaning of a data.
   1. QuickLab plots: 
      1. For more nuanced selection of plots of FFTs, IClabel, or Component ERP
- A matrix displaying currently selected channels and epochs for interpolation and rejection:
  - Red vertical lines: epoch rejection
  - Green vertical lines: epoch selected for interpolation
  - Black lines: partial channels to be interpolated in each epoch
  - Yellow lines: full channel interpolation
  - You can click on a highlighted epoch and it will take you to that epoch!
- Right panel buttons: 
  - Apply Changes:
    - Runs a program (eegrej\_adv) that interpolates and reject and selected channels OR components (it does not run both at the same time). It saves a backup of the file with all selections, and creates a new file with a small description of changes made (number of channels, components, and epochs rejected).
  - FFT(avg): allows you to click on a time and it will display the headmodel at that time.
  - IClabel: runs IClabel and opens Viewprops+, which has been modified to allow you to select components for rejection by click the tick box OR by clicking on the headmodel
    - Viewprops+ plots ALL components at once, in parallel (if par is available)
    - You can save components to use on CORRMAP
    - You can reject components and run a PCA reducing number of components by 1
    - Plotted components have the option for time-frequency display
    - Dipfitted components have the strongest BA area at the name
    - Plot the component scroll
  - Show ICA/Show Channel: toggle between ICA and Channel data
  - Hide Epoch: If data is epoched, you can toggle the epoch display on or off. 
    - It doesn’t remove the epoching, just display the data AS IF it is not epoched. 
    - This allows one to interpolate spikes of data that are smaller than an epoch, if necessary.
    - Useful to interpolate components that have very sharp and unique spikes that are dominating the component
  - Interpolation Mode/Rejection Mode: toggle between interpolation and rejection.
  - Load file from Folder: This is a list of all files in the folder. Changing this will RELOAD eegplot\_adv and a new file will be displayed. 
  - Enter text to Add to Filename: Adding text here, then pressing Save File with Text, will automatically save the file, at the file’s folder, with the added text at the end. This way you can continue processing the data now in a new file, with a new add-on.
  - Transfer to EEGLAB: reloads the current file in EEGLAB’s original UI.
- Events have been changed: now you can toggle events on and off. This only removes the display of the events, not the events themselves.
- All EEGLAB tabs are added to the UI. This theoretically allows one to perform Any EEGLAB operation on the current data. This may not work all the time, not all functions work. Some functions with display may crash, but as far as I can tell, most common functions will work. These functions are encapsulated in a way that eegplot\_adv collects the EEG output from the EEGLAB functions and plots in the UI. I have not tested all of them, so they may break. Keep me updated with any bugs and we’ll find a way to work around.

Quicklab contains a lot of other functions. Here are some:

- Edit QuickLab defaults: Not an exhaustive list, but I added here a way to change the majority of the defaults of QuickLab. It’s supposed to be suitable for anyone and anyone’s defaults, so that you can process your dataset as quickly as possible.
- Quick Plots: Viewprops + and FFT +, as described above.
- Other: 
  - FFT plots using LE or default reference. I only plot FFT using average reference as it is the most useful. LE needs to be set in default, it also may not work
  - ERP plots+. This allows one to plot the ERP of every component, projected to a specific channel and selected from a specific event. If you need to see your components in ERP style, this is the way. Not very useful, but can give an interesting perspective on a dataset.
  - Quick PCA: This just run a PCA using the default function (CUDAICA or BINICA or whatever you set on Quicklab Defaults). I have non-exhaustive list to quickly run a PCA from the menu without having to interact with ANY prompts.
  - BSS menu: the defaults BSS from AAR library is incorrect and breaks the data. Here you can select to run BSS selected every 2 epochs, the full file, or full file in parallel. Basically, when BSS runs in anything BUT full file, Components become very inconsistent as they are partially rejected based on, say, every 2 epochs. Full file is the most consistent one, but it is slow, so I also added a parallel version – which runs super-fast.
  - Quick Channel Edit: 
    - Re-reference data to AVG
    - Reduce channels (ignore): my personal scripts for my dissertation where I removed channels from below the crown.
    - Quick Filter: Let’s you quickly run a highpass or lowpass on the data, without any prompts.
  - Quick Epoch Edits:
    - Re-epoch data every X seconds. No prompts.
    - Un-epoch data: a simple script that removed the epoching on the data. This can be useful in special circumstances.
  - Quick Corrmap:
    - My own version of CORRMAP. This is made to be run on individual files. The idea is simple: You can select topoplots from components using the viewprops+. Save them in a folder. Then, you can run the corrmap rejection here. My version of Corrmap is SUPER fast, but can’t be run on STUDY as far as I know.
    - Maps are saved in folders based on number of channels, and only run the corrmaps in the correct folder for that number of channels you selected.
    - Runs in parallel if available.
  - Quick Parallel Processes: Here, DipFit 1 or 2 dipoles is re-written to be run in parallel. Again, runs super-fast, with no prompts.


