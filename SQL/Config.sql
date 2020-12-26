-- Config
-- Author: blkbutterfly74
-- DateCreated: 1/20/2018 10:31:57 AM
--------------------------------------------------------------
INSERT INTO Maps (File, Domain, Name, Description)
VALUES 
	('{1D0546BE-00D0-4B09-964D-402E3678EA3D}Maps/SouthAmerica.lua', 'StandardMaps', 'LOC_MAP_SOUTH_AMERICA_NAME', 'LOC_MAP_SOUTH_AMERICA_DESCRIPTION'),
	('{1D0546BE-00D0-4B09-964D-402E3678EA3D}Maps/SouthAmerica_XP2.lua', 'Maps:Expansion2Maps', 'LOC_MAP_SOUTH_AMERICA_NAME', 'LOC_MAP_SOUTH_AMERICA_DESCRIPTION');

INSERT INTO DomainValueFilters (Domain, Value, Filter)
VALUES 
	('Maps:Expansion2Maps', '{1D0546BE-00D0-4B09-964D-402E3678EA3D}Maps/SouthAmerica.lua', 'difference');

INSERT INTO Parameters (Key1, Key2, ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES
	-- rainfall
	('Map', '{1D0546BE-00D0-4B09-964D-402E3678EA3D}Maps/SouthAmerica.lua', 'Rainfall', 'LOC_MAP_RAINFALL_NAME', 'LOC_MAP_RAINFALL_DESCRIPTION', 'Rainfall', 2, 'Map', 'rainfall', 'MapOptions', 250),

	-- world age
	('Map', '{1D0546BE-00D0-4B09-964D-402E3678EA3D}Maps/SouthAmerica.lua', 'WorldAge', 'LOC_MAP_WORLD_AGE_NAME', 'LOC_MAP_WORLD_AGE_DESCRIPTION', 'WorldAge', 2, 'Map', 'world_age', 'MapOptions', 230);

	-- rainfall
	('Map', '{1D0546BE-00D0-4B09-964D-402E3678EA3D}Maps/SouthAmerica_XP2.lua', 'Rainfall', 'LOC_MAP_RAINFALL_NAME', 'LOC_MAP_RAINFALL_DESCRIPTION', 'Rainfall', 2, 'Map', 'rainfall', 'MapOptions', 250),

	-- world age
	('Map', '{1D0546BE-00D0-4B09-964D-402E3678EA3D}Maps/SouthAmerica_XP2.lua', 'WorldAge', 'LOC_MAP_WORLD_AGE_NAME', 'LOC_MAP_WORLD_AGE_DESCRIPTION', 'WorldAge', 2, 'Map', 'world_age', 'MapOptions', 230);