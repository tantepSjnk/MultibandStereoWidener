classdef BPF < audioPlugin
    properties
        gain = 0;
    end
    properties (Constant)
        PluginInterface = ...
            audioPluginInterface(...
            'InputChannels',2,...
            'OutputChannels',2,...
            audioPluginParameter('gain',...
            'Mapping',{'lin',-20,20}))
    end
 
    properties (Access = private)
        pFilter
        bM;
    end
    methods
        function obj = BPF()
            fs = getSampleRate(obj);
            n = 128;
            obj.pFilter = dsp.FIRFilter(fir1(n,[355]/(fs/2)));
        end
        
        function out = process(obj,in)
            
            y = obj.pFilter(in);
            out = 10^(obj.gain/20) .* y;
        end
        
        function reset(obj)
            fs = getSampleRate(obj);
            reset(obj.pFilter);
        end
    end
end

% function 
% end