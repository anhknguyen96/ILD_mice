% % % check this first, if number of 50ms licks decrease, if not try pause

function [correct, response, rt, licks_left, licks_right, release_left, release_right, vecL, vecR, NewLickOk] = sample_lick(time_stimulus, time_elapsed, trial_type, board, baseline_spout, vecL, vecR, licks_left, licks_right, release_left, release_right, NewLickOk, correct_response)

%   parameters
    conv_fac_time = 24*3600;        % conversion factor to convert "now time" in seconds
    touch = [0 0];                  % assume the animal is not licking when the function starts
    lickNexit = 0;                  % do not exist the lick function
    lickYexit = 1;                  % exit the lick function
    ambientlight = 3;               % ambient light 
    time_flash = 0.02;
    

%   fwt trial
    if trial_type == 1
        %   start timing
        tic;
%       while elapsed time or correct == 1 
        while toc < time_elapsed 
                           
%           count lick
            [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(time_elapsed - toc, lickYexit,board,baseline_spout,vecL,vecR, NewLickOk);
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
            release_left = [release_left; noTouch{1}];      % save release left
            release_right = [release_right; noTouch{2}];    % save release right

%           examine lick
            if isempty(time_licks{1})==0
                response = 0;                  % response was left
                rt = (time_licks{1}-time_stimulus)*conv_fac_time;
            elseif isempty(time_licks{2})==0
                response = 1;                  % response was right
                rt = (time_licks{2}-time_stimulus)*conv_fac_time;
            else
                response = 0.5;                   % no response
                rt = -1;
            end

%           this is the outcome of the trial
            correct = double(response==correct_response);
            
            toc;
            
            if correct == 0 && response ~= 0.5
%               punish
                sb_io_set_dig(board,[ambientlight],0);         % turn off the ambient light
                pause(time_flash)
                sb_io_set_dig(board,[ambientlight],1);         % turn on the ambient light      
            
            elseif correct == 1
                break
            end
            
     
        end
    
%   st trial
    elseif trial_type == 0 
        
        % count lick
        [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(time_elapsed,lickYexit,board,baseline_spout,vecL,vecR, NewLickOk);
        licks_left = [licks_left; time_licks{1}];      % save licks left
        licks_right = [licks_right; time_licks{2}];    % save licks right
        release_left = [release_left; noTouch{1}];      % save release left
        release_right = [release_right; noTouch{2}];    % save release right
        
        % examine lick
        if isempty(time_licks{1})==0
            response = 0;                  % response was left
            rt = (time_licks{1}-time_stimulus)*conv_fac_time;
        elseif isempty(time_licks{2})==0
            response = 1;                  % response was right
            rt = (time_licks{2}-time_stimulus)*conv_fac_time;
        else
            response = 0.5;                   % no response
            rt = -1;
        end
        
        % this is the outcome of the trial
        correct = double(response==correct_response);

    
%   monitor lick in ITI
    else    
        %   start timing
        tic;
%       while elapsed time or correct == 1 
        while toc < time_elapsed 
                           
%           count lick
            [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(time_elapsed - toc, lickYexit,board,baseline_spout,vecL,vecR, NewLickOk);
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
            release_left = [release_left; noTouch{1}];      % save release left
            release_right = [release_right; noTouch{2}];    % save release right
            
            
            if (((licks_left(end)-tic)*conv_fac_time)<IT_nl) | (((licks_right(end)-tic)*conv_fac_time)<IT_nl)
                
            elseif (((licks_left(end)-tic)*conv_fac_time)>=IT_nl) | (((licks_right(end)-tic)*conv_fac_time)>=IT_nl)
                correct = 1;
            end
                
            
            toc;
            
            if correct == 1
                break
            end
        end
end



    
% 
% %   start timing
%     t0 = clock;
%     
% %   fwt trial
%     if trial_type == 1
%         
% %       while elapsed time or correct == 1 
%         while etime(clock, t0) < time_elapsed 
%                            
% %           count lick
%             [time_licks,~,touch] = Check2Spouts_IOBoard_Anh(time_elapsed - etime(clock, t0),lickYexit, board, baseline_spout,touch, licks_left(end), licks_right(end));     % check licks
%             licks_left = [licks_left; time_licks{1}];      % save licks left
%             licks_right = [licks_right; time_licks{2}];    % save licks right
% 
% %           examine lick
%             if isempty(time_licks{1})==0
%                 response = 0;                  % response was left
%                 rt = (time_licks{1}-time_stimulus)*conv_fac_time;
%             elseif isempty(time_licks{2})==0
%                 response = 1;                  % response was right
%                 rt = (time_licks{2}-time_stimulus)*conv_fac_time;
%             else
%                 response = 0.5;                   % no response
%                 rt = -1;
%             end
% 
% %           this is the outcome of the trial
%             correct = double(response==correct_response);
% 
%             if correct == 0 && response ~= 0.5
% %               punish
%                 sb_io_set_dig(board,[ambientlight],0);         % turn off the ambient light
%                 pause(time_flash)
%                 sb_io_set_dig(board,[ambientlight],1);         % turn on the ambient light
%                 
%             elseif correct == 1
%                 break
%             end
%             
% %             pause(pause_time)
%             
%         end
%     
% %   st trial
%     else
%         
%         while etime(clock, t0) < time_elapsed 
% %           count lick
%             [time_licks,~,touch] = Check2Spouts_IOBoard_Anh(time_elapsed - etime(clock, t0),lickYexit, board, baseline_spout,touch, licks_left(end), licks_right(end));     % check licks
%             licks_left = [licks_left; time_licks{1}];      % save licks left
%             licks_right = [licks_right; time_licks{2}];    % save licks right
% 
% %           examine lick
%             if isempty(time_licks{1})==0
%                 response = 0;                  % response was left
%                 rt = (time_licks{1}-time_stimulus)*conv_fac_time;
%             elseif isempty(time_licks{2})==0
%                 response = 1;                  % response was right
%                 rt = (time_licks{2}-time_stimulus)*conv_fac_time;
%             else
%                 response = 0.5;                   % no response
%                 rt = -1;
%             end
% 
% %           this is the outcome of the trial
%             correct = double(response==correct_response);
%             
%             
%             if  any([response ==1, response ==0])
%                 break
%             end
%             
% %             pause(pause_time)
% 
%         end
%     end
