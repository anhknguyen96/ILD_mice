function params_touse = choose_params_v6(phase)

switch phase
    
     case 0
         
        time_flash = 0.02;              % duration between flash
        inbetween_repeat = 0.5;         % duration between repeats in FWT and ST
        st_repeat = 4;                  % sound presentation repeat in ST
        fwt_repeat = 4;                % sound presentation repeat in FWT
        min_rewards = 6;                % min successful ST to trigger block change
        max_rewards = 10;               % max successful ST to trigger block change
        min_st = 3;                     % min failed/disengaged ST 
        max_st = 6;                     % max failed/disengaged ST
        min_freewater_block = 5;        % min number of FWT 
        max_freewater_block = 5;        % max number of FWT 
        set_freewater_block = 10;
        sound_duration = 3;             % sound duration (s)
        min_duration_fwt = 55;          % minimum duration for the next free water after disengagement (s)
        max_duration_fwt = 60;          % maximum duration for the next free water after disengagement (s)  
        min_duration_iti = 6;           % minimum duration ITI (s)
        mean_duration_iti = 7;          % mean duration ITI (s)
        max_duration_iti = 10;           % maximum duration ITI (s)
        response_window = 2;            % response window for the animal to report (s)
        tau_bias = [0.8 0.95];          % parameters for bias moving average estimation
        tau_perf = [0.8 0.95];          % parameters for performance moving average estimation
%         gamma_bias = 1e6;               % gain to control bias-removal strength
%         gamma_perf = 1e6;               % gain to control multiple ILDs
        gamma_bias = 0.18;               % gain to control bias-removal strength
        gamma_perf = 0.5;               % gain to control multiple ILDs
        max_trial = 1000;               % max number of trials
        time_punishment = 0;            % timeout after mistakes (s)
        ABL = [30];                     % ABL (dB)
        ILD = [-60 60];                 % ILD (dB)
        ABL_block = 1;                  % if 1 means that ABL is picked fresh every trial, if more, that's the block size
        f_range = [2000 16000];         % frequency range noise (Hz)
        ramp_duration = 0.01;           % ramp duration (s)
        nbias_freewater = 5;           % number of consecutive bias that triggers free water
        time_freewater = 0.5;           % time to wait to deliver free water
        
    case 1
        
        time_flash = 0.02;              % duration between flash
        inbetween_repeat = 0.5;         % duration between repeats in FWT and ST
        st_repeat = 4;                  % sound presentation repeat in ST
        fwt_repeat = 4;                % sound presentation repeat in FWT
        min_rewards = 6;                % min successful ST to trigger block change
        max_rewards = 10;               % max successful ST to trigger block change
        min_st = 3;                      % min failed/disengaged ST 
        max_st = 6;                      % max failed/disengaged ST
        min_freewater_block = 4;        % min number of FWT 
        max_freewater_block = 4;        % max number of FWT 
        set_freewater_block = 2;
        sound_duration = 3;             % sound duration (s)
        min_duration_fwt = 55;          % minimum duration for the next free water after disengagement (s)      
        max_duration_fwt = 60;          % maximum duration for the next free water after disengagement (s)      
        min_duration_iti = 6;           % minimum duration ITI (s)
        mean_duration_iti = 8.32;          % mean duration ITI (s)
        max_duration_iti = 10;           % maximum duration ITI (s)
        response_window = 2;            % response window for the animal to report (s)
        tau_bias = [0.8 0.95];          % parameters for bias moving average estimation
        tau_perf = [0.9 0.95];          % parameters for performance moving average estimation
%         gamma_bias = 1e6;               % gain to control bias-removal strength
%         gamma_perf = 1e6;               % gain to control multiple ILDs
        gamma_bias = 0.25;               % gain to control bias-removal strength
        gamma_perf = 0.5;               % gain to control multiple ILDs
        max_trial = 1000;               % max number of trials
        time_punishment = 12;            % timeout after mistakes (s)
        ABL = [30];                     % ABL (dB)
        ILD = [-60 60];                 % ILD (dB)
        ABL_block = 1;                  % if 1 means that ABL is picked fresh every trial, if more, that's the block size
        f_range = [2000 16000];         % frequency range noise (Hz)
        ramp_duration = 0.01;           % ramp duration (s)
        nbias_freewater = 5;           % number of consecutive bias that triggers free water
        time_freewater = 0.5;           % time to wait to deliver free water
        
    case 2
        
        time_flash = 0.1;              % duration between flash
        inbetween_repeat = 0.5;         % duration between repeats in FWT and ST
        st_repeat = 5;                  % sound presentation repeat in ST
        fwt_repeat = 12;                % sound presentation repeat in FWT
        min_rewards = 6;                % min successful ST to trigger block change
        max_rewards = 10;               % max successful ST to trigger block change
        min_st = 3;                     % min failed/disengaged ST 
        max_st = 6;                     % max failed/disengaged ST
        min_freewater_block = 2;        % min number of FWT 
        max_freewater_block = 2;        % max number of FWT 
        set_freewater_block = 2;
        sound_duration = 2;             % sound duration (s)
        min_duration_fwt = 1;          % minimum duration for the next free water after disengagement (s)
        max_duration_fwt = 2;          % maximum duration for the next free water after disengagement (s)  
        min_duration_iti = 3;           % minimum duration ITI (s)
        mean_duration_iti = 8.32;          % mean duration ITI (s)
        max_duration_iti = 4;          % maximum duration ITI (s)
        response_window = 2;            % response window for the animal to report (s)
        tau_bias = [0.8 0.95];          % parameters for bias moving average estimation
        tau_perf = [0.9 0.95];          % parameters for performance moving average estimation
        gamma_bias = 1e6;               % gain to control bias-removal strength
        gamma_perf = 1e6;               % gain to control multiple ILDs
%         gamma_bias = 0.25;               % gain to control bias-removal strength
%         gamma_perf = 0.5;               % gain to control multiple ILDs
        max_trial = 1000;               % max number of trials
        time_punishment = 12;            % timeout after mistakes (s)
%         ABL = [30];                     % ABL (dB)
%         ILD = [-60 60];                 % ILD (dB)
        ABL = [40];                     % ABL (dB)
        ILD = [-40 40];                 % ILD (dB)
        ABL_block = 1;                  % if 1 means that ABL is picked fresh every trial, if more, that's the block size
        f_range = [2000 16000];         % frequency range noise (Hz)
        ramp_duration = 0.01;           % ramp duration (s)
        nbias_freewater = 5;           % number of consecutive bias that triggers free water
        time_freewater = 0.5;           % time to wait to deliver free water
                
    case 3
        
        time_flash = 0.1;              % duration between flash
        inbetween_repeat = 0.5;         % duration between repeats in FWT and ST
        st_repeat = 5;                  % sound presentation repeat in ST
        fwt_repeat = 12;                % sound presentation repeat in FWT
        min_rewards = 6;                % min successful ST to trigger block change
        max_rewards = 10;               % max successful ST to trigger block change
        min_st = 3;                     % min failed/disengaged ST 
        max_st = 6;                     % max failed/disengaged ST
        min_freewater_block = 2;        % min number of FWT 
        max_freewater_block = 2;        % max number of FWT 
        set_freewater_block = 2;
        sound_duration = 2;                             % sound duration (s)
        min_duration_fwt = 5;          % minimum duration for the next free water after disengagement (s)
        max_duration_fwt = 6;          % maximum duration for the next free water after disengagement (s)  
        min_duration_iti = 1;                           % minimum duration ITI (s)
        mean_duration_iti = 1.5;                         % mean duration ITI (s)
        max_duration_iti = 2;                          % maximum duration ITI (s)
        response_window = 2;                            % response window for the animal to report (s)
        tau_bias = [0.8 0.95];                          % parameters for bias moving average estimation
        tau_perf = [0.9 0.95];                          % parameters for performance moving average estimation
        gamma_bias = 1e6;                               % gain to control bias-removal strength
        gamma_perf = 1e6;                               % gain to control multiple ILDs
        max_trial = 1000;                               % max number of trials
        time_punishment = 12;                            % timeout after mistakes (s)
        ABL = [40];                                     % ABL (dB)
        ILD = [-16 -12 -8 -4 4 8 12 16];        % ILD (dB)
        ABL_block = 1;                                  % if 1 means that ABL is picked fresh every trial, if more, that's the block size
        f_range = [2000 16000];                         % frequency range noise (Hz)
        ramp_duration = 0.01;                           % ramp duration (s)
        nbias_freewater = 5;                           % number of consecutive bias that triggers free water
        time_freewater = 0.5;                           % time to wait to deliver free water
        
            
    case 4
        
        time_flash = 0.02;              % duration between flash
        inbetween_repeat = 0.5;         % duration between repeats in FWT and ST
        st_repeat = 5;                  % sound presentation repeat in ST
        fwt_repeat = 12;                % sound presentation repeat in FWT
        min_rewards = 6;                % min successful ST to trigger block change
        max_rewards = 10;               % max successful ST to trigger block change
        min_st = 3;                     % min failed/disengaged ST 
        max_st = 6;                     % max failed/disengaged ST
        min_freewater_block = 2;        % min number of FWT 
        max_freewater_block = 2;        % max number of FWT 
        set_freewater_block = 2;
        sound_duration = 3;                             % sound duration (s)
        min_duration_fwt = 100;          % minimum duration for the next free water after disengagement (s)
        max_duration_fwt = 120;          % maximum duration for the next free water after disengagement (s)  
        min_duration_iti = 4;                           % minimum duration ITI (s)
        mean_duration_iti = 8;                          % mean duration ITI (s)
        max_duration_iti = 16;                          % maximum duration ITI (s)
        response_window = 3;                            % response window for the animal to report (s)
        tau_bias = [0.7 0.95];                          % parameters for bias moving average estimation
        tau_perf = [0.9 0.95];                          % parameters for performance moving average estimation
        gamma_bias = 0.5;                               % gain to control bias-removal strength
        gamma_perf = 0.5;                               % gain to control multiple ILDs
        max_trial = 1000;                               % max number of trials
        time_punishment = 10;                           % timeout after mistakes (s)
        ABL = [20 40 60];                               % ABL (dB)
        ILD = [-10 -5 -2.5 -1.25 1.25 2.5 5 10];        % ILD (dB)
        ABL_block = 30;                                 % if 1 means that ABL is picked fresh every trial, if more, that's the block size
        f_range = [2000 16000];                         % frequency range noise (Hz)
        ramp_duration = 0.01;                           % ramp duration (s)
        nbias_freewater = 5;                           % number of consecutive bias that triggers free water
        time_freewater = 0.5;                           % time to wait to deliver free water
                
end

% save everything
params_touse.time_flash = time_flash;
params_touse.inbetween_repeat = inbetween_repeat;
params_touse.st_repeat = st_repeat; 
params_touse.fwt_repeat = fwt_repeat; 
params_touse.min_rewards = min_rewards; 
params_touse.max_rewards = max_rewards;
params_touse.min_st = min_st; 
params_touse.max_st = max_st;
params_touse.min_freewater_block = min_freewater_block;
params_touse.max_freewater_block = max_freewater_block;
params_touse.set_freewater_block = set_freewater_block;  
params_touse.min_duration_fwt = min_duration_fwt;
params_touse.max_duration_fwt = max_duration_fwt;
params_touse.min_duration_iti = min_duration_iti;
params_touse.mean_duration_iti = mean_duration_iti;
params_touse.max_duration_iti = max_duration_iti;
params_touse.response_window = response_window;
params_touse.tau_bias = tau_bias;
params_touse.tau_perf = tau_perf;
params_touse.gamma_bias = gamma_bias;
params_touse.gamma_perf = gamma_perf;
params_touse.max_trial = max_trial;
params_touse.time_punishment = time_punishment;
params_touse.phase = phase;
params_touse.ABL = ABL;
params_touse.ILD = ILD;
params_touse.ABL_block = ABL_block;
params_touse.f_range = f_range;
params_touse.sound_duration = sound_duration;
params_touse.ramp_duration = ramp_duration;
params_touse.nbias_freewater = nbias_freewater;
params_touse.time_freewater = time_freewater;
        
