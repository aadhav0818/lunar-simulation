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
