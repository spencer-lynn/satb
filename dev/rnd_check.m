global posresponse negresponse %set by set_responseKeys


%% set random stream
try %use try since RandStream is new to ML7.7
    rstream=RandStream.setDefaultStream(RandStream('mt19937ar','seed',sum(100*clock))) %reseed the random-number generator for each expt.
catch rnderr
    rnderr
    %rand('state',sum(100*clock)); % reseed the random-number generator for each expt.
end



loops=10;
for i=1:loops
    
    %% set random keys
    keypath='/Users/spencer/Coding/Matlabber/my_m-files/SAlab/experiments/zeromiss/zeromiss_program/lists/keys_yesno_list.txt';
    set_responseKeys(keypath); %randomly associate response keys with stimulus classes
    %[posresponse negresponse]
    pos(i)=posresponse;
    neg(i)=negresponse;
    
    %% check rnd calls
    r(i) = ceil(2.*rand(1,1)); %used by set_responseKeys
    unirand(i)=rand(1,1); %used by base rate
    sigval_stat(i)=round(normrnd(7,1.5)); %Stat TB call used by fetch_signal
    sigval_gen(i)=round(7 + 1.5 .*randn(1)); %ML call used by fetch_signal
    %[r unirand sigval_stat sigval_gen]
        
end
    [pos' neg' r' unirand' sigval_stat' sigval_gen']
