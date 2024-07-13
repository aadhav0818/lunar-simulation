classdef rocket_simulation_v2 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        LunarMissionSimulationUIFigure  matlab.ui.Figure
        LoggerPanel                     matlab.ui.container.Panel
        StageCompletionIndicatorSwitch  matlab.ui.control.Switch
        StageCompletionIndicatorSwitchLabel  matlab.ui.control.Label
        SimulationSpeedSlider           matlab.ui.control.Slider
        SimulationSpeedSliderLabel      matlab.ui.control.Label
        TextArea                        matlab.ui.control.TextArea
        TimeElapsedGauge                matlab.ui.control.LinearGauge
        TimeElapsedGaugeLabel           matlab.ui.control.Label
        RocketPanel                     matlab.ui.container.Panel
        Altimeterm                      Aero.ui.control.Altimeter
        AltimetermLabel                 matlab.ui.control.Label
        VelocitymsAirspeedIndicator     Aero.ui.control.AirspeedIndicator
        VelocitymsLabel                 matlab.ui.control.Label
        SpacecraftPanel                 matlab.ui.container.Panel
        Altimeterm_2                    Aero.ui.control.Altimeter
        Altimeterm_2Label               matlab.ui.control.Label
        VelocitymsAirspeedIndicator_2   Aero.ui.control.AirspeedIndicator
        VelocitymsAirspeedIndicator_2Label  matlab.ui.control.Label
        TabGroup2                       matlab.ui.container.TabGroup
        DataTranscriptionTab            matlab.ui.container.Tab
        RELATIVEVELOCITYLabel           matlab.ui.control.Label
        MASSEXPUSLIONRATELabel          matlab.ui.control.Label
        GRAVITATIONLabel                matlab.ui.control.Label
        PAYLOADMASSLabel                matlab.ui.control.Label
        ROCKETMASSLabel                 matlab.ui.control.Label
        TIMEELAPSEDLabel                matlab.ui.control.Label
        HEIGHTLabel                     matlab.ui.control.Label
        VELOCITYLabel                   matlab.ui.control.Label
        StageTrackerTab                 matlab.ui.container.Tab
        WARNINGSLabel                   matlab.ui.control.Label
        Label_2                         matlab.ui.control.Label
        LOCATIONLabel                   matlab.ui.control.Label
        STATUSLabel                     matlab.ui.control.Label
        NEXTSTAGELabel                  matlab.ui.control.Label
        CURRENTSTAGELabel               matlab.ui.control.Label
        Lamp                            matlab.ui.control.Lamp
        StartSimulationButton           matlab.ui.control.Button
        TabGroup                        matlab.ui.container.TabGroup
        PresetsTab                      matlab.ui.container.Tab
        PresetsDropDown                 matlab.ui.control.DropDown
        PresetsDropDownLabel            matlab.ui.control.Label
        GravitationTab                  matlab.ui.container.Tab
        MoonGravitationms2Spinner       matlab.ui.control.Spinner
        MoonGravitationms2SpinnerLabel  matlab.ui.control.Label
        EarthGravitationms2Spinner      matlab.ui.control.Spinner
        EarthGravitationms2SpinnerLabel  matlab.ui.control.Label
        PayloadsTab                     matlab.ui.container.Tab
        PayloadMasskgSpinner            matlab.ui.control.Spinner
        PayloadMasskgSpinnerLabel       matlab.ui.control.Label
        RocketMasskgSpinner             matlab.ui.control.Spinner
        RocketMasskgSpinnerLabel        matlab.ui.control.Label
        RatesTab                        matlab.ui.container.Tab
        SpacecraftAccelerationms2Spinner  matlab.ui.control.Spinner
        SpacecraftAccelerationms2SpinnerLabel  matlab.ui.control.Label
        RelativeVelocitymsSpinner       matlab.ui.control.Spinner
        RelativeVelocitymsSpinnerLabel  matlab.ui.control.Label
        MERatekgsSpinner                matlab.ui.control.Spinner
        MERatekgsSpinnerLabel           matlab.ui.control.Label
        OrbitsTab                       matlab.ui.container.Tab
        OrbitsTransitiontoMoonSpinner   matlab.ui.control.Spinner
        OrbitsTransitiontoMoonSpinnerLabel  matlab.ui.control.Label
        OrbitsEarthtoTransitionSpinner  matlab.ui.control.Spinner
        OrbitsEarthtoTransitionSpinnerLabel  matlab.ui.control.Label
        UIAxes_2                        matlab.ui.control.UIAxes
        UIAxes_3                        matlab.ui.control.UIAxes
        UIAxes                          matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        velocity                            % m/s
        height                              % m
        time_elapsed                        % s
        rocket_mass                         % kg
        payload_mass                        % kg
        mass_expulsion_rate                 % kg/s
        relative_velocity                   % m/s
        gravity                             % m/s^2
        moon_gravity                        % m/s^2
        stage1_deployment                   % m
        stage3_landing                      % m
        orbits_earth_transition             % int
        orbits_transition_moon              % int
        spacecraft_acceleration_rate        % m/s^2
        
        radius_earth = 6.371*10.^6          % m 
        radius_moon = 1.73744 * 10.^6       % m 
        G = 6.673*10.^11                    % Nm^2/kg^2
        apogee_moon = 406.7 * 10.^6         % m 
        perigee_moon = 356.5 * 10.^6        % m 
        mass_earth = 5.976*10.^24           % kg
        
        sim_counter = 1                     % int
        logger = ""                         % string
        checkpoint_1 = false                % bool
        checkpoint_2 = false                % bool
        checkpoint_3 = false                % bool
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Reading all the variables 
            app.velocity = 0;
            app.height = 0;
            app.time_elapsed = 0;
            app.rocket_mass = app.RocketMasskgSpinner.Value;
            app.payload_mass = app.PayloadMasskgSpinner.Value;
            app.mass_expulsion_rate = app.MERatekgsSpinner.Value;
            app.relative_velocity = app.RelativeVelocitymsSpinner.Value;
            app.gravity = app.EarthGravitationms2Spinner.Value;
            app.moon_gravity = app.MoonGravitationms2Spinner.Value;
            app.stage1_deployment = 300*10.^3; % FIX LATER
            app.stage3_landing = 110*10.^3;
            app.orbits_earth_transition = app.OrbitsEarthtoTransitionSpinner.Value;
            app.orbits_transition_moon = app.OrbitsTransitiontoMoonSpinner.Value;
            app.spacecraft_acceleration_rate = app.SpacecraftAccelerationms2Spinner.Value;

            app.WARNINGSLabel.Text = "WARNINGS: NONE";
            app.ROCKETMASSLabel.Text = "ROCKET MASS: " + string(app.rocket_mass) + "kg";
            app.PAYLOADMASSLabel.Text = "PAYLOAD MASS: " + string(app.payload_mass) + "kg";
            app.GRAVITATIONLabel.Text = "GRAVITATION: " + string(app.gravity) + "m/s^2";
            app.MASSEXPUSLIONRATELabel.Text = "MASS EXPULSION RATE: " + string(app.mass_expulsion_rate) + "kg/s";
            app.RELATIVEVELOCITYLabel.Text = "RELATIVE VELOCITY: " + string(app.relative_velocity) + "m/s";


            xlim(app.UIAxes, [0,100]);
            ylim(app.UIAxes, [0,100]);
            xlim(app.UIAxes_2, [1, max(app.orbits_earth_transition, app.orbits_transition_moon) + 1]);
            ylim(app.UIAxes_2, [0, app.perigee_moon ./ 1000]);



        end

        % Button pushed function: StartSimulationButton
        function StartSimulationButtonPushed(app, event)
            
            %Disabling change on variables
            set(app.PresetsDropDown, 'Enable', 'off');
            set(app.MoonGravitationms2Spinner, 'Enable', 'off');
            set(app.EarthGravitationms2Spinner, 'Enable', 'off');
            set(app.PayloadMasskgSpinner, 'Enable', 'off');
            set(app.RocketMasskgSpinner, 'Enable', 'off');
            set(app.SpacecraftAccelerationms2Spinner, 'Enable', 'off');
            set(app.RelativeVelocitymsSpinner, 'Enable', 'off');
            set(app.MERatekgsSpinner, 'Enable', 'off');
            set(app.OrbitsTransitiontoMoonSpinner, 'Enable', 'off');
            set(app.OrbitsEarthtoTransitionSpinner, 'Enable', 'off');


            %Refreshing application
            set(app.UIAxes, 'color', '#ffffff');
            set(app.UIAxes_2, 'color', '#ffffff');
            set(app.UIAxes_3, 'color', '#ffffff');
            set(app.OrbitsEarthtoTransitionSpinner, 'Enable', 'off');
            set(app.OrbitsEarthtoTransitionSpinner, 'Enable', 'off');
            app.logger = "";
            app.TextArea.Value = app.logger;
            
            plot(app.UIAxes_3, 0, 0);
            cla(app.UIAxes_2, "reset");
            title(app.UIAxes_2, 'Orbit Trajectory')
            xlabel(app.UIAxes_2, 'Number of Orbits (int)')
            ylabel(app.UIAxes_2, 'Distance (km)')

        

            app.logger = app.logger + string("Simulation started " + "(" + app.sim_counter + ") ") + newline;
            app.TextArea.Value = app.logger;

            app.sim_counter = app.sim_counter + 1;
            if app.sim_counter > 1
                app.StartSimulationButton.Text = "Restart Simulation";
            end

            app.Lamp.Color = "Green";
            time_vector = 0;
            height_vector = 0;
            time_vector_3 = 0;
            height_vector_3 = 0;

            g = app.gravity;
            gm = app.moon_gravity;
            U = app.relative_velocity;
            M0 = app.rocket_mass;
            m = app.payload_mass;
            R = app.mass_expulsion_rate;
            h0m = app.stage3_landing;
            h0e = app.stage1_deployment;
            Rm = app.radius_moon;
            Re = app.radius_earth;
            RP = app.perigee_moon;
            RA = app.apogee_moon;
            Nse = app.orbits_earth_transition;
            Nsm = app.orbits_transition_moon;
            
            x = 0;
            tr = 0;
            xl = 0;

            dhl0 = 0.1.*h0m;
            dhl1 = h0m - dhl0;

            tl0 = sqrt(2*dhl0 ./ gm);
            
            vl0 = 0;
            vl1 = vl0 + gm*tl0;

            Fr = m*((gm*tl0).^2/(2*dhl1) + gm);

            tl1 = (gm*tl0)./(-gm+(Fr/m));
            tlt = tl0 + tl1; %#ok<*NASGU> 

            tolerance = 0.01*h0m;
            
            %Initial Step of Orbit
            r0e = h0e + Re;
            r0m = h0m + Rm;
            c2 = 1-((gm.*Rm.^2)./(g .* Re.^2));
            c1 = -2*RP;
            c0 = RP.^2;
            re = roots([c2, c1, c0]);
            rt = re(re < RP);
            hte = rt - r0e;                                   %Total distance to navigate from the earth to transition
            htm = RP - rt- r0m;                               %Total distance to navigate from the transition to moon
            dhe = hte ./ Nse;      
            dhm = htm ./ Nsm;
            dt_ac = sqrt(1./app.spacecraft_acceleration_rate);

            %Vector Initialization Earth to Transition
            he = zeros(Nse+1, 1);                             %Distance from the earth
            rpe = zeros(Nse+1, 1);
            rae = zeros(Nse+1, 1);
            vpe = zeros(Nse+1, 1);
            vae = zeros(Nse+1, 1);
            dve = zeros(Nse+1, 1);
            ae = zeros(Nse+1, 1);
            Fe = zeros(Nse+1, 1);

            %Vector Initialization Transition to Moon
            hm = zeros(Nsm+1, 1);                            %Distance from the moon
            rpm = zeros(Nsm+1, 1);
            ram = zeros(Nsm+1, 1);
            vpm = zeros(Nsm+1, 1);
            vam = zeros(Nsm+1, 1);
            dvm = zeros(Nsm+1, 1);
            am = zeros(Nsm+1, 1);
            Fm = zeros(Nsm+1, 1);
            
            orbit_number_e = 0;
            orbit_distance_e = 0;
            orbit_number_m = 0;
            orbit_distance_m = 0;
            o = 0;
               
            ii = 0;
            
            app.logger = app.logger + "Liftoff (t-0s)" + newline;
            app.TextArea.Value = app.logger;
            ot_tracker = 0;
            
            app.RocketPanel.BackgroundColor = '#4DBEEE';
            while ii <= 10000
                t = ii;
                app.TimeElapsedGauge.Value = t;
                app.TIMEELAPSEDLabel.Text = "TIME ELAPSED: " + string(t) + "s";

                %VISUALISE DATA AND START SIMULATION

                if x <= app.stage1_deployment
                    v = -g.*t+U*(log((M0+m)./(M0+m-R.*t)));
                    x = (-g.*t.^2)./2+U.*t.*log(M0+m)+((U.*(M0+m-R.*t))./R).*(log(M0+m-R.*t)-1)-(U.*(M0+m)./R).*(log(M0+m)-1);
                    app.Lamp.Color = "Green";
                    app.VELOCITYLabel.Text = "VELOCITY: " + v / 1000 + " km/s  |  " + v + " m/s";
                    app.HEIGHTLabel.Text = "HEIGHT: " + x / 1000 + " km  |  " + x + " m";
                    
                    if isreal(v./1000) 
                        app.VelocitymsAirspeedIndicator.Airspeed = v ./ 1000;
                    else
                        app.WARNINGSLabel.Text = "WARNINGS: PROCESSING NON-REAL VALUES";
                    end
                    if isreal(x./1000)
                        app.Altimeterm.Altitude = x ./ 1000;
                    else
                        app.WARNINGSLabel.Text = "WARNINGS: PROCESSING NON-REAL VALUES";
                    end

                    app.WARNINGSLabel.Text = "WARNINGS: NONE";
                    app.CURRENTSTAGELabel.Text = "CURRENT STAGE: 1 - Launch -> Orbit";
                    app.NEXTSTAGELabel.Text = "NEXT STAGE: 2 - Gravity-Assisted Navigation";
                    app.LOCATIONLabel.Text = "LOCATION: Earth";
                    
                    time_vector(1, end+1) = t;
                    height_vector(1, end+1) = x ./ 1000;
                    %Plotting the height vs time graph 
                    plot(app.UIAxes, time_vector, height_vector)
                    tr = t;

                    pause(0.1);
                elseif (x > app.stage1_deployment) && (o < 1)

                    if app.StageCompletionIndicatorSwitch.Value == "On"
                        set(app.UIAxes, 'color', '#80e362');
                    end

                    app.checkpoint_1 = true;
                    app.RocketPanel.BackgroundColor = 'White';
                    app.SpacecraftPanel.BackgroundColor = '#4DBEEE';

                    %Navigate from the transition to the moon

                    app.logger = app.logger + "Spacecraft has detached from launch vehicle" + newline;
                    app.TextArea.Value = app.logger;

                    hold(app.UIAxes_2, 'on');

                    for jj = 1:Nse+1

                        app.logger = app.logger + "Applying thrust to reach earth orbital stage " + jj + newline;
                        app.TextArea.Value = app.logger;

                        he(jj) = h0e + (jj-1) * dhe;
                        rpe(jj) = he(jj) + Re;
                        rae(jj) = rpe(jj) + dhe;
                        vpe(jj) = sqrt(2.*g.*Re.^2.*(1./rpe(jj)-1./rae(jj))./(1-(rpe(jj)./rae(jj)).^2));
                        vae(jj) = (vpe(jj).*rpe(jj))./rae(jj);
                        if jj==1
                            dve(jj) = vpe(jj);
                        else
                            dve(jj) = vpe(jj)-vae(jj-1);
                        end
                        ae(jj) = dve(jj) ./ dt_ac;
                        Fe(jj) = ae(jj) * m;
                        orbit_number_e(1, end + 1) = jj;
                        orbit_distance_e(1, end + 1) = he(jj) ./ 1000;
                        
                        p2_1 = plot(app.UIAxes_2, orbit_number_e(2:end), orbit_distance_e(2:end), 'r--o');
                        
                        pause(1);
            
                    end
                    
                    app.logger = app.logger + "Spacecraft is now following the Lunar Transfer Trajectory" + newline;
                    app.TextArea.Value = app.logger;
                    pause(2);

                    % Navigate from the Transition to the Moon
                    
                    app.logger = app.logger + "Spacecraft has reached lunar orbit" + newline;
                    app.TextArea.Value = app.logger;

                    for kk = 1:Nsm+1
                        
                        app.logger = app.logger + "Applying thrust to reach lunar orbital stage " + kk + newline;
                        app.TextArea.Value = app.logger;

                        hm(kk) = (htm + h0m) - (kk-1) * dhm;  
                        rpm(kk) = Rm + hm(kk) - dhm;
                        ram(kk) = hm(kk) + Rm;
                        vpm(kk) = sqrt(2.*gm.*Rm.^2.*(1./rpm(kk)-1./ram(kk))./(1-(rpm(kk)./ram(kk)).^2));
                        vam(kk) = (vpm(kk).*rpm(kk))./ram(kk);
                        if kk==1
                            dvm(kk) = vam(kk) - vae(end,1);
                        else
                            dvm(kk) = vam(kk)-vpm(kk);
                        end
                        am(kk) = dvm(kk) ./ dt_ac;
                        Fm(kk) = am(kk) * m;
                        orbit_number_m(1, end + 1) = kk; %#ok<*AGROW> 
                        orbit_distance_m(1, end + 1) = hm(kk) ./ 1000;
                        
                        p2_2 = plot(app.UIAxes_2, orbit_number_m(2:end), orbit_distance_m(2:end), 'b--o');

                        pause(1);

                    end
                    
                    o = 1;
                    legend(app.UIAxes_2, [p2_1(1), p2_2(1)], 'Earth to Lunar Transfer Trajectory Orbital', 'Lunar Transfer Trajectory to Moon Orbital')
                    app.checkpoint_2 = true;
                    if app.StageCompletionIndicatorSwitch.Value == "On"
                        set(app.UIAxes_2, 'color', '#80e362');
                    end

                else


                    ot_tracker = ot_tracker + 1;
                    if ot_tracker == 1
                        app.logger = app.logger + "Lunar module has detached from main spacecraft" + newline + "Module has entered the lunar descent stage" + newline;
                        app.TextArea.Value = app.logger;
                    end

                    if (t - tr <= tl0)
                        a = gm;
                        xl = h0m - (vl0 * (t -tr) + 0.5.*a.*(t -tr).^2);
                        vl = vl0 + a .* (t -tr);
                    else
                        a = (gm-Fr./m);
                        xl = (h0m - dhl0) - (vl1 * ((t -tr) - tl0) + 0.5.*a.*((t -tr)-tl0).^2);
                        vl = vl1 + a .* (t -tr);
                    end
                    
                    app.Lamp.Color = "Green";
                    app.VELOCITYLabel.Text = "VELOCITY: " + vl / 1000 + " km/s  |  " + vl + " m/s";
                    app.HEIGHTLabel.Text = "HEIGHT: " + xl / 1000 + " km  |  " + xl + " m";
    
                    if isreal(vl./1000)
                        app.VelocitymsAirspeedIndicator_2.Airspeed = vl ./ 1000;
                    end
                    if isreal(xl./1000)
                        app.Altimeterm_2.Altitude = xl ./ 1000;
                    end

                    app.WARNINGSLabel.Text = "WARNINGS: NONE";
                    app.GRAVITATIONLabel.Text = "GRAVITATION: " + num2str(app.moon_gravity) + "m/s^2";
                    app.CURRENTSTAGELabel.Text = "CURRENT STAGE: 3 - Lunar Orbit -> Ground";
                    app.NEXTSTAGELabel.Text = "NEXT STAGE: 4 - Mission Complete";
                    app.LOCATIONLabel.Text = "LOCATION: Moon";
                    
                
                    time_vector_3(1, end+1) = t - tr;
                    height_vector_3(1, end+1) = xl ./ 1000;
                    %Plotting the height vs time graph 
                    plot(app.UIAxes_3, time_vector_3(2:end) , height_vector_3(2:end))
                    if xl <= (0 + tolerance)
                        break;
                    end
                    

                    pause(0.1);
                end
                ii = ii + app.SimulationSpeedSlider.Value;
            end
            
            if app.StageCompletionIndicatorSwitch.Value == "On"
                set(app.UIAxes_3, 'color', '#80e362');
                app.WARNINGSLabel.Text = "WARNINGS: NONE";
                app.CURRENTSTAGELabel.Text = "CURRENT STAGE: Mission Complete";
                app.NEXTSTAGELabel.Text = "NEXT STAGE: None";
                app.LOCATIONLabel.Text = "LOCATION: Moon";
            end
            app.checkpoint_3 = true;

            app.SpacecraftPanel.BackgroundColor = 'White';
            app.logger = app.logger + "Module has made touchdown with the Lunar Surface" + newline;
            app.TextArea.Value = app.logger;

            app.Lamp.Color = "Red";

            %Re-Enabling Changes
            set(app.PresetsDropDown, 'Enable', 'on');
            set(app.MoonGravitationms2Spinner, 'Enable', 'on');
            set(app.EarthGravitationms2Spinner, 'Enable', 'on');
            set(app.PayloadMasskgSpinner, 'Enable', 'on');
            set(app.RocketMasskgSpinner, 'Enable', 'on');
            set(app.SpacecraftAccelerationms2Spinner, 'Enable', 'on');
            set(app.RelativeVelocitymsSpinner, 'Enable', 'on');
            set(app.MERatekgsSpinner, 'Enable', 'on');
            set(app.OrbitsTransitiontoMoonSpinner, 'Enable', 'on');
            set(app.OrbitsEarthtoTransitionSpinner, 'Enable', 'on');


        end

        % Value changed function: RocketMasskgSpinner
        function RocketMasskgSpinnerValueChanged(app, event)
            value = app.RocketMasskgSpinner.Value;
            app.rocket_mass = value;
            app.ROCKETMASSLabel.Text = "ROCKET MASS: " + string(value) + "kg";
        end

        % Value changed function: PayloadMasskgSpinner
        function PayloadMasskgSpinnerValueChanged(app, event)
            value = app.PayloadMasskgSpinner.Value;
            app.payload_mass = value;
            app.PAYLOADMASSLabel.Text = "PAYLOAD MASS: " + string(value) + "kg";
        end

        % Value changed function: EarthGravitationms2Spinner
        function EarthGravitationms2SpinnerValueChanged(app, event)
            value = app.EarthGravitationms2Spinner.Value;
            app.gravity = value;
            app.GRAVITATIONLabel.Text = "GRAVITATION: " + string(value) + "m/s";
        end

        % Value changed function: MERatekgsSpinner
        function MERatekgsSpinnerValueChanged(app, event)
            value = app.MERatekgsSpinner.Value;
            app.mass_expulsion_rate = value;
            app.MASSEXPUSLIONRATELabel.Text = "MASS EXPULSION RATE: " + string(value) + "kg/s";
        end

        % Value changed function: RelativeVelocitymsSpinner
        function RelativeVelocitymsSpinnerValueChanged(app, event)
            value = app.RelativeVelocitymsSpinner.Value;
            app.relative_velocity = value;
            app.RELATIVEVELOCITYLabel.Text = "RELATIVE VELOCITY: " + string(value) + "m/s";
        end

        % Value changed function: SimulationSpeedSlider
        function SimulationSpeedSliderValueChanged(app, event)
            value = app.SimulationSpeedSlider.Value;
            app.logger = app.logger + "Simulation speed changed to " + app.SimulationSpeedSlider.Value + "x" + newline;
            app.TextArea.Value = string(app.logger);
        end

        % Value changed function: StageCompletionIndicatorSwitch
        function StageCompletionIndicatorSwitchValueChanged(app, event)
            value = app.StageCompletionIndicatorSwitch.Value;
            if value == "On"
                if app.checkpoint_1
                    set(app.UIAxes, 'color', '#80e362');
                end
                if app.checkpoint_2
                    set(app.UIAxes_2, 'color', '#80e362');
                end
                if app.checkpoint_3
                    set(app.UIAxes_3, 'color', '#80e362');
                end
            else
                set(app.UIAxes, 'color', '#ffffff');
                set(app.UIAxes_2, 'color', '#ffffff');
                set(app.UIAxes_3, 'color', '#ffffff');
            end
        end

        % Value changed function: PresetsDropDown
        function PresetsDropDownValueChanged(app, event)
            value = app.PresetsDropDown.Value;
            %NOTE: Values may be slightly off due mission changes and mission deliverables associated with each rocket launch

            switch value
                case "NASA - Saturn V"
                    app.rocket_mass = 2800000;
                    app.RocketMasskgSpinner.Value = 2800000;
                    app.ROCKETMASSLabel.Text = "ROCKET MASS: " + string(2800000) + "kg";

                    app.payload_mass = 28000; % NASA Space Shuttle
                    app.PayloadMasskgSpinner.Value = 28000;
                    app.PAYLOADMASSLabel.Text = "PAYLOAD MASS: " + string(28000) + "kg";

                    app.mass_expulsion_rate = 25000;
                    app.MERatekgsSpinner.Value = 25000;
                    app.MASSEXPUSLIONRATELabel.Text = "MASS EXPULSION RATE: " + string(25000) + "kg/s";

                    app.relative_velocity = 2200;
                    app.RelativeVelocitymsSpinner.Value = 2200;
                    app.RELATIVEVELOCITYLabel.Text = "RELATIVE VELOCITY: " + string(2200) + "m/s";

                case "SpaceX - Falcon 9"
                    app.rocket_mass = 549054;
                    app.RocketMasskgSpinner.Value = 549054;
                    app.ROCKETMASSLabel.Text = "ROCKET MASS: " + string(549054) + "kg";

                    app.payload_mass = 12055; % SpaceX Crew Dragon
                    app.PayloadMasskgSpinner.Value = 12055;
                    app.PAYLOADMASSLabel.Text = "PAYLOAD MASS: " + string(12055) + "kg";

                    app.mass_expulsion_rate = 2100;
                    app.MERatekgsSpinner.Value = 2100;
                    app.MASSEXPUSLIONRATELabel.Text = "MASS EXPULSION RATE: " + string(2100) + "kg/s";

                    app.relative_velocity = 3000;
                    app.RelativeVelocitymsSpinner.Value = 3000;
                    app.RELATIVEVELOCITYLabel.Text = "RELATIVE VELOCITY: " + string(3000) + "m/s";

                case "RosCosmos - Soyuz"
                    app.rocket_mass = 308000;
                    app.RocketMasskgSpinner.Value = 308000;
                    app.ROCKETMASSLabel.Text = "ROCKET MASS: " + 308000 + "kg";

                    app.payload_mass = 7220; % Soyuz 2.1a
                    app.PayloadMasskgSpinner.Value = 7220;
                    app.PAYLOADMASSLabel.Text = "PAYLOAD MASS: " + 7220 + "kg";

                    app.mass_expulsion_rate = 1614;
                    app.MERatekgsSpinner.Value = 1614;
                    app.MASSEXPUSLIONRATELabel.Text = "MASS EXPULSION RATE: " + string(1614) + "kg/s";

                    app.relative_velocity = 500;
                    app.RelativeVelocitymsSpinner.Value = 500;
                    app.RELATIVEVELOCITYLabel.Text = "RELATIVE VELOCITY: " + string(500) + "m/s";


            end
        end

        % Value changed function: MoonGravitationms2Spinner
        function MoonGravitationms2SpinnerValueChanged(app, event)
            value = app.MoonGravitationms2Spinner.Value;
            app.moon_gravity = value;
        end

        % Value changed function: OrbitsEarthtoTransitionSpinner
        function OrbitsEarthtoTransitionSpinnerValueChanged(app, event)
            value = app.OrbitsEarthtoTransitionSpinner.Value;
            app.orbits_earth_transition = value;
        end

        % Value changed function: OrbitsTransitiontoMoonSpinner
        function OrbitsTransitiontoMoonSpinnerValueChanged(app, event)
            value = app.OrbitsTransitiontoMoonSpinner.Value;
            app.orbits_transition_moon = value;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create LunarMissionSimulationUIFigure and hide until all components are created
            app.LunarMissionSimulationUIFigure = uifigure('Visible', 'off');
            app.LunarMissionSimulationUIFigure.Color = [0.902 0.902 0.902];
            app.LunarMissionSimulationUIFigure.Colormap = [0.2431 0.149 0.6588;0.2431 0.1529 0.6745;0.2471 0.1569 0.6863;0.2471 0.1608 0.698;0.251 0.1647 0.7059;0.251 0.1686 0.7176;0.2549 0.1725 0.7294;0.2549 0.1765 0.7412;0.2588 0.1804 0.749;0.2588 0.1843 0.7608;0.2627 0.1882 0.7725;0.2627 0.1922 0.7843;0.2627 0.1961 0.7922;0.2667 0.2 0.8039;0.2667 0.2039 0.8157;0.2706 0.2078 0.8235;0.2706 0.2157 0.8353;0.2706 0.2196 0.8431;0.2745 0.2235 0.851;0.2745 0.2275 0.8627;0.2745 0.2314 0.8706;0.2745 0.2392 0.8784;0.2784 0.2431 0.8824;0.2784 0.2471 0.8902;0.2784 0.2549 0.898;0.2784 0.2588 0.902;0.2784 0.2667 0.9098;0.2784 0.2706 0.9137;0.2784 0.2745 0.9216;0.2824 0.2824 0.9255;0.2824 0.2863 0.9294;0.2824 0.2941 0.9333;0.2824 0.298 0.9412;0.2824 0.3059 0.9451;0.2824 0.3098 0.949;0.2824 0.3137 0.9529;0.2824 0.3216 0.9569;0.2824 0.3255 0.9608;0.2824 0.3294 0.9647;0.2784 0.3373 0.9686;0.2784 0.3412 0.9686;0.2784 0.349 0.9725;0.2784 0.3529 0.9765;0.2784 0.3569 0.9804;0.2784 0.3647 0.9804;0.2745 0.3686 0.9843;0.2745 0.3765 0.9843;0.2745 0.3804 0.9882;0.2706 0.3843 0.9882;0.2706 0.3922 0.9922;0.2667 0.3961 0.9922;0.2627 0.4039 0.9922;0.2627 0.4078 0.9961;0.2588 0.4157 0.9961;0.2549 0.4196 0.9961;0.251 0.4275 0.9961;0.2471 0.4314 1;0.2431 0.4392 1;0.2353 0.4431 1;0.2314 0.451 1;0.2235 0.4549 1;0.2196 0.4627 0.9961;0.2118 0.4667 0.9961;0.2078 0.4745 0.9922;0.2 0.4784 0.9922;0.1961 0.4863 0.9882;0.1922 0.4902 0.9882;0.1882 0.498 0.9843;0.1843 0.502 0.9804;0.1843 0.5098 0.9804;0.1804 0.5137 0.9765;0.1804 0.5176 0.9725;0.1804 0.5255 0.9725;0.1804 0.5294 0.9686;0.1765 0.5333 0.9647;0.1765 0.5412 0.9608;0.1765 0.5451 0.9569;0.1765 0.549 0.9529;0.1765 0.5569 0.949;0.1725 0.5608 0.9451;0.1725 0.5647 0.9412;0.1686 0.5686 0.9373;0.1647 0.5765 0.9333;0.1608 0.5804 0.9294;0.1569 0.5843 0.9255;0.1529 0.5922 0.9216;0.1529 0.5961 0.9176;0.149 0.6 0.9137;0.149 0.6039 0.9098;0.1451 0.6078 0.9098;0.1451 0.6118 0.9059;0.1412 0.6196 0.902;0.1412 0.6235 0.898;0.1373 0.6275 0.898;0.1373 0.6314 0.8941;0.1333 0.6353 0.8941;0.1294 0.6392 0.8902;0.1255 0.6471 0.8902;0.1216 0.651 0.8863;0.1176 0.6549 0.8824;0.1137 0.6588 0.8824;0.1137 0.6627 0.8784;0.1098 0.6667 0.8745;0.1059 0.6706 0.8706;0.102 0.6745 0.8667;0.098 0.6784 0.8627;0.0902 0.6824 0.8549;0.0863 0.6863 0.851;0.0784 0.6902 0.8471;0.0706 0.6941 0.8392;0.0627 0.698 0.8353;0.0549 0.702 0.8314;0.0431 0.702 0.8235;0.0314 0.7059 0.8196;0.0235 0.7098 0.8118;0.0157 0.7137 0.8078;0.0078 0.7176 0.8;0.0039 0.7176 0.7922;0 0.7216 0.7882;0 0.7255 0.7804;0 0.7294 0.7765;0.0039 0.7294 0.7686;0.0078 0.7333 0.7608;0.0157 0.7333 0.7569;0.0235 0.7373 0.749;0.0353 0.7412 0.7412;0.051 0.7412 0.7373;0.0627 0.7451 0.7294;0.0784 0.7451 0.7216;0.0902 0.749 0.7137;0.102 0.7529 0.7098;0.1137 0.7529 0.702;0.1255 0.7569 0.6941;0.1373 0.7569 0.6863;0.1451 0.7608 0.6824;0.1529 0.7608 0.6745;0.1608 0.7647 0.6667;0.1686 0.7647 0.6588;0.1725 0.7686 0.651;0.1804 0.7686 0.6471;0.1843 0.7725 0.6392;0.1922 0.7725 0.6314;0.1961 0.7765 0.6235;0.2 0.7804 0.6157;0.2078 0.7804 0.6078;0.2118 0.7843 0.6;0.2196 0.7843 0.5882;0.2235 0.7882 0.5804;0.2314 0.7882 0.5725;0.2392 0.7922 0.5647;0.251 0.7922 0.5529;0.2588 0.7922 0.5451;0.2706 0.7961 0.5373;0.2824 0.7961 0.5255;0.2941 0.7961 0.5176;0.3059 0.8 0.5059;0.3176 0.8 0.498;0.3294 0.8 0.4863;0.3412 0.8 0.4784;0.3529 0.8 0.4667;0.3686 0.8039 0.4549;0.3804 0.8039 0.4471;0.3922 0.8039 0.4353;0.4039 0.8039 0.4235;0.4196 0.8039 0.4118;0.4314 0.8039 0.4;0.4471 0.8039 0.3922;0.4627 0.8 0.3804;0.4745 0.8 0.3686;0.4902 0.8 0.3569;0.5059 0.8 0.349;0.5176 0.8 0.3373;0.5333 0.7961 0.3255;0.5451 0.7961 0.3176;0.5608 0.7961 0.3059;0.5765 0.7922 0.2941;0.5882 0.7922 0.2824;0.6039 0.7882 0.2745;0.6157 0.7882 0.2627;0.6314 0.7843 0.251;0.6431 0.7843 0.2431;0.6549 0.7804 0.2314;0.6706 0.7804 0.2235;0.6824 0.7765 0.2157;0.698 0.7765 0.2078;0.7098 0.7725 0.2;0.7216 0.7686 0.1922;0.7333 0.7686 0.1843;0.7451 0.7647 0.1765;0.7608 0.7647 0.1725;0.7725 0.7608 0.1647;0.7843 0.7569 0.1608;0.7961 0.7569 0.1569;0.8078 0.7529 0.1529;0.8157 0.749 0.1529;0.8275 0.749 0.1529;0.8392 0.7451 0.1529;0.851 0.7451 0.1569;0.8588 0.7412 0.1569;0.8706 0.7373 0.1608;0.8824 0.7373 0.1647;0.8902 0.7373 0.1686;0.902 0.7333 0.1765;0.9098 0.7333 0.1804;0.9176 0.7294 0.1882;0.9255 0.7294 0.1961;0.9373 0.7294 0.2078;0.9451 0.7294 0.2157;0.9529 0.7294 0.2235;0.9608 0.7294 0.2314;0.9686 0.7294 0.2392;0.9765 0.7294 0.2431;0.9843 0.7333 0.2431;0.9882 0.7373 0.2431;0.9961 0.7412 0.2392;0.9961 0.7451 0.2353;0.9961 0.7529 0.2314;0.9961 0.7569 0.2275;0.9961 0.7608 0.2235;0.9961 0.7686 0.2196;0.9961 0.7725 0.2157;0.9961 0.7804 0.2078;0.9961 0.7843 0.2039;0.9961 0.7922 0.2;0.9922 0.7961 0.1961;0.9922 0.8039 0.1922;0.9922 0.8078 0.1922;0.9882 0.8157 0.1882;0.9843 0.8235 0.1843;0.9843 0.8275 0.1804;0.9804 0.8353 0.1804;0.9765 0.8392 0.1765;0.9765 0.8471 0.1725;0.9725 0.851 0.1686;0.9686 0.8588 0.1647;0.9686 0.8667 0.1647;0.9647 0.8706 0.1608;0.9647 0.8784 0.1569;0.9608 0.8824 0.1569;0.9608 0.8902 0.1529;0.9608 0.898 0.149;0.9608 0.902 0.149;0.9608 0.9098 0.1451;0.9608 0.9137 0.1412;0.9608 0.9216 0.1373;0.9608 0.9255 0.1333;0.9608 0.9333 0.1294;0.9647 0.9373 0.1255;0.9647 0.9451 0.1216;0.9647 0.949 0.1176;0.9686 0.9569 0.1098;0.9686 0.9608 0.1059;0.9725 0.9686 0.102;0.9725 0.9725 0.0941;0.9765 0.9765 0.0863;0.9765 0.9843 0.0824];
            app.LunarMissionSimulationUIFigure.Position = [100 100 1433 827];
            app.LunarMissionSimulationUIFigure.Name = 'Lunar Mission Simulation';
            app.LunarMissionSimulationUIFigure.Icon = 'waxing-crescent-moon.jpg';

            % Create UIAxes
            app.UIAxes = uiaxes(app.LunarMissionSimulationUIFigure);
            title(app.UIAxes, 'Rocket Trajectory')
            xlabel(app.UIAxes, 'Time (s)')
            ylabel(app.UIAxes, 'Height (km)')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Colormap = [0.2431 0.149 0.6588;0.2431 0.1529 0.6745;0.2471 0.1569 0.6863;0.2471 0.1608 0.698;0.251 0.1647 0.7059;0.251 0.1686 0.7176;0.2549 0.1725 0.7294;0.2549 0.1765 0.7412;0.2588 0.1804 0.749;0.2588 0.1843 0.7608;0.2627 0.1882 0.7725;0.2627 0.1922 0.7843;0.2627 0.1961 0.7922;0.2667 0.2 0.8039;0.2667 0.2039 0.8157;0.2706 0.2078 0.8235;0.2706 0.2157 0.8353;0.2706 0.2196 0.8431;0.2745 0.2235 0.851;0.2745 0.2275 0.8627;0.2745 0.2314 0.8706;0.2745 0.2392 0.8784;0.2784 0.2431 0.8824;0.2784 0.2471 0.8902;0.2784 0.2549 0.898;0.2784 0.2588 0.902;0.2784 0.2667 0.9098;0.2784 0.2706 0.9137;0.2784 0.2745 0.9216;0.2824 0.2824 0.9255;0.2824 0.2863 0.9294;0.2824 0.2941 0.9333;0.2824 0.298 0.9412;0.2824 0.3059 0.9451;0.2824 0.3098 0.949;0.2824 0.3137 0.9529;0.2824 0.3216 0.9569;0.2824 0.3255 0.9608;0.2824 0.3294 0.9647;0.2784 0.3373 0.9686;0.2784 0.3412 0.9686;0.2784 0.349 0.9725;0.2784 0.3529 0.9765;0.2784 0.3569 0.9804;0.2784 0.3647 0.9804;0.2745 0.3686 0.9843;0.2745 0.3765 0.9843;0.2745 0.3804 0.9882;0.2706 0.3843 0.9882;0.2706 0.3922 0.9922;0.2667 0.3961 0.9922;0.2627 0.4039 0.9922;0.2627 0.4078 0.9961;0.2588 0.4157 0.9961;0.2549 0.4196 0.9961;0.251 0.4275 0.9961;0.2471 0.4314 1;0.2431 0.4392 1;0.2353 0.4431 1;0.2314 0.451 1;0.2235 0.4549 1;0.2196 0.4627 0.9961;0.2118 0.4667 0.9961;0.2078 0.4745 0.9922;0.2 0.4784 0.9922;0.1961 0.4863 0.9882;0.1922 0.4902 0.9882;0.1882 0.498 0.9843;0.1843 0.502 0.9804;0.1843 0.5098 0.9804;0.1804 0.5137 0.9765;0.1804 0.5176 0.9725;0.1804 0.5255 0.9725;0.1804 0.5294 0.9686;0.1765 0.5333 0.9647;0.1765 0.5412 0.9608;0.1765 0.5451 0.9569;0.1765 0.549 0.9529;0.1765 0.5569 0.949;0.1725 0.5608 0.9451;0.1725 0.5647 0.9412;0.1686 0.5686 0.9373;0.1647 0.5765 0.9333;0.1608 0.5804 0.9294;0.1569 0.5843 0.9255;0.1529 0.5922 0.9216;0.1529 0.5961 0.9176;0.149 0.6 0.9137;0.149 0.6039 0.9098;0.1451 0.6078 0.9098;0.1451 0.6118 0.9059;0.1412 0.6196 0.902;0.1412 0.6235 0.898;0.1373 0.6275 0.898;0.1373 0.6314 0.8941;0.1333 0.6353 0.8941;0.1294 0.6392 0.8902;0.1255 0.6471 0.8902;0.1216 0.651 0.8863;0.1176 0.6549 0.8824;0.1137 0.6588 0.8824;0.1137 0.6627 0.8784;0.1098 0.6667 0.8745;0.1059 0.6706 0.8706;0.102 0.6745 0.8667;0.098 0.6784 0.8627;0.0902 0.6824 0.8549;0.0863 0.6863 0.851;0.0784 0.6902 0.8471;0.0706 0.6941 0.8392;0.0627 0.698 0.8353;0.0549 0.702 0.8314;0.0431 0.702 0.8235;0.0314 0.7059 0.8196;0.0235 0.7098 0.8118;0.0157 0.7137 0.8078;0.0078 0.7176 0.8;0.0039 0.7176 0.7922;0 0.7216 0.7882;0 0.7255 0.7804;0 0.7294 0.7765;0.0039 0.7294 0.7686;0.0078 0.7333 0.7608;0.0157 0.7333 0.7569;0.0235 0.7373 0.749;0.0353 0.7412 0.7412;0.051 0.7412 0.7373;0.0627 0.7451 0.7294;0.0784 0.7451 0.7216;0.0902 0.749 0.7137;0.102 0.7529 0.7098;0.1137 0.7529 0.702;0.1255 0.7569 0.6941;0.1373 0.7569 0.6863;0.1451 0.7608 0.6824;0.1529 0.7608 0.6745;0.1608 0.7647 0.6667;0.1686 0.7647 0.6588;0.1725 0.7686 0.651;0.1804 0.7686 0.6471;0.1843 0.7725 0.6392;0.1922 0.7725 0.6314;0.1961 0.7765 0.6235;0.2 0.7804 0.6157;0.2078 0.7804 0.6078;0.2118 0.7843 0.6;0.2196 0.7843 0.5882;0.2235 0.7882 0.5804;0.2314 0.7882 0.5725;0.2392 0.7922 0.5647;0.251 0.7922 0.5529;0.2588 0.7922 0.5451;0.2706 0.7961 0.5373;0.2824 0.7961 0.5255;0.2941 0.7961 0.5176;0.3059 0.8 0.5059;0.3176 0.8 0.498;0.3294 0.8 0.4863;0.3412 0.8 0.4784;0.3529 0.8 0.4667;0.3686 0.8039 0.4549;0.3804 0.8039 0.4471;0.3922 0.8039 0.4353;0.4039 0.8039 0.4235;0.4196 0.8039 0.4118;0.4314 0.8039 0.4;0.4471 0.8039 0.3922;0.4627 0.8 0.3804;0.4745 0.8 0.3686;0.4902 0.8 0.3569;0.5059 0.8 0.349;0.5176 0.8 0.3373;0.5333 0.7961 0.3255;0.5451 0.7961 0.3176;0.5608 0.7961 0.3059;0.5765 0.7922 0.2941;0.5882 0.7922 0.2824;0.6039 0.7882 0.2745;0.6157 0.7882 0.2627;0.6314 0.7843 0.251;0.6431 0.7843 0.2431;0.6549 0.7804 0.2314;0.6706 0.7804 0.2235;0.6824 0.7765 0.2157;0.698 0.7765 0.2078;0.7098 0.7725 0.2;0.7216 0.7686 0.1922;0.7333 0.7686 0.1843;0.7451 0.7647 0.1765;0.7608 0.7647 0.1725;0.7725 0.7608 0.1647;0.7843 0.7569 0.1608;0.7961 0.7569 0.1569;0.8078 0.7529 0.1529;0.8157 0.749 0.1529;0.8275 0.749 0.1529;0.8392 0.7451 0.1529;0.851 0.7451 0.1569;0.8588 0.7412 0.1569;0.8706 0.7373 0.1608;0.8824 0.7373 0.1647;0.8902 0.7373 0.1686;0.902 0.7333 0.1765;0.9098 0.7333 0.1804;0.9176 0.7294 0.1882;0.9255 0.7294 0.1961;0.9373 0.7294 0.2078;0.9451 0.7294 0.2157;0.9529 0.7294 0.2235;0.9608 0.7294 0.2314;0.9686 0.7294 0.2392;0.9765 0.7294 0.2431;0.9843 0.7333 0.2431;0.9882 0.7373 0.2431;0.9961 0.7412 0.2392;0.9961 0.7451 0.2353;0.9961 0.7529 0.2314;0.9961 0.7569 0.2275;0.9961 0.7608 0.2235;0.9961 0.7686 0.2196;0.9961 0.7725 0.2157;0.9961 0.7804 0.2078;0.9961 0.7843 0.2039;0.9961 0.7922 0.2;0.9922 0.7961 0.1961;0.9922 0.8039 0.1922;0.9922 0.8078 0.1922;0.9882 0.8157 0.1882;0.9843 0.8235 0.1843;0.9843 0.8275 0.1804;0.9804 0.8353 0.1804;0.9765 0.8392 0.1765;0.9765 0.8471 0.1725;0.9725 0.851 0.1686;0.9686 0.8588 0.1647;0.9686 0.8667 0.1647;0.9647 0.8706 0.1608;0.9647 0.8784 0.1569;0.9608 0.8824 0.1569;0.9608 0.8902 0.1529;0.9608 0.898 0.149;0.9608 0.902 0.149;0.9608 0.9098 0.1451;0.9608 0.9137 0.1412;0.9608 0.9216 0.1373;0.9608 0.9255 0.1333;0.9608 0.9333 0.1294;0.9647 0.9373 0.1255;0.9647 0.9451 0.1216;0.9647 0.949 0.1176;0.9686 0.9569 0.1098;0.9686 0.9608 0.1059;0.9725 0.9686 0.102;0.9725 0.9725 0.0941;0.9765 0.9765 0.0863;0.9765 0.9843 0.0824];
            app.UIAxes.Position = [34 23 419 261];

            % Create UIAxes_3
            app.UIAxes_3 = uiaxes(app.LunarMissionSimulationUIFigure);
            title(app.UIAxes_3, 'Lunar Descent')
            xlabel(app.UIAxes_3, 'Time (s)')
            ylabel(app.UIAxes_3, 'Height (km)')
            zlabel(app.UIAxes_3, 'Z')
            app.UIAxes_3.Colormap = [0.2431 0.149 0.6588;0.2431 0.1529 0.6745;0.2471 0.1569 0.6863;0.2471 0.1608 0.698;0.251 0.1647 0.7059;0.251 0.1686 0.7176;0.2549 0.1725 0.7294;0.2549 0.1765 0.7412;0.2588 0.1804 0.749;0.2588 0.1843 0.7608;0.2627 0.1882 0.7725;0.2627 0.1922 0.7843;0.2627 0.1961 0.7922;0.2667 0.2 0.8039;0.2667 0.2039 0.8157;0.2706 0.2078 0.8235;0.2706 0.2157 0.8353;0.2706 0.2196 0.8431;0.2745 0.2235 0.851;0.2745 0.2275 0.8627;0.2745 0.2314 0.8706;0.2745 0.2392 0.8784;0.2784 0.2431 0.8824;0.2784 0.2471 0.8902;0.2784 0.2549 0.898;0.2784 0.2588 0.902;0.2784 0.2667 0.9098;0.2784 0.2706 0.9137;0.2784 0.2745 0.9216;0.2824 0.2824 0.9255;0.2824 0.2863 0.9294;0.2824 0.2941 0.9333;0.2824 0.298 0.9412;0.2824 0.3059 0.9451;0.2824 0.3098 0.949;0.2824 0.3137 0.9529;0.2824 0.3216 0.9569;0.2824 0.3255 0.9608;0.2824 0.3294 0.9647;0.2784 0.3373 0.9686;0.2784 0.3412 0.9686;0.2784 0.349 0.9725;0.2784 0.3529 0.9765;0.2784 0.3569 0.9804;0.2784 0.3647 0.9804;0.2745 0.3686 0.9843;0.2745 0.3765 0.9843;0.2745 0.3804 0.9882;0.2706 0.3843 0.9882;0.2706 0.3922 0.9922;0.2667 0.3961 0.9922;0.2627 0.4039 0.9922;0.2627 0.4078 0.9961;0.2588 0.4157 0.9961;0.2549 0.4196 0.9961;0.251 0.4275 0.9961;0.2471 0.4314 1;0.2431 0.4392 1;0.2353 0.4431 1;0.2314 0.451 1;0.2235 0.4549 1;0.2196 0.4627 0.9961;0.2118 0.4667 0.9961;0.2078 0.4745 0.9922;0.2 0.4784 0.9922;0.1961 0.4863 0.9882;0.1922 0.4902 0.9882;0.1882 0.498 0.9843;0.1843 0.502 0.9804;0.1843 0.5098 0.9804;0.1804 0.5137 0.9765;0.1804 0.5176 0.9725;0.1804 0.5255 0.9725;0.1804 0.5294 0.9686;0.1765 0.5333 0.9647;0.1765 0.5412 0.9608;0.1765 0.5451 0.9569;0.1765 0.549 0.9529;0.1765 0.5569 0.949;0.1725 0.5608 0.9451;0.1725 0.5647 0.9412;0.1686 0.5686 0.9373;0.1647 0.5765 0.9333;0.1608 0.5804 0.9294;0.1569 0.5843 0.9255;0.1529 0.5922 0.9216;0.1529 0.5961 0.9176;0.149 0.6 0.9137;0.149 0.6039 0.9098;0.1451 0.6078 0.9098;0.1451 0.6118 0.9059;0.1412 0.6196 0.902;0.1412 0.6235 0.898;0.1373 0.6275 0.898;0.1373 0.6314 0.8941;0.1333 0.6353 0.8941;0.1294 0.6392 0.8902;0.1255 0.6471 0.8902;0.1216 0.651 0.8863;0.1176 0.6549 0.8824;0.1137 0.6588 0.8824;0.1137 0.6627 0.8784;0.1098 0.6667 0.8745;0.1059 0.6706 0.8706;0.102 0.6745 0.8667;0.098 0.6784 0.8627;0.0902 0.6824 0.8549;0.0863 0.6863 0.851;0.0784 0.6902 0.8471;0.0706 0.6941 0.8392;0.0627 0.698 0.8353;0.0549 0.702 0.8314;0.0431 0.702 0.8235;0.0314 0.7059 0.8196;0.0235 0.7098 0.8118;0.0157 0.7137 0.8078;0.0078 0.7176 0.8;0.0039 0.7176 0.7922;0 0.7216 0.7882;0 0.7255 0.7804;0 0.7294 0.7765;0.0039 0.7294 0.7686;0.0078 0.7333 0.7608;0.0157 0.7333 0.7569;0.0235 0.7373 0.749;0.0353 0.7412 0.7412;0.051 0.7412 0.7373;0.0627 0.7451 0.7294;0.0784 0.7451 0.7216;0.0902 0.749 0.7137;0.102 0.7529 0.7098;0.1137 0.7529 0.702;0.1255 0.7569 0.6941;0.1373 0.7569 0.6863;0.1451 0.7608 0.6824;0.1529 0.7608 0.6745;0.1608 0.7647 0.6667;0.1686 0.7647 0.6588;0.1725 0.7686 0.651;0.1804 0.7686 0.6471;0.1843 0.7725 0.6392;0.1922 0.7725 0.6314;0.1961 0.7765 0.6235;0.2 0.7804 0.6157;0.2078 0.7804 0.6078;0.2118 0.7843 0.6;0.2196 0.7843 0.5882;0.2235 0.7882 0.5804;0.2314 0.7882 0.5725;0.2392 0.7922 0.5647;0.251 0.7922 0.5529;0.2588 0.7922 0.5451;0.2706 0.7961 0.5373;0.2824 0.7961 0.5255;0.2941 0.7961 0.5176;0.3059 0.8 0.5059;0.3176 0.8 0.498;0.3294 0.8 0.4863;0.3412 0.8 0.4784;0.3529 0.8 0.4667;0.3686 0.8039 0.4549;0.3804 0.8039 0.4471;0.3922 0.8039 0.4353;0.4039 0.8039 0.4235;0.4196 0.8039 0.4118;0.4314 0.8039 0.4;0.4471 0.8039 0.3922;0.4627 0.8 0.3804;0.4745 0.8 0.3686;0.4902 0.8 0.3569;0.5059 0.8 0.349;0.5176 0.8 0.3373;0.5333 0.7961 0.3255;0.5451 0.7961 0.3176;0.5608 0.7961 0.3059;0.5765 0.7922 0.2941;0.5882 0.7922 0.2824;0.6039 0.7882 0.2745;0.6157 0.7882 0.2627;0.6314 0.7843 0.251;0.6431 0.7843 0.2431;0.6549 0.7804 0.2314;0.6706 0.7804 0.2235;0.6824 0.7765 0.2157;0.698 0.7765 0.2078;0.7098 0.7725 0.2;0.7216 0.7686 0.1922;0.7333 0.7686 0.1843;0.7451 0.7647 0.1765;0.7608 0.7647 0.1725;0.7725 0.7608 0.1647;0.7843 0.7569 0.1608;0.7961 0.7569 0.1569;0.8078 0.7529 0.1529;0.8157 0.749 0.1529;0.8275 0.749 0.1529;0.8392 0.7451 0.1529;0.851 0.7451 0.1569;0.8588 0.7412 0.1569;0.8706 0.7373 0.1608;0.8824 0.7373 0.1647;0.8902 0.7373 0.1686;0.902 0.7333 0.1765;0.9098 0.7333 0.1804;0.9176 0.7294 0.1882;0.9255 0.7294 0.1961;0.9373 0.7294 0.2078;0.9451 0.7294 0.2157;0.9529 0.7294 0.2235;0.9608 0.7294 0.2314;0.9686 0.7294 0.2392;0.9765 0.7294 0.2431;0.9843 0.7333 0.2431;0.9882 0.7373 0.2431;0.9961 0.7412 0.2392;0.9961 0.7451 0.2353;0.9961 0.7529 0.2314;0.9961 0.7569 0.2275;0.9961 0.7608 0.2235;0.9961 0.7686 0.2196;0.9961 0.7725 0.2157;0.9961 0.7804 0.2078;0.9961 0.7843 0.2039;0.9961 0.7922 0.2;0.9922 0.7961 0.1961;0.9922 0.8039 0.1922;0.9922 0.8078 0.1922;0.9882 0.8157 0.1882;0.9843 0.8235 0.1843;0.9843 0.8275 0.1804;0.9804 0.8353 0.1804;0.9765 0.8392 0.1765;0.9765 0.8471 0.1725;0.9725 0.851 0.1686;0.9686 0.8588 0.1647;0.9686 0.8667 0.1647;0.9647 0.8706 0.1608;0.9647 0.8784 0.1569;0.9608 0.8824 0.1569;0.9608 0.8902 0.1529;0.9608 0.898 0.149;0.9608 0.902 0.149;0.9608 0.9098 0.1451;0.9608 0.9137 0.1412;0.9608 0.9216 0.1373;0.9608 0.9255 0.1333;0.9608 0.9333 0.1294;0.9647 0.9373 0.1255;0.9647 0.9451 0.1216;0.9647 0.949 0.1176;0.9686 0.9569 0.1098;0.9686 0.9608 0.1059;0.9725 0.9686 0.102;0.9725 0.9725 0.0941;0.9765 0.9765 0.0863;0.9765 0.9843 0.0824];
            app.UIAxes_3.Position = [949 17 456 267];

            % Create UIAxes_2
            app.UIAxes_2 = uiaxes(app.LunarMissionSimulationUIFigure);
            title(app.UIAxes_2, 'Orbit Trajectory')
            xlabel(app.UIAxes_2, 'Number of Orbits (int)')
            ylabel(app.UIAxes_2, 'Distance (km)')
            zlabel(app.UIAxes_2, 'Z')
            app.UIAxes_2.Colormap = [0.2431 0.149 0.6588;0.2431 0.1529 0.6745;0.2471 0.1569 0.6863;0.2471 0.1608 0.698;0.251 0.1647 0.7059;0.251 0.1686 0.7176;0.2549 0.1725 0.7294;0.2549 0.1765 0.7412;0.2588 0.1804 0.749;0.2588 0.1843 0.7608;0.2627 0.1882 0.7725;0.2627 0.1922 0.7843;0.2627 0.1961 0.7922;0.2667 0.2 0.8039;0.2667 0.2039 0.8157;0.2706 0.2078 0.8235;0.2706 0.2157 0.8353;0.2706 0.2196 0.8431;0.2745 0.2235 0.851;0.2745 0.2275 0.8627;0.2745 0.2314 0.8706;0.2745 0.2392 0.8784;0.2784 0.2431 0.8824;0.2784 0.2471 0.8902;0.2784 0.2549 0.898;0.2784 0.2588 0.902;0.2784 0.2667 0.9098;0.2784 0.2706 0.9137;0.2784 0.2745 0.9216;0.2824 0.2824 0.9255;0.2824 0.2863 0.9294;0.2824 0.2941 0.9333;0.2824 0.298 0.9412;0.2824 0.3059 0.9451;0.2824 0.3098 0.949;0.2824 0.3137 0.9529;0.2824 0.3216 0.9569;0.2824 0.3255 0.9608;0.2824 0.3294 0.9647;0.2784 0.3373 0.9686;0.2784 0.3412 0.9686;0.2784 0.349 0.9725;0.2784 0.3529 0.9765;0.2784 0.3569 0.9804;0.2784 0.3647 0.9804;0.2745 0.3686 0.9843;0.2745 0.3765 0.9843;0.2745 0.3804 0.9882;0.2706 0.3843 0.9882;0.2706 0.3922 0.9922;0.2667 0.3961 0.9922;0.2627 0.4039 0.9922;0.2627 0.4078 0.9961;0.2588 0.4157 0.9961;0.2549 0.4196 0.9961;0.251 0.4275 0.9961;0.2471 0.4314 1;0.2431 0.4392 1;0.2353 0.4431 1;0.2314 0.451 1;0.2235 0.4549 1;0.2196 0.4627 0.9961;0.2118 0.4667 0.9961;0.2078 0.4745 0.9922;0.2 0.4784 0.9922;0.1961 0.4863 0.9882;0.1922 0.4902 0.9882;0.1882 0.498 0.9843;0.1843 0.502 0.9804;0.1843 0.5098 0.9804;0.1804 0.5137 0.9765;0.1804 0.5176 0.9725;0.1804 0.5255 0.9725;0.1804 0.5294 0.9686;0.1765 0.5333 0.9647;0.1765 0.5412 0.9608;0.1765 0.5451 0.9569;0.1765 0.549 0.9529;0.1765 0.5569 0.949;0.1725 0.5608 0.9451;0.1725 0.5647 0.9412;0.1686 0.5686 0.9373;0.1647 0.5765 0.9333;0.1608 0.5804 0.9294;0.1569 0.5843 0.9255;0.1529 0.5922 0.9216;0.1529 0.5961 0.9176;0.149 0.6 0.9137;0.149 0.6039 0.9098;0.1451 0.6078 0.9098;0.1451 0.6118 0.9059;0.1412 0.6196 0.902;0.1412 0.6235 0.898;0.1373 0.6275 0.898;0.1373 0.6314 0.8941;0.1333 0.6353 0.8941;0.1294 0.6392 0.8902;0.1255 0.6471 0.8902;0.1216 0.651 0.8863;0.1176 0.6549 0.8824;0.1137 0.6588 0.8824;0.1137 0.6627 0.8784;0.1098 0.6667 0.8745;0.1059 0.6706 0.8706;0.102 0.6745 0.8667;0.098 0.6784 0.8627;0.0902 0.6824 0.8549;0.0863 0.6863 0.851;0.0784 0.6902 0.8471;0.0706 0.6941 0.8392;0.0627 0.698 0.8353;0.0549 0.702 0.8314;0.0431 0.702 0.8235;0.0314 0.7059 0.8196;0.0235 0.7098 0.8118;0.0157 0.7137 0.8078;0.0078 0.7176 0.8;0.0039 0.7176 0.7922;0 0.7216 0.7882;0 0.7255 0.7804;0 0.7294 0.7765;0.0039 0.7294 0.7686;0.0078 0.7333 0.7608;0.0157 0.7333 0.7569;0.0235 0.7373 0.749;0.0353 0.7412 0.7412;0.051 0.7412 0.7373;0.0627 0.7451 0.7294;0.0784 0.7451 0.7216;0.0902 0.749 0.7137;0.102 0.7529 0.7098;0.1137 0.7529 0.702;0.1255 0.7569 0.6941;0.1373 0.7569 0.6863;0.1451 0.7608 0.6824;0.1529 0.7608 0.6745;0.1608 0.7647 0.6667;0.1686 0.7647 0.6588;0.1725 0.7686 0.651;0.1804 0.7686 0.6471;0.1843 0.7725 0.6392;0.1922 0.7725 0.6314;0.1961 0.7765 0.6235;0.2 0.7804 0.6157;0.2078 0.7804 0.6078;0.2118 0.7843 0.6;0.2196 0.7843 0.5882;0.2235 0.7882 0.5804;0.2314 0.7882 0.5725;0.2392 0.7922 0.5647;0.251 0.7922 0.5529;0.2588 0.7922 0.5451;0.2706 0.7961 0.5373;0.2824 0.7961 0.5255;0.2941 0.7961 0.5176;0.3059 0.8 0.5059;0.3176 0.8 0.498;0.3294 0.8 0.4863;0.3412 0.8 0.4784;0.3529 0.8 0.4667;0.3686 0.8039 0.4549;0.3804 0.8039 0.4471;0.3922 0.8039 0.4353;0.4039 0.8039 0.4235;0.4196 0.8039 0.4118;0.4314 0.8039 0.4;0.4471 0.8039 0.3922;0.4627 0.8 0.3804;0.4745 0.8 0.3686;0.4902 0.8 0.3569;0.5059 0.8 0.349;0.5176 0.8 0.3373;0.5333 0.7961 0.3255;0.5451 0.7961 0.3176;0.5608 0.7961 0.3059;0.5765 0.7922 0.2941;0.5882 0.7922 0.2824;0.6039 0.7882 0.2745;0.6157 0.7882 0.2627;0.6314 0.7843 0.251;0.6431 0.7843 0.2431;0.6549 0.7804 0.2314;0.6706 0.7804 0.2235;0.6824 0.7765 0.2157;0.698 0.7765 0.2078;0.7098 0.7725 0.2;0.7216 0.7686 0.1922;0.7333 0.7686 0.1843;0.7451 0.7647 0.1765;0.7608 0.7647 0.1725;0.7725 0.7608 0.1647;0.7843 0.7569 0.1608;0.7961 0.7569 0.1569;0.8078 0.7529 0.1529;0.8157 0.749 0.1529;0.8275 0.749 0.1529;0.8392 0.7451 0.1529;0.851 0.7451 0.1569;0.8588 0.7412 0.1569;0.8706 0.7373 0.1608;0.8824 0.7373 0.1647;0.8902 0.7373 0.1686;0.902 0.7333 0.1765;0.9098 0.7333 0.1804;0.9176 0.7294 0.1882;0.9255 0.7294 0.1961;0.9373 0.7294 0.2078;0.9451 0.7294 0.2157;0.9529 0.7294 0.2235;0.9608 0.7294 0.2314;0.9686 0.7294 0.2392;0.9765 0.7294 0.2431;0.9843 0.7333 0.2431;0.9882 0.7373 0.2431;0.9961 0.7412 0.2392;0.9961 0.7451 0.2353;0.9961 0.7529 0.2314;0.9961 0.7569 0.2275;0.9961 0.7608 0.2235;0.9961 0.7686 0.2196;0.9961 0.7725 0.2157;0.9961 0.7804 0.2078;0.9961 0.7843 0.2039;0.9961 0.7922 0.2;0.9922 0.7961 0.1961;0.9922 0.8039 0.1922;0.9922 0.8078 0.1922;0.9882 0.8157 0.1882;0.9843 0.8235 0.1843;0.9843 0.8275 0.1804;0.9804 0.8353 0.1804;0.9765 0.8392 0.1765;0.9765 0.8471 0.1725;0.9725 0.851 0.1686;0.9686 0.8588 0.1647;0.9686 0.8667 0.1647;0.9647 0.8706 0.1608;0.9647 0.8784 0.1569;0.9608 0.8824 0.1569;0.9608 0.8902 0.1529;0.9608 0.898 0.149;0.9608 0.902 0.149;0.9608 0.9098 0.1451;0.9608 0.9137 0.1412;0.9608 0.9216 0.1373;0.9608 0.9255 0.1333;0.9608 0.9333 0.1294;0.9647 0.9373 0.1255;0.9647 0.9451 0.1216;0.9647 0.949 0.1176;0.9686 0.9569 0.1098;0.9686 0.9608 0.1059;0.9725 0.9686 0.102;0.9725 0.9725 0.0941;0.9765 0.9765 0.0863;0.9765 0.9843 0.0824];
            app.UIAxes_2.XTick = [1 2 3 4 5 6];
            app.UIAxes_2.XTickLabel = {'1'; '2'; '3'; '4'; '5'; '6'};
            app.UIAxes_2.YTick = [0 0.2 0.4 0.6 0.8 1];
            app.UIAxes_2.Position = [469 19 446 267];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.LunarMissionSimulationUIFigure);
            app.TabGroup.Position = [64 678 405 113];

            % Create PresetsTab
            app.PresetsTab = uitab(app.TabGroup);
            app.PresetsTab.Title = 'Presets';

            % Create PresetsDropDownLabel
            app.PresetsDropDownLabel = uilabel(app.PresetsTab);
            app.PresetsDropDownLabel.HorizontalAlignment = 'right';
            app.PresetsDropDownLabel.Position = [99 34 46 22];
            app.PresetsDropDownLabel.Text = 'Presets';

            % Create PresetsDropDown
            app.PresetsDropDown = uidropdown(app.PresetsTab);
            app.PresetsDropDown.Items = {'SpaceX - Falcon 9', 'RosCosmos - Soyuz', 'NASA - Saturn V', 'Custom'};
            app.PresetsDropDown.ValueChangedFcn = createCallbackFcn(app, @PresetsDropDownValueChanged, true);
            app.PresetsDropDown.Position = [160 34 141 22];
            app.PresetsDropDown.Value = 'NASA - Saturn V';

            % Create GravitationTab
            app.GravitationTab = uitab(app.TabGroup);
            app.GravitationTab.Title = 'Gravitation';

            % Create EarthGravitationms2SpinnerLabel
            app.EarthGravitationms2SpinnerLabel = uilabel(app.GravitationTab);
            app.EarthGravitationms2SpinnerLabel.HorizontalAlignment = 'right';
            app.EarthGravitationms2SpinnerLabel.Position = [72 48 139 22];
            app.EarthGravitationms2SpinnerLabel.Text = 'Earth Gravitation (m/s^2)';

            % Create EarthGravitationms2Spinner
            app.EarthGravitationms2Spinner = uispinner(app.GravitationTab);
            app.EarthGravitationms2Spinner.ValueChangedFcn = createCallbackFcn(app, @EarthGravitationms2SpinnerValueChanged, true);
            app.EarthGravitationms2Spinner.Position = [226 48 100 22];
            app.EarthGravitationms2Spinner.Value = 9.81;

            % Create MoonGravitationms2SpinnerLabel
            app.MoonGravitationms2SpinnerLabel = uilabel(app.GravitationTab);
            app.MoonGravitationms2SpinnerLabel.HorizontalAlignment = 'right';
            app.MoonGravitationms2SpinnerLabel.Position = [71 23 140 22];
            app.MoonGravitationms2SpinnerLabel.Text = 'Moon Gravitation (m/s^2)';

            % Create MoonGravitationms2Spinner
            app.MoonGravitationms2Spinner = uispinner(app.GravitationTab);
            app.MoonGravitationms2Spinner.ValueChangedFcn = createCallbackFcn(app, @MoonGravitationms2SpinnerValueChanged, true);
            app.MoonGravitationms2Spinner.Position = [226 23 100 22];
            app.MoonGravitationms2Spinner.Value = 1.625;

            % Create PayloadsTab
            app.PayloadsTab = uitab(app.TabGroup);
            app.PayloadsTab.Title = 'Payloads';

            % Create RocketMasskgSpinnerLabel
            app.RocketMasskgSpinnerLabel = uilabel(app.PayloadsTab);
            app.RocketMasskgSpinnerLabel.HorizontalAlignment = 'right';
            app.RocketMasskgSpinnerLabel.Position = [85 56 99 22];
            app.RocketMasskgSpinnerLabel.Text = 'Rocket Mass (kg)';

            % Create RocketMasskgSpinner
            app.RocketMasskgSpinner = uispinner(app.PayloadsTab);
            app.RocketMasskgSpinner.ValueChangedFcn = createCallbackFcn(app, @RocketMasskgSpinnerValueChanged, true);
            app.RocketMasskgSpinner.Position = [199 56 100 22];
            app.RocketMasskgSpinner.Value = 2800000;

            % Create PayloadMasskgSpinnerLabel
            app.PayloadMasskgSpinnerLabel = uilabel(app.PayloadsTab);
            app.PayloadMasskgSpinnerLabel.HorizontalAlignment = 'right';
            app.PayloadMasskgSpinnerLabel.Position = [80 27 105 22];
            app.PayloadMasskgSpinnerLabel.Text = 'Payload Mass (kg)';

            % Create PayloadMasskgSpinner
            app.PayloadMasskgSpinner = uispinner(app.PayloadsTab);
            app.PayloadMasskgSpinner.ValueChangedFcn = createCallbackFcn(app, @PayloadMasskgSpinnerValueChanged, true);
            app.PayloadMasskgSpinner.Position = [200 27 100 22];
            app.PayloadMasskgSpinner.Value = 28000;

            % Create RatesTab
            app.RatesTab = uitab(app.TabGroup);
            app.RatesTab.Title = 'Rates';

            % Create MERatekgsSpinnerLabel
            app.MERatekgsSpinnerLabel = uilabel(app.RatesTab);
            app.MERatekgsSpinnerLabel.HorizontalAlignment = 'right';
            app.MERatekgsSpinnerLabel.Position = [114 61 92 22];
            app.MERatekgsSpinnerLabel.Text = 'M.E. Rate (kg/s)';

            % Create MERatekgsSpinner
            app.MERatekgsSpinner = uispinner(app.RatesTab);
            app.MERatekgsSpinner.ValueChangedFcn = createCallbackFcn(app, @MERatekgsSpinnerValueChanged, true);
            app.MERatekgsSpinner.Position = [221 61 100 22];
            app.MERatekgsSpinner.Value = 25000;

            % Create RelativeVelocitymsSpinnerLabel
            app.RelativeVelocitymsSpinnerLabel = uilabel(app.RatesTab);
            app.RelativeVelocitymsSpinnerLabel.HorizontalAlignment = 'right';
            app.RelativeVelocitymsSpinnerLabel.Position = [81 33 124 22];
            app.RelativeVelocitymsSpinnerLabel.Text = 'Relative Velocity (m/s)';

            % Create RelativeVelocitymsSpinner
            app.RelativeVelocitymsSpinner = uispinner(app.RatesTab);
            app.RelativeVelocitymsSpinner.ValueChangedFcn = createCallbackFcn(app, @RelativeVelocitymsSpinnerValueChanged, true);
            app.RelativeVelocitymsSpinner.Position = [220 33 100 22];
            app.RelativeVelocitymsSpinner.Value = 2200;

            % Create SpacecraftAccelerationms2SpinnerLabel
            app.SpacecraftAccelerationms2SpinnerLabel = uilabel(app.RatesTab);
            app.SpacecraftAccelerationms2SpinnerLabel.HorizontalAlignment = 'right';
            app.SpacecraftAccelerationms2SpinnerLabel.Position = [31 3 181 22];
            app.SpacecraftAccelerationms2SpinnerLabel.Text = 'Spacecraft Acceleration (m/s^2)  ';

            % Create SpacecraftAccelerationms2Spinner
            app.SpacecraftAccelerationms2Spinner = uispinner(app.RatesTab);
            app.SpacecraftAccelerationms2Spinner.Position = [220 4 100 22];
            app.SpacecraftAccelerationms2Spinner.Value = 1;

            % Create OrbitsTab
            app.OrbitsTab = uitab(app.TabGroup);
            app.OrbitsTab.Title = 'Orbits';

            % Create OrbitsEarthtoTransitionSpinnerLabel
            app.OrbitsEarthtoTransitionSpinnerLabel = uilabel(app.OrbitsTab);
            app.OrbitsEarthtoTransitionSpinnerLabel.HorizontalAlignment = 'right';
            app.OrbitsEarthtoTransitionSpinnerLabel.Position = [81 52 142 22];
            app.OrbitsEarthtoTransitionSpinnerLabel.Text = 'Orbits: Earth to Transition';

            % Create OrbitsEarthtoTransitionSpinner
            app.OrbitsEarthtoTransitionSpinner = uispinner(app.OrbitsTab);
            app.OrbitsEarthtoTransitionSpinner.RoundFractionalValues = 'on';
            app.OrbitsEarthtoTransitionSpinner.ValueChangedFcn = createCallbackFcn(app, @OrbitsEarthtoTransitionSpinnerValueChanged, true);
            app.OrbitsEarthtoTransitionSpinner.Position = [238 52 100 22];
            app.OrbitsEarthtoTransitionSpinner.Value = 3;

            % Create OrbitsTransitiontoMoonSpinnerLabel
            app.OrbitsTransitiontoMoonSpinnerLabel = uilabel(app.OrbitsTab);
            app.OrbitsTransitiontoMoonSpinnerLabel.HorizontalAlignment = 'right';
            app.OrbitsTransitiontoMoonSpinnerLabel.Position = [80 23 143 22];
            app.OrbitsTransitiontoMoonSpinnerLabel.Text = 'Orbits: Transition to Moon';

            % Create OrbitsTransitiontoMoonSpinner
            app.OrbitsTransitiontoMoonSpinner = uispinner(app.OrbitsTab);
            app.OrbitsTransitiontoMoonSpinner.RoundFractionalValues = 'on';
            app.OrbitsTransitiontoMoonSpinner.ValueChangedFcn = createCallbackFcn(app, @OrbitsTransitiontoMoonSpinnerValueChanged, true);
            app.OrbitsTransitiontoMoonSpinner.Position = [238 23 100 22];
            app.OrbitsTransitiontoMoonSpinner.Value = 3;

            % Create StartSimulationButton
            app.StartSimulationButton = uibutton(app.LunarMissionSimulationUIFigure, 'push');
            app.StartSimulationButton.ButtonPushedFcn = createCallbackFcn(app, @StartSimulationButtonPushed, true);
            app.StartSimulationButton.BackgroundColor = [0.8 0.8 0.8];
            app.StartSimulationButton.Position = [63 415 406 24];
            app.StartSimulationButton.Text = 'Start Simulation';

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.LunarMissionSimulationUIFigure);
            app.TabGroup2.Position = [65 460 404 204];

            % Create DataTranscriptionTab
            app.DataTranscriptionTab = uitab(app.TabGroup2);
            app.DataTranscriptionTab.Title = 'Data Transcription';

            % Create VELOCITYLabel
            app.VELOCITYLabel = uilabel(app.DataTranscriptionTab);
            app.VELOCITYLabel.FontWeight = 'bold';
            app.VELOCITYLabel.Position = [8 149 262 22];
            app.VELOCITYLabel.Text = 'VELOCITY: ';

            % Create HEIGHTLabel
            app.HEIGHTLabel = uilabel(app.DataTranscriptionTab);
            app.HEIGHTLabel.FontWeight = 'bold';
            app.HEIGHTLabel.Position = [8 128 262 22];
            app.HEIGHTLabel.Text = 'HEIGHT:';

            % Create TIMEELAPSEDLabel
            app.TIMEELAPSEDLabel = uilabel(app.DataTranscriptionTab);
            app.TIMEELAPSEDLabel.FontWeight = 'bold';
            app.TIMEELAPSEDLabel.Position = [8 107 262 22];
            app.TIMEELAPSEDLabel.Text = 'TIME ELAPSED: ';

            % Create ROCKETMASSLabel
            app.ROCKETMASSLabel = uilabel(app.DataTranscriptionTab);
            app.ROCKETMASSLabel.FontWeight = 'bold';
            app.ROCKETMASSLabel.Position = [9 86 261 22];
            app.ROCKETMASSLabel.Text = 'ROCKET MASS:';

            % Create PAYLOADMASSLabel
            app.PAYLOADMASSLabel = uilabel(app.DataTranscriptionTab);
            app.PAYLOADMASSLabel.FontWeight = 'bold';
            app.PAYLOADMASSLabel.Position = [9 65 261 22];
            app.PAYLOADMASSLabel.Text = 'PAYLOAD MASS: ';

            % Create GRAVITATIONLabel
            app.GRAVITATIONLabel = uilabel(app.DataTranscriptionTab);
            app.GRAVITATIONLabel.FontWeight = 'bold';
            app.GRAVITATIONLabel.Position = [9 44 262 22];
            app.GRAVITATIONLabel.Text = 'GRAVITATION: ';

            % Create MASSEXPUSLIONRATELabel
            app.MASSEXPUSLIONRATELabel = uilabel(app.DataTranscriptionTab);
            app.MASSEXPUSLIONRATELabel.FontWeight = 'bold';
            app.MASSEXPUSLIONRATELabel.Position = [9 23 261 22];
            app.MASSEXPUSLIONRATELabel.Text = 'MASS EXPUSLION RATE:';

            % Create RELATIVEVELOCITYLabel
            app.RELATIVEVELOCITYLabel = uilabel(app.DataTranscriptionTab);
            app.RELATIVEVELOCITYLabel.FontWeight = 'bold';
            app.RELATIVEVELOCITYLabel.Position = [8 2 262 22];
            app.RELATIVEVELOCITYLabel.Text = 'RELATIVE VELOCITY:';

            % Create StageTrackerTab
            app.StageTrackerTab = uitab(app.TabGroup2);
            app.StageTrackerTab.Title = 'Stage Tracker';

            % Create Lamp
            app.Lamp = uilamp(app.StageTrackerTab);
            app.Lamp.Position = [61 27 12 12];
            app.Lamp.Color = [0.902 0.902 0.902];

            % Create CURRENTSTAGELabel
            app.CURRENTSTAGELabel = uilabel(app.StageTrackerTab);
            app.CURRENTSTAGELabel.FontWeight = 'bold';
            app.CURRENTSTAGELabel.Position = [8 149 381 22];
            app.CURRENTSTAGELabel.Text = 'CURRENT STAGE: ';

            % Create NEXTSTAGELabel
            app.NEXTSTAGELabel = uilabel(app.StageTrackerTab);
            app.NEXTSTAGELabel.FontWeight = 'bold';
            app.NEXTSTAGELabel.Position = [8 128 381 22];
            app.NEXTSTAGELabel.Text = 'NEXT STAGE: ';

            % Create STATUSLabel
            app.STATUSLabel = uilabel(app.StageTrackerTab);
            app.STATUSLabel.FontWeight = 'bold';
            app.STATUSLabel.Position = [7 22 56 22];
            app.STATUSLabel.Text = 'STATUS:';

            % Create LOCATIONLabel
            app.LOCATIONLabel = uilabel(app.StageTrackerTab);
            app.LOCATIONLabel.FontWeight = 'bold';
            app.LOCATIONLabel.Position = [8 107 382 22];
            app.LOCATIONLabel.Text = 'LOCATION: ';

            % Create Label_2
            app.Label_2 = uilabel(app.StageTrackerTab);
            app.Label_2.FontWeight = 'bold';
            app.Label_2.Position = [6 65 25 22];
            app.Label_2.Text = '';

            % Create WARNINGSLabel
            app.WARNINGSLabel = uilabel(app.StageTrackerTab);
            app.WARNINGSLabel.FontWeight = 'bold';
            app.WARNINGSLabel.Position = [7 1 381 22];
            app.WARNINGSLabel.Text = 'WARNINGS: ';

            % Create SpacecraftPanel
            app.SpacecraftPanel = uipanel(app.LunarMissionSimulationUIFigure);
            app.SpacecraftPanel.Title = 'Spacecraft Panel';
            app.SpacecraftPanel.BackgroundColor = [1 1 1];
            app.SpacecraftPanel.Position = [780 357 196 431];

            % Create VelocitymsAirspeedIndicator_2Label
            app.VelocitymsAirspeedIndicator_2Label = uilabel(app.SpacecraftPanel);
            app.VelocitymsAirspeedIndicator_2Label.HorizontalAlignment = 'center';
            app.VelocitymsAirspeedIndicator_2Label.Position = [56 18 78 22];
            app.VelocitymsAirspeedIndicator_2Label.Text = 'Velocity (m/s)';

            % Create VelocitymsAirspeedIndicator_2
            app.VelocitymsAirspeedIndicator_2 = uiaeroairspeed(app.SpacecraftPanel);
            app.VelocitymsAirspeedIndicator_2.Limits = [0 45];
            app.VelocitymsAirspeedIndicator_2.ScaleColorLimits = [0 9;5 15;10 25;20 50];
            app.VelocitymsAirspeedIndicator_2.Position = [25 56 139 139];

            % Create Altimeterm_2Label
            app.Altimeterm_2Label = uilabel(app.SpacecraftPanel);
            app.Altimeterm_2Label.HorizontalAlignment = 'center';
            app.Altimeterm_2Label.Position = [59 208 74 22];
            app.Altimeterm_2Label.Text = 'Altimeter (m)';

            % Create Altimeterm_2
            app.Altimeterm_2 = uiaeroaltimeter(app.SpacecraftPanel);
            app.Altimeterm_2.Position = [27 245 137 137];

            % Create RocketPanel
            app.RocketPanel = uipanel(app.LunarMissionSimulationUIFigure);
            app.RocketPanel.Title = 'Rocket Panel';
            app.RocketPanel.BackgroundColor = [1 1 1];
            app.RocketPanel.Position = [521 357 196 431];

            % Create VelocitymsLabel
            app.VelocitymsLabel = uilabel(app.RocketPanel);
            app.VelocitymsLabel.HorizontalAlignment = 'center';
            app.VelocitymsLabel.Position = [56 18 78 22];
            app.VelocitymsLabel.Text = 'Velocity (m/s)';

            % Create VelocitymsAirspeedIndicator
            app.VelocitymsAirspeedIndicator = uiaeroairspeed(app.RocketPanel);
            app.VelocitymsAirspeedIndicator.Limits = [0 45];
            app.VelocitymsAirspeedIndicator.ScaleColorLimits = [0 9;5 15;10 25;20 50];
            app.VelocitymsAirspeedIndicator.Position = [25 56 139 139];

            % Create AltimetermLabel
            app.AltimetermLabel = uilabel(app.RocketPanel);
            app.AltimetermLabel.HorizontalAlignment = 'center';
            app.AltimetermLabel.Position = [59 208 74 22];
            app.AltimetermLabel.Text = 'Altimeter (m)';

            % Create Altimeterm
            app.Altimeterm = uiaeroaltimeter(app.RocketPanel);
            app.Altimeterm.Position = [27 245 137 137];

            % Create TimeElapsedGaugeLabel
            app.TimeElapsedGaugeLabel = uilabel(app.LunarMissionSimulationUIFigure);
            app.TimeElapsedGaugeLabel.HorizontalAlignment = 'center';
            app.TimeElapsedGaugeLabel.Position = [235 336 78 22];
            app.TimeElapsedGaugeLabel.Text = 'Time Elapsed';

            % Create TimeElapsedGauge
            app.TimeElapsedGauge = uigauge(app.LunarMissionSimulationUIFigure, 'linear');
            app.TimeElapsedGauge.Limits = [0 200];
            app.TimeElapsedGauge.Position = [64 359 405 40];

            % Create LoggerPanel
            app.LoggerPanel = uipanel(app.LunarMissionSimulationUIFigure);
            app.LoggerPanel.Title = 'Logger Panel';
            app.LoggerPanel.Position = [1047 357 326 428];

            % Create TextArea
            app.TextArea = uitextarea(app.LoggerPanel);
            app.TextArea.Position = [11 125 303 271];

            % Create SimulationSpeedSliderLabel
            app.SimulationSpeedSliderLabel = uilabel(app.LoggerPanel);
            app.SimulationSpeedSliderLabel.HorizontalAlignment = 'right';
            app.SimulationSpeedSliderLabel.Position = [112 96 100 22];
            app.SimulationSpeedSliderLabel.Text = 'Simulation Speed';

            % Create SimulationSpeedSlider
            app.SimulationSpeedSlider = uislider(app.LoggerPanel);
            app.SimulationSpeedSlider.Limits = [1 12];
            app.SimulationSpeedSlider.ValueChangedFcn = createCallbackFcn(app, @SimulationSpeedSliderValueChanged, true);
            app.SimulationSpeedSlider.Position = [20 91 283 3];
            app.SimulationSpeedSlider.Value = 1;

            % Create StageCompletionIndicatorSwitchLabel
            app.StageCompletionIndicatorSwitchLabel = uilabel(app.LoggerPanel);
            app.StageCompletionIndicatorSwitchLabel.HorizontalAlignment = 'center';
            app.StageCompletionIndicatorSwitchLabel.Position = [146 22 150 22];
            app.StageCompletionIndicatorSwitchLabel.Text = 'Stage Completion Indicator';

            % Create StageCompletionIndicatorSwitch
            app.StageCompletionIndicatorSwitch = uiswitch(app.LoggerPanel, 'slider');
            app.StageCompletionIndicatorSwitch.ValueChangedFcn = createCallbackFcn(app, @StageCompletionIndicatorSwitchValueChanged, true);
            app.StageCompletionIndicatorSwitch.Position = [55 23 45 20];

            % Show the figure after all components are created
            app.LunarMissionSimulationUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = rocket_simulation_v2

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.LunarMissionSimulationUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.LunarMissionSimulationUIFigure)
        end
    end
end
