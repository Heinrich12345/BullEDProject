clear all;

%s = [0 0.1 0.21];%element distance from reference
s = [0 0.1 0.21];
trueFrequency = [7.5e9,6.5e9];%carrier frequencies


%ADC params
n= 20000; %number of samples
Fs = 4e9; %sampling frequency
Flo=5.8e9; %intermediate frequency. 5.8e9, 11.8e9, 16.3e9 for low, mid, high frequencies.

%Parameters to generate signal and splitting it into each channel
measuredDoA1 = [-30 30];%Measure azimuth and elevation
trueAzim1 = measuredDoA1(1)*(pi/180);%True DOA in Azimuth
trueElev1 = measuredDoA1(2)*(pi/180);%True DOA in Elevation
dc1 = 0.1;%duty cycle for pulse signal
Fif1 = 1.7e9;%IF signal
signal1 = GeneratePulse(Fif1,Fs,n,dc1);

measuredDoA2 = [-30 30];%Measure azimuth and elevation
trueAzim2 = measuredDoA2(1)*(pi/180);%True DOA in Azimuth
trueElev2 = measuredDoA2(2)*(pi/180);%True DOA in Elevation
dc2 = 0.1;%duty cycle for pulse signal
Fif2 = 0.7e9;%IF signal
signal2 = GeneratePulse(Fif2,Fs,n,dc2);

numOfRuns=2;

snr = 0:0.1:20;
RMSEaz1=zeros(1,length(snr));
RMSEel1=zeros(1,length(snr));
RMSEaz2=zeros(1,length(snr));
RMSEel2=zeros(1,length(snr));
for i = 1:length(snr)
    datInd=1;
    errorAz=zeros(1,numOfRuns);
    errorEl=zeros(1,numOfRuns);
    for runNumber = 1:numOfRuns
        
        horChannels1 = GenerateChannels(signal1, s, trueAzim1, trueFrequency(1));%Generates signal 1 in each horizontal channel and adds phase to each
        verChannels1 = GenerateChannels(signal1, s, trueElev1, trueFrequency(1));%Generates signal 1 in each vertical channel and adds phase to each

        
        horChannels2 = GenerateChannels(signal2, s, trueAzim2, trueFrequency(2));%Generates signal 2 in each horizontal channel and adds phase to each
        verChannels2 = GenerateChannels(signal2, s, trueElev2, trueFrequency(2));%Generates signal 2 in each vertical channel and adds phase to each

        
        horChannels = horChannels1 + horChannels2;%Horizontal channels
        verChannels = verChannels1 + verChannels2;%Vertical Channels

        horChannels = awgn(horChannels, snr(i), "measured");%Add noise to horizontal channels
        verChannels = awgn(verChannels, snr(i), "measured");%Add noise to vertical channels
    
        fftHorChannels = HalfFFT(horChannels);%Get the fft of horizntal channels
        fftVerChannels = HalfFFT(verChannels);%Get the fft of vertical channels
    
        indices = FindDominantSignal(fftHorChannels);%Getting indices of dominant frequencies for horizontal array
        indices = findMiddleIndices(indices);

        if(length(indices)==2)
            horPhases = FindDominantSignalPhase(indices,fftHorChannels);%Getting phase of dominant frequencies for horizontal array
            verPhases = FindDominantSignalPhase(indices,fftVerChannels);%Getting phase of dominant frequencies for vertiical array

            for k = 1:width(horPhases)
                horPhaseShift(:,k) = (horPhases(:,k) - horPhases(1,k));%calculating horizontal phase shift from reference
                verPhaseShift(:,k) = (verPhases(:,k) - verPhases(1,k));%calculating vertical phase shift from reference
            end
            fif=(n/2-indices)*2e5;%Converting index to corresponding IF
            frequency = fif+Flo;%Converting baseband frequency to RF frequency.

            [azim2,azim3]=CalculateAoA(horPhaseShift,s,frequency);
            calculatedAz1 = azim3(1)*180/pi;
            calculatedAz2 = azim3(2)*180/pi;

            [elev2,elev3]=CalculateAoA(verPhaseShift,s,frequency);
            calculatedEl1 = elev3(1)*180/pi;
            calculatedEl2 = elev3(2)*180/pi;
    
            errorAz1(datInd) = abs(measuredDoA1(1) - calculatedAz1);
            errorEl1(datInd) = abs(measuredDoA1(2) - calculatedEl1);
            
            errorAz2(datInd) = abs(measuredDoA2(1) - calculatedAz2);
            errorEl2(datInd) = abs(measuredDoA2(2) - calculatedEl2);
    
            datInd=datInd+1;
        end
    end
    RMSEaz1(i) = sqrt(mean((errorAz1).^2));
    RMSEel1(i) = sqrt(mean((errorEl1).^2));
    RMSEaz2(i) = sqrt(mean((errorAz2).^2));
    RMSEel2(i) = sqrt(mean((errorEl2).^2));
end
figure;
subplot(2,1,1); 
plot(snr,RMSEaz1)
title("7GHz Pulse azimuth RMSE vs SNR");
xlabel("SNR(dB)")
ylabel("RMSE (deg)")
subplot(2,1,2); 
plot(snr,RMSEel1)
title("7GHz Frequency Pulse elevation RMSE vs SNR");
xlabel("SNR(dB)")
ylabel("RMSE (deg)")

figure;
subplot(2,1,1); 
plot(snr,RMSEaz2)
title("7GHz Pulse azimuth RMSE vs SNR");
xlabel("SNR(dB)")
ylabel("RMSE (deg)")
subplot(2,1,2); 
plot(snr,RMSEel2)
title("7GHz Frequency Pulse elevation RMSE vs SNR");
xlabel("SNR(dB)")
ylabel("RMSE (deg)")

