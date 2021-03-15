| loader path |
path := (CfsPath named: '<insert path to root VAST-Webside local repo here>').
loader := TonelLoader readFromPath: path.
loader
	beUnattended;
	useGitVersion.
loader loadAllMapsWithRequiredMaps.
