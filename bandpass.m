classdef bandpass < audioPlugin
    properties
        gain = 0;
    end
    properties (Constant)
        PluginInterface = ...
            audioPluginInterface(...
            audioPluginParameter('gain',...
            'Mapping',{'lin',-20,20}))
    end
    properties
        % internal state
        z = zeros(2);
        b = zeros(1,5);
        a = zeros(1,5);
    end
    methods
        function out = process(p,in)
            [out,p.z] = filter(p.b,p.a,in,p.z);
            out = out .* 10^(p.gain/20);
        end
        function reset(p)
            % initialize internal state
            p.z = zeros(4,2);
            Fs = getSampleRate(p);
            [p.b, p.a] = bandpassCoeffs(Fs);
        end

    end
end

function [b,a] = bandpassCoeffs(Fs)
    [b,a] = butter(2,[88 355]/(Fs/2),'bandpass');
end



