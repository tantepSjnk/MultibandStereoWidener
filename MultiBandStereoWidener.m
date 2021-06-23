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
    properties (Constant)
        PluginInterface = ...
            audioPluginInterface(...
            'InputChannels',2,...
            'OutputChannels',2,...
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
        bB;
        bLM;
        bM;
        bUM;
        bH;
        aB;
        aLM;
        aM;
        aUM;
        aH;
        zB;
        zLM;
        zM;
        zUM;
        zH;
    end
    
    methods
        function obj = MultiBandStereoWidener()
            fs = getSampleRate(obj);
            [obj.bB,obj.aB] = butter(2,88/(fs/2),'low');
            [obj.bLM,obj.aLM] = butter(2,[88 335]/(fs/2),'bandpass');
            [obj.bM,obj.aM] = butter(2,[355 1420]/(fs/2),'bandpass');
            [obj.bUM,obj.aUM] = butter(2,[1420 5680]/(fs/2),'bandpass');
            [obj.bH,obj.aH] = butter(2,5680/(fs/2),'high');
            obj.zB = zeros(2);
            obj.zLM = zeros(4,2);
            obj.zM = zeros(4,2);
            obj.zUM = zeros(4,2);
            obj.zH= zeros(2);
        end
        
        function out = process(obj,in)
            [yL,obj.zB] = filter(obj.bB,obj.aB,in,obj.zB);
            [yLM,obj.zLM] = filter(obj.bLM,obj.aLM,in,obj.zLM);
            [yM,obj.zM] = filter(obj.bM,obj.aM,in,obj.zM);
            [yUM,obj.zUM] = filter(obj.bUM,obj.aUM,in,obj.zUM);
            [yH,obj.zH] = filter(obj.bH,obj.aH,in,obj.zH);        
            
            g1 = 10^(obj.gainBass/20);     
            g2 = 10^(obj.gainLowerMid/20);   
            g3 = 10^(obj.gainMid/20);         
            g4 = 10^(obj.gainUpperMid/20);    
            g5 = 10^(obj.gainHigh/20);       
            out = g1.*yL + g2.*yLM + g3.*yM + g4.*yUM + g5.*yH;
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
        
        function reset(obj)
            fs = getSampleRate(obj);
            [obj.bB,obj.aB] = butter(2,88/(fs/2),'low');
            [obj.bLM,obj.aLM] = butter(2,[88 335]/(fs/2),'bandpass');
            [obj.bM,obj.aM] = butter(2,[355 1420]/(fs/2),'bandpass');
            [obj.bUM,obj.aUM] = butter(2,[1420 5680]/(fs/2),'bandpass');
            [obj.bH,obj.aH] = butter(2,5680/(fs/2),'high');
            obj.zB = zeros(2);

            obj.zLM = zeros(4,2);
            obj.zM = zeros(4,2);
            obj.zUM = zeros(4,2);
            obj.zH= zeros(2);
        end
    end
end