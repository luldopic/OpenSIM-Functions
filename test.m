import org.opensim.modeling.*
mainpath = cd;
% Change the path according to your own circumstance
modelpath = "C:\Users\luldo\Documents\OpenSim\4.1\Models\Gait2392_Simbody";
filename = "gait2392_simbody.osim";
geopath = "C:\OpenSim 4.0\Geometry";
cd(modelpath)
ModelVisualizer.addDirToGeometrySearchPaths(geopath)
model = Model(filename);
cd(mainpath)
jtest = plotFunctions(model);

