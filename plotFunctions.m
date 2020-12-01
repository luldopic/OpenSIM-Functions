% Plot Functions
classdef plotFunctions
    properties (Access = public)%Input Properties
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
    end
    properties (Constant) % List of internal values
        %List of valid YQuantity values
        ValidY = {'moment arm','moment','muscle-tendon length','fiber-length','tendon-length','normalized fiber-length','tendon force','active fiber-force','passive fiber-force','total fiber-force'};
        
    end
    properties (Constant) % Error Messages)
        InputError = "Invalid input arguments"; % Error message in case of invalid input argument
    end
    methods
        function obj = plotFunctions() % Importing model for initial set up
%             % Search for OpenSim Library and load if missing
%             L = import;
%             opensimlib = 0;
%             for k = 1:size(L)
%                 if L{k} == "org.opensim.modeling.*"
%                     opensimlib = 1;
%                     break;
%                 end
%             end
%             if opensimlib == 0
%                 import org.opensim.modeling.*
%             end
%             import org.opensim.modeling.*
%             % Syntax of input arguments
%             % arg 1 model should be a "org.opensim.modeling.Model" java Object
%             % arg 2 sto should be a "org.opensim.modeling.Storage" java
%             % Object (optional argument)
%             if nargin == 1
%                 if strcmp(char(model.getClass.getName),'org.opensim.modeling.Model')
%                     obj.model = model;
%                     obj.state = model.initSystem();
%                     n = 1;
%                     for i = 0:model.getCoordinateSet.getSize-1
%                         if model.getCoordinateSet.get(i).isDependent(obj.state) == 0 % Iterate through all non-dependent coord
%                             cSet{1,n} = char(model.getCoordinateSet.get(i).getName);
%                             n = n+1;
%                         end
%                     end
%                     obj.cSet = cSet;
%                     n= 1;
%                     for i = 0:model.getMuscles.getSize-1
%                         mSet{1,n} = char(model.getMuscles.get(i).getName);
%                         n=n+1;
%                     end
%                     obj.mSet = mSet;
%                 else
%                     disp(obj.InputError)
%                 end
%             elseif nargin == 2
%                 if strcmp(char(model.getClass.getName),'org.opensim.modeling.Model') && strcmp(char(varargin{1}.getClass.getName),'org.opensim.modeling.Storage')
%                     obj.model = model;
%                     obj.motion = varargin{1};
%                     obj.state = model.initSystem();
%                     n = 1;
%                     for i = 0:model.getCoordinateSet.getSize-1
%                         if model.getCoordinateSet.get(i).isDependent(obj.state) == 0 % Iterate through all non-dependent coord
%                             cSet{n} = char(model.getCoordinateSet.get(i).getName);
%                             n = n+1;
%                         end
%                     end
%                     obj.cSet = cSet;
%                     for i = 0:model.getMuscles.getSize-1
%                         mSet{n} = char(model.getMuscles.get(i).getName);
%                     end
%                     obj.mSet = mSet;
%                 else
%                     disp(obj.InputError)
%                 end
%             else
%                 disp(obj.InputError)
%             end            
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
        function bool = checkInputArg(varargin)
            % Case 1: args = (model,YQuantity (not moment or moment arm), 
            % muscle array, XQuantity) nargs=4
            % Case 2: args = (model,YQuantity (moment or moment arm), coord, 
            % muscle array, XQuantity) nargs=5 
            % Case 3: args = (model, motion, YQuantity (as coord),
            % XQuantity) nargin = 4
            bool = 0;
            if nargin == 4
                % Case 1 or 3
                % Test for 1 or 3
                if not(isjava(varargin{2})) && iscellstr(varargin{end-1})
                    % Case 1
                    model_arg = varargin{1};
                    motion_arg = varargin{2};
                    YCase = setYCase();
                    XCase = setXCase();
                    YQuantity_arg = varargin{3};
                    XQuantity_arg = varargin{4};
                    if checkModelArg(model_arg) == 1
                        setModel(model_arg)
                    else
                        return
                    end
                    if checkMotionArg(motion_arg) == 1
                        setMotion(motion_arg)
                    else
                        return
                    end
                    if checkYQuantityArg(YQuantity_arg, YCase) == 1
                        setYQuantity(YQuantity_arg)
                    else
                        return
                    end
                    if checkXQuantityArg(XQuantity_arg,XCase) == 1
                        setXQuantity(XQuantity_arg)
                    else
                        return
                    end
                else
                    % Case 3
                    model_arg = varargin{1};
                    YCase = setYCase();
                    XCase = setXCase();
                    YQuantity_arg = varargin{2};
                    muscle_arg = varargin{3};
                    XQuantity_arg = varargin{4};
                    if checkModelArg(model_arg) == 1
                        setModel(model_arg)
                    else
                        return
                    end
                    if checkYQuantityArg(YQuantity_arg, YCase) == 1
                        setYQuantity(YQuantity_arg)
                    else
                        return
                    end
                    if checkMusclesArg(muscle_arg)
                        setMuscle(muscle_arg)
                    else
                        return
                    end
                    if checkXQuantityArg(XQuantity_arg,XCase) == 1
                        setXQuantity(XQuantity_arg)
                    else
                        return
                    end
                end
            elseif nargin == 5
                % Case 2
            else
                return
            end
            function bool = checkModelArg(model)
                % Input validation 
                % model must be a java object with the name
                % "org.opensim.modeling.Model"
                bool = 0;
                if isjava(model)
                    if strcmp(char(model.getClass.getName),'org.opensim.modeling.Model')
                        bool = 1;
                    else
                        return
                    end
                else
                    return
                end
            end
            function bool = checkMotionArg(motion)
                % Input validation 
                % model must be a java object with the name
                % "org.opensim.modeling.storage"
                bool = 0;
                if isjava(motion)
                    if strcmp(char(motion.getClass.getName),'org.opensim.modeling.Storage')
                        bool = 1;
                    else
                        return
                    end
                else
                    return
                end
            end
            function bool = checkYQuantityArg(YQuantity, casenum)
                % Input validation 
                % YQuantity must be a character array.
                % Case 1: Motion is loaded
                % Valid input == ValidY OR Coord OR Time
                % Case 2: Motion is not loaded
                % Valid input == ValidY
                bool = 0;
                if ischar(YQuantity)
                    if casenum == 1
                        locValidY = [obj.ValidY obj.coord {'time'}];
                    elseif casenum == 2
                        locValidY = obj.ValidY;
                    end
                else
                    return
                end
                for i = 1:size(locValidY)
                    if YQuantity == locValidY{i}
                        bool = 1;
                        break
                    end
                end
            end
            function bool = checkCoordArg(coord)
                % Input validation 
                % coord must be a character array.
                % Case 1: Motion is loaded
                % Valid input == Coord
                bool = 0;
                if ischar(coord)
                    loccoord = [obj.coord];
                else
                    return
                end
                for i = 1:size(loccoord)
                    if coord == loccoord{i}
                        bool = 1;
                        break
                    end
                end
            end
            function bool = checkMusclesArg(muscles)
                % Input validation 
                % muscle must be a cell array of character array.
                bool = 0;
                if not(iscellstr(muscle))
                    return
                end
                for i = 1:size(obj.muscles)
                    if not(muscles == obj.muscles{i})
                        return
                    end
                end
                bool =1;
                
            end
            function bool = checkXQuantityArg(XQuantity,casenum)
                % Input validation 
                % XQuantity must be a character array.
                % Case 1: YQuantity is coord
                % Valid input == Coord OR Time
                % Case 2: YQuantity is not coord
                % Valid input == Coord
                bool = 0;
                if ischar(XQuantity)
                    if casenum == 1
                        locValidX = [obj.coord];
                    elseif casenum == 2
                        locValidX = [obj.coord {'time'}];
                    end
                else
                    return
                end
                for i = 1:size(locValidX)
                    if XQuantity == locValidX{i}
                        bool = 1;
                        break
                    end
                end
            end
        end
        function genPlot()
            function [XMin,XMax] = genPlotXRange(coord)
                XMin = coord.get(obj.XQuantity).getRangeMin();
                XMax = coord.get(obj.XQuantity).getRangeMax();
            end
            function genPlotMomentArm()
            end
            function genPlotMoment()
                temp_model = obj.model;
                temp_state = obj.model.initSystem();
                temp_coord = temp_model.getCoordinateSet();
                [coord_min,coord_max] = genPlotXRange(temp_coord.get(obj.XQuantity));
                plotpoints = zeros(size(coord_min:0.001:coord_max),size(obj.muscles)+1);
                n = 1;
                for i = coord_min:0.001:coord_max
                    temp_model.updCoordinateSet().get(obj.XQuantity).setValue(temp_state,i)
                    temp_model.equilibrateMuscles(temp_state)
                    temp_model.realizePosition(temp_state)
                    plotpoints(n,1) = i;
                    for j = 1:size(obj.muscles)
                        plotpoints(n,j+1) = temp_model.getMuscles.get(obj.muscles(j)).getFiberLength(temp_state);
                    end
                    n = n+1;
                end
            end
            function genPlotMuscleTendonLength()
                % Incomplete
            end
            function plotpoints = genPlotFiberLength()
                temp_model = obj.model;
                temp_state = obj.model.initSystem();
                temp_coord = temp_model.getCoordinateSet();
                [coord_min,coord_max] = genPlotXRange(temp_coord.get(obj.XQuantity));
                plotpoints = zeros(size(coord_min:0.001:coord_max),size(obj.muscles)+1);
                n = 1;
                for i = coord_min:0.001:coord_max
                    temp_model.updCoordinateSet().get(obj.XQuantity).setValue(temp_state,i)
                    temp_model.equilibrateMuscles(temp_state)
                    temp_model.realizePosition(temp_state)
                    plotpoints(n,1) = i;
                    for j = 1:size(obj.muscles)
                        plotpoints(n,j+1) = temp_model.getMuscles.get(obj.muscles(j)).getFiberLength(temp_state);
                    end
                    n = n+1;
                end
            end
            function plotpoints = genPlotTendonLength()
                temp_model = obj.model;
                temp_state = obj.model.initSystem();
                temp_coord = temp_model.getCoordinateSet();
                [coord_min,coord_max] = genPlotXRange(temp_coord.get(obj.XQuantity));
                plotpoints = zeros(size(coord_min:0.001:coord_max),size(obj.muscles)+1);
                n = 1;
                for i = coord_min:0.001:coord_max
                    temp_model.updCoordinateSet().get(obj.XQuantity).setValue(temp_state,i)
                    temp_model.equilibrateMuscles(temp_state)
                    temp_model.realizePosition(temp_state)
                    plotpoints(n,1) = i;
                    for j = 1:size(obj.muscles)
                        plotpoints(n,j+1) = temp_model.getMuscles.get(obj.muscles(j)).getTendonLength(temp_state);
                    end
                    n = n+1;
                end
            end
            function plotpoints = genPlotNormalisedFiberLength()
                temp_model = obj.model;
                temp_state = obj.model.initSystem();
                temp_coord = temp_model.getCoordinateSet();
                [coord_min,coord_max] = genPlotXRange(temp_coord.get(obj.XQuantity));
                plotpoints = zeros(size(coord_min:0.001:coord_max),size(obj.muscles)+1);
                n = 1;
                for i = coord_min:0.001:coord_max
                    temp_model.updCoordinateSet().get(obj.XQuantity).setValue(temp_state,i)
                    temp_model.equilibrateMuscles(temp_state)
                    temp_model.realizePosition(temp_state)
                    plotpoints(n,1) = i;
                    for j = 1:size(obj.muscles)
                        plotpoints(n,j+1) = temp_model.getMuscles.get(obj.muscles(j)).getNormalizedFiberLength(temp_state);
                    end
                    n = n+1;
                end
            end
            function plotpoints = genPlotTendonForce()
                temp_model = obj.model;
                temp_state = obj.model.initSystem();
                temp_coord = temp_model.getCoordinateSet();
                [coord_min,coord_max] = genPlotXRange(temp_coord.get(obj.XQuantity));
                plotpoints = zeros(size(coord_min:0.001:coord_max),size(obj.muscles)+1);
                n = 1;
                for i = coord_min:0.001:coord_max
                    temp_model.updCoordinateSet().get(obj.XQuantity).setValue(temp_state,i)
                    temp_model.equilibrateMuscles(temp_state)
                    temp_model.realizePosition(temp_state)
                    plotpoints(n,1) = i;
                    for j = 1:size(obj.muscles)
                        plotpoints(n,j+1) = temp_model.getMuscles.get(obj.muscles(j)).getTendonForce(temp_state);
                    end
                    n = n+1;
                end
            end
            function plotpoints = genPlotActiveFiberForce()
                temp_model = obj.model;
                temp_state = obj.model.initSystem();
                temp_coord = temp_model.getCoordinateSet();
                [coord_min,coord_max] = genPlotXRange(temp_coord.get(obj.XQuantity));
                plotpoints = zeros(size(coord_min:0.001:coord_max),size(obj.muscles)+1);
                n = 1;
                for i = coord_min:0.001:coord_max
                    temp_model.updCoordinateSet().get(obj.XQuantity).setValue(temp_state,i)
                    temp_model.equilibrateMuscles(temp_state)
                    temp_model.realizePosition(temp_state)
                    plotpoints(n,1) = i;
                    for j = 1:size(obj.muscles)
                        plotpoints(n,j+1) = temp_model.getMuscles.get(obj.muscles(j)).getActiveFiberForce(temp_state);
                    end
                    n = n+1;
                end
            end
            function plotpoints = genPlotPassiveFiberForce()
                temp_model = obj.model;
                temp_state = obj.model.initSystem();
                temp_coord = temp_model.getCoordinateSet();
                [coord_min,coord_max] = genPlotXRange(temp_coord.get(obj.XQuantity));
                plotpoints = zeros(size(coord_min:0.001:coord_max),size(obj.muscles)+1);
                n = 1;
                for i = coord_min:0.001:coord_max
                    temp_model.updCoordinateSet().get(obj.XQuantity).setValue(temp_state,i)
                    temp_model.equilibrateMuscles(temp_state)
                    temp_model.realizePosition(temp_state)
                    plotpoints(n,1) = i;
                    for j = 1:size(obj.muscles)
                        plotpoints(n,j+1) = temp_model.getMuscles.get(obj.muscles(j)).getPassiveFiberForce(temp_state);
                    end
                    n = n+1;
                end
            end
            function plotpoints = genPlotTotalFiberForce()
                temp_model = obj.model;
                temp_state = obj.model.initSystem();
                temp_coord = temp_model.getCoordinateSet();
                [coord_min,coord_max] = genPlotXRange(temp_coord.get(obj.XQuantity));
                plotpoints = zeros(size(coord_min:0.001:coord_max),size(obj.muscles)+1);
                n = 1;
                for i = coord_min:0.001:coord_max
                    temp_model.updCoordinateSet().get(obj.XQuantity).setValue(temp_state,i)
                    temp_model.equilibrateMuscles(temp_state)
                    temp_model.realizePosition(temp_state)
                    plotpoints(n,1) = i;
                    for j = 1:size(obj.muscles)
                        plotpoints(n,j+1) = temp_model.getMuscles.get(obj.muscles(j)).getFiberForce(temp_state);
                    end
                    n = n+1;
                end
            end
            function genPlotMotion()
                % Incomplete
            end
               
        end
    end
end
