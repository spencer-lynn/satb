function set_responseKeys(keylist)
%SAtb fn: set_responseKeys -- Associate response keys with one or two response types, set here as globals.
%
%Change Log:
% 7/18/10 - #keys>1, randomizes position of first 2 keys 
%           additional keys ignored (but still legal, in position specified by key-list file).
% 2/8/11 - modified to use new listfile stucture

global posresponse negresponse listfolder

keyinfo=read_list(strcat(listfolder,keylist));
[keys{1:numel(keyinfo)}]=keyinfo.Stimulus;

numKeys=num2str(length(keys));
switch numKeys
    case '1'
        %If only one response key, then no need to randomize position
        posresponse=KbName(keys(1)); % S+ response key
        negresponse=[]; % S- response key

    otherwise %Randomly associate first two keys with response type
        %disp('2 keys detected')
        keys={[KbName(keys(1)) KbName(keys(2))] [KbName(keys(2)) KbName(keys(1))]};
        %Randomly assign response keys
        r = ceil(2.*rand(1,1)); %random draw from set (1,2) (see help rand)
        posresponse=keys{r}(1); % S+ response key
        negresponse=keys{r}(2); % S- response key

%     otherwise
%                 disp('Cannot randomize >2 keys, in set_responseKeys.m.')

        %if greater than 2 response keys
        %...randomization routine not written yet
end
end %fn
