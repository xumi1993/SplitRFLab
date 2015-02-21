% PRIVATE
%
% Files
%   SL_cmtread           - Read earthquake database from Harvard-CMT catalogue and saves in SplitLab
%   SL_neic2mat          - Save earthquake catalogue data to read with Splitlab
%   calcEnergy           - calulate energy of SV wave for given mechanism 
%   calcphase            - calculate travel-times for earthquake
%   configpanelFINDFILE  - Station data
%   configpanelGENERAL   - the GENERAL panel
%   configpanelPHASES    - function  out = configPhases(cfig,pos)
%   configpanelSEARCHWIN - Magnitude
%   configpanelUSER      - field descriptions text
%   cutandsaveasSAC      - Cut multiple SAC files at common start and end times
%   getFileAndEQseconds  - calculate start times of the files in seconds after midnight January first:
%   installSL_GUI        - function installSL_GUI
%   readseis3D           - read three seismograms (eq(i).seisfiles{1:3}) and rotate in 3D
%   resultextract        - 
%   seisKeyPress         - handle keypress within Splitlab seismmogram plot
%   seisfigbuttons       - 
%   sort_components      - sort filelist such that seismograms are ordered as East, North, Vertical
%   SL_ttcurves          - Plot Travel time curves and travel paths
