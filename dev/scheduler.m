%call SCHEDULER below as...
try
     on_schedule=scheduler('fr',1,0);    
     if on_schedule
         loadscreen(behav)
     else
         %do nothing, or maybe show blank screen w/out feedback.
         % to do latter, set stim type to 'o' in stiminfo
     end
 catch % catch error
    cleanup
    psychrethrow(psychlasterror);
end % try ... catch %



function sched=scheduler(schedule_type,avg,vari)
%Provide feedback on specified reinforcement schedule.
%
%Could schedule over (1) all responses (trad'l comp psych), (2) specific response
%type (eg CD<>MD) or (3) source of signal (CD=MD), or key (CD=FA)
%If placed in xCD then cannot do #1 
persistent num_responses %need persistent var to count types of responses
num_responses=1;
switch schedule_type
    case 'fr' %Fixed Response: payoff delivered after fixed number of responses
        if num_responses==avg
            sched=1;
        end
    case 'vr' %Variable Response
    case 'fi' %Fixed Interval (will need a timer)
    case 'vi'
end %switch
end %fn

