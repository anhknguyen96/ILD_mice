function params_touse = choose_params(phase)

switch phase
    
    case 1
        
        sound_duration = 3;             % sound duration (s)
        duration_nolick_prestim = 0;    % time animals must not lick before stimulus presentation (s)
        min_duration_iti = 2;           % minimum duration ITI (s)
        mean_duration_iti = 4;          % mean duration ITI (s)
        max_duration_iti = 8;           % maximum duration ITI (s)
        response_window = 3;            % response window for the animal to report (s)
        tau_bias = [0.7 0.95];          % parameters for bias moving average estimation
        tau_perf = [0.9 0.95];          % parameters for performance moving average estimation
        gamma_bias = 1e6;               % gain to control bias-removal strength
        gamma_perf = 1e6;               % gain to control multiple ILDs
        max_trial = 1000;               % max number of trials
        time_punishment = 0;            % timeout after mistakes (s)
        ABL = [30];                     % ABL (dB)
        ILD = [-60 60];                 % ILD (dB)
        ABL_block = 1;                  % if 1 means that ABL is picked fresh every trial, if more, that's the block size
        f_range = [2000 16000];         % frequency range noise (Hz)
        ramp_duration = 0.01;           % ramp duration (s)
        nskips_freewater = 1e6;         % number of consecutive skips that triggers free water
        time_freewater = 0.5;           % time to wait to deliver free water
        
    case 2
        
        sound_duration = 3;             % sound duration (s)
        duration_nolick_prestim = 1;    % time animals must not lick before stimulus presentation (s)
        min_duration_iti = 4;           % minimum duration ITI (s)
        mean_duration_iti = 8;         % mean duration ITI (s)
        max_duration_iti = 16;          % maximum duration ITI (s)
        response_window = 3;            % response window for the animal to report (s)
        tau_bias = [0.7 0.95];          % parameters for bias moving average estimation
        tau_perf = [0.9 0.95];          % parameters for performance moving average estimation
        gamma_bias = 0.5;               % gain to control bias-removal strength
        gamma_perf = 0.5;               % gain to control multiple ILDs
        max_trial = 1000;               % max number of trials
        time_punishment = 8;           % timeout after mistakes (s)
        ABL = [30];                     % ABL (dB)
        ILD = [-60 60];                 % ILD (dB)
        ABL_block = 1;                  % if 1 means that ABL is picked fresh every trial, if more, that's the block size
        f_range = [2000 16000];         % frequency range noise (Hz)
        ramp_duration = 0.01;           % ramp duration (s)
        nskips_freewater = 20;          % number of consecutive skips that triggers free water
        time_freewater = 0.5;           % time to wait to deliver free water
                
    case 3
        
        sound_duration = 3;                             % sound duration (s)
        duration_nolick_prestim = 1;                    % time animals must not lick before stimulus presentation (s)
        min_duration_iti = 4;                           % minimum duration ITI (s)
        mean_duration_iti = 8;                         % mean duration ITI (s)
        max_duration_iti = 16;                          % maximum duration ITI (s)
        response_window = 3;                            % response window for the animal to report (s)
        tau_bias = [0.7 0.95];                          % parameters for bias moving average estimation
        tau_perf = [0.9 0.95];                          % parameters for performance moving average estimation
        gamma_bias = 0.5;                               % gain to control bias-removal strength
        gamma_perf = 0.5;                               % gain to control multiple ILDs
        max_trial = 1000;                               % max number of trials
        time_punishment = 8;                            % timeout after mistakes (s)
        ABL = [50];                                     % ABL (dB)
        ILD = [-10 -5 -2.5 -1.25 1.25 2.5 5 10];        % ILD (dB)
        ABL_block = 1;                                  % if 1 means that ABL is picked fresh every trial, if more, that's the block size
        f_range = [2000 16000];                         % frequency range noise (Hz)
        ramp_duration = 0.01;                           % ramp duration (s)
        nskips_freewater = 1e6;                          % number of consecutive skips that triggers free water
        time_freewater = 0.5;                           % time to wait to deliver free water
        
            
    case 4
        
        sound_duration = 3;                             % sound duration (s)
        duration_nolick_prestim = 1;                    % time animals must not lick before stimulus presentation (s)
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
        nskips_freewater = 1e6;                         % number of consecutive skips that triggers free water
        time_freewater = 0.5;                           % time to wait to deliver free water
                
end

% save everything
params_touse.duration_nolick_prestim = duration_nolick_prestim;
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
params_touse.nskips_freewater = nskips_freewater;
params_touse.time_freewater = time_freewater;
        
