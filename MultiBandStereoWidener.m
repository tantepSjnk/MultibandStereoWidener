classdef MultiBandStereoWidener < audioPlugin
% % % 5 Band FIR-based
% % % Bass      : 22 - 88 Hz
% % % LowerMid  : 88 - 355 Hz
% % % Mid       : 355 - 1420 Hz
% % % UpperMid  : 1420 - 5680 Hz
% % % High      : 5680 - 22720 Hz
    properties
        gainBass        = 0;
        gainLowerMid    = 0;
        gainMid         = 0;
        gainUpperMid    = 0;
        gainHigh        = 0;
    end
    properties
        Order = '6 dB/Oct';
    end
    properties (Constant)
        PluginInterface = ...
            audioPluginInterface(...
            'InputChannels',2,...
            'OutputChannels',2,...
            audioPluginParameter('Order',...
            'Mapping',{'enum', '6 dB/Oct', '12 dB/Oct', '24 dB/Oct'}),...
            audioPluginParameter('gainBass',...
            'Mapping',{'lin',-20,20}),...
            audioPluginParameter('gainLowerMid',...
            'Mapping',{'lin',-20,20}),...
            audioPluginParameter('gainMid',...
            'Mapping',{'lin',-20,20}),...
            audioPluginParameter('gainUpperMid',...
            'Mapping',{'lin',-20,20}),...
            audioPluginParameter('gainHigh',...
            'Mapping',{'lin',-20,20}))
%             audioPluginParameter('Width',...
%             'Mapping',{'pow',2,0,4}),...
%             audioPluginParameter('Pan',...
%             'Mapping',{'lin',-100,100}))
    end
 
    properties (Access = private)   
        xFilt6
        xFilt12
        xFilt24
    end
    
    methods
        function obj = MultiBandStereoWidener()
            fs = getSampleRate(obj);
            obj.xFilt6 = crossoverFilter( ...
                        'NumCrossovers',4, ...
                        'CrossoverFrequencies',[88,355,1420,5680], ...
                        'CrossoverSlopes',6, ...
                        'SampleRate',fs);
            obj.xFilt12 = crossoverFilter( ...
                        'NumCrossovers',4, ...
                        'CrossoverFrequencies',[88,355,1420,5680], ...
                        'CrossoverSlopes',12, ...
                        'SampleRate',fs);
            obj.xFilt24 = crossoverFilter( ...
                        'NumCrossovers',4, ...
                        'CrossoverFrequencies',[88,355,1420,5680], ...
                        'CrossoverSlopes',24, ...
                        'SampleRate',fs);
        end
        
        function out = process(obj,in)
            yB = zeros(size(in));
            yLM = zeros(size(in));
            yM = zeros(size(in));
            yUM = zeros(size(in));
            yH  = zeros(size(in));
            
            switch (obj.Order)
                case '6 dB/Oct'
                    [yB, yLM, yM, yUM, yH] = obj.xFilt6(in);
                case '12 dB/Oct'
                    [yB, yLM, yM, yUM, yH] = obj.xFilt12(in);
                case '24 dB/Oct'
                    [yB, yLM, yM, yUM, yH] = obj.xFilt24(in);
            end
            
            g1 = 10^(obj.gainBass/20);     
            g2 = 10^(obj.gainLowerMid/20);   
            g3 = 10^(obj.gainMid/20);         
            g4 = 10^(obj.gainUpperMid/20);    
            g5 = 10^(obj.gainHigh/20);       
            out = g1.*yB + g2.*yLM + g3.*yM + g4.*yUM + g5.*yH;
%             % % Stereo Width
%             mid = (in(:,1) + in(:,2)) ./ 2;
%             side = (in(:,1) - in(:,2)) ./ 2;
%             side = side * obj.Width;
%             newLeft = mid + side;
%             newRight = mid - side;
%             inNew = [newLeft, newRight];
%             % % Panning
%             panNormalized = (obj.Pan/200) + 0.5;
%             leftGain = 1 - panNormalized; 
%             rightGain = panNormalized;
%             leftChannel = leftGain.*inNew(:,1); 
%             rightChannel = rightGain.*inNew(:,2);
%             out = [leftChannel,rightChannel];
        end
%         function set.Order(obj, val)
%             obj.xFilt.CrossoverSlopes = val*6;%#ok<MCSUP>
%         end
%         function val = get.Order(obj)
%             val = 6*obj.xFilt.CrossoverSlopes;
%         end
        
        function reset(obj)
            fs = getSampleRate(obj);
            obj.xFilt6.SampleRate = fs;
            reset(obj.xFilt6);
            obj.xFilt12.SampleRate = fs;
            reset(obj.xFilt12);
            obj.xFilt24.SampleRate = fs;
            reset(obj.xFilt24);
        end
    end
end

