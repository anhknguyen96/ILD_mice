clear all
close all

% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% SAVING LOCATION
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
folder_DB = 'C:\Users\AlfonsoRenart\Dropbox\MATLAB\data_ILD_2020\'; % folder location DropBox
folder_local = 'C:\Users\AlfonsoRenart\Documents\data_ILD_2020_local\';  % local folder to save
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
 
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% MOUSE/SESSION INFO
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
mouse_number = input('Good morning. Please enter the mouse number:   ');    % ask for the mouse number
mouse_weight = input('Weight of the animal prior to training [g]:   ');     % ask for the mouse weight (g)
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------

% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% DATA TO LOAD
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
filename = [folder_DB 'MouseILD' num2str(mouse_number) '.mat'];   % this is the filename
filename_local = [folder_local 'MouseILD' num2str(mouse_number) '.mat'];   % this is the filename
if exist(filename)==0
    session = 1;                                        % if it doesn't exist, this is the first session
    phase = 1;                                          % initial phase
    params_touse = choose_params(phase);                % get the parameters
else
    load(filename)
    output_prev = check_prev_performance(datastruct)
    session = length(datastruct)+1;                             % if the file exist, load it and session = session + 1
    phase_yesterday = datastruct(end).table_data(end,:).Phase;  % get the phase in the previous session
    phase = choose_phase(datastruct);
    ans = input(['Phase would move from ' num2str(phase_yesterday) ' to ' num2str(phase) ': are you ok with that (y/n)? ']);
    if strcmp(ans,'y')==1
        disp(['Phase changed to: ' num2str(phase)])
    else
        phase = input('What phase do you want to use? ');
    end
    params_touse = choose_params(phase);
end
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------

% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% PARAMETERS
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% check choose_params function for the parameters and the phase transitions
duration_nolick_prestim = params_touse.duration_nolick_prestim;
min_duration_iti = params_touse.min_duration_iti;
mean_duration_iti = params_touse.mean_duration_iti;
max_duration_iti = params_touse.max_duration_iti;
response_window = params_touse.response_window;
tau_bias = params_touse.tau_bias;
gamma_bias = params_touse.gamma_bias;
tau_perf = params_touse.tau_perf;
gamma_perf = params_touse.gamma_perf;
max_trial = params_touse.max_trial;
time_punishment = params_touse.time_punishment;
phase = params_touse.phase;
ABL = params_touse.ABL;
ILD = params_touse.ILD;
ABL_block = params_touse.ABL_block;
f_range = params_touse.f_range;
sound_duration = params_touse.sound_duration;
ramp_duration = params_touse.ramp_duration;
nskips_freewater = params_touse.nskips_freewater;
nbias_freewater = params_touse.nbias_freewater;
time_freewater = params_touse.time_freewater;

% HOUSE CLEANING PARAMETERS
conv_fac_time = 24*3600;        % conversion factor to convert "now time" in seconds
touch = [0 0];                  % assume the animal is not licking when the function starts
lickNexit = 0;                  % do not exist the lick function
lickYexit = 1;                  % exit the lick function
run_window_perf = [10 50];      % running windows for local estiamates of performances and p
infrared = 4;                   % infrared light for the pupil
ambientlight = 3;               % ambient light 
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
 
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% INITIALIZE HARDWARE
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% RIG NUMBER
load('C:\Users\AlfonsoRenart\Documents\MATLAB\SetupSpecs');  % load the specs of the rig
params_touse.setupnumber = SetupNo;     % save the setup number

% IO BOARD
board = Initialise_TheGermanWay(3);     % initialize the in/out board (the German way)
sb_io_set_dig(board,0:6,0)              % set all digital Pins to 0 - just in case...
fprintf('Thank you. Calibrating LickPorts Now....')
baseline_spout = GetLickPortBaseline(1,board, SetupNo);    %if no lickport baseline value was spacifies when calling the function, lickport will be caibrated here (takes 1s)
disp('[DONE]')
sb_io_set_dig(board,[ambientlight infrared],1); % switch on both the infrared and the ambient light

% INITIALIZE PSYCHOTOOLBOX
fs_sound = 192000;
InitializePsychSound(1);                                        % initialize
devices = PsychPortAudio('GetDevices',[],[]);                   % get the audio devices

if SetupNo ~= 8
    name_audio = 'Xonar DX ASIO(64)';
else
    name_audio = 'ASUS Xonar D2X ASIO (64)';
end

for i = 1:length(devices)
    comp_string(i) = strcmp(devices(i).DeviceName,name_audio);  % find the right one
end
device_id = devices(find(comp_string==1)).DeviceIndex;          % get the ID number
nrchannels = 2;                                                 % nchannels psychotoolbox
mode = 1;                                                       % play only
aggressive = 0;                                                 % don't be aggressive
pahandle = PsychPortAudio('Open', device_id, mode, aggressive, fs_sound, nrchannels, 64,.000005);
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------

% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% INITIALIZE VARIABLES
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
licks_left = 0; licks_right = 0;
bias = [0.5 0.5];
perf = [0 0];
bias_0 = 0.5;
perf_0 = 0.95;
response = 0.5;
correct = 0;
free_water = 0;
trial_number = 0;
response_vec = NaN(1000,1);
p_vec = NaN(1000,1);
stimulus_vec = NaN(1000,1);
stimulus_vec_ABL = NaN(1000,1);
sound_pres_vec = NaN(1000,1);
rt_vec = NaN(1000,1);
correct_vec = NaN(1000,1);
time_lost_vec = NaN(1000,1);
bias_vec = NaN(1000,2);
perf_vec = NaN(1000,2);
free_water_vec = zeros(1000,1);
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------

% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% CREATE SOUNDS
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
for i = 1:length(ABL)
    for j = 1:length(ILD)
        output_waveform(:,:,j,i) = generate_noise_ILD(f_range,ABL(i),ILD(j),sound_duration,ramp_duration,0);
    end
end
ndiff = length(ILD)/2;  % get the number of difficulties used
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------

% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% LAST INITIALIZATIONS
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
tostop_session = stoploop({'Click here to', 'stop the session'}) ;
task = 1;   % if this is one you go on "whiling"
state = 'firsthalf_ITI';    % initialize the state
lock_ABL = 0;       % make sure that ABL can be defined the first time
nskips = 0;         % initialize the number of skips
nbias = 0;         % initialize the number of bias 
% nbias_left = 0;         % initialize the number of skips
pause(60);          % wait 20 seconds before starting the sessions
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------

while task==1
        
    switch state
        
         case 'timeout'
                    
            [time_licks,~,touch] = Check2Spouts_IOBoard(time_punishment,lickNexit, board, baseline_spout,touch);     % check licks
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
            
            % change state
            state = 'firsthalf_ITI';
        
        case 'firsthalf_ITI'
                    
            iti_duration = generate_expdist_numbers(mean_duration_iti,min_duration_iti,max_duration_iti);    % this is the ITI duration (s)
            [time_licks,~,touch] = Check2Spouts_IOBoard(iti_duration/2,lickNexit, board, baseline_spout,touch);     % check licks
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
            
            time_firsthalf_ITI = now;
            
            % change state
            state = 'timeconsuming_operations';
            
        case 'secondhalf_ITI'
            
            time_secondhalf_ITI = now;
            time_lost = conv_fac_time*(time_secondhalf_ITI-time_firsthalf_ITI);
            
            [time_licks,~,touch] = Check2Spouts_IOBoard((iti_duration/2)-time_lost,lickNexit, board, baseline_spout,touch);     % check licks
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
            timenow = now;              % check the current time
            
            % if the animal licked before, stay in the ITI state otherwise
            % go to the sound state
            if (((timenow - licks_left(end))*conv_fac_time)<duration_nolick_prestim) || (((timenow - licks_right(end))*conv_fac_time)<duration_nolick_prestim)
                
                % we still consider this response for the bias removal
                % algorithm
                if licks_left(end)>licks_right(end)               
                    response = 0;
                else
                    response = 1;
                end
                
                sound_index = 0;        % but here the sound index is zero (that's the way we label this trials/aborts)
                sound_index_ABL = 0;    % and the same for the ABL part
                time_stimulus = now;    % but still save the time the sound would have occurred
                rt = NaN;               % and this is another way we can keep track of these trials
                correct = 0;            % for visualization, these it's a wrong trial
                
                state = 'firsthalf_ITI';
                
            else
                
                state = 'sound';
                free_water = 0;  % just to kep track of this
                
                % if there were too many skips go to a different state
                if nskips > nskips_freewater
                    out = randsrc;
                    if out == 1
                        state = 'freewater';
                        nskips = 0;
                        free_water = 1;  % to keep track of this
                    end
                end    
                
                if nbias > nbias_freewater
                    out =randsrc;
                    if out == 1
                        state = 'freewater';
                        nbias = 0;
                        free_water = 1;
                    end
                end
                
            end
            
            % if the button has been pressed stop the task
            if tostop_session.Stop()==1
                task = 0;
            end
            
        case 'timeconsuming_operations'
            
            trial_number = trial_number + 1;
                        
            if trial_number>1
                % save variables
                response_vec(trial_number-1) = response;
                p_vec(trial_number-1) = p;
                stimulus_vec(trial_number-1) = sound_index;
                stimulus_vec_ABL(trial_number-1) = sound_index_ABL;
                sound_pres_vec(trial_number-1) = time_stimulus;
                rt_vec(trial_number-1) = rt;
                correct_vec(trial_number-1) = correct;
                time_lost_vec(trial_number-1) = time_lost;
                bias_vec(trial_number-1,:) = bias;
                perf_vec(trial_number-1,:) = perf;
                free_water_vec(trial_number-1,:) = free_water;
                                                
                % visualization
                try
                    disp(['TrN: ' num2str(trial_number-1) '  TR: ' num2str(sum(correct_vec(1:trial_number-1))) '  p: ' num2str(round(p*100)/100) '  ABL: ' num2str(ABL(sound_index_ABL)) '  ILD: ' num2str(ILD(sound_index)) '  FW: ' num2str(free_water) '  R: ' num2str(response) '  C: ' num2str(correct) '  RT: ' num2str(round(rt*100)/100) '  C1: ' num2str(round(perf(1)*100)/100) '  C2: ' num2str(round(perf(2)*100)/100) '  B1: ' num2str(round(bias(1)*100)/100) '  B2: ' num2str(round(bias(2)*100)/100)]) 
                catch
                    disp(['TrN: ' num2str(trial_number-1) '  TR: ' num2str(sum(correct_vec(1:trial_number-1))) '  p: ' num2str(round(p*100)/100) '  ABL: Abort' '  ILD: Abort' '  FW: ' num2str(free_water) '  R: ' num2str(response) '  C: ' num2str(correct) '  RT: ' num2str(round(rt*100)/100) '  C1: ' num2str(round(perf(1)*100)/100) '  C2: ' num2str(round(perf(2)*100)/100) '  B1: ' num2str(round(bias(1)*100)/100) '  B2: ' num2str(round(bias(2)*100)/100)])
                end
                    
            end
            
            % bias correction
            if response == 0.5
                bias = bias;
            else
                bias = (1-tau_bias).*[response response] + tau_bias.*bias;                 % estimate the bias
            end
            p = 1 / ( 1 + exp( ( bias(1) - bias_0 )/gamma_bias));   % change the probability accordingly 
            

            rand_number = rand;     % get a random number and then depending on the probability, decide whether using left or right stimuli
            if rand_number>p
                sound_index_side = 1;
            else
                sound_index_side = length(ILD);
            end
            
            
            % pick ILD
            perf = (1-tau_perf).*[correct correct] + tau_perf.*perf;        % estimate the performance
            delta = -1 + 2 ./ ( 1 + exp( (perf(1)-perf_0)/gamma_perf ) );      % estimate for the probs of the ILDs
            phi_num = 1 - geocdf([1:ndiff],delta);                          % numerators
            phi = phi_num/sum(phi_num);                                     % actual probabilities perf-dependent
            if isnan(sum(phi))==1
                phi = 1/n * ones(1,n);      % if the animals are very good, then equal probabilities for ILDs
            end
            diff_touse = randsrc(1,1,[1:ndiff; phi]);                       % this is the difficulty to use
            
            % get the stimulus, based on the side we want and the
            % difficulty we got
            if sign(ILD(sound_index_side))>0
                sound_index = length(ILD)-(diff_touse-1);   % move left from the last one
            else
                sound_index = 1 + (diff_touse-1);           % move right from the first one
            end
            
            % pick the ABL
            % if you reached ABL_block trials then pick another ABL
            % otherwise go on counting
            if lock_ABL == 0
                sound_index_ABL = randi(length(ABL),1,1);          % pick a random index for ABL
                count_ABL = 1;                              % restart the counter
                lock_ABL = 1;                               % lock ABL for now
            else
                count_ABL = count_ABL + 1;                  % just count
            end
            
            % if you reach the number of trials in the block, unlock ABL
            if count_ABL == ABL_block
                lock_ABL = 0;
            end
            
            PsychPortAudio('DeleteBuffer');                                         %Clear SoundBuffer
            PsychPortAudio('FillBuffer', pahandle,output_waveform(:,:,sound_index,sound_index_ABL)');     % fill the buffer
                        
            % check whether we should go to a normal trial or a free water
            % trial
            if response == 0.5
                nskips = nskips + 1;    % go on summing
            else
                nskips = 0;             % otherwise initialize
            end
            
            if ismember(mouse_number, [117 120])
                if round(bias(1)*100)/100 > 0.9 | round(bias(1)*100)/100 < 0.1
                    nbias = nbias + 1;    % go on summing
                else
                    nbias = 0;             % otherwise initialize
                end
            else
                if ismember(round(bias(1)*100)/100, [1 0])
                    nbias = nbias + 1;    % go on summing
                else
                    nbias = 0;             % otherwise initialize
                end
            end

            % change state
            state = 'secondhalf_ITI';
                        
            if (trial_number-1)==max_trial
                task = 0;
            end
            
        case 'sound'
            
            PsychPortAudio('Start', pahandle, 1, 0, 1);                             % trigger the sound
            time_stimulus = now;
            [time_licks,~,touch] = Check2Spouts_IOBoard(response_window,lickYexit, board, baseline_spout,touch);     % check licks
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
            PsychPortAudio('Stop', pahandle, 2, 0);        % if the animal licks, we stop the sound right away
            
            % check the responses
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
                
            % what is the correct response
            correct_response = ((sign(ILD(sound_index)))+1)/2;
            
            % if the response is correct, give reward
            if response == correct_response
                DeliverReward_IO(correct_response,board,ValveTime);
            end
            
            % this is the outcome of the trial
            correct = double(response==correct_response);
            
            % make sure trials are not shorter based on the response
            if rt~=-1
                [time_licks,~,touch] = Check2Spouts_IOBoard(response_window-rt,lickNexit, board, baseline_spout,touch);     % check licks
                licks_left = [licks_left; time_licks{1}];      % save licks left
                licks_right = [licks_right; time_licks{2}];    % save licks right
            end
               
            % if it's incorrect
            if (correct==0) && (response~=0.5)                
                state = 'timeout';
            else
                state = 'firsthalf_ITI';
            end
                         
         
        case 'freewater'
            
            PsychPortAudio('Start', pahandle, 1, 0, 1);                             % trigger the sound
            time_stimulus = now;
            [time_licks,~,touch] = Check2Spouts_IOBoard(time_freewater,lickNexit, board, baseline_spout,touch);     % check licks
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
            
             % what would be the correct response
            correct_response = ((sign(ILD(sound_index)))+1)/2;
                        
            % deliver the water automatically after time_freewater
            DeliverReward_IO(correct_response,board,ValveTime);
            
            % restart tracking licks
            [time_licks,~,touch] = Check2Spouts_IOBoard(response_window-time_freewater,lickYexit, board, baseline_spout,touch);     % check licks
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
       
            PsychPortAudio('Stop', pahandle, 2, 0);        % if the animal licks, we stop the sound right away
            
            % check the responses
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
            
            % make sure trials are not shorter based on the response
            if rt~=-1
                [time_licks,~,touch] = Check2Spouts_IOBoard(response_window-rt,lickNexit, board, baseline_spout,touch);     % check licks
                licks_left = [licks_left; time_licks{1}];      % save licks left
                licks_right = [licks_right; time_licks{2}];    % save licks right
            end
               
            % if it's incorrect
            if (correct==0) && (response~=0.5)                
                state = 'timeout';
            else
                state = 'firsthalf_ITI';
            end
           
    end
    
end

% turn off the lights
sb_io_set_dig(board,[ambientlight infrared],0); % turn off both the infrared and the ambient light

% cleaning variables
trial_number = trial_number-1;
response_vec = response_vec(1:trial_number);
p_vec = p_vec(1:trial_number);
stimulus_vec = stimulus_vec(1:trial_number);
stimulus_vec_ABL = stimulus_vec_ABL(1:trial_number);
stimulus_ABL = stimulus_vec_ABL;
stimulus_ILD = stimulus_vec;
stimulus_ABL(stimulus_vec_ABL~=0) = ABL(stimulus_vec_ABL(stimulus_vec_ABL~=0));
stimulus_ILD(stimulus_vec~=0) = ILD(stimulus_vec(stimulus_vec~=0));
sound_pres_vec = sound_pres_vec(1:trial_number);
rt_vec = rt_vec(1:trial_number);
correct_vec = correct_vec(1:trial_number);
time_lost_vec = time_lost_vec(1:trial_number);
bias_vec = bias_vec(1:trial_number,:);
perf_vec = perf_vec(1:trial_number,:);
free_water_vec = free_water_vec(1:trial_number,:);
licks_left(1) = NaN;
licks_right(1) = NaN;

data = [mouse_number*ones(trial_number,1) session*ones(trial_number,1) [1:trial_number]' response_vec stimulus_vec stimulus_ABL stimulus_ILD sound_pres_vec correct_vec rt_vec bias_vec(:,1) perf_vec(:,1) p_vec time_lost_vec free_water_vec mouse_weight*ones(trial_number,1) phase*ones(trial_number,1)];
varNames = {'MouseID','Session','TrialNumber','Response','Stimulus','ABL','ILD','StimulusTime','Correct','RT','Bias','Perf','ProbStimulus','TimeLost','FreeWater','MouseWeight','Phase'};
table_data = array2table(data);
table_data.Properties.VariableNames = varNames;

% package the data properly
datastruct(session).table_data = table_data;
datastruct(session).licks.licks_left = licks_left;
datastruct(session).licks.licks_right = licks_right;
datastruct(session).mouse_number = mouse_number;
datastruct(session).mouse_weight = mouse_weight;
datastruct(session).params_touse = params_touse;

% and now we save the files
save(filename,'datastruct')
save(filename_local,'datastruct')
