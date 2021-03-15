| writer path |
path := (CfsPath named: '<insert path to root VAST-Webside local repo here>').
writer := TonelWriter new.
writer
	addLatestConfigurationMapNamed: 'Webside';
	addApplicationsFromConfigurationMaps.
writer writeProjectInto: path.
