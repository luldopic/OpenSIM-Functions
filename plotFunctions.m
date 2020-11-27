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
        ErrMess = "Invalid input arguments"; % Error message in case of invalid input argument
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
                    disp(obj.ErrMess)
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
                    disp(obj.ErrMess)
                end
            else
                disp(obj.ErrMess)
            end            
        end
        function obj = setYQuantity(YQuantity,varargin)
            % arg 1 YQuantity should be char array e.g. 'fiber-length'
            % YQuantity should be equal to one member of ValidY
            % if motion object exists, YQuantity can be a motion object
            % name
            % arg 2 is for the muscle which you want to plot for
            % if motion name is chosen for YQuantity, this argument should
            % be empty
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