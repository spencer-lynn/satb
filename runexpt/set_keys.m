function set_keys(keylist)
%SAtb fn: set_keys -- Load valid response keys (keyinfo and keyfilter) for current block.
% 
% Change Log:
% 2/8/11 - This replaces getkeys in order to use new listfile structure.
%     Consider rewriting to use non-transposed read_list (see, eg, new set_params.m)
%     Consider rewriting to use [keyinfo.Stimulus] rather than [keys{}]= (see response_feedback.m)

global keyinfo keyfilter currentkeys listfolder %globals so that can be changed by xfn for probe trials in middle of a block

keyinfo=read_list(strcat(listfolder,keylist));


%numel(keyinfo) %number of legal keys in keylist (ie, rows)
currentkeys=cell(numel(keyinfo),1); %needs to be pre-defined as cell to make assignments (otw cell->double error).

[keys{1:numel(keyinfo)}]=keyinfo.Stimulus; %Assign each cell of Stimulus to a array element, for later use by strmatch.


for i=1:numel(keyinfo)
% if response_code is numeric/double (like for ratings), need to put the code into a cell array to avoid cell->double error when processing keypresses.
    if isequal(class(keyinfo(i).Response_Code),'double')
        keyinfo(i).Response_Code={keyinfo(i).Response_Code};
    end
end

    
keynames=KbName('KeyNames'); %Get listing of all possible keys
keyfilter=false(size(keynames)); %create logical array of zeros, over all possible keys.

%{
% This single loop version doesn't work on Windows
for k=1:length(keys)
  match=strmatch(keys(k),keynames{1:end}); %Will match '1!' on keyboard or '1' on numeric keypad.
  keyfilter(match)=1; %Put one's into logical filter at our key positions.
end
%}

%This double for-loop required by WIN.
for k=1:length(keys)
    currentkeys(k)=keys{k}; %extract the cell-array-of-string from the enclosing cell.
    for n=1:length(keynames)
        if isequal(char(keys{k}),keynames{n})
           keyfilter(n)=1; %Put one's into logical filter at our key positions.
        end
    end
end

% keyinfo.Response_Code
end %fn
