function [phases] = FindDominantSignalPhase(freqIndices,fftChannels)
    %Determines phase of the dominant signals
    
    Voltage = fftChannels(:,freqIndices);%getting the complex value of the dominant signals
    phases = angle(Voltage);%determining the phase of the dominant signals
end

