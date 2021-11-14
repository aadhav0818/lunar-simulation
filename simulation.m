classdef rocket_simulation < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup2                       matlab.ui.container.TabGroup
        StageTrackerTab                 matlab.ui.container.Tab
        LOCATIONLabel                   matlab.ui.control.Label
        STATUSLabel                     matlab.ui.control.Label
        NEXTSTAGELabel                  matlab.ui.control.Label
        CURRENTSTAGELabel               matlab.ui.control.Label
        Lamp                            matlab.ui.control.Lamp
        DataTranscriptionTab            matlab.ui.container.Tab
        RELATIVEVELOCITYLabel           matlab.ui.control.Label
        MASSEXPUSLIONRATELabel          matlab.ui.control.Label
        GRAVITATIONLabel                matlab.ui.control.Label
        PAYLOADMASSLabel                matlab.ui.control.Label
        ROCKETMASSLabel                 matlab.ui.control.Label
        TIMEELAPSEDLabel                matlab.ui.control.Label
        HEIGHTLabel                     matlab.ui.control.Label
        VELOCITYLabel                   matlab.ui.control.Label
        SimulationPresetsButtonGroup    matlab.ui.container.ButtonGroup
        NASASaturnVButton_2             matlab.ui.control.ToggleButton
        RosCosmosSoyuzButton            matlab.ui.control.ToggleButton
        SpaceXFalcon9Button             matlab.ui.control.ToggleButton
        CustomButton                    matlab.ui.control.ToggleButton
        StartSimulationButton           matlab.ui.control.Button
        TabGroup                        matlab.ui.container.TabGroup
        PayloadsTab                     matlab.ui.container.Tab
        PayloadMasskgSpinner            matlab.ui.control.Spinner
        PayloadMasskgSpinnerLabel       matlab.ui.control.Label
        RocketMasskgSpinner             matlab.ui.control.Spinner
        RocketMasskgSpinnerLabel        matlab.ui.control.Label
        Label                           matlab.ui.control.Label
        GravitationTab                  matlab.ui.container.Tab
        GravitationmsSpinner            matlab.ui.control.Spinner
        GravitationmsSpinnerLabel       matlab.ui.control.Label
        RatesTab                        matlab.ui.container.Tab
        RelativeVelocitymsSpinner       matlab.ui.control.Spinner
        RelativeVelocitymsSpinnerLabel  matlab.ui.control.Label
        MERatekgsSpinner                matlab.ui.control.Spinner
        MERatekgsSpinnerLabel           matlab.ui.control.Label
        TimeElapsedGauge                matlab.ui.control.LinearGauge
        TimeElapsedGaugeLabel           matlab.ui.control.Label
        VelocityAirspeedIndicator       Aero.ui.control.AirspeedIndicator
        VelocityAirspeedIndicatorLabel  matlab.ui.control.Label
        Altimeter                       Aero.ui.control.Altimeter
        AltimeterLabel                  matlab.ui.control.Label
        UIAxes                          matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        velocity                % m/s
        height                  % m
        time_elapsed            % s
        rocket_mass             % kg
        payload_mass            % kg
        mass_expulsion_rate     % kg/s
        relative_velocity       % m/s
        gravity                 % m/s
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.velocity = 0;
            app.height = 0;
            app.time_elapsed = 0;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 843 566];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Rocket Trajectory')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [335 184 464 340];

            % Create AltimeterLabel
            app.AltimeterLabel = uilabel(app.UIFigure);
            app.AltimeterLabel.HorizontalAlignment = 'center';
            app.AltimeterLabel.Position = [66 28 53 22];
            app.AltimeterLabel.Text = 'Altimeter';

            % Create Altimeter
            app.Altimeter = uiaeroaltimeter(app.UIFigure);
            app.Altimeter.Position = [32 65 120 120];

            % Create VelocityAirspeedIndicatorLabel
            app.VelocityAirspeedIndicatorLabel = uilabel(app.UIFigure);
            app.VelocityAirspeedIndicatorLabel.HorizontalAlignment = 'center';
            app.VelocityAirspeedIndicatorLabel.Position = [234 28 47 22];
            app.VelocityAirspeedIndicatorLabel.Text = 'Velocity';

            % Create VelocityAirspeedIndicator
            app.VelocityAirspeedIndicator = uiaeroairspeed(app.UIFigure);
            app.VelocityAirspeedIndicator.Position = [197 65 120 120];

            % Create TimeElapsedGaugeLabel
            app.TimeElapsedGaugeLabel = uilabel(app.UIFigure);
            app.TimeElapsedGaugeLabel.HorizontalAlignment = 'center';
            app.TimeElapsedGaugeLabel.Position = [433 28 78 22];
            app.TimeElapsedGaugeLabel.Text = 'Time Elapsed';

            % Create TimeElapsedGauge
            app.TimeElapsedGauge = uigauge(app.UIFigure, 'linear');
            app.TimeElapsedGauge.Limits = [0 200];
            app.TimeElapsedGauge.Position = [350 65 245 40];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [33 429 272 107];

            % Create PayloadsTab
            app.PayloadsTab = uitab(app.TabGroup);
            app.PayloadsTab.Title = 'Payloads';

            % Create Label
            app.Label = uilabel(app.PayloadsTab);
            app.Label.Position = [40 50 25 22];
            app.Label.Text = '';

            % Create RocketMasskgSpinnerLabel
            app.RocketMasskgSpinnerLabel = uilabel(app.PayloadsTab);
            app.RocketMasskgSpinnerLabel.HorizontalAlignment = 'right';
            app.RocketMasskgSpinnerLabel.Position = [30 50 99 22];
            app.RocketMasskgSpinnerLabel.Text = 'Rocket Mass (kg)';

            % Create RocketMasskgSpinner
            app.RocketMasskgSpinner = uispinner(app.PayloadsTab);
            app.RocketMasskgSpinner.Position = [144 50 100 22];

            % Create PayloadMasskgSpinnerLabel
            app.PayloadMasskgSpinnerLabel = uilabel(app.PayloadsTab);
            app.PayloadMasskgSpinnerLabel.HorizontalAlignment = 'right';
            app.PayloadMasskgSpinnerLabel.Position = [25 21 105 22];
            app.PayloadMasskgSpinnerLabel.Text = 'Payload Mass (kg)';

            % Create PayloadMasskgSpinner
            app.PayloadMasskgSpinner = uispinner(app.PayloadsTab);
            app.PayloadMasskgSpinner.Position = [145 21 100 22];

            % Create GravitationTab
            app.GravitationTab = uitab(app.TabGroup);
            app.GravitationTab.Title = 'Gravitation';

            % Create GravitationmsSpinnerLabel
            app.GravitationmsSpinnerLabel = uilabel(app.GravitationTab);
            app.GravitationmsSpinnerLabel.HorizontalAlignment = 'right';
            app.GravitationmsSpinnerLabel.Position = [30 31 94 22];
            app.GravitationmsSpinnerLabel.Text = 'Gravitation (m/s)';

            % Create GravitationmsSpinner
            app.GravitationmsSpinner = uispinner(app.GravitationTab);
            app.GravitationmsSpinner.Position = [139 31 100 22];

            % Create RatesTab
            app.RatesTab = uitab(app.TabGroup);
            app.RatesTab.Title = 'Rates';

            % Create MERatekgsSpinnerLabel
            app.MERatekgsSpinnerLabel = uilabel(app.RatesTab);
            app.MERatekgsSpinnerLabel.HorizontalAlignment = 'right';
            app.MERatekgsSpinnerLabel.Position = [43 50 92 22];
            app.MERatekgsSpinnerLabel.Text = 'M.E. Rate (kg/s)';

            % Create MERatekgsSpinner
            app.MERatekgsSpinner = uispinner(app.RatesTab);
            app.MERatekgsSpinner.Position = [150 50 100 22];

            % Create RelativeVelocitymsSpinnerLabel
            app.RelativeVelocitymsSpinnerLabel = uilabel(app.RatesTab);
            app.RelativeVelocitymsSpinnerLabel.HorizontalAlignment = 'right';
            app.RelativeVelocitymsSpinnerLabel.Position = [10 21 124 22];
            app.RelativeVelocitymsSpinnerLabel.Text = 'Relative Velocity (m/s)';

            % Create RelativeVelocitymsSpinner
            app.RelativeVelocitymsSpinner = uispinner(app.RatesTab);
            app.RelativeVelocitymsSpinner.Position = [149 21 100 22];

            % Create StartSimulationButton
            app.StartSimulationButton = uibutton(app.UIFigure, 'push');
            app.StartSimulationButton.BackgroundColor = [0.8 0.8 0.8];
            app.StartSimulationButton.Position = [371 123 203 22];
            app.StartSimulationButton.Text = 'Start Simulation';

            % Create SimulationPresetsButtonGroup
            app.SimulationPresetsButtonGroup = uibuttongroup(app.UIFigure);
            app.SimulationPresetsButtonGroup.Title = 'Simulation Presets';
            app.SimulationPresetsButtonGroup.Position = [639 28 159 127];

            % Create CustomButton
            app.CustomButton = uitogglebutton(app.SimulationPresetsButtonGroup);
            app.CustomButton.Text = 'Custom';
            app.CustomButton.Position = [11 74 135 22];
            app.CustomButton.Value = true;

            % Create SpaceXFalcon9Button
            app.SpaceXFalcon9Button = uitogglebutton(app.SimulationPresetsButtonGroup);
            app.SpaceXFalcon9Button.Text = 'SpaceX - Falcon 9';
            app.SpaceXFalcon9Button.Position = [11 53 135 22];

            % Create RosCosmosSoyuzButton
            app.RosCosmosSoyuzButton = uitogglebutton(app.SimulationPresetsButtonGroup);
            app.RosCosmosSoyuzButton.Text = 'RosCosmos - Soyuz';
            app.RosCosmosSoyuzButton.Position = [11 32 135 22];

            % Create NASASaturnVButton_2
            app.NASASaturnVButton_2 = uitogglebutton(app.SimulationPresetsButtonGroup);
            app.NASASaturnVButton_2.Text = 'NASA - Saturn V';
            app.NASASaturnVButton_2.Position = [12 11 135 22];

            % Create TabGroup2
            app.TabGroup2 = uitabgroup(app.UIFigure);
            app.TabGroup2.Position = [34 206 271 204];

            % Create StageTrackerTab
            app.StageTrackerTab = uitab(app.TabGroup2);
            app.StageTrackerTab.Title = 'Stage Tracker';

            % Create Lamp
            app.Lamp = uilamp(app.StageTrackerTab);
            app.Lamp.Position = [64 109 18 18];
            app.Lamp.Color = [0.902 0.902 0.902];

            % Create CURRENTSTAGELabel
            app.CURRENTSTAGELabel = uilabel(app.StageTrackerTab);
            app.CURRENTSTAGELabel.FontWeight = 'bold';
            app.CURRENTSTAGELabel.Position = [8 149 115 22];
            app.CURRENTSTAGELabel.Text = 'CURRENT STAGE: ';

            % Create NEXTSTAGELabel
            app.NEXTSTAGELabel = uilabel(app.StageTrackerTab);
            app.NEXTSTAGELabel.FontWeight = 'bold';
            app.NEXTSTAGELabel.Position = [8 128 89 22];
            app.NEXTSTAGELabel.Text = 'NEXT STAGE: ';

            % Create STATUSLabel
            app.STATUSLabel = uilabel(app.StageTrackerTab);
            app.STATUSLabel.FontWeight = 'bold';
            app.STATUSLabel.Position = [8 107 59 22];
            app.STATUSLabel.Text = 'STATUS: ';

            % Create LOCATIONLabel
            app.LOCATIONLabel = uilabel(app.StageTrackerTab);
            app.LOCATIONLabel.FontWeight = 'bold';
            app.LOCATIONLabel.Position = [9 86 75 22];
            app.LOCATIONLabel.Text = 'LOCATION: ';

            % Create DataTranscriptionTab
            app.DataTranscriptionTab = uitab(app.TabGroup2);
            app.DataTranscriptionTab.Title = 'Data Transcription';

            % Create VELOCITYLabel
            app.VELOCITYLabel = uilabel(app.DataTranscriptionTab);
            app.VELOCITYLabel.FontWeight = 'bold';
            app.VELOCITYLabel.Position = [8 149 72 22];
            app.VELOCITYLabel.Text = 'VELOCITY: ';

            % Create HEIGHTLabel
            app.HEIGHTLabel = uilabel(app.DataTranscriptionTab);
            app.HEIGHTLabel.FontWeight = 'bold';
            app.HEIGHTLabel.Position = [8 128 53 22];
            app.HEIGHTLabel.Text = 'HEIGHT:';

            % Create TIMEELAPSEDLabel
            app.TIMEELAPSEDLabel = uilabel(app.DataTranscriptionTab);
            app.TIMEELAPSEDLabel.FontWeight = 'bold';
            app.TIMEELAPSEDLabel.Position = [8 107 102 22];
            app.TIMEELAPSEDLabel.Text = 'TIME ELAPSED: ';

            % Create ROCKETMASSLabel
            app.ROCKETMASSLabel = uilabel(app.DataTranscriptionTab);
            app.ROCKETMASSLabel.FontWeight = 'bold';
            app.ROCKETMASSLabel.Position = [9 86 98 22];
            app.ROCKETMASSLabel.Text = 'ROCKET MASS:';

            % Create PAYLOADMASSLabel
            app.PAYLOADMASSLabel = uilabel(app.DataTranscriptionTab);
            app.PAYLOADMASSLabel.FontWeight = 'bold';
            app.PAYLOADMASSLabel.Position = [9 65 108 22];
            app.PAYLOADMASSLabel.Text = 'PAYLOAD MASS: ';

            % Create GRAVITATIONLabel
            app.GRAVITATIONLabel = uilabel(app.DataTranscriptionTab);
            app.GRAVITATIONLabel.FontWeight = 'bold';
            app.GRAVITATIONLabel.Position = [9 44 93 22];
            app.GRAVITATIONLabel.Text = 'GRAVITATION: ';

            % Create MASSEXPUSLIONRATELabel
            app.MASSEXPUSLIONRATELabel = uilabel(app.DataTranscriptionTab);
            app.MASSEXPUSLIONRATELabel.FontWeight = 'bold';
            app.MASSEXPUSLIONRATELabel.Position = [9 23 152 22];
            app.MASSEXPUSLIONRATELabel.Text = 'MASS EXPUSLION RATE:';

            % Create RELATIVEVELOCITYLabel
            app.RELATIVEVELOCITYLabel = uilabel(app.DataTranscriptionTab);
            app.RELATIVEVELOCITYLabel.FontWeight = 'bold';
            app.RELATIVEVELOCITYLabel.Position = [8 2 130 22];
            app.RELATIVEVELOCITYLabel.Text = 'RELATIVE VELOCITY:';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = rocket_simulation

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
