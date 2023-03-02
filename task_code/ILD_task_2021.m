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
    phase = 0;                                          % initial phase
    params_touse = choose_params_2021(phase);                % get the parameters
    perf_cus = input('Performance threshold for block transition:   ');
    sound_index_start = input('Starting sound side: ');
else
    load(filename)
%     output_prev = check_prev_performance(datastruct)
    session = length(datastruct)+1;                             % if the file exist, load it and session = session + 1
    phase_yesterday = datastruct(end).table_data(end,:).Phase;  % get the phase in the previous session
    phase = choose_phase(datastruct);
    ans = input(['Phase would move from ' num2str(phase_yesterday) ' to ' num2str(phase) ': are you ok with that (y/n)? ']);
    if strcmp(ans,'y')==1
        disp(['Phase changed to: ' num2str(phase)])
    else
        phase = input('What phase do you want to use? ');
    end
    params_touse = choose_params_2021(phase);
    perf_cus = input('Performance threshold for block transition:   ');
    sound_index_start = input('Starting sound side: ');
end
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------

% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% PARAMETERS
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------
% check choose_params function for the parameters and the phase transitions
time_flash = params_touse.time_flash;
inbetween_repeat = params_touse.inbetween_repeat;
st_repeat = params_touse.st_repeat;
fwt_repeat = params_touse.fwt_repeat;
min_rewards = params_touse.min_rewards; 
max_rewards = params_touse.max_rewards;
min_st = params_touse.min_st; 
max_st = params_touse.max_st;
min_freewater_block = params_touse.min_freewater_block; 
max_freewater_block = params_touse.max_freewater_block; 
set_freewater_block = params_touse.set_freewater_block;
min_duration_fwt = params_touse.min_duration_fwt;
max_duration_fwt = params_touse.max_duration_fwt;
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
nbias_freewater = params_touse.nbias_freewater;
time_freewater = params_touse.time_freewater;
side = stim_sequence(60,length(ILD), 8);

% if mouse_number == 5
%     side = stim_sequence(50,length(ILD), 6);
% elseif mouse_number == 2
%     side = stim_sequence(60,length(ILD), 8);
%     min_duration_fwt = 1100;
%     max_duration_fwt = 1200;
% else 
%     side = stim_sequence(60,length(ILD), 8);
% end
    


% HOUSE CLEANING PARAMETERS
conv_fac_time = 24*3600;        % conversion factor to convert "now time" in seconds
touch = [0 0];                  % assume the animal is not licking when the function starts
lickNexit = 0;                  % do not exist the lick function
lickYexit = 1;                  % exit the lick function
run_window_perf = [10 50];      % running windows for local estiamates of performances and p
infrared = 4;                   % infrared light for the pupil
ambientlight = 3;               % ambient light 
sound_trigger = 2;              %Pin ID to trigger sound replay
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
release_left = 0; release_right = 0;
vecL = 0; vecR = 0;
NewLickOk = 0;
fwt_track = 0;
freewater_block = [];
valid_trials = [];
correct_trials = [];
correct_fst = [];
sound_index = 0;
sound_index_ABL = 0;
correct = 0;
repeat_sound = 0;
repeat_fw = 0;
n_rewards = 0;
n_rewards_tot = 0;
n_failedst = 0;
n_failedst_max = randi([min_st max_st]);
n_disengaged = 0;
n_disengaged_max = n_failedst_max;
trial_switch = 0;                                       % monitor ST switch to FWT after successive incorrect/disengaged STs
soundside_switch = 0;
trial_type_switch=0;                                    % monitor FWT to FWT-ST
trial_no_switch =1;
change = 0;                                             % sound initiation T_I, T_nl
dis = 0;
bias = [0.5 0.5];
perf = [0 0];
running_perf = 0;
running_fst = 0;
bias_0 = 0.5;
perf_0 = 0.95;
response = 0.5;
correct = 0;
free_water = 0;                                         % in phase 0, this also includes free water in FWT
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
running_perf_vec = NaN(1000,1);
running_fst_vec = NaN(1000,1);
perf_vec = NaN(1000,2);
free_water_vec = NaN(1000,1);
dis_trials_vec = NaN(1000,1);
tnl_duration_vec = NaN(1000,1);
tfwt_duration_vec = NaN(1000,1);
time_secondhalfITI_vec = NaN(1000,1);
time_elapsed_vec = NaN(1000,1);
time_elapseddis_vec = NaN(1000,1);
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
lock_freewater = 0;
lock_soundside = 0;
nskips = 0;         % initialize the number of skips
sb_io_set_dig(board,sound_trigger,0)  
pause
% --------------------------------------------------------------------------------------------------------------------------
% --------------------------------------------------------------------------------------------------------------------------

while task==1
        
    switch state
        
         case 'punishment'
             
             for i = 1:120
                 sb_io_set_dig(board,[ambientlight],0); % turn off both the infrared and the ambient light
                 [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(time_flash,lickNexit,board,baseline_spout,vecL,vecR, NewLickOk);
                 licks_left = [licks_left; time_licks{1}];      % save licks left
                 licks_right = [licks_right; time_licks{2}];    % save licks right
                 release_left = [release_left; noTouch{1}];      % save release left
                 release_right = [release_right; noTouch{2}];    % save release right
                 sb_io_set_dig(board,[ambientlight],1); % turn on both the infrared and the ambient light
                 [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(time_flash,lickNexit,board,baseline_spout,vecL,vecR, NewLickOk);
                 licks_left = [licks_left; time_licks{1}];      % save licks left
                 licks_right = [licks_right; time_licks{2}];    % save licks right
                 release_left = [release_left; noTouch{1}];      % save release left
                 release_right = [release_right; noTouch{2}];    % save release right
             end
             

            % change state
            state = 'firsthalf_ITI';
        
        case 'firsthalf_ITI'
            
            
            t_fwt = randi([min_duration_fwt max_duration_fwt]);                 % [40 60] (s)          
            [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(t_fwt/1000,lickNexit,board,baseline_spout,vecL,vecR, NewLickOk);
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
            release_left = [release_left; noTouch{1}];      % save release left
            release_right = [release_right; noTouch{2}];    % save release right
            
            time_firsthalf_ITI = now;
            
            
            % change state
            state = 'timeconsuming_operations';
            
        case 'secondhalf_ITI'
            
            
            t_start = tic;
            time_secondhalf_ITI = now;
            time_lost = conv_fac_time*(time_secondhalf_ITI-time_firsthalf_ITI);
            
            % animal disengaged in the previous trial, enter possible free water trial
            if response == 0.5                                    
                                                                
                [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020((t_fwt-t_fwt/1000)-time_lost, lickYexit,board,baseline_spout,vecL,vecR, NewLickOk);
                licks_left = [licks_left; time_licks{1}];      % save licks left
                licks_right = [licks_right; time_licks{2}];    % save licks right
                release_left = [release_left; noTouch{1}];      % save release left
                release_right = [release_right; noTouch{2}];    % save release right
                
                if isempty(time_licks{1}) && isempty(time_licks{2})
                    dis = 1;  
                    state = 'freewater';
                    free_water = 1;     
                    
                else
                    dis = 0;
                    
                    % initial training phase with FWT
                    
                        
                    while change ~= 1
                        [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(t_nl, lickYexit,board,baseline_spout,vecL,vecR, NewLickOk);
                        licks_left = [licks_left; time_licks{1}];      % save licks left
                        licks_right = [licks_right; time_licks{2}];    % save licks right
                        release_left = [release_left; noTouch{1}];      % save release left
                        release_right = [release_right; noTouch{2}];    % save release right
                        
                        
                        if isempty(time_licks{1}) && isempty(time_licks{2})
                            change = 1;
                        end
                    end
                        
                        state = state_change;
%                         free_water = 0;
                        change = 0;
                        
                    
                end
                
                t_dis = toc(t_start);
            
            % animal is still engaging
            else                                                           
                dis = 0;
                
                % initial training phase with FWT

                        
                while change ~= 1
                    [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(t_nl, lickYexit,board,baseline_spout,vecL,vecR, NewLickOk);
                    licks_left = [licks_left; time_licks{1}];      % save licks left
                    licks_right = [licks_right; time_licks{2}];    % save licks right
                    release_left = [release_left; noTouch{1}];      % save release left
                    release_right = [release_right; noTouch{2}];    % save release right
                    
                    
                    if isempty(time_licks{1}) && isempty(time_licks{2})
                        change = 1;
                    end
                end
                            
                    state = state_change;
%                     free_water = 0;
                    change = 0;

            end      
                   
            t_end = toc(t_start);    
            
            % if the button has been pressed stop the task
            if tostop_session.Stop()==1
                task = 0;
            end
            
        case 'timeconsuming_operations'
            
%             t_nl = generate_expdist_numbers(mean_duration_iti,min_duration_iti,max_duration_iti);    % this is the ITI duration (s)
            t_nl = randi([min_duration_iti max_duration_iti])
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
                running_perf_vec(trial_number-1) = running_perf;
                running_fst_vec(trial_number-1) = running_fst;
                free_water_vec(trial_number-1) = free_water;
                dis_trials_vec(trial_number-1) = dis;
                tnl_duration_vec(trial_number-1) = t_nl;
                tfwt_duration_vec(trial_number-1) = t_fwt;
                time_secondhalfITI_vec(trial_number-1) = time_secondhalf_ITI;
                time_elapsed_vec(trial_number-1) = t_end;
                time_elapseddis_vec(trial_number-1) = t_dis;
                
   
                % visualization
                try
                    disp(['TrN: ' num2str(trial_number-1) '  TR: ' num2str(sum(correct_vec(1:trial_number-1))) '  p: ' num2str(round(p*100)/100) '  ABL: ' num2str(ABL(sound_index_ABL)) '  ILD: ' num2str(ILD(sound_index)) '  FW: ' num2str(free_water) '  R: ' num2str(response) '  C: ' num2str(correct) '  RT: ' num2str(round(rt*100)/100) '  C1: ' num2str(round(perf(1)*100)/100) '  C2: ' num2str(round(perf(1)*100)/100) '  B1: ' num2str(round(bias(1)*100)/100) '  B2: ' num2str(round(bias(2)*100)/100)]) 
                catch
                    disp(['TrN: ' num2str(trial_number-1) '  TR: ' num2str(sum(correct_vec(1:trial_number-1))) '  p: ' num2str(round(p*100)/100) '  ABL: Abort' '  ILD: Abort' '  FW: ' num2str(free_water) '  R: ' num2str(response) '  C: ' num2str(correct) '  RT: ' num2str(round(rt*100)/100) '  C1: ' num2str(round(perf(1)*100)/100) '  C2: ' num2str(running_perf) '  B1: ' num2str(round(bias(1)*100)/100) '  B2: ' num2str(round(bias(2)*100)/100)])
                end
                    
            end
            
                
            % bias correction
            bias = (1-tau_bias).*[response response] + tau_bias.*bias;                 % estimate the bias
            p = 1 / ( 1 + exp( ( bias(1) - bias_0 )/gamma_bias));   % change the probability accordingly 
            
%             rand_number = rand;     % get a random number and then depending on the probability, decide whether using left or right stimuli
         
            
            % pick ILD
            if phase == 0
                
                if length(valid_trials) < 10                                                % for beginning of each block
                    % only take into account valid trials
                    valid_trials = [valid_trials trial_number-1]
                    if correct == 1                                                     % for running performance
                        if free_water ==0
                            correct_trials = [correct_trials trial_number-1]
                        end
                        if rt < 0.5 && length(track_time_stimuli)==1
                            
                            if response == 1
                                tmp_lick = (licks_left - track_time_stimuli)*conv_fac_time;
                                tmp_lick = intersect(tmp_lick(tmp_lick>0),tmp_lick(tmp_lick<rt));
                                if isempty(tmp_lick)
                                    correct_fst = [correct_fst trial_number-1]
                                end
                            else
                                tmp_lick = (licks_right - track_time_stimuli)*conv_fac_time;
                                tmp_lick = intersect(tmp_lick(tmp_lick>0),tmp_lick(tmp_lick<rt));
                                if isempty(tmp_lick)
                                    correct_fst = [correct_fst trial_number-1]
                                end
                            end
                            
                            tmp_lick =[];
%                             correct_fst = [correct_fst trial_number-1]
                        end
                    end
                    
                else                                                                        % after a while
                    if ~isempty(correct_trials) & valid_trials(1) == correct_trials(1)      % if no new correct trials within the running window
                        correct_trials(1) = []
                    end
                    
                    if ~isempty(correct_fst) & valid_trials(1) == correct_fst(1)            % if no new correct trials within the running window
                        correct_fst(1) = []
                    end
                    
                    valid_trials(1) = [];                                                   % omit the first one to include a new one
                    
                    
                    valid_trials = [valid_trials trial_number-1]
                    if correct == 1
                        if free_water ==0
                            correct_trials = [correct_trials trial_number-1]
                        end
                        if rt < 0.5 && length(track_time_stimuli)==1
                            if response == 1
                                tmp_lick = (licks_left - track_time_stimuli)*conv_fac_time;
                                tmp_lick = intersect(tmp_lick(tmp_lick>0),tmp_lick(tmp_lick<rt));
                                if isempty(tmp_lick)
                                    correct_fst = [correct_fst trial_number-1]
                                end
                            else
                                tmp_lick = (licks_right - track_time_stimuli)*conv_fac_time;
                                tmp_lick = intersect(tmp_lick(tmp_lick>0),tmp_lick(tmp_lick<rt));
                                if isempty(tmp_lick)
                                    correct_fst = [correct_fst trial_number-1]
                                end
                            end
                            tmp_lick =[];
%                             correct_fst = [correct_fst trial_number-1]
                        end
                    end
                    
                end
                
                
                
                if ~isempty(valid_trials)                                                     % only calculate running perf when there are 10 valid trials
                    running_perf = length(correct_trials)/length(valid_trials);
                    running_fst = length(correct_fst)/length(valid_trials);
                else
                    running_perf = 0;
                    running_fst = 0;
                end
                
                
            else
                perf = (1-tau_perf).*[correct correct] + tau_perf.*perf;        % estimate the performance
            end
            
%             perf = (1-tau_perf).*[correct correct] + tau_perf.*perf;        % estimate the performance
            delta = -1 + 2 ./ ( 1 + exp( (perf(1)-perf_0)/gamma_perf ) );      % estimate for the probs of the ILDs
            phi_num = 1 - geocdf([1:ndiff],delta);                          % numerators
            phi = phi_num/sum(phi_num);                                     % actual probabilities perf-dependent
            if isnan(sum(phi))==1
                phi = 1/ndiff * ones(1,ndiff);      % if the animals are very good, then equal probabilities for ILDs
            end
%             diff_touse = randsrc(1,1,[1:ndiff; phi]);                       % this is the difficulty to use
  
            % in phase 0, choose the sound side based on moving avg perf in
            % ST
            
            if phase == 0
                
                % automatic change from FWT to FWT-ST
                if length(freewater_block) >2
                    tmp=diff(trial_no_switch);
                    if tmp(end) <11 && tmp(end-1) <11 
                        trial_type_switch = 1;
                    end
                end
%                             
                    

                if lock_soundside == 0                                              % first trial
                    sound_index_side = sound_index_start;
%                     sound_index_side = randi(length(ILD),1,1);                      % pick a random index for ABL
                    lock_soundside = 1;                                             % lock soundside for now
                    freewater_block = [freewater_block randi([min_freewater_block max_freewater_block])];
  
                elseif trial_type_switch==0 & running_fst >= perf_cus & length(valid_trials)>=7          % now instead of a certain max successful ST number, use moving avg of perf
                    sound_index_side = (length(ILD) - sound_index_side) + 1;
                    valid_trials = [];
                    correct_trials = [];
                    correct_fst =[];
                    running_fst = 0;
                    running_perf = 0;                                                   % reset perf calculation
                    n_rewards = 0;                                                  % reset n_rewards
                    trial_no_switch = [trial_no_switch trial_number];
                    freewater_block = [freewater_block randi([min_freewater_block max_freewater_block])];
                    
                elseif trial_type_switch == 1 & running_perf >= perf_cus & length(valid_trials)>=5
                    sound_index_side = (length(ILD) - sound_index_side) + 1;
                    soundside_switch = 1;
                    valid_trials = [];
                    correct_trials = [];
                    correct_fst =[];
                    running_fst = 0;
                    running_perf = 0;                                                   % reset perf calculation
                    n_rewards = 0;                                                  % reset n_rewards
%                     switch_trial_no = [switch_trial_no trial_number];
%                     freewater_block = [freewater_block randi([min_freewater_block max_freewater_block])];
                   
                else                                                                 % during no switches
                    sound_index_side = sound_index_side;
                end
                              
            elseif phase == 1
                
                if lock_soundside == 0                                              % first trial
                    sound_index_side = sound_index_start;
                    sound_index_side = randi(length(ILD),1,1);                      % pick a random index for ABL
                    lock_soundside = 1;                                             % lock soundside for now
                    freewater_block = [freewater_block randi([min_freewater_block max_freewater_block])];
  
                elseif length(freewater_block) <= set_freewater_block 
                    if soundside_switch == 1          % switch side in the first 4 FWT sets
                        sound_index_side = (length(ILD) - sound_index_side) + 1;
                        n_rewards = 0;                                                  % reset n_rewards
                        freewater_block = [freewater_block randi([min_freewater_block max_freewater_block])];
                    else
                        sound_index_side = sound_index_side;
                    end
                        
                    
                else
                    sound_index_side = side(trial_number);
                end
                
            else
                sound_index_side = side(trial_number);
            end
            
            diff_touse = randi(length(ILD)/2,1);
            

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
            
            if trial_number>1
                allstim_times{trial_number-1} = track_time_stimuli;
            end
            track_time_stimuli = [];
                        
            
            % in phase 0, check whether we should go to a sound_prime or freewater_prime case

            if phase == 0
                
                if lock_freewater == 0                             % first trial
                    state_change = 'freewater_prime';
                    count_freewater = 1;
                    lock_freewater = 1;
                    free_water = 1;
                end
                
                if trial_type_switch == 0                          % blocks of FWTs
                    state_change = 'freewater_prime';
                    free_water = 1;
                else                                                % blocks of FWT-ST
                    if soundside_switch == 1                        
                        state_change = 'freewater_prime';
                        count_freewater = 1;
                        free_water = 1;
                        soundside_switch=0;
                    else
                        count_freewater = count_freewater + 1;         % during no switch
                        free_water = 1;
                        state_change = 'freewater_prime';
                    end
                    
                    if count_freewater >= freewater_block(end)       % the 3th FWT in one of the FWT sets
                        state_change = 'sound_prime';
                        free_water = 0;
                        if n_failedst == n_failedst_max                    % FWT when fail multiple times
                            n_failedst_max = randi([min_st max_st]);
                            n_failedst = 0;
                            trial_switch = 1;                              % to terminate repeats in FWT that's triggered by successive failed/disengaged
                            state_change = 'freewater_prime';
                            free_water = 1;
                        elseif n_disengaged == n_disengaged_max            % FWT when disengaged multiple times
                            n_disengaged_max = randi([min_st max_st]);
                            n_disengaged = 0;
                            trial_switch = 1;
                            state_change = 'freewater_prime';
                            free_water = 1;
                        end
                    end
                end
                
                
            elseif phase == 1
                if length(freewater_block) <= set_freewater_block     % first 4 FWT sets
                    
                    if lock_freewater == 0                             % first trial
                        state_change = 'freewater_prime'
                        count_freewater = 1;
                        lock_freewater = 1;
                        free_water = 1;
                    elseif soundside_switch == 1                       % start of every switch
                        state_change = 'freewater_prime'
                        count_freewater = 1;
                        free_water = 1;
                        soundside_switch=0;
                    else
                        count_freewater = count_freewater + 1;         % during no switch
                        free_water = 1;
                        state_change = 'freewater_prime'
                    end
                    
                    if count_freewater >= freewater_block(end)       % the 3th FWT in one of the FWT sets
                        soundside_switch = 1;
                    end
                    
                else
                    
                    state_change = 'sound'                       % now full on ST
                    free_water = 0;
                    if n_failedst == n_failedst_max                    % FWT when fail multiple times
                        n_failedst_max = randi([min_st max_st]);
                        n_failedst = 0;
                        trial_switch = 1;                              % to terminate repeats in FWT that's triggered by successive failed/disengaged
                        state_change = 'freewater'
                        free_water = 1;
                    elseif n_disengaged == n_disengaged_max            % FWT when disengaged multiple times
                        n_disengaged_max = randi([min_st max_st]);
                        n_disengaged = 0;
                        trial_switch = 1;
                        state_change = 'freewater'
                        free_water = 1;
                    end
                end
            end
            
            
            
            % change state
            state = 'secondhalf_ITI';
                        
            if (trial_number-1)==max_trial
                task = 0;
            end
            
        case 'sound_prime'
            
            sb_io_set_dig(board,sound_trigger,1) 
            PsychPortAudio('Start', pahandle, 1, 0, 1);                             % trigger the sound
            time_stimulus = now;
            
           % what is the correct response
            correct_response = ((sign(ILD(sound_index)))+1)/2;
                       
           % outcome of trial
           [correct, response, rt, licks_left, licks_right, release_left, release_right, vecL, vecR, NewLickOk] = sample_lick(time_stimulus, response_window, 0, board, baseline_spout, vecL, vecR, licks_left, licks_right, release_left, release_right, NewLickOk, correct_response);


           % stop sound when there's a lick or not responding for the whole
           % trial
            PsychPortAudio('Stop', pahandle, 2, 0);        
            
            % if it's incorrect, punish and exit
            if (correct==0) && (response~=0.5)
                n_failedst = n_failedst + 1;                   % keep count of number of failed standard trials
                n_disengaged = 0;                              % reset disengaged trials
                repeat_sound = 0;
                state = 'punishment';
                
            % if it's not responding, wait for 0.5s and repeat until repeat_sound = 5
            elseif (correct==0) && (response==0.5)
                sb_io_set_dig(board,sound_trigger,0)
                
                if repeat_sound == (st_repeat - 1)                          % so that there's no 0.5s lag
                    state = 'punishment'
                    repeat_sound = 0;                                       % reset repeat
                    n_disengaged = n_disengaged + 1;
                    n_failedst = 0;                                         % reset failes trials
                else
                    [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(inbetween_repeat,lickNexit,board,baseline_spout,vecL,vecR, NewLickOk);
                    licks_left = [licks_left; time_licks{1}];      % save licks left
                    licks_right = [licks_right; time_licks{2}];    % save licks right
                    release_left = [release_left; noTouch{1}];      % save release left
                    release_right = [release_right; noTouch{2}];    % save release right

                    repeat_sound = repeat_sound + 1;               % keep count of number of repeats
                    state = 'sound_prime'
                    
                    end
                
            % if it's correct
            elseif correct==1
                DeliverReward_IO(correct_response,board,ValveTime);
               
                
                n_rewards = n_rewards + 1;                      % keep count of number of rewards to change sound side
                n_rewards_tot = n_rewards_tot + 1;              % keep count of the total number of rewards
                n_failedst = 0;
                n_disengaged = 0;
                repeat_sound = 0;
                state = 'firsthalf_ITI'
                

            end
            
                        
            track_time_stimuli = [track_time_stimuli time_stimulus];
            sb_io_set_dig(board,sound_trigger,0) 
            
                     
        case 'freewater_prime'
            
            sb_io_set_dig(board,sound_trigger,1)                  % Tell Arduino
            PsychPortAudio('Start', pahandle, 1, 0, 1);           % trigger the sound
            time_stimulus = now;

            % what is the correct response
            correct_response = ((sign(ILD(sound_index)))+1)/2;
                        
            % first freewater presentation
            if repeat_fw == 0
            % before 0.5s
                bwt = now;
                [correct, response, rt, licks_left, licks_right, release_left, release_right, vecL, vecR, NewLickOk] = sample_lick(time_stimulus, time_freewater, 1, board, baseline_spout, vecL, vecR, licks_left, licks_right, release_left, release_right, NewLickOk, correct_response);
                wt = now;
                if (wt - bwt)*conv_fac_time <0.5
                    DeliverReward_IO(correct_response,board,ValveTime);
                end
                % deliver water if didn't respond correctly in the first 0.5s
                if correct == 0
                    DeliverReward_IO(correct_response,board,ValveTime);
                    [correct, response, rt, licks_left, licks_right, release_left, release_right, vecL, vecR, NewLickOk] = sample_lick(time_stimulus, response_window - time_freewater, 1, board, baseline_spout, vecL, vecR, licks_left, licks_right, release_left, release_right, NewLickOk, correct_response);
                end
                
            % first repeat and so on
            else
                
                [correct, response, rt, licks_left, licks_right, release_left, release_right, vecL, vecR, NewLickOk] = sample_lick(time_stimulus, response_window, 1, board, baseline_spout, vecL, vecR, licks_left, licks_right, release_left, release_right, NewLickOk, correct_response);

            end
            
            PsychPortAudio('Stop', pahandle, 2, 0);        % if the animal licks , we stop the sound right away
            
            % check correct  
            
            if correct == 0
                
                repeat_fw = repeat_fw + 1;
                
                if repeat_fw == fwt_repeat | trial_switch == 1
                    
                    repeat_fw = 0;                                  % reset repeat
                    trial_switch = 0;                               % reset trial switch
                    state = 'punishment'

                else
                    
                    sb_io_set_dig(board,sound_trigger,0)
                    
                    [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(inbetween_repeat,lickNexit,board,baseline_spout,vecL,vecR, NewLickOk);
                    licks_left = [licks_left; time_licks{1}];      % save licks left
                    licks_right = [licks_right; time_licks{2}];    % save licks right
                    release_left = [release_left; noTouch{1}];      % save release left
                    release_right = [release_right; noTouch{2}];    % save release right
                    
                    state = 'freewater_prime'
                    
                    
                end
                
            else
                
                
                fwt_track = fwt_track + 1;                    % keep track of collected water
                repeat_fw = 0;
                trial_switch = 0;
                state = 'firsthalf_ITI';
                
            end
        
            track_time_stimuli = [track_time_stimuli time_stimulus];
            sb_io_set_dig(board,sound_trigger,0)
                                    
        case 'sound'
            
            sb_io_set_dig(board,sound_trigger,1)
            PsychPortAudio('Start', pahandle, 1, 0, 1);                     % trigger the sound
            time_stimulus = now;
            [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(response_window,lickYexit,board,baseline_spout,vecL,vecR, NewLickOk);
            licks_left = [licks_left; time_licks{1}];                       % save licks left
            licks_right = [licks_right; time_licks{2}];                     % save licks right
            release_left = [release_left; noTouch{1}];                      % save release left
            release_right = [release_right; noTouch{2}];                    % save release right
            PsychPortAudio('Stop', pahandle, 2, 0);                         % if the animal licks, we stop the sound right away
            
            % check the responses
            if isempty(time_licks{1})==0
                response = 0;                                               % response was left
                rt = (time_licks{1}-time_stimulus)*conv_fac_time;
            elseif isempty(time_licks{2})==0
                response = 1;                                               % response was right
                rt = (time_licks{2}-time_stimulus)*conv_fac_time;
            else
                response = 0.5;                                             % no response
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
                [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(response_window-rt,lickNexit,board,baseline_spout,vecL,vecR, NewLickOk);
                licks_left = [licks_left; time_licks{1}];                   % save licks left
                licks_right = [licks_right; time_licks{2}];                 % save licks right
                release_left = [release_left; noTouch{1}];                  % save release left
                release_right = [release_right; noTouch{2}];                % save release right
            end
               
            % if it's incorrect
            if (correct==0) && (response~=0.5)                
                state = 'punishment';
            else
                state = 'firsthalf_ITI';
            end
            
            track_time_stimuli = [track_time_stimuli time_stimulus];
            sb_io_set_dig(board,sound_trigger,0)
         
        case 'freewater'
            
            sb_io_set_dig(board,sound_trigger,1);
            PsychPortAudio('Start', pahandle, 1, 0, 1);                             % trigger the sound
            time_stimulus = now;
            [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(time_freewater,lickNexit,board,baseline_spout,vecL,vecR, NewLickOk);
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
            release_left = [release_left; noTouch{1}];      % save release left
            release_right = [release_right; noTouch{2}];    % save release right
            
             % what would be the correct response
            correct_response = ((sign(ILD(sound_index)))+1)/2;
                        
            % deliver the water automatically after time_freewater
            DeliverReward_IO(correct_response,board,ValveTime);
            
            % restart tracking licks
            [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(response_window-time_freewater,lickYexit,board,baseline_spout,vecL,vecR, NewLickOk);
            licks_left = [licks_left; time_licks{1}];      % save licks left
            licks_right = [licks_right; time_licks{2}];    % save licks right
            release_left = [release_left; noTouch{1}];      % save release left
            release_right = [release_right; noTouch{2}];    % save release right
       
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
                [time_licks,noTouch,vecL,vecR, NewLickOk] = Check2Spouts_IOBoard_2020(response_window-rt,lickNexit,board,baseline_spout,vecL,vecR, NewLickOk);
                licks_left = [licks_left; time_licks{1}];      % save licks left
                licks_right = [licks_right; time_licks{2}];    % save licks right
                release_left = [release_left; noTouch{1}];      % save release left
                release_right = [release_right; noTouch{2}];    % save release right
            end
               
            % if it's incorrect
            if (correct==0) && (response~=0.5)                
                state = 'punishment';
            else
                state = 'firsthalf_ITI';
            end
            
            track_time_stimuli = [track_time_stimuli time_stimulus];
            sb_io_set_dig(board,sound_trigger,0);
           
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
free_water_vec = free_water_vec(1:trial_number);
dis_trials_vec = dis_trials_vec(1:trial_number);
time_secondhalfITI_vec = time_secondhalfITI_vec(1:trial_number);
time_elapsed_vec = time_elapsed_vec(1:trial_number);
time_elapseddis_vec = time_elapseddis_vec(1:trial_number);
tnl_duration_vec = tnl_duration_vec(1:trial_number);
tfwt_duration_vec = tfwt_duration_vec(1:trial_number);
bias_vec = bias_vec(1:trial_number,:);
perf_vec = perf_vec(1:trial_number,:);
running_perf_vec = running_perf_vec(1:trial_number);
running_fst_vec = running_fst_vec(1:trial_number);
licks_left(1) = NaN;
licks_right(1) = NaN;
release_left(1) = NaN;
release_right(1) = NaN;
params_touse.min_duration_iti = min_duration_iti;
params_touse.max_duration_iti = max_duration_iti;
params_touse.min_duration_fwt = min_duration_fwt;
params_touse.max_duration_fwt = max_duration_fwt;



data = [mouse_number*ones(trial_number,1) session*ones(trial_number,1) [1:trial_number]' response_vec stimulus_vec stimulus_ABL stimulus_ILD sound_pres_vec correct_vec rt_vec bias_vec(:,1) running_fst_vec running_perf_vec running_fst_vec p_vec time_lost_vec time_secondhalfITI_vec time_elapsed_vec time_elapseddis_vec tnl_duration_vec tfwt_duration_vec free_water_vec dis_trials_vec mouse_weight*ones(trial_number,1) phase*ones(trial_number,1)];
varNames = {'MouseID','Session','TrialNumber','Response','Stimulus','ABL','ILD','StimulusTime','Correct','RT','Bias','Perf', 'RunningPerf', 'RunningFst', 'ProbStimulus','TimeLost','TimeSecondhalfITI', 'ElapsedTime', 'ElapsedTimeDis', 'TimeNL', 'TimeFWT', 'FreeWater', 'Disengaged', 'MouseWeight','Phase'};
table_data = array2table(data);
table_data.Properties.VariableNames = varNames;

% package the data properly
datastruct(session).table_data = table_data;
datastruct(session).licks.licks_left = licks_left;
datastruct(session).licks.licks_right = licks_right;
datastruct(session).licks.release_left = release_left;
datastruct(session).licks.release_right = release_right;
datastruct(session).mouse_number = mouse_number;
datastruct(session).mouse_weight = mouse_weight;
datastruct(session).params_touse = params_touse;
datastruct(session).allstim_times = allstim_times;

% and now we save the files
save(filename,'datastruct')
save(filename_local,'datastruct')
