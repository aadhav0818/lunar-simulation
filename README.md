# lunar-simulation

## About

- Simulates all three stages of a lunar mission (launch, orbit, and lunar descent) in a MATLAB GUI.
- Contains files related to the mathematical calculations (provided in LaTeX format) and computing behind each step.
- Graphically visualizes the launch trajectory and position of a spacecraft throughout the duration of a standard lunar mission.
- Programmed and built in 2021.

> MLX (live script) files are provided with a LaTeX text transcription in this repository.

## Simulation Features

- Multiple Presets that match the initial conditions of various iconic launch vehicles
> [USA] Saturn V, [USA] Falcon 9, [RUS] Soyuz, etc.
- Rocket & Spacecraft design editor for manually changing the initial conditions to any specific value.
- Logging panel that actively records critical parts of the simulation in text.
- Indicator lights to visually indicate the current mission stage
- 3 2D plots that record the orbit data, launch data, and descent data.
- Speed selector which allows the user to speed up or slow down the simulation.
- Speed and Altitude gauges that reflect the trajectory of the spacecraft.
- Live mission statistics panel.

## Programming 
- Each stage of the misson has its own testing file that neatly documents the physics calculations line by line (mlx file).
- This application was programmed in MATLAB R2021b, so errors may be present if any of the code is loaded on a more recent version.

## Variables
- Initial conditions are formulated from the following variables:
```matlab
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
```
