% Plot Functions
classdef plotFunctions
    properties %Input Properties
        model
        XQuantity
        YQuantity
        motion
        coord
        muscles 
    end
    properties %Properties from Input objects
        cSet % List of non-dependent coordinates
        mSet % List of muscles
        state
    end
    properties (Constant) % List of internal values
        %List of valid YQuantity values
        ValidY = {'moment arm','moment','muscle-tendon length','fiber-length','tendon-length','normalized fiber-length','tendon force','active fiber-force','passive fiber-force','total fiber-force'};
        InputError = "Invalid input arguments"; % Error message in case of invalid input argument
    end
    methods
        function obj = plotFunctions(model,varargin) % Importing model for initial set up
            % Search for OpenSim Library and load if missing
            L = import;
            opensimlib = 0;
            for k = 1:size(L)
                if L{k} == "org.opensim.modeling.*"
                    opensimlib = 1;
                    break;
                end
            end
            if opensimlib == 0
                import org.opensim.modeling.*
            end
            % Syntax of input arguments
            % arg 1 model should be a "org.opensim.modeling.Model" java Object
            % arg 2 sto should be a "org.opensim.modeling.Storage" java
            % Object (optional argument)
            if nargin == 1
                if strcmp(char(model.getClass.getName),'org.opensim.modeling.Model')
                    obj.model = model;
                    obj.state = model.initSystem();
                    n = 1;
                    for i = 0:model.getCoordinateSet.getSize-1
                        if model.getCoordinateSet.get(i).isDependent(obj.state) == 0 % Iterate through all non-dependent coord
                            cSet{n,1} = char(model.getCoordinateSet.get(i).getName);
                            n = n+1;
                        end
                    end
                    obj.cSet = cSet;
                    n= 1;
                    for i = 0:model.getMuscles.getSize-1
                        mSet{n,1} = char(model.getMuscles.get(i).getName);
                        n=n+1;
                    end
                    obj.mSet = mSet;
                else
                    disp(obj.InputError)
                end
            elseif nargin == 2
                if strcmp(char(model.getClass.getName),'org.opensim.modeling.Model') && strcmp(char(varargin{1}.getClass.getName),'org.opensim.modeling.Storage')
                    obj.model = model;
                    obj.motion = varargin{1};
                    obj.state = model.initSystem();
                    n = 1;
                    for i = 0:model.getCoordinateSet.getSize-1
                        if model.getCoordinateSet.get(i).isDependent(obj.state) == 0 % Iterate through all non-dependent coord
                            cSet{n} = char(model.getCoordinateSet.get(i).getName);
                            n = n+1;
                        end
                    end
                    obj.cSet = cSet;
                    for i = 0:model.getMuscles.getSize-1
                        mSet{n} = char(model.getMuscles.get(i).getName);
                    end
                    obj.mSet = mSet;
                else
                    disp(obj.InputError)
                end
            else
                disp(obj.InputError)
            end            
        end
        function obj = setYQuantity(YQuantity,varargin)
            % arg 1 YQuantity should be char array e.g. 'fiber-length'
            % YQuantity should be equal to one member of ValidY
            % if motion object exists, YQuantity can be a motion object
            % name
            % arg 2 should be char array
            % arg 2 should be a coord  if YQuantity is moment arm OR moment
            % arg 2 (3 if condition above is satified) should be a cell array
            % This arg is for the muscle which you want to plot for
            % if motion name is chosen for YQuantity, this argument should
            % be empty
            
            % Three Cases
            
            % Case 1:
            % Condition 1: Motion object exists AND 
            % Condition 2: YQuantity is a valid coord input
            if nargin == 1
                bool1 = 1; % Boolean for condition 1
                % Check Motion object exists
                if isempty(obj.motion)
                    bool1 = 0;
                    disp(obj.InputError)
                end
                
                bool2 = 0; %Boolean for condition 2
                for i = 1:size(obj.cSet)
                    if YQuantity == obj.cSet{i}
                        bool2 = 1;
                        break
                    end
                end
                
                %Check if any condition is breached else assign YQuantity
                if bool1 == 0 || bool2 == 0
                    disp(obj.InputError)
                else
                    obj.YQuantity = YQuantity;
                end
            
            % Case 2
            % Condition 1: YQuantity is a Valid Y
            % Condition 2: YQuantity is NOT (moment arm OR moment)
            % Condition 3: All elements in varargin{1} are valid muscles
            elseif nargin == 2
                bool1 = 0; % Boolean for condition 1 False by Default
                for i = 1:size(obj.ValidY) 
                    if YQuantity == obj.ValidY{i}
                        bool1 = 1;
                        break
                    end
                end
                
                bool2 = 1; % Boolean for condition 2 True by Default
                if strcmp(YQuantity,obj.ValidY{1}) || strcmp(YQuantity,obj.ValidY{2})
                    bool2 = 0;
                end
                
                bool3 = 1; % Boolean for condition 3 True by Default              
                if size(varargin{1}) == 0
                    bool3 = 0;
                else                 
                    for i = 1:size(varargin{1}) % Check each muscles individually
                        if ~any(strcmp(obj.mSet,varargin{1}{i}))
                            bool3 = 0;
                        end                            
                    end
                end
                
                % Check a booleans else assign YQuantity and muscles
                if bool1 == 0 || bool2 == 0 || bool3 == 0
                    disp(obj.InputError)
                else
                    obj.YQuantity = YQuantity;
                    obj.muscles = varargin{1};
                end
                
            % Case 3
            % Condition 1: YQuantity is a Valid Y
            % Condition 2: YQuantity is (moment arm OR moment)
            % Condition 3: All elements in varargin{1} are valid muscles
            elseif nargin == 3                
                bool1 = 0; % Boolean for condition 1 False by Default
                for i = 1:size(obj.ValidY) 
                    if YQuantity == obj.ValidY{i}
                        bool1 = 1;
                        break
                    end
                end
                
                bool2 = 0; % Boolean for condition 2 False by Default
                if strcmp(YQuantity,obj.ValidY{1}) || strcmp(YQuantity,obj.ValidY{2})
                    bool2 = 1;
                end
                
                bool3 = 1; % Boolean for condition 3 True by Default              
                if size(varargin{1}) == 0
                    bool3 = 0;
                else                 
                    for i = 1:size(varargin{1}) % Check each muscles individually
                        if ~any(strcmp(obj.mSet,varargin{1}{i}))
                            bool3 = 0;
                        end                            
                    end
                end
                
                % Check a booleans else assign YQuantity and muscles
                if bool1 == 0 || bool2 == 0 || bool3 == 0
                    disp(obj.InputError)
                else
                    obj.YQuantity = YQuantity;
                    obj.muscles = varargin{1};
                end
            end
           
        end
        function obj = setXQuantity(XQuantity)
            % arg 2 XQuantity should be a char array e.g. 'knee_angle_r'
            % The char array should be a coordinate in the coordinateSet
            % OR (name of motion object (mot.getName) OR 'time') if STO object is added. 
            % if YQuantity is a motion quantity i.e. pelvis rotation, 
            % XQuantity cannot be name of motion object
        end
    end
end