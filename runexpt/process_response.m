function [behavior response]=process_response(response)
%Process response type (incoming response is a keycode string, like '1!')
%Updates:
%7/18/10 -- added case for correct ID of distractor "dresponse"
%           (eg, for pressing space bar to non-training stim in a peask shift task)
%           behavior gets coded as for no-response. If used, dresponse must
%           be defined as global elsewhere (eg, in main expt) for coding to
%           be reflected in data file.

global posresponse negresponse noresponse dresponse
if ~isempty(response) %catch response={} errors gracefully (from failure of strmatch against keycode)
    switch response %Code behavior based on response

        case KbName(posresponse) %subject pressed Target/S+ key
            behavior=1;
            response=KbName(response); %convert response to kb code# rather than letter-name string.

        case KbName(negresponse) %subject pressed Foil/S- key
            behavior=-1;
            response=KbName(response); %convert response to kb code# rather than letter-name string.

        case KbName(noresponse) %no key press, response still = 'null'
            behavior=0;
            response=KbName(response); %convert response to kb code# rather than letter-name string.

        case KbName(dresponse) %"distractor"-key press, response still = 'null'
%             hmm.. what is this case, really? I don't think this really
%             works. How could reponse = both null and kb(drresponse)?
            behavior=0;
            response=KbName(response); %convert response to kb code# rather than letter-name string.

        case 'null' %no key press, response still = 'null'
            behavior=0;
            response=NaN; %convert response to kb code# rather than letter-name string.
        otherwise %a Likert rating trial or something like that w/ >2 response possibilities
            try
                if isequal(class(response),'double') %Rating
                    behavior=response;
                else %Navigation
                    behavior=response;
                end
            catch
                behavior=NaN;
                disp('Error during response/behavior assignment in process_response.m')
                disp(KbName(KeyCode))
            end
    end %behavior switch

else %>1 simultaneous key presses? Press during masked target? Press to stim + rapid press to likert (right at code transition?)
    behavior=NaN;
    response='Error'
    responsetime=NaN;
    disp('Response detection error in process_response.m, perhaps in show_stim.m')
%   disp(KbName(KeyCode))
end %if response not empty
end
