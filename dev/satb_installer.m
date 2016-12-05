These cases from Psychtoolbox
- use as examples for satb

% Check OS
isWin=strcmp(computer,'PCWIN') | strcmp(computer,'PCWIN64')| strcmp(computer, 'i686-pc-mingw32');
isOSX=strcmp(computer,'MAC') | strcmp(computer,'MACI') | ~isempty(findstr(computer, 'apple-darwin'));
isLinux=strcmp(computer,'GLNX86') | ~isempty(findstr(computer, 'linux-gnu'));



case 'install'
        %See also: DownloadPsychtoolbox,PsychtoolboxPostInstallRoutine

        if isOSX | isLinux
            [err]=system(checkoutcommand);
            result = 'For reason, see output above.';
        else
            [err,result]=dos(checkoutcommand, '-echo');
        end
        
        
        if err
            % Failed! Let's retry it via http protocol. This may work-around overly
            % restrictive firewalls or otherwise screwed network proxies:
            fprintf('Command "CHECKOUT" failed with error code %d: \n',err);
            fprintf('%s\n\n',result);
        end
        fprintf('Download succeeded!\n\n');

        
        
        
    case 'upate'
                %See also: UpdatePsychtoolbox,PsychtoolboxPostInstallRoutine

        fprintf('About to update your working copy of the OpenGL-based Psychtoolbox.\n');
        updatecommand=[svnpath 'svn update '  targetRevision ' ' strcat('"',targetdirectory,'"') ];
        fprintf('Will execute the following update command:\n');
        fprintf('%s\n', updatecommand);
        if isOSX | isLinux
            err=system(updatecommand);
            result = 'For reason, see output above.';
        else
            [err, result]=dos(updatecommand, '-echo');
        end
        
        if err
            fprintf('Sorry. The update command failed:\n');
            fprintf('%s\n', result);
            error('Update failed.');
        end
