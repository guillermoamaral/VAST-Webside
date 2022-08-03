| writer path |
path := (CfsPath named: 'C:\Users\guillermo.amaral\OneDrive - Quorum Business Solutions\Gamaral\Webside\servers\vast\VAST-Webside').
writer := TonelWriter new.
writer
	addLatestConfigurationMapNamed: 'Webside';
	addLatestConfigurationMapNamed: 'Webside Tests';
	addApplicationsFromConfigurationMaps.
writer writeProjectInto: path.