function outcome=decision_outcome(response,trial_info) 
%SAtb fn: decision_outcome -- Determines behavior result type. 
%     Hard-coded for two-button response rather than go/no-go.
% 
%Change log:
% 7/6/09 - added nargin/mystiminfo for independance from global stiminfo (eg, for abx).
% 5/3/10 - added response='rating' option for easy coding of Likert ratings.
% 7/18/10- added 'dresponse' for pressing a "distractor" key. If used, dresponse must
%        be defined as global elsewhere (eg, in main expt) for coding to be reflected in data file.
% 10/15/10- added corrans/Response Code = 'likert', specified in list file for rating trials.
% 2/8/11 - modified for new listfile structure
%          global stiminfo = Depricated 2/8/11, replaced w/ trial_info


global dresponse negresponse posresponse posobjtype negobjtype noobjtype 
% Notes:
% dresponse is for pressing a "distractor" key. It must be defined as global, eg, in main expt) 
% posresponse, negresponse are S+ and S- response keys defined by set_responseKeys.m
% posobjtype, negobjtype, noobjtype are defined in main expt script and designated in trial_list 
%         (or stimulus_list) Response_Code field (eg, as +,-,0). Can also be added dynamically, eg by get_signal.
%          noobjtype is neutral/distractor designator (used for confidence-rated trials).

corrans=char(trial_info.Response_Code);
%Outcomes must be listed in the feedback_list's Response_Code column with non-"blank" stim type for feedback to display

if isnan(response)
    outcome='NaN'; %response=NaN as originally set
else if (isequal(response,posresponse) && isequal(corrans,posobjtype))
        outcome='CD'; %correct detection
    else if (isequal(response,negresponse) && isequal(corrans,posobjtype))
            outcome='MD'; %missed detection
        else if (isequal(response,posresponse) && isequal(corrans,negobjtype))
                outcome='FA'; %false alarm
            else if (isequal(response,negresponse) && isequal(corrans,negobjtype))
                    outcome='CR'; %correct rejection
                else if (isnan(response(1)) && isequal(corrans,noobjtype))
                        outcome='NR0'; %no valid response by subject, correctly
                    else if (isnan(response(1)) && isequal(corrans,posobjtype))
                            outcome='NR+'; %subject missed an S+
                        else if (isnan(response(1)) && isequal(corrans,negobjtype))
                                outcome='NR-'; %subject missed an S-
                                
                            else if ((isequal(response,dresponse) && isequal(corrans,noobjtype)))
                                    outcome='D0'; %Correctly press distractor-key to distractor stim
                                else if ((isequal(response,dresponse) && isequal(corrans,posobjtype)))
                                        outcome='Dx'; %Incorrectly press distractor-key to S+ stim
                                    else if ((isequal(response,dresponse) && isequal(corrans,negobjtype)))
                                            outcome='Dx'; %Incorrectly press distractor-key to S- stim
                                            
                                        else if ((isequal(response,posresponse) && sum(strcmp(corrans,noobjtype))>0))
                                                outcome='D+'; %Button press to distractor stim
                                            else if ((isequal(response,negresponse) && sum(strcmp(corrans,noobjtype))>0))
                                                    outcome='D-'; %Button press to distractor stim
                                                    
                                                else if ((isequal(response,posresponse) && isequal(corrans,noobjtype)))
                                                        outcome='D+'; %S+ button press to distractor stim
                                                    else if ((isequal(response,negresponse) && isequal(corrans,noobjtype)))
                                                            outcome='D-'; %S- button press to distractor stim
                                                            
                                                        else if ((isequal(response,'forward') || isequal(response,'backward')))
                                                                outcome='Navigation'; %Navigation keys used
                                                                
                                                            else if isequal(corrans,'rating')
                                                                    outcome='Rating';
                                                                else if isequal(response,'rating')
                                                                        outcome='Rating';
                                                                    else if findstr(response,'1 2 3 4 5 6 7 8 9')
                                                                            outcome='Rating';
                                                                            %This really work. Would response ever be a num-as-char?
                                                                        else
                                                                            outcome='Error?';
                                                                            disp('Unrecognized response type in decision_outcome.m:')
                                                                            response
                                                                        end
                                                                    end
                                                                end
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
end %fn decision_outcome

