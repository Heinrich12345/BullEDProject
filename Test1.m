clear all;

trueFrequency = [16.2e9,16e9];%carrier frequency
s = [0 0.1 0.21];%element distance from reference
snr = 20*rand(1);
n= 20000;
Fs = 4e9; %sampling frequency

Flo=15e9;

%Parameters to generate signal 1 and splitting it into each channel
trueAzim1 = -30*(pi/180);
trueElev1 = 50*(pi/180);
dc1 = 0.1;
Fif1 = 1.8e9;
signal1 = GeneratePulse(Fif1,Fs,n,dc1);
horChannels1 = GenerateChannels(signal1, s, trueAzim1, trueFrequency(1));%Generates signal 1 in each horizontal channel and adds phase to each
verChannels1 = GenerateChannels(signal1, s, trueElev1, trueFrequency(1));%Generates signal 1 in each vertical channel and adds phase to each

%Parameters to generate signal 2 and splitting it into each channel
trueAzim2 = 20*(pi/180);
trueElev2 = 30*(pi/180);
dc2 = 0.1;
Fif2 = 0.5e9;
signal2 = GeneratePulse(Fif2,Fs,n,dc2);
horChannels2 = GenerateChannels(signal2, s, trueAzim2, trueFrequency(2));%Generates signal 2 in each horizontal channel and adds phase to each
verChannels2 = GenerateChannels(signal2, s, trueElev2, trueFrequency(2));%Generates signal 2 in each vertical channel and adds phase to each

signal=signal1+signal2;
fftSignal = HalfFFT(signal);%Get signal fft
plot(abs(fftSignal));

%I = FindMaxSigIndex(fftSignal);%Find fft index with maximum power

horChannels = horChannels1 + horChannels2;%Horizontal channels
verChannels = verChannels1 + verChannels2;%Vertical Channels

horChannels = awgn(horChannels, snr, "measured");%Add noise to horizontal channels
verChannels = awgn(verChannels, snr, "measured");%Add noise to vertical channels

fftHorChannels = HalfFFT(horChannels);%Get the fft of horizntal channels
fftVerChannels = HalfFFT(verChannels);%Get the fft of vertical channels

indices = FindDominantSignal2Sig(fftHorChannels);%Getting indices of dominant frequencies for horizontal array
indices = findMiddleIndices(indices);

horPhases = FindDominantSignalPhase(indices,fftHorChannels);%Getting phase of dominant frequencies for horizontal array
verPhases = FindDominantSignalPhase(indices,fftVerChannels);%Getting phase of dominant frequencies for vertiical array

for k = 1:width(horPhases)
    horPhaseShift(:,k) = (horPhases(:,k) - horPhases(1,k));%calculating horizontal phase shift from reference
    verPhaseShift(:,k) = (verPhases(:,k) - verPhases(1,k));%calculating vertical phase shift from reference
end
fif=(n/2-indices)*2*1e5;
frequency = fif+Flo;

[azim2,azim3]=CalculateAoA(horPhaseShift,s,frequency);
azim2deg = azim2*180/pi;
azim3deg = azim3*180/pi

[elev2,elev3]=CalculateAoA(verPhaseShift,s,frequency);
elev2deg = elev2*180/pi;
elevm3deg = elev3*180/pi