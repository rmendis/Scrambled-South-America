-- South America.lua
-- Author: blkbutterfly74
-- DateCreated: 5/10/2017 6:25:20 PM
-- Creates a Standard map shaped like real-world South America 
-- based off Scrambled Africa & Greenland map scripts
-- Thanks to Firaxis
-----------------------------------------------------------------------------

include "MapEnums"
include "MapUtilities"
include "MountainsCliffs"
include "RiversLakes"
include "FeatureGenerator"
include "TerrainGenerator"
include "NaturalWonderGenerator"
include "ResourceGenerator"
include "AssignStartingPlots"

local g_iW, g_iH;
local g_iFlags = {};
local g_continentsFrac = nil;
local g_iNumTotalLandTiles = 0; 
local g_CenterX = 18;
local g_CenterY = 62;
local america = nil;

-------------------------------------------------------------------------------
function GenerateMap()
	print("Generating South America Map");
	local pPlot;

	-- Set globals
	g_iW, g_iH = Map.GetGridSize();
	g_iFlags = TerrainBuilder.GetFractalFlags();
	local temperature = 0;
	
	plotTypes = GeneratePlotTypes();
	terrainTypes = GenerateTerrainTypesSouthAmerica(plotTypes, g_iW, g_iH, g_iFlags, true);

	for i = 0, (g_iW * g_iH) - 1, 1 do
		pPlot = Map.GetPlotByIndex(i);
		if (plotTypes[i] == g_PLOT_TYPE_HILLS) then
			terrainTypes[i] = terrainTypes[i] + 1;
		end
		TerrainBuilder.SetTerrainType(pPlot, terrainTypes[i]);
	end

	-- Temp
	AreaBuilder.Recalculate();
	local biggest_area = Areas.FindBiggestArea(false);
	print("After Adding Hills: ", biggest_area:GetPlotCount());
	
	-- Place lakes before rivers so that they may act as sources
	local numLargeLakes = math.floor(GameInfo.Maps[Map.GetMapSize()].Continents * 0.3);
	AddLakes(numLargeLakes);

	-- River generation is affected by plot types, originating from highlands and preferring to traverse lowlands.
	AddRivers();

	AddFeatures();
	
	print("Adding cliffs");
	AddCliffs(plotTypes, terrainTypes);
	
	local args = {
		numberToPlace = GameInfo.Maps[Map.GetMapSize()].NumNaturalWonders,
	};

	local nwGen = NaturalWonderGenerator.Create(args);

	AreaBuilder.Recalculate();
	TerrainBuilder.AnalyzeChokepoints();
	TerrainBuilder.StampContinents();
	
	resourcesConfig = MapConfiguration.GetValue("resources");
	local args = {
		resources = resourcesConfig,
		LuxuriesPerRegion = 7,
	}
	local resGen = ResourceGenerator.Create(args);

	print("Creating start plot database.");
	-- START_MIN_Y and START_MAX_Y is the percent of the map ignored for major civs' starting positions.
	local startConfig = MapConfiguration.GetValue("start");-- Get the start config
	local args = {
		MIN_MAJOR_CIV_FERTILITY = 300,
		MIN_MINOR_CIV_FERTILITY = 50, 
		MIN_BARBARIAN_FERTILITY = 1,
		START_MIN_Y = 15,
		START_MAX_Y = 15,
		START_CONFIG = startConfig,
		LAND = true,
	};
	local start_plot_database = AssignStartingPlots.Create(args)

	local GoodyGen = AddGoodies(g_iW, g_iH);
end

-- Input a Hash; Export width, height, and wrapX
function GetMapInitData(MapSize)
	local Width = 54;
	local Height = 78;
	local WrapX = false;
	return {Width = Width, Height = Height, WrapX = WrapX,}
end
-------------------------------------------------------------------------------
function GeneratePlotTypes()
	print("Generating Plot Types");
	local plotTypes = {};

	-- Start with it all as water
	for x = 0, g_iW - 1 do
		for y = 0, g_iH - 1 do
			local i = y * g_iW + x;
			local pPlot = Map.GetPlotByIndex(i);
			plotTypes[i] = g_PLOT_TYPE_OCEAN;
			TerrainBuilder.SetTerrainType(pPlot, g_TERRAIN_TYPE_OCEAN);
		end
	end

	-- Each land strip is defined by: Y, X Start, X End
	local xOffset = 0;
	local yOffset = 1;
	local landStrips = {
		{1, 14, 16},
		{2, 12, 18},
		{3, 10, 17},
		{4, 9, 16},
		{5, 8, 15},
		{5, 24, 26},
		{6, 8, 14},
		{6, 25, 26},
		{7, 8, 15},
		{8, 8, 16},
		{9, 8, 17},
		{10, 9, 18},
		{11, 9, 16},
		{12, 10, 16},
		{13, 11, 18},
		{14, 11, 19},
		{15, 11, 20},
		{16, 11, 19},
		{17, 10, 22},
		{18, 10, 22},
		{19, 10, 24},
		{20, 10, 27},
		{21, 10, 28},
		{22, 11, 28},
		{23, 11, 28},
		{24, 12, 31},
		{25, 12, 32},
		{26, 12, 33},
		{27, 12, 34},
		{28, 12, 34},
		{29, 12, 35},
		{30, 12, 36},
		{31, 13, 37},
		{32, 13, 37},
		{33, 13, 36},
		{34, 13, 37},
		{35, 13, 39},
		{36, 13, 41},
		{37, 14, 44},
		{38, 14, 45},
		{39, 14, 45},
		{40, 14, 46},
		{41, 13, 46},
		{42, 12, 47},
		{43, 11, 47},
		{44, 9, 47},
		{45, 8, 47},
		{46, 7, 47},
		{47, 7, 47},
		{48, 6, 48},
		{49, 6, 49},
		{50, 5, 50},
		{51, 5, 51},
		{52, 4, 51},
		{53, 3, 51},
		{54, 3, 51},
		{55, 2, 51},
		{56, 2, 51},
		{57, 2, 48},
		{58, 3, 47},
		{59, 2, 43},
		{60, 2, 41},
		{61, 2, 37},
		{62, 3, 36},
		{63, 4, 36},
		{64, 5, 35},
		{65, 6, 34},
		{66, 6, 34},
		{67, 6, 32},
		{68, 6, 30},
		{69, 5, 26},
		{70, 1, 2},
		{70, 5, 25},
		{71, 0, 5},
		{71, 7, 24},
		{72, 8, 23},
		{73, 8, 15},
		{73, 20, 21},
		{74, 10, 14}}; 

		
	for i, v in ipairs(landStrips) do
		local y = v[1] + yOffset; 
		local xStart = v[2] + xOffset;
		local xEnd = v[3] + xOffset; 
		for x = xStart, xEnd do
			local i = y * g_iW + x;
			local pPlot = Map.GetPlotByIndex(i);
			plotTypes[i] = g_PLOT_TYPE_LAND;
			TerrainBuilder.SetTerrainType(pPlot, g_TERRAIN_TYPE_GRASS);  -- temporary setting so can calculate areas
			g_iNumTotalLandTiles = g_iNumTotalLandTiles + 1;
		end
	end
		
	AreaBuilder.Recalculate();

	--	world_age
	local world_age_new = 4;
	local world_age_normal = 2;
	local world_age_old = 1;

	local world_age = MapConfiguration.GetValue("world_age");
	if (world_age == 1) then
		world_age = world_age_new;
	elseif (world_age == 2) then
		world_age = world_age_normal;
	elseif (world_age == 3) then
		world_age = world_age_old;
	else
		world_age = 2 + TerrainBuilder.GetRandomNumber(4, "Random World Age - Lua");
	end
	
	local args = {};
	args.world_age = world_age;
	args.iW = g_iW;
	args.iH = g_iH
	args.iFlags = g_iFlags;
	args.blendRidge = 10;
	args.blendFract = 1;
	args.extra_mountains = 4;
	plotTypes = ApplyTectonics(args, plotTypes);

	return plotTypes;
end

function InitFractal(args)

	if(args == nil) then args = {}; end

	local continent_grain = args.continent_grain or 2;
	local rift_grain = args.rift_grain or -1; -- Default no rifts. Set grain to between 1 and 3 to add rifts. - Bob
	local invert_heights = args.invert_heights or false;
	local polar = args.polar or true;
	local ridge_flags = args.ridge_flags or g_iFlags;

	local fracFlags = {};
	
	if(invert_heights) then
		fracFlags.FRAC_INVERT_HEIGHTS = true;
	end
	
	if(polar) then
		fracFlags.FRAC_POLAR = true;
	end
	
	if(rift_grain > 0 and rift_grain < 4) then
		local riftsFrac = Fractal.Create(g_iW, g_iH, rift_grain, {}, 6, 5);
		g_continentsFrac = Fractal.CreateRifts(g_iW, g_iH, continent_grain, fracFlags, riftsFrac, 6, 5);
	else
		g_continentsFrac = Fractal.Create(g_iW, g_iH, continent_grain, fracFlags, 6, 5);	
	end

	-- Use Brian's tectonics method to weave ridgelines in to the continental fractal.
	-- Without fractal variation, the tectonics come out too regular.
	--
	--[[ "The principle of the RidgeBuilder code is a modified Voronoi diagram. I 
	added some minor randomness and the slope might be a little tricky. It was 
	intended as a 'whole world' modifier to the fractal class. You can modify 
	the number of plates, but that is about it." ]]-- Brian Wade - May 23, 2009
	--
	local MapSizeTypes = {};
	for row in GameInfo.Maps() do
		MapSizeTypes[row.MapSizeType] = row.PlateValue;
	end
	local sizekey = Map.GetMapSize();

	local numPlates = MapSizeTypes[sizekey] or 4

	-- Blend a bit of ridge into the fractal.
	-- This will do things like roughen the coastlines and build inland seas. - Brian

	g_continentsFrac:BuildRidges(numPlates, {}, 1, 2);
end

function AddFeatures()
	print("Adding Features");

	-- Get Rainfall setting input by user.
	local rainfall = MapConfiguration.GetValue("rainfall");
	if rainfall == 4 then
		rainfall = 1 + TerrainBuilder.GetRandomNumber(3, "Random Rainfall - Lua");
	end

	local args = {rainfall = rainfall, iJunglePercent = 70, iMarshPercent = 10, iForestPercent = 20, iReefPercent = 10}	-- jungle & marsh max coverage
	local featuregen = FeatureGenerator.Create(args);

	featuregen:AddFeatures();
end

------------------------------------------------------------------------------
function GenerateTerrainTypesSouthAmerica(plotTypes, iW, iH, iFlags, bNoCoastalMountains)
	print("Generating Terrain Types");
	local terrainTypes = {};

	local fracXExp = -1;
	local fracYExp = -1;
	local grain_amount = 3;

	america = Fractal.Create(iW, iH, 
									grain_amount, iFlags, 
									fracXExp, fracYExp);
									
	local iGrassTop = america:GetHeight(100);
																		
	local iPlainsTop = america:GetHeight(100);
	local iPlainsBottom = america:GetHeight(10);
																		
	local iTundraTop = america:GetHeight(85);
																		
	local iSnowTop = america:GetHeight(100);

	for iX = 0, iW - 1 do
		for iY = 0, iH - 1 do
			local index = (iY * iW) + iX;
			if (plotTypes[index] == g_PLOT_TYPE_OCEAN) then
				if (IsAdjacentToLand(plotTypes, iX, iY)) then
					terrainTypes[index] = g_TERRAIN_TYPE_COAST;
				else
					terrainTypes[index] = g_TERRAIN_TYPE_OCEAN;
				end
			end
		end
	end

	if (bNoCoastalMountains == true) then
		plotTypes = RemoveCoastalMountains(plotTypes, terrainTypes);
	end

	for iX = 0, iW - 1 do
		for iY = 0, iH - 1 do
			local index = (iY * iW) + iX;

			local iDistanceFromCenter = Map.GetPlotDistance (iX, iY, g_CenterX, g_CenterY);
			local lat = GetLatitudeAtPlot(america, iX, iY);

			local americaVal = america:GetHeight(iX, iY);

			-- patagonia
			if (lat > 0.72 and iY < g_CenterY) then
				local iTundraBottom = america:GetHeight((1 - iDistanceFromCenter/(iH/2)) * 100);
				local iSnowBottom = america:GetHeight((1 - iDistanceFromCenter/(iH/2)) * 100);

				if (plotTypes[index] == g_PLOT_TYPE_MOUNTAIN) then
					terrainTypes[index] = g_TERRAIN_TYPE_DESERT_MOUNTAIN;

					if ((americaVal >= iTundraBottom) and (americaVal <= iTundraTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_TUNDRA_MOUNTAIN;
					elseif ((americaVal >= iPlainsBottom) and (americaVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS_MOUNTAIN;
					elseif ((americaVal >= iSnowBottom) and (americaVal <= iSnowTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;
					end

				elseif (plotTypes[index] ~= g_PLOT_TYPE_OCEAN) then
					terrainTypes[index] = g_TERRAIN_TYPE_DESERT;
				
					if ((americaVal >= iTundraBottom) and (americaVal <= iTundraTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_TUNDRA;
					elseif ((americaVal >= iPlainsBottom) and (americaVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS;
					elseif ((americaVal >= iSnowBottom) and (americaVal <= iSnowTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_SNOW;
					end
				end

			-- Amazon
			else 		
				local iGrassBottom = america:GetHeight(40);
				iPlainsTop = iGrassBottom;

				if (plotTypes[index] == g_PLOT_TYPE_MOUNTAIN) then
					terrainTypes[index] = g_TERRAIN_TYPE_DESERT_MOUNTAIN;

					if ((americaVal >= iGrassBottom) and (americaVal <= iGrassTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_GRASS_MOUNTAIN;
					elseif ((americaVal >= iPlainsBottom) and (americaVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS_MOUNTAIN;
					end

				elseif (plotTypes[index] ~= g_PLOT_TYPE_OCEAN) then
					terrainTypes[index] = g_TERRAIN_TYPE_DESERT;
		
					if ((americaVal >= iGrassBottom) and (americaVal <= iGrassTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_GRASS;
					elseif ((americaVal >= iPlainsBottom) and (americaVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS;
					end
				end
			end
		end
	end

	local bExpandCoasts = true;

	if bExpandCoasts == false then
		return
	end

	print("Expanding coasts");
	for iI = 0, 2 do
		local shallowWaterPlots = {};
		for iX = 0, iW - 1 do
			for iY = 0, iH - 1 do
				local index = (iY * iW) + iX;
				if (terrainTypes[index] == g_TERRAIN_TYPE_OCEAN) then
					-- Chance for each eligible plot to become an expansion is 1 / iExpansionDiceroll.
					-- Default is two passes at 1/4 chance per eligible plot on each pass.
					if (IsAdjacentToShallowWater(terrainTypes, iX, iY) and TerrainBuilder.GetRandomNumber(4, "add shallows") == 0) then
						table.insert(shallowWaterPlots, index);
					end
				end
			end
		end
		for i, index in ipairs(shallowWaterPlots) do
			terrainTypes[index] = g_TERRAIN_TYPE_COAST;
		end
	end
	
	return terrainTypes; 
end

------------------------------------------------------------------------------
function FeatureGenerator:AddIceAtPlot(plot, iX, iY)
	local lat = GetLatitudeAtPlot(america, iX, iY);
	
	if (lat > 0.9 and iY < g_CenterY) then
		local iScore = TerrainBuilder.GetRandomNumber(100, "Resource Placement Score Adjust");

		iScore = iScore + math.abs(lat) * 100;

		if(IsAdjacentToLandPlot(iX,iY) == true) then
			iScore = iScore / 2.0;
		end

		local iAdjacent = TerrainBuilder.GetAdjacentFeatureCount(plot, g_FEATURE_ICE);
		iScore = iScore + 10.0 * iAdjacent;

		if(iScore > 130) then
			TerrainBuilder.SetFeatureType(plot, g_FEATURE_ICE);
			return true;
		end
	end
	return false;
end

------------------------------------------------------------------------------
function FeatureGenerator:AddReefAtPlot(plot, iX, iY)
	--Reef Check. First see if it can place the feature.
	local lat = (iY - self.iGridH/2)/(self.iGridH/2);
	if(TerrainBuilder.CanHaveFeature(plot, g_FEATURE_REEF) and lat >= -0.81 * 0.9) then
		self.iNumReefablePlots = self.iNumReefablePlots + 1;
		if(math.ceil(self.iReefCount * 100 / self.iNumReefablePlots) <= self.iReefMaxPercent) then
				local iEquator = self.iGridH;

				--Weight based on adjacent plots
				local iScore  = 3 * (iEquator - iY);
				local iAdjacent = TerrainBuilder.GetAdjacentFeatureCount(plot, g_FEATURE_REEF);

				if(iAdjacent == 0 ) then
					iScore = iScore + 100;
				elseif(iAdjacent == 1) then
					iScore = iScore + 125;
				elseif (iAdjacent == 2) then
					iScore = iScore  + 150;
				elseif (iAdjacent == 3 or iAdjacent == 4) then
					iScore = iScore + 175;
				else
					iScore = iScore + 10000;
				end

				if(TerrainBuilder.GetRandomNumber(200, "Resource Placement Score Adjust") >= iScore) then
					TerrainBuilder.SetFeatureType(plot, g_FEATURE_REEF);
					self.iReefCount = self.iReefCount + 1;
				end
		end
	end
end

-- override: southern forest bias
function FeatureGenerator:AddForestsAtPlot(plot, iX, iY)
	--Forest Check. First see if it can place the feature.
	
	if(TerrainBuilder.CanHaveFeature(plot, g_FEATURE_FOREST)) then
		if(math.ceil(self.iForestCount * 100 / self.iNumLandPlots) <= self.iForestMaxPercent) then
			--Weight based on adjacent plots if it has more than 3 start subtracting
			local iScore = 3 * (1 - iY/g_iH) * 100;
			local iAdjacent = TerrainBuilder.GetAdjacentFeatureCount(plot, g_FEATURE_FOREST);

			if(iAdjacent == 0 ) then
				iScore = iScore;
			elseif(iAdjacent == 1) then
				iScore = iScore + 50;
			elseif (iAdjacent == 2 or iAdjacent == 3) then
				iScore = iScore + 150;
			elseif (iAdjacent == 4) then
				iScore = iScore - 50;
			else
				iScore = iScore - 200;
			end
				
			if(TerrainBuilder.GetRandomNumber(300, "Resource Placement Score Adjust") <= iScore) then
				TerrainBuilder.SetFeatureType(plot, g_FEATURE_FOREST);
				self.iForestCount = self.iForestCount + 1;
			end
		end
	end
end

-- override: more northern jungle
function FeatureGenerator:AddJunglesAtPlot(plot, iX, iY)
	--Jungle Check. First see if it can place the feature.
	if(TerrainBuilder.CanHaveFeature(plot, g_FEATURE_JUNGLE)) then
		if(math.ceil(self.iJungleCount * 100 / self.iNumLandPlots) <= self.iJungleMaxPercent) then

			--Weight based on adjacent plots if it has more than 3 start subtracting
			local iScore = 400 * iY;
			local iAdjacent = TerrainBuilder.GetAdjacentFeatureCount(plot, g_FEATURE_JUNGLE);

			if(iAdjacent == 0 ) then
				iScore = iScore;
			elseif(iAdjacent == 1) then
				iScore = iScore + 50;
			elseif (iAdjacent == 2 or iAdjacent == 3) then
				iScore = iScore + 150;
			elseif (iAdjacent == 4) then
				iScore = iScore - 50;
			else
				iScore = iScore - 200;
			end

			if(TerrainBuilder.GetRandomNumber(100, "Resource Placement Score Adjust") <= iScore) then
				TerrainBuilder.SetFeatureType(plot, g_FEATURE_JUNGLE);
				local terrainType = plot:GetTerrainType();

				if(terrainType == g_TERRAIN_TYPE_PLAINS_HILLS or terrainType == g_TERRAIN_TYPE_GRASS_HILLS) then
					TerrainBuilder.SetTerrainType(plot, g_TERRAIN_TYPE_PLAINS_HILLS);
				else
					TerrainBuilder.SetTerrainType(plot, g_TERRAIN_TYPE_PLAINS);
				end

				self.iJungleCount = self.iJungleCount + 1;
				return true;
			end

		end
	end

	return false
end