% Read-me file for the Signals Approach Toolbox.
% Developed by Spencer Lynn, spencer.lynn@gmail.com
% 
% Installing a SIGNALS experiment
% (1) Install Matlab
% (2) Install Psychophysics Toolbox (http://psychtoolbox.org/)
% (3) Add satoolbox to your Matlab path using the "Add with subfolders" option.
% 
% 
% Notes:
% 
%% 12/6/10 - 2/2011 Coding for SAtb v3
% Coded to:
% - send triggers/event codes in show_stim, improve readlist, eliminate writedata, new list file format + read_list, passing single trial_info vector rather than entire stiminfo array.
% - So, new versions of read_stim/list, load_stim, show_stim, set_params, fetch_signal, and many other files.
%     
% To do:
% - bring CFS components into toolbox (ie, separate stereo channels in show_stim)
% 
%% 9/18/09
% Organized mFiles into folders, added quality control and data processing code.
% 
%% 6/14/09 v2.2
% Pretty much done with modifications for SIG3 ("pilot2")
% - added tune_stimdur
% - added preloading of masks, and stim in fetchsignal (1/15/11 fetchsignal was deprecated by fetch_signal for sig3p3 (w/ no preloading).
% - separated initializers.m from init_prb.m
% - fixed double key-press/invalid key crashes (I think)
% - moved xSignal to fetchsignal...still need to clean up
% 
%% 4/13/09 v2.1
% Working on modifications for SAP3/sig3. 
% - Moved some deprecated files into SAP2 folder, renamed with SAP2-prefix.
% 
%% 2/16/09 SAtb v2
% Dev for SAP2 is done...only a couple bug fixes follow. (except for Windows-SP3 issues). Beginning dev for SAP3.
% 
%% 20 Jan 09
% crashing in Windows
% - appears to be an XP svc pack 3 issue?!
% - issue has resolved itself by Sept 2010 when moved to NEU and testing computers have SP3 installed.
% 
%% 11-30-08 SAtb v1
% set version working w/out key lists for SAP1 btw-subj version
% - old versions of callblock,decision_outcome,showstim, renamed with sap1-prefix
%
%% ------ End -------
