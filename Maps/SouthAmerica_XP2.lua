-- SouthAmerica_XP2.lua
-- Author: blkbutterfly74
-- DateCreated: 12/26/2020 9:29:43 AM
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
include "CoastalLowlands"
include "AssignStartingPlots"

local g_iW, g_iH;
local g_iFlags = {};
local g_continentsFrac = nil;
local g_iNumTotalLandTiles = 0; 
local g_CenterX = 18;
local g_CenterY = 62;
local featuregen = nil;

-------------------------------------------------------------------------------
function GenerateMap()
	print("Generating South America Map");
	local pPlot;

	-- Set globals
	g_iW, g_iH = Map.GetGridSize();
	g_iFlags = TerrainBuilder.GetFractalFlags();
	local temperature = 0;

	--	local world_age
	local world_age_new = 5;
	local world_age_normal = 3;
	local world_age_old = 2;

	local world_age = MapConfiguration.GetValue("world_age");
	if (world_age == 1) then
		world_age = world_age_new;
	elseif (world_age == 3) then
		world_age = world_age_old;
	else
		world_age = world_age_normal;	-- default
	end
	
	plotTypes = GeneratePlotTypes(world_age);
	terrainTypes = GenerateTerrainTypesSouthAmerica(plotTypes, g_iW, g_iH, g_iFlags, true);
	ApplyBaseTerrain(plotTypes, terrainTypes, g_iW, g_iH);

	AreaBuilder.Recalculate();
	--[[ blackbutterfly74 - Why this additional AnalyzeChockepoint()? Commenting out for now:
	TerrainBuilder.AnalyzeChokepoints(); --]]
	TerrainBuilder.StampContinents();

	local iContinentBoundaryPlots = GetContinentBoundaryPlotCount(g_iW, g_iH);
	local biggest_area = Areas.FindBiggestArea(false);
	print("After Adding Hills: ", biggest_area:GetPlotCount());
	AddTerrainFromContinents(plotTypes, terrainTypes, world_age, g_iW, g_iH, iContinentBoundaryPlots);

	AreaBuilder.Recalculate();
	
	-- Place lakes before rivers so that they may act as sources
	local numLargeLakes = math.floor(GameInfo.Maps[Map.GetMapSize()].Continents * 0.3);
	AddLakes(numLargeLakes);

	-- River generation is affected by plot types, originating from highlands and preferring to traverse lowlands.
	AddRivers();

	AddFeatures();

	TerrainBuilder.AnalyzeChokepoints();
	
	print("Adding cliffs");
	AddCliffs(plotTypes, terrainTypes);
	
	local args = {
		numberToPlace = GameInfo.Maps[Map.GetMapSize()].NumNaturalWonders,
	};

	local nwGen = NaturalWonderGenerator.Create(args);

	AddFeaturesFromContinents();
	MarkCoastalLowlands();
	
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
function GeneratePlotTypes(world_age)
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

	local args = {rainfall = rainfall, iJunglePercent = 65, iMarshPercent = 15, iForestPercent = 7, iReefPercent = 10}	-- jungle & marsh max coverage
	featuregen = FeatureGenerator.Create(args);

	featuregen:AddFeatures(true, true);  --second parameter is whether or not rivers start inland);

	-- add extra rainforest more densely at center
	for iX = 0, g_iW - 1 do
		for iY = 0, g_iH - 1 do
			local index = (iY * g_iW) + iX;
			local plot = Map.GetPlot(iX, iY);
			local iDistanceFromCenter = Map.GetPlotDistance (iX, iY, g_CenterX, g_CenterY);

			-- inverse of Australia floolplain logic
			if (TerrainBuilder.GetRandomNumber(25, "Resource Placement Score Adjust") >= iDistanceFromCenter) then
				featuregen:AddJunglesAtPlot(plot, iX, iY);
			end
		end
	end
end
------------------------------------------------------------------------------
function GenerateTerrainTypesSouthAmerica(plotTypes, iW, iH, iFlags, bNoCoastalMountains)
	print("Generating Terrain Types");
	local terrainTypes = {};

	local fracXExp = -1;
	local fracYExp = -1;
	local grain_amount = 3;

	grass = Fractal.Create(iW, iH, 
									grain_amount, iFlags, 
									fracXExp, fracYExp);
									
	iGrassTop = grass:GetHeight(100);

	plains = Fractal.Create(iW, iH, 
									grain_amount, iFlags, 
									fracXExp, fracYExp);
																		
	iPlainsTop = grass:GetHeight(100);
	iPlainsBottom = grass:GetHeight(10);

	tundra = Fractal.Create(iW, iH, 
									grain_amount, iFlags, 
									fracXExp, fracYExp);
																		
	iTundraTop = tundra:GetHeight(85);

	snow = Fractal.Create(iW, iH, 
									grain_amount, iFlags, 
									fracXExp, fracYExp);
																		
	iSnowTop = tundra:GetHeight(100);

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
			local iV = TerrainBuilder.GetRandomNumber(8, "Random variance");
			local lat = -((iH/2) - iY + iV)/(iH/2);		-- inverted + a rnd to make the division natural

			local grassVal = grass:GetHeight(iX, iY);
			local plainsVal = plains:GetHeight(iX, iY);
			local tundraVal = tundra:GetHeight(iX, iY);
			local snowVal = tundra:GetHeight(iX, iY);

			-- Amazon 
			if (lat > -0.72) then
				local iGrassBottom = grass:GetHeight(iDistanceFromCenter/(iH/2) * 100);

				if (plotTypes[index] == g_PLOT_TYPE_MOUNTAIN) then
					terrainTypes[index] = g_TERRAIN_TYPE_DESERT_MOUNTAIN;

					if ((grassVal >= iGrassBottom) and (grassVal <= iGrassTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_GRASS_MOUNTAIN;
					elseif ((plainsVal >= iPlainsBottom) and (plainsVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS_MOUNTAIN;
					end

				elseif (plotTypes[index] ~= g_PLOT_TYPE_OCEAN) then
					terrainTypes[index] = g_TERRAIN_TYPE_DESERT;
		
					if ((grassVal >= iGrassBottom) and (grassVal <= iGrassTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_GRASS;
					elseif ((plainsVal >= iPlainsBottom) and (plainsVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS;
					end
				end

			-- patagonia
			else 
				local iTundraBottom = tundra:GetHeight((1 - iDistanceFromCenter/(iH/2)) * 100);
				local iSnowBottom = snow:GetHeight((1 - iDistanceFromCenter/(iH/2)) * 100);

				if (plotTypes[index] == g_PLOT_TYPE_MOUNTAIN) then
					terrainTypes[index] = g_TERRAIN_TYPE_DESERT_MOUNTAIN;

					if ((tundraVal >= iTundraBottom) and (tundraVal <= iTundraTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_TUNDRA_MOUNTAIN;
					elseif ((plainsVal >= iPlainsBottom) and (plainsVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS_MOUNTAIN;
					elseif ((snowVal >= iSnowBottom) and (snowVal <= iSnowTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_SNOW_MOUNTAIN;
					end

				elseif (plotTypes[index] ~= g_PLOT_TYPE_OCEAN) then
					terrainTypes[index] = g_TERRAIN_TYPE_DESERT;
				
					if ((tundraVal >= iTundraBottom) and (tundraVal <= iTundraTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_TUNDRA;
					elseif ((plainsVal >= iPlainsBottom) and (plainsVal <= iPlainsTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_PLAINS;
					elseif ((snowVal >= iSnowBottom) and (snowVal <= iSnowTop)) then
						terrainTypes[index] = g_TERRAIN_TYPE_SNOW;
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
function FeatureGenerator:AddIceToMap()
	local iTargetIceTiles = (self.iGridH * self.iGridW *  (GlobalParameters.ICE_TILES_PERCENT + self.iIceModifiedPercent)) / 100;

	local aPhases = {};
	local iPhases = 0;
	for row in GameInfo.RandomEvents() do
		if (row.EffectOperatorType == "SEA_LEVEL") then
			local kPhaseDetails = {};
			kPhaseDetails.RandomEventEnum = row.Index;
			kPhaseDetails.IceLoss = row.IceLoss;
			table.insert(aPhases, kPhaseDetails);
			iPhases = iPhases + 1;
		end
	end
	
	if (iPhases <= 0) then 
		return;
	end

	------------------------------
	-- PHASE ONE: PERMANENT ICE --
	------------------------------
	local iIceLossThisLevel = aPhases[iPhases].IceLoss;
	local iPermanentIcePercent = 100 - iIceLossThisLevel;
	local iPermanentIceTiles = (iTargetIceTiles * iPermanentIcePercent) / 100;

	print ("Permanent Ice Tiles: " .. tostring(iPermanentIceTiles));

	-- Count top/bottom map tiles
	local iWaterTilesOnEdges = 0;

	--   On bottom
	for x = 0, self.iGridW - 1, 1 do
		y = 0;
		local i = y * self.iGridW + x;
		local plot = Map.GetPlotByIndex(i);
		if (plot ~= nil) then
			if(TerrainBuilder.CanHaveFeature(plot, g_FEATURE_ICE) == true and IsAdjacentToLandPlot(x, y) == false) then
				iWaterTilesOnEdges = iWaterTilesOnEdges + 1;
			end
		end
	end

	--   On top
	for x = 0, self.iGridW - 1, 1 do
		local y = self.iGridH - 1;
		local i = y * self.iGridW + x;
		local plot = Map.GetPlotByIndex(i);
		if (plot ~= nil) then
			if(TerrainBuilder.CanHaveFeature(plot, g_FEATURE_ICE) == true and IsAdjacentToLandPlot(x, y) == false) then
				iWaterTilesOnEdges = iWaterTilesOnEdges + 1;
			end
		end
	end

	if (iWaterTilesOnEdges > 0) then
		local iPercentNeeded = 100 * iPermanentIceTiles / iWaterTilesOnEdges;

		for x = 0, self.iGridW - 1, 1 do
			for y = self.iGridH - 1, 0, -1 do
				local i = y * self.iGridW + x;
				local plot = Map.GetPlotByIndex(i);
				if (plot ~= nil) then
					if(TerrainBuilder.CanHaveFeature(plot, g_FEATURE_ICE) == true and IsAdjacentToLandPlot(x, y) == false) then
						if (TerrainBuilder.GetRandomNumber(100, "Permanent Ice") <= iPercentNeeded) then
							AddIceAtPlot(plot, x, y, -1); 
						end
					end
				end
			end
		end
	end

	---------------------------------------
	-- PHASE TWO: ICE THAT CAN DISAPPEAR --
	---------------------------------------
	if (iPhases > 1) then
		for iPhaseIndex = iPhases, 1, -1 do
			kPhaseDetails = aPhases[iPhaseIndex];
			local iIcePercentToAdd = 0;
			if (iPhaseIndex == 1) then 
				iIcePercentToAdd = kPhaseDetails.IceLoss;			
			else
				iIcePercentToAdd = kPhaseDetails.IceLoss - aPhases[iPhaseIndex - 1].IceLoss;
			end
			local iIceTilesToAdd = (iTargetIceTiles * iIcePercentToAdd) / 100;

			print ("iPhaseIndex: " .. tostring(iPhaseIndex) .. ", iIceTilesToAdd: " .. tostring(iIceTilesToAdd) .. ", RandomEventEnum: " .. tostring(kPhaseDetails.RandomEventEnum));

			-- Find all plots on map adjacent to already-placed ice
			local aTargetPlots = {};
			for y = 0, self.iGridH - 1, 1 do
				for x = 0, self.iGridW - 1, 1 do
					local i = y * self.iGridW + x;
					local plot = Map.GetPlotByIndex(i);
					if (plot ~= nil) then
						local iAdjacent = TerrainBuilder.GetAdjacentFeatureCount(plot, g_FEATURE_ICE);
						if (TerrainBuilder.CanHaveFeature(plot, g_FEATURE_ICE) == true and iAdjacent > 0) then
							local kPlotDetails = {};
							kPlotDetails.PlotIndex = i;
							kPlotDetails.AdjacentIce = iAdjacent;
							kPlotDetails.AdjacentToLand = IsAdjacentToLandPlot(x, y);
							table.insert(aTargetPlots, kPlotDetails);
						end
					end
				end
			end

			-- Roll die to see which of these get ice
			if (#aTargetPlots > 0) then
				local iPercentNeeded = 100 * iIceTilesToAdd / #aTargetPlots;
				for i, targetPlot in ipairs(aTargetPlots) do
					local iFinalPercentNeeded = iPercentNeeded + 10 * targetPlot.AdjacentIce;
					if (targetPlot.AdjacentToLand == true) then
						iFinalPercentNeeded = iFinalPercentNeeded / 5;
					end
					if (TerrainBuilder.GetRandomNumber(100, "Permanent Ice") <= iFinalPercentNeeded) then
					    local plot = Map.GetPlotByIndex(targetPlot.PlotIndex);
						AddIceAtPlot(plot, x, y, kPhaseDetails.RandomEventEnum); 
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------------
function AddIceAtPlot(plot, iX, iY, iE)
	local iV = TerrainBuilder.GetRandomNumber(12, "Random variance");
	local lat = (iY - g_iH/2 + iV)/(g_iH/2);	-- variance to make a more natural looking ice shelf
	
	if (lat < -0.81) then
		local iScore = TerrainBuilder.GetRandomNumber(100, "Resource Placement Score Adjust");

		iScore = iScore + math.abs(lat) * 100;

		if(IsAdjacentToLandPlot(iX,iY) == true) then
			iScore = iScore / 2.0;
		end

		local iAdjacent = TerrainBuilder.GetAdjacentFeatureCount(plot, g_FEATURE_ICE);
		iScore = iScore + 10.0 * iAdjacent;

		if(iScore > 130) then
			TerrainBuilder.SetFeatureType(plot, g_FEATURE_ICE);
			TerrainBuilder.AddIce(plot:GetIndex(), iE); 
		end

		return true;
	end
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

------------------------------------------------------------------------------
function AddFeaturesFromContinents()
	print("Adding Features from Continents");

	featuregen:AddFeaturesFromContinents();
end