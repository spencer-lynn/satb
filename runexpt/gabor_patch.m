function gabor_patch(trial_info,conditions)
% SAtb function: gabor_patch -- Use Psychtoolbox calls to make single static gabor stimulus.
% 
% Usage: gabor_patch(trial_info,conditions), where:
% 
% - trial_info is expected to contain all the necessary Gabor
% parameters (eg, specfied in a stimulus list file as ad hoc columns with
% names as below).
% 
% - conditions is the SATB global, provided in case you need to adjust any
% params for a given condition.
% 
% This function is intended to be called from a stimulus list file as an xfn.
% 
% 
% For more information, see PTB functions:
% help ProceduralGarboriumDemo %<--- Triple-click and press ENTER for more info.
% help ProceduralGaborDemo     %<--- Triple-click and press ENTER for more info.
% help CreateProceduralGabor   %<--- Triple-click and press ENTER for more info.
%
% For more about Gabors, parameters, see:
% http://matlabserver.cs.rug.nl/edgedetectionweb/web/edgedetection_params.html
%

%  -- Begin fn --
%Uncomment to check values:
% trial_info %single row of information about current trial.
% conditions %structure about current block's conditions (a global, if declared as such)

% The following based on PTB's ProceduralGarboriumDemo.m, ProceduralGarborDemo.m demos
% Initial parameters of gabors:
%% Size of support in pixels, derived from si:
% tw = 450;
% th = 450;

%% tilt of gabor lines in degrees
% rotationangle = 180;

%% 'phase' is the phase of the gabors sine grating in degrees.
% - range probably -180 to 180
% - Is white (0), black(180), or border (90, -90) centered in patch?
% phase = 0;

%% 'sc' is the spatial constant of the gaussian hull function of the gabor, ie.
% the "sigma" value in the exponential function.
% - like diameter of mask, but effects contrast, too.
% sc = 60.0;

%% 'freq' is its spatial frequency in cycles per pixel.
% - range like 0-1; smaller is thicker. !/lamda (wavelength in traditional Gabor specs).
% freq = str2double(trial_info.gabor_freq{1})


%% 'contrast' is the amplitude of your gabor in intensity units - A factor
% that is multiplied to the evaluated gabor equation before converting the
% value into a color value. 'contrast' may be a bit of a misleading term here...
% contrast = 100.0;

%% 'aspectratio' (width div height) defines the aspect ratio of the hull of the gabor. This
% parameter is ignored if the 'nonSymmetric' flag hasn't been set to 1 when
% calling the CreateProceduralGabor() function.
%aspectratio = .5;

%% Build a procedural gabor texture for a gabor with a support of tw x th
% pixels and the 'nonsymetric' flag set to 1 == Gabor shall allow runtime
% change of aspect-ratio. 'backgroundColorOffset' Optional, defaults to [0 0 0 0]. A RGBA offset
% color to add to the final RGBA colors of the drawn gabor, prior to
% drawing it (ie, [0.5 0.5 0.5 0.0] would be "gray")
gabortex = CreateProceduralGabor(trial_info.wptr,trial_info.tw,trial_info.th,trial_info.nonsym,[trial_info.offset_R trial_info.offset_G trial_info.offset_B trial_info.offset_A]);

%% Draw the gabor. The flag 'kPsychDontDoRotation' tells 'DrawTexture' not
% to apply its built-in texture rotation code for rotation, but just pass
% the rotation angle to the 'gabortex' shader -- it will implement its own
% rotation code, optimized for its purpose. Additional stimulus parameters
% like phase, sc, etc. are passed as 'auxParameters' vector to
% 'DrawTexture', this vector is just passed along to the shader. For
% technical reasons this vector must always contain a multiple of 4
% elements, so we pad with three zero elements at the end to get 8
% elements.
Screen('DrawTexture',trial_info.wptr, gabortex, [], [], trial_info.rot, [], [], [], [], kPsychDontDoRotation, [trial_info.phase, trial_info.gabor_freq, trial_info.sc, trial_info.contrast, trial_info.aspect, 0, 0, 0]);

end %fn