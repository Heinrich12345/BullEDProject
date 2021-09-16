function [freqIndices] = FindDominantSignal2Sig(fftChannels)
    %Finding indices of dominant frequencies in the signal

    channelOne = fftChannels(1,:);%dominant frequencies should be present in all channels, 
                                  %therefore the reference channel is used.

    averagePower = abs(mean(channelOne));%determining average power in the channel
    freqIndices = find(abs(channelOne)>300*averagePower);%Finding indicies with power much greater than average

end

