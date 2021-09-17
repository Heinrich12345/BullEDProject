clear all;

%s = [0 0.1 0.21];%element distance from reference
s = [0 0.1 0.21];
trueFrequency = 6e9;%carrier frequency


%ADC params
n= 20000; %number of samples
Fs = 4e9; %sampling frequency
Flo=5.8e9; %intermediate frequency. 5.8e9, 11.8e9, 16.3e9 for low, mid, high frequencies.

%Parameters to generate signal and splitting it into each channel
measuredDoA = [-30 30];%Measure azimuth and elevation
trueAzim = measuredDoA(1)*(pi/180);%True DOA in Azimuth
trueElev = measuredDoA(2)*(pi/180);%True DOA in Elevation
dc = 0.1;%duty cycle for pulse signal
Fif = 0.2e9;%IF signal
signal = GeneratePulse(Fif,Fs,n,dc);
%signal = GenerateContinuous(Fif,Fs,n,dc);
%signal = GenerateChirp(Fif,Fs,n,dc);
fftSignal = HalfFFT(signal);%Get signal fft
plot(abs(fftSignal));
%Monte-Carlo sim parameters
numOfRuns=100;

test=CalculatePhaseOffsets(trueFrequency,trueAzim,s);

snr = 0:0.1:20;
RMSEaz=zeros(1,length(snr));
RMSEel=zeros(1,length(snr));
for i = 1:length(snr)
    datInd=1;
    errorAz=zeros(1,numOfRuns);
    errorEl=zeros(1,numOfRuns);
    for runNumber = 1:numOfRuns
        
        horChannels = GenerateChannels(signal, s, trueAzim, trueFrequency);%Generates signal in each horizontal channel and adds phase to each
        verChannels = GenerateChannels(signal, s, trueElev, trueFrequency);%Generates signal in each vertical channel and adds phase to each
    
        horChannels = awgn(horChannels, snr(i), "measured");%Add noise to horizontal channels
        verChannels = awgn(verChannels, snr(i), "measured");%Add noise to vertical channels
    
        fftHorChannels = HalfFFT(horChannels);%Get the fft of horizntal channels
        fftVerChannels = HalfFFT(verChannels);%Get the fft of vertical channels
    
        indices = FindDominantSignal(fftHorChannels);%Getting indices of dominant frequencies for horizontal array
        indices = findMiddleIndices(indices);

        if(length(indices)==1)
            horPhases = FindDominantSignalPhase(indices,fftHorChannels);%Getting phase of dominant frequencies for horizontal array
            verPhases = FindDominantSignalPhase(indices,fftVerChannels);%Getting phase of dominant frequencies for vertiical array

            for k = 1:width(horPhases)
                horPhaseShift(:,k) = (horPhases(:,k) - horPhases(1,k));%calculating horizontal phase shift from reference
                verPhaseShift(:,k) = (verPhases(:,k) - verPhases(1,k));%calculating vertical phase shift from reference
            end
            fif=(n/2-indices)*2e5;%Converting index to corresponding IF
            frequency = fif+Flo;%Converting baseband frequency to RF frequency.

            [azim2,azim3]=CalculateAoA(horPhaseShift,s,frequency);
            calculatedAz = azim3*180/pi;

            [elev2,elev3]=CalculateAoA(verPhaseShift,s,frequency);
            calculatedEl = elev3*180/pi;
    
            errorAz(datInd) = abs(measuredDoA(1) - calculatedAz);
            errorEl(datInd) = abs(measuredDoA(2) - calculatedEl);
    
            datInd=datInd+1;
        end
    end
    RMSEaz(i) = sqrt(mean((errorAz).^2));
    RMSEel(i) = sqrt(mean((errorEl).^2));
end

subplot(2,1,1); 
plot(snr,RMSEaz)
title("Low Frequency Pulse azimuth RMSE vs SNR");
xlabel("SNR(dB)")
ylabel("RMSE (deg)")
subplot(2,1,2); 
plot(snr,RMSEel)
title("Low Frequency Pulse elevation RMSE vs SNR");
xlabel("SNR(dB)")
ylabel("RMSE (deg)")
