function networkslice_wdm_controller()
    %% Complete Event-Driven 5G SDN Interactive Core Simulation Panel
    clc;

    % Initialize the random number generator to shuffle ONCE at app bootup
    rng('shuffle'); 

    %% 1. Persistent Topography Layer Setup
    nodeNames = {'gNB_A', 'gNB_B', 'gNB_C', 'Edge_DC', 'Core_DC'};
    numNodes  = length(nodeNames);

    distances = [
         0,  20, Inf,  30, Inf;  
        20,   0,  25,  45, Inf;  
       Inf,  25,   0,  25,  70;  
        30,  45,  25,   0,  40;  
       Inf, Inf,  70,  40,   0   
    ];

    energyCosts = [
         0,  15, Inf,  15, Inf;  
        15,   0,  20,  90, Inf;  
       Inf,  20,   0,  20,  60;  
        15,  90,  20,   0,  30;  
       Inf, Inf,  60,  30,   0   
    ];

    connectionLoad = [
         0,  10, Inf,  15, Inf;  
        10,   0,  15,  30, Inf;  
       Inf,  15,   0,  20,  95;  
        15,  30,  20,   0,  15;  
       Inf, Inf,  95,  15,   0   
    ];

    % Global normalization factors
    max_d = max(distances(~isinf(distances)));
    max_e = max(energyCosts(~isinf(energyCosts)));
    max_l = max(connectionLoad(~isinf(connectionLoad)));

    cleanDistances = distances;
    cleanDistances(isinf(cleanDistances)) = 0; 
    G_latency = graph(cleanDistances, nodeNames, 'omitselfloops');
    numEdges  = numedges(G_latency); 

    %% 2. Persistent WDM Physical Spectrum Snapshot
    lambdaNames = {'\lambda_1', '\lambda_2', '\lambda_3', '\lambda_4'};
    channel_clear_probability = 0.55; 
    
    % Generated ONCE here. It remains identical no matter how many changes you make in UI
    wavelength_pool_snapshot = double(rand(numEdges, 4) <= channel_clear_probability);

    % Core operational network physical constants
    fiber_attenuation = 0.2;       
    c_light_fiber = 2e5;           
    base_launch_power = 45.0;      
    receiver_noise_figure = 5.0;   
    
    % EDFA Amplifier Engineering Specifications
    edfa_distance_threshold = 70.0; % km trigger threshold for inline amplification
    edfa_ase_noise_penalty = 0.35;  % dB accumulated OSNR noise floor penalty per stage

    %% 3. UI Window & Graphic Component Assembly
    fig = uifigure('Name', 'SDN Core Controller Telemetry Dashboard', 'Position', [80, 80, 1250, 540]);
    fig.Color = [0.94, 0.94, 0.96];

    % App Banner Title
    lblTitle = uilabel(fig, 'Text', '5G-OPTICAL INTENT-BASED CROSS-LAYER CONTROLLER INTERACTIVE CONTROL PANEL', ...
        'Position', [25, 495, 1200, 40], 'FontWeight', 'bold', 'FontSize', 15, ...
        'FontName', 'Arial', 'FontColor', [0.1, 0.2, 0.4]);

    % Left Sidebar Control Panel Container
    pnlControls = uipanel(fig, 'Title', 'SDN Intent Parameters', 'Position', [25, 25, 240, 460], ...
        'FontWeight', 'bold', 'FontSize', 11, 'BackgroundColor', [0.91, 0.92, 0.95]);

    % Ingress Selector Dropdown
    uilabel(pnlControls, 'Text', 'Select Ingress Network gNB:', 'Position', [15, 395, 200, 20], 'FontWeight', 'bold');
    ddSource = uidropdown(pnlControls, 'Items', {'gNB_A', 'gNB_B', 'gNB_C'}, 'Position', [15, 365, 200, 30], ...
        'ValueChangedFcn', @(src, event) executeSdnEngine());

    % SLA Slice Selector Dropdown
    uilabel(pnlControls, 'Text', 'Service Level Agreement (SLA):', 'Position', [15, 305, 200, 20], 'FontWeight', 'bold');
    ddSlice = uidropdown(pnlControls, 'Items', {'1. eMBB (High Capacity)', '2. URLLC (Ultra-Low Latency)', '3. mMTC (Massive Balancing)'}, ...
        'Position', [15, 275, 200, 30], 'ValueChangedFcn', @(src, event) executeSdnEngine());

    % Local Fiber Degradation Switch
    uilabel(pnlControls, 'Text', 'Inject Outbound Fiber Degradation:', 'Position', [15, 205, 200, 20], 'FontWeight', 'bold');
    swDegradation = uiswitch(pnlControls, 'slider', 'Items', {'No', 'Yes'}, 'Position', [85, 155, 60, 40], ...
        'ValueChangedFcn', @(src, event) executeSdnEngine());

    % O-E-O Wavelength Conversion Switch
    uilabel(pnlControls, 'Text', 'Enable Node O-E-O Converters:', 'Position', [15, 95, 200, 20], 'FontWeight', 'bold');
    swConversion = uiswitch(pnlControls, 'slider', 'Items', {'No', 'Yes'}, 'Position', [85, 45, 60, 40], ...
        'ValueChangedFcn', @(src, event) executeSdnEngine());

    % Center Grid Table Component
    tableDashboard = uitable(fig, 'Position', [285, 25, 530, 460]);
    tableDashboard.ColumnName = {'SDN Infrastructure Parameter', 'Live Telemetry', 'Controller Context Analysis'};
    tableDashboard.ColumnWidth = {180, 175, 170};
    tableDashboard.FontSize = 10.5;
    tableDashboard.FontName = 'Arial';

    % Right Side Graphic Topology Component
    axTopology = uiaxes(fig, 'Position', [835, 25, 390, 460]);
    axTopology.Color = [0.98, 0.98, 1.0];
    title(axTopology, 'Live Transport Graph Topology View', 'FontWeight', 'bold', 'FontSize', 12, 'Color', [0.1, 0.2, 0.4]);

    % Initial Static Setup for Graph Visualization (Prevents layout jumping)
    pGraph = plot(axTopology, G_latency, 'EdgeLabel', G_latency.Edges.Weight, ...
        'LineWidth', 1.5, 'EdgeColor', [0.7, 0.7, 0.7], 'NodeColor', [0.2, 0.2, 0.2], ...
        'MarkerSize', 7, 'NodeFontWeight', 'bold', 'EdgeFontWeight', 'bold', ...
        'NodeFontSize', 10, 'EdgeFontSize', 10);
    axTopology.XTick = []; axTopology.YTick = [];

    %% 4. The Live Recalculation Engine Callback Block
    % Call once at startup to populate initial selection data
    executeSdnEngine();

    function executeSdnEngine()
        % Reset the local mutable wavelength pool copy using the unchanged global blueprint
        wavelength_pool = wavelength_pool_snapshot;

        % Parse Interactive UI Inputs
        sourceNode = ddSource.Value;
        slice_choice = ddSlice.Value;
        is_congested = strcmp(swDegradation.Value, 'Yes');
        has_wavelength_conversion = strcmp(swConversion.Value, 'Yes');

        % Dynamic Profile Resolution Configurations
        if contains(slice_choice, 'eMBB')
            app.name = 'eMBB'; app.target = 'Core_DC'; app.base_rate = 50.0; app.unit = 'Gbps'; app.max_lat = 20.0;
            app.policy = 'Dynamic Fitness Optimization (Energy Bound)';
            w_L = 0.20; w_E = 0.50; w_Load = 0.30;
        elseif contains(slice_choice, 'URLLC')
            app.name = 'URLLC'; app.target = 'Edge_DC'; app.base_rate = 5.0; app.unit = 'Gbps'; app.max_lat = 0.5;
            app.policy = 'Dynamic Fitness Optimization (Latency Bound)';
            w_L = 0.70; w_E = 0.15; w_Load = 0.15;
        else
            app.name = 'mMTC'; app.target = 'Core_DC'; app.base_rate = 25.0; app.unit = 'Mbps'; app.max_lat = 100.0;
            app.policy = 'Dynamic Fitness Optimization (Load Balanced)';
            w_L = 0.20; w_E = 0.20; w_Load = 0.60;
        end
        destNode = app.target;

        %% Execution Brain Phase 1: AI Score Matrix Computation
        scoreMatrix = zeros(numNodes, numNodes);
        for u = 1:numNodes
            for v = 1:numNodes
                if distances(u,v) > 0 && distances(u,v) < Inf
                    norm_lat  = distances(u,v) / max_d;
                    norm_eng  = energyCosts(u,v) / max_e;
                    norm_load = connectionLoad(u,v) / max_l;
                    scoreMatrix(u,v) = (w_L * norm_lat) + (w_E * norm_eng) + (w_Load * norm_load);
                end
            end
        end

        G_intent = graph(scoreMatrix, nodeNames, 'omitselfloops');
        [preliminaryPath, ~] = shortestpath(G_intent, sourceNode, destNode);

        if is_congested == 1 && length(preliminaryPath) > 1
            local_u = preliminaryPath{1}; local_v = preliminaryPath{2};
            edgeIdx = findedge(G_intent, local_u, local_v);
            if edgeIdx > 0
                if strcmp(app.name, 'URLLC')
                    G_intent = rmedge(G_intent, local_u, local_v); 
                else
                    G_intent.Edges.Weight(edgeIdx) = G_intent.Edges.Weight(edgeIdx) + 5.0; 
                end
            end
        end

        %% Execution Brain Phase 2: CSPF Routing Execution Loop
        G_working = G_intent; 
        path_found = false; rwa_success = false; attempts = 0; max_attempts = 5;
        channel_allocation_text = ''; finalPath = {}; edges_visited = []; 
        total_slots_on_path = 0; available_slots_on_path = 0;

        while ~path_found && attempts < max_attempts
            attempts = attempts + 1;
            [finalPath, ~] = shortestpath(G_working, sourceNode, destNode);
            if isempty(finalPath) || length(finalPath) < 2
                channel_allocation_text = 'CRITICAL: Spectral/Path Exhaustion.';
                break; 
            end
            
            path_wavelength_intersection = [1, 1, 1, 1]; edges_visited = [];
            total_slots_on_path = (length(finalPath) - 1) * 4;
            
            for i = 1:(length(finalPath)-1)
                edgeIdx = findedge(G_latency, finalPath{i}, finalPath{i+1});
                edges_visited = [edges_visited, edgeIdx];
                path_wavelength_intersection = path_wavelength_intersection .* wavelength_pool(edgeIdx, :);
            end
            
            available_slots_on_path = sum(sum(wavelength_pool(edges_visited, :)));
            
            if has_wavelength_conversion == 0
                %% CASE A: O-E-O Converters Disabled (Stricter Continuity Constraints)
                assigned_lambda_idx = find(path_wavelength_intersection == 1, 1, 'first');
                if ~isempty(assigned_lambda_idx)
                    path_found = true; rwa_success = true;
                    channel_allocation_text = sprintf('\\lambda_%d Allocated (Attempt #%d)', assigned_lambda_idx, attempts);
                    wavelength_pool(edges_visited, assigned_lambda_idx) = 0; 
                else
                    edge_capacities = sum(wavelength_pool(edges_visited, :), 2);
                    [~, local_worst_idx] = min(edge_capacities);
                    G_working = rmedge(G_working, finalPath{local_worst_idx}, finalPath{local_worst_idx+1});
                end
            else
                %% CASE B: O-E-O Converters Enabled (Intelligent Look-Ahead Strategy)
                path_violates_rwa = false;
                for i = 1:(length(finalPath)-1)
                    edgeIdx = edges_visited(i);
                    if ~any(wavelength_pool(edgeIdx, :) == 1)
                        path_violates_rwa = true;
                        break;
                    end
                end
                
                if ~path_violates_rwa
                    path_found = true; rwa_success = true;
                    channel_allocation_text = 'Active O-E-O: ';
                    for i = 1:(length(finalPath)-1)
                        edgeIdx = edges_visited(i);
                        local_free_idx = find(wavelength_pool(edgeIdx, :) == 1, 1, 'first');
                        wavelength_pool(edgeIdx, local_free_idx) = 0; 
                        channel_allocation_text = [channel_allocation_text, sprintf('(%s->%s):\\lambda_%d ', finalPath{i}, finalPath{i+1}, local_free_idx)];
                    end
                else
                    % If a link completely lacks wavelengths, intelligently prune that exact bottleneck link
                    edge_capacities = sum(wavelength_pool(edges_visited, :), 2);
                    [~, local_worst_idx] = min(edge_capacities);
                    G_working = rmedge(G_working, finalPath{local_worst_idx}, finalPath{local_worst_idx+1});
                end
            end
        end

        %% Post-Routing Analytics Processing
        backupPathList = {};
        if rwa_success
            totalDist = 0; totalEnergy = 0; totalLoad = 0;
            running_span_distance = 0;
            edfa_stages_triggered = 0;
            
            % Step through active path hop-by-hop to track signal power propagation
            for i = 1:(length(finalPath)-1)
                u = findnode(G_latency, finalPath{i}); v = findnode(G_latency, finalPath{i+1});
                link_dist = distances(u, v);
                
                totalDist   = totalDist + link_dist;
                totalEnergy = totalEnergy + energyCosts(u, v);
                totalLoad   = totalLoad + connectionLoad(u, v);
                
                running_span_distance = running_span_distance + link_dist;
                
                % EDFA Hardware Trigger Condition
                if running_span_distance >= edfa_distance_threshold
                    edfa_stages_triggered = edfa_stages_triggered + 1;
                    running_span_distance = 0; % The signal is boosted back up; reset accumulation tracking
                end
            end
            
            final_latency = (totalDist / c_light_fiber) * 1000; 
            
            total_cd  = 17 * totalDist;             
            total_pmd = 0.1 * sqrt(totalDist);      
            total_nli = 0.02 * totalDist;           
            
            % Physics Core Model Update: EDFA perfectly offsets fiber attenuation up to the point of amplification
            distance_requiring_raw_attenuation = running_span_distance;
            distance_fully_compensated_by_edfa = totalDist - distance_requiring_raw_attenuation;
            total_edfa_gain_db = distance_fully_compensated_by_edfa * fiber_attenuation;
            
            % Final OSNR Engine incorporates added EDFA boost alongside its minor noise penalty
            final_osnr = base_launch_power - (fiber_attenuation * totalDist) + total_edfa_gain_db ...
                         - receiver_noise_figure - total_nli - (edfa_stages_triggered * edfa_ase_noise_penalty);
            
            osnr_linear = 10^(final_osnr / 10);
            
            if final_osnr > 25
                modulation_scheme = '16-QAM'; bits_per_symbol = 4;
                final_ber = (3/8) * erfc(sqrt(osnr_linear / 10));
            elseif final_osnr > 18
                modulation_scheme = 'QPSK'; bits_per_symbol = 2;
                final_ber = 0.5 * erfc(sqrt(osnr_linear / 2));
            else
                modulation_scheme = 'BPSK'; bits_per_symbol = 1;
                final_ber = 0.5 * erfc(sqrt(osnr_linear));
            end
            
            rate_multiplier = bits_per_symbol / 2;
            realized_rate_val = app.base_rate * rate_multiplier;
            realized_rate_str = sprintf('%.1f %s', realized_rate_val, app.unit);
            utilization_pct = (1 - (available_slots_on_path / total_slots_on_path)) * 100;
            active_path_str = strjoin(finalPath, ' -> ');
            
            if edfa_stages_triggered > 0
                edfa_status_str = sprintf('%d Active (+%.1f dB Gain)', edfa_stages_triggered, total_edfa_gain_db);
            else
                edfa_status_str = '0 Deployed (Span < 70km)';
            end
            
            % Compute Protection Detour path
            G_backup_calc = G_intent;
            for i = 1:(length(finalPath)-1)
                if findedge(G_backup_calc, finalPath{i}, finalPath{i+1}) > 0
                    G_backup_calc = rmedge(G_backup_calc, finalPath{i}, finalPath{i+1});
                end
            end
            [backupPathList, ~] = shortestpath(G_backup_calc, sourceNode, destNode);
            if isempty(backupPathList), backup_path_str = 'No Detour Available';
            else, backup_path_str = strjoin(backupPathList, ' -> '); end
        else
            active_path_str = 'FAILED / BLOCKED'; backup_path_str = 'NONE';
            modulation_scheme = 'NONE'; realized_rate_str = '0 Gbps'; edfa_status_str = 'NONE';
            totalDist = 0; totalEnergy = 0; totalLoad = 0; final_latency = 0; final_osnr = 0;
            total_cd = 0; total_pmd = 0; total_nli = 0; final_ber = 0.5; utilization_pct = 0;
        end

        %% Refresh Dashboard Data Structure
        tableDashboard.Data = {
            'Selected Network Slice Profile', app.name, '3GPP SLA Target Allocation Context';
            'Allocated Core Modulation', modulation_scheme, 'Dynamic Physical Coding Adaptive State';
            'Realized Data Throughput', realized_rate_str, 'OSNR Constellation Adjusted Rate';
            'Primary Routing Path Vector', active_path_str, 'Calculated Minimum Weight Vector';
            'Pre-Computed Backup Path', backup_path_str, 'Proactive Protection Detour Span';
            'End-to-End Propagation Latency', sprintf('%.3f ms', final_latency), sprintf('Max SLA Budget Target: %.1f ms', app.max_lat);
            'Coherent Receiver OSNR Target', sprintf('%.2f dB', final_osnr), 'Link Physical Metric Requirement (>15dB)';
            'Decoded Bit Error Rate (BER)', sprintf('%e', final_ber), 'Analytical Signal Integrity Vector';
            'Inline EDFA Stages Triggered', edfa_status_str, 'Cascaded Optical Gain Equalization Context'; %% <-- NEW DISCOVERY METRIC
            'WDM Channel Selection Status', channel_allocation_text, 'Optical Core Frequency Assignment';
            'Spectrum Block Coherent Load', sprintf('%.1f %%', utilization_pct), 'Active Slice Slot Utilization Metric';
            'Chromatic Dispersion Accumulation', sprintf('%.2f ps/nm', total_cd), 'Linear Dispersion Propagation Shift';
            'Polarization Mode Disp. (PMD)', sprintf('%.3f ps', total_pmd), 'Birefringence Phase Disruption Factor';
            'Non-Linear Penalty Structural Distortion', sprintf('%.2f dB', total_nli), 'Kerr-Effect Phase Variance Metric'
        };

        %% Refresh Visual Map Highlights
        pGraph.EdgeColor = [0.7, 0.7, 0.7]; pGraph.LineWidth = 1.5;
        pGraph.NodeColor = [0.2, 0.2, 0.2]; pGraph.MarkerSize = 7;
        
        if rwa_success
            highlight(pGraph, finalPath, 'EdgeColor', [0.85, 0.16, 0.24], 'LineWidth', 4.5, ...
                'NodeColor', [0.85, 0.16, 0.24], 'MarkerSize', 9);
            if ~isempty(backupPathList) && length(backupPathList) >= 2
                highlight(pGraph, backupPathList, 'EdgeColor', [0.0, 0.45, 0.74], 'LineWidth', 2.5, ...
                    'LineStyle', '--');
            end
        end
    end
end